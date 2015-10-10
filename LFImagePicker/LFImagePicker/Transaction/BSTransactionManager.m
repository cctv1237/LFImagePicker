//
//  BSImageUploader.m
//  yili
//
//  Created by casa on 15/7/23.
//  Copyright (c) 2015年 casa. All rights reserved.
//

#import "BSTransactionManager.h"
#import "LFFetchSelectedImageTransaction.h"

@interface BSTransactionManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation BSTransactionManager

#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static BSTransactionManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BSTransactionManager alloc] init];
    });
    return sharedInstance;
}

- (void)fetchSelectedImage:(NSArray<PHAsset *> *)selectedImage success:(void (^)(NSDictionary *))success fail:(void (^)(NSDictionary *))fail progress:(void (^)(NSDictionary *))outerProgress
{
    NSInteger count = [selectedImage count];
    __block NSInteger finishedCount = 0;
    
    NSMutableArray *processedImageList = [[NSMutableArray alloc] init];
    
    [selectedImage enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *transactionInfo = [[NSMutableDictionary alloc] init];
        
        transactionInfo[kLFFetchImageTransactionInfoKeyAsset] = asset;
        transactionInfo[kLFFetchImageTransactionInfoKeyProgressCallback] = ^(NSDictionary *info){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = info[@"compressedImage"];
                finishedCount++;
                [processedImageList addObject:image];
                if (finishedCount == count) {
                    success(NSDictionaryOfVariableBindings(processedImageList));
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
