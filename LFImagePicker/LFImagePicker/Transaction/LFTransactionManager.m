//
//  BSImageUploader.m
//  yili
//
//  Created by casa on 15/7/23.
//  Copyright (c) 2015年 casa. All rights reserved.
//

#import "LFTransactionManager.h"
#import "LFFetchSelectedImageTransaction.h"
#import "UIImage+PickerCompress.h"

@interface LFTransactionManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation LFTransactionManager

#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static LFTransactionManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LFTransactionManager alloc] init];
    });
    return sharedInstance;
}

- (void)fetchSelectedImage:(NSArray<PHAsset *> *)selectedImage cameraImage:(UIImage *)cameraImage success:(void (^)(NSDictionary *))success fail:(void (^)(NSDictionary *))fail progress:(void (^)(NSDictionary *))outerProgress
{
    NSInteger count = [selectedImage count];
    __block NSInteger finishedCount = 0;
    NSMutableArray *processedImageList = [[NSMutableArray alloc] init];
    
    //camera image processing
    if (cameraImage) {
        count++;
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            UIImage *compressedImage = cameraImage;
            CGFloat preferredWidth = 1080.0f;
            CGFloat factor = preferredWidth / cameraImage.size.width;
            if (factor < 1) {
                compressedImage = [cameraImage lf_compressImageWithNewSize:CGSizeMake(cameraImage.size.width * factor, cameraImage.size.height * factor) interpolationQuality:kCGInterpolationHigh];
            }
            compressedImage = [compressedImage lf_compressImageWithPreferDataSize:300*1024];
            NSData *data = UIImageJPEGRepresentation(compressedImage, 1.0f);
            NSString *secId = [[NSUUID UUID] UUIDString];
            NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:secId];
            [data writeToFile:imagePath atomically:YES];
            
            finishedCount++;
            [processedImageList addObject:@{
                                            kLFFetchImageTransactionResultInfoKeyType:@"image",
                                            kLFFetchImageTransactionResultInfoKeyContent:[NSURL fileURLWithPath:imagePath]
                                            }];
            if (finishedCount == count) {
                if ([processedImageList count] > 0) {
                    success(NSDictionaryOfVariableBindings(processedImageList));
                } else {
//#warning todo
                }
            } else {
                outerProgress(@{
                                @"totalCount":@(count),
                                @"finishedCount":@(finishedCount)
                                });
            }
        }];
        [self.operationQueue addOperation:operation];
    }
    
    
    //selected image processing
    [selectedImage enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *transactionInfo = [[NSMutableDictionary alloc] init];
        
        transactionInfo[kLFFetchImageTransactionInfoKeyAsset] = asset;
        transactionInfo[kLFFetchImageTransactionInfoKeyProgressCallback] = ^(NSDictionary *info){
            dispatch_async(dispatch_get_main_queue(), ^{
                finishedCount++;
                if (info) {
                    [processedImageList addObject:info];
                }
                if (finishedCount == count) {
                    if ([processedImageList count] > 0) {
                        success(NSDictionaryOfVariableBindings(processedImageList));
                    } else {
                        fail(nil);
                    }
                } else {
                    outerProgress(@{
                                    @"totalCount":@(count),
                                    @"finishedCount":@(finishedCount)
                                    });
                }
            });
        };
        
        LFFetchSelectedImageTransaction *transaction = [[LFFetchSelectedImageTransaction alloc] init];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:transaction selector:@selector(fetchImageWithInfo:) object:transactionInfo];
        [self.operationQueue addOperation:operation];
    }];
}

#pragma mark - getters and setters

- (NSOperationQueue *)operationQueue
{
    if (_operationQueue == nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

@end
