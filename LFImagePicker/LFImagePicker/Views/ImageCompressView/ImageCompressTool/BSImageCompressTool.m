//
//  BSImageCompressTool.m
//  yili
//
//  Created by casa on 15/7/31.
//  Copyright (c) 2015年 casa. All rights reserved.
//

#import "BSImageCompressTool.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Compress.h"

@interface BSImageCompressTool ()

@property (nonatomic, strong) NSOperationQueue *compressOperationQueue;

@end

@implementation BSImageCompressTool

#pragma mark - public methods
- (void)compressWithImageList:(NSArray *)imageList cameraImage:(UIImage *)cameraImage
{
    NSInteger totalCount = [imageList count];
    
    __weak typeof(self) weakSelf = self;
    if (cameraImage) {
        totalCount++;
        NSBlockOperation *compressOperation = [NSBlockOperation blockOperationWithBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            UIImage *compressedImage = cameraImage;
            CGFloat preferredWidth = 1080.0f;
            CGFloat factor = preferredWidth / cameraImage.size.width;
            if (factor < 1) {
                compressedImage = [cameraImage compressImageWithNewSize:CGSizeMake(cameraImage.size.width * factor, cameraImage.size.height * factor) interpolationQuality:kCGInterpolationHigh];
            }
            compressedImage = [compressedImage compressImageWithPreferDataSize:300*1024];
            
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(imageCompressTool:didSuccessedCompressedImage:currentCount:totalCount:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.delegate imageCompressTool:strongSelf didSuccessedCompressedImage:compressedImage currentCount:1 totalCount:totalCount];
                });
            }
        }];
        [self.compressOperationQueue addOperation:compressOperation];
    }
    
    [imageList enumerateObjectsUsingBlock:^(ALAsset *imageAsset, NSUInteger idx, BOOL *stop) {
        NSBlockOperation *compressOperation = [NSBlockOperation blockOperationWithBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;

            // ALAsset to UIImage
            ALAssetRepresentation *representation = [imageAsset defaultRepresentation];
            CGImageRef iref = [[imageAsset defaultRepresentation] fullResolutionImage];
            UIImage *image = [UIImage imageWithCGImage:iref scale:[representation scale] orientation:(UIImageOrientation)[representation orientation]];

            if (image) {

                UIImage *compressedImage = image;
                CGFloat preferredWidth = 1080.0f;
                CGFloat factor = preferredWidth / image.size.width;
                if (factor < 1) {
                    compressedImage = [image compressImageWithNewSize:CGSizeMake(image.size.width * factor, image.size.height * factor) interpolationQuality:kCGInterpolationHigh];
                }
                compressedImage = [compressedImage compressImageWithPreferDataSize:300*1024];

                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(imageCompressTool:didSuccessedCompressedImage:currentCount:totalCount:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (cameraImage == nil) {
                            [strongSelf.delegate imageCompressTool:strongSelf didSuccessedCompressedImage:compressedImage currentCount:idx+1 totalCount:totalCount];
                        } else {
                            [strongSelf.delegate imageCompressTool:strongSelf didSuccessedCompressedImage:compressedImage currentCount:idx+2 totalCount:totalCount];
                        }
                    });
                }
            }
        }];
        [self.compressOperationQueue addOperation:compressOperation];
    }];
}

- (UIImage *)imageWillShareToWeChat:(UIImage *)image
{
    UIImage *compressedImage = [image compressImageWithNewSize:CGSizeMake(250, 250) interpolationQuality:kCGInterpolationHigh];
    compressedImage = [compressedImage compressImageWithPreferDataSize:32*1024];
    return compressedImage;
}

#pragma mark - getters and setters
- (NSOperationQueue *)compressOperationQueue
{
    if (_compressOperationQueue == nil) {
        _compressOperationQueue = [[NSOperationQueue alloc] init];
        _compressOperationQueue.maxConcurrentOperationCount = 1;
    }
    return _compressOperationQueue;
}

@end
