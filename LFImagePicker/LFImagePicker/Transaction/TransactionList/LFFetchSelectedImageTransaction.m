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
    
    PHAsset *asset = info[kLFFetchImageTransactionInfoKeyAsset];
    
    [self.cachingImageManager requestImageForAsset:asset
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
                                                       progress(NSDictionaryOfVariableBindings(compressedImage));
                                                   }
                                                   self.shouldWaiting = NO;
                                               });
                                           }];
    
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
