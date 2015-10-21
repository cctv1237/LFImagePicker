//
//  LFFetchSelectedImageTransaction.m
//  LFImagePicker
//
//  Created by LongFan on 15/10/9.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFFetchSelectedImageTransaction.h"
#import <Photos/Photos.h>
#import "UIImage+PickerCompress.h"

NSString * const kLFFetchImageTransactionInfoKeySuccessCallback = @"kLFFetchImageTransactionInfoKeySuccessCallback";
NSString * const kLFFetchImageTransactionInfoKeyFailCallback = @"kLFFetchImageTransactionInfoKeyFailCallback";
NSString * const kLFFetchImageTransactionInfoKeyProgressCallback = @"kLFFetchImageTransactionInfoKeyProgressCallback";
NSString * const kLFFetchImageTransactionInfoKeyAsset = @"kLFFetchImageTransactionInfoKeyAsset";

NSString * const kLFFetchImageTransactionResultInfoKeyType = @"kLFFetchImageTransactionResultInfoKeyType";
NSString * const kLFFetchImageTransactionResultInfoKeyContent = @"kLFFetchImageTransactionResultInfoKeyContent";

@interface LFFetchSelectedImageTransaction ()

@property (nonatomic, assign) BOOL shouldWaiting;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

@end

@implementation LFFetchSelectedImageTransaction

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldWaiting = YES;
    }
    return self;
}

/*
 BSChangeUserHeaderCallbackBlock fail = self.info[kBSChangeUserHeaderTransactionInfoKeyFailCallback];
 if (fail) {
 fail(@{});
 }
 */

- (void)fetchImageWithInfo:(NSDictionary *)info
{
    self.info = info;
    
    PHAsset *selectedAsset = info[kLFFetchImageTransactionInfoKeyAsset];
    
    if (selectedAsset.mediaType == PHAssetMediaTypeImage) {
        [self.cachingImageManager requestImageForAsset:selectedAsset
                                            targetSize:PHImageManagerMaximumSize
                                           contentMode:PHImageContentModeDefault
                                               options:nil
                                         resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
                                             
                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                 UIImage *compressedImage = image;
                                                 CGFloat preferredWidth = 1080.0f;
                                                 CGFloat factor = preferredWidth / image.size.width;
                                                 if (factor < 1) {
                                                     compressedImage = [image lf_compressImageWithNewSize:CGSizeMake(image.size.width * factor, image.size.height * factor) interpolationQuality:kCGInterpolationHigh];
                                                 }
                                                 compressedImage = [compressedImage lf_compressImageWithPreferDataSize:300*1024];
                                                 
                                                 LFFetchImageCallbackBlock progress = self.info[kLFFetchImageTransactionInfoKeyProgressCallback];
                                                 if (progress) {
                                                     progress(@{
                                                                kLFFetchImageTransactionResultInfoKeyType:@"image",
                                                                kLFFetchImageTransactionResultInfoKeyContent:compressedImage
                                                                });
                                                 }
                                                 self.shouldWaiting = NO;
                                             });
                                         }];
    }
    
    if (selectedAsset.mediaType == PHAssetMediaTypeVideo) {
        [self.cachingImageManager requestAVAssetForVideo:selectedAsset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset *urlAsset = (AVURLAsset *)asset;
                LFFetchImageCallbackBlock progress = self.info[kLFFetchImageTransactionInfoKeyProgressCallback];
                if (progress) {
                    progress(@{
                               kLFFetchImageTransactionResultInfoKeyType:@"video",
                               kLFFetchImageTransactionResultInfoKeyContent:urlAsset.URL
                               });
                }
            }
            
            self.shouldWaiting = NO;
        }];
    }

    
    while (self.shouldWaiting) {
    }
}

#pragma mark - getters and setters
- (PHCachingImageManager *)cachingImageManager
{
    if (_cachingImageManager == nil) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

@end
