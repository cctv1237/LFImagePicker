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
NSString * const kLFFetchImageTransactionResultInfoKeyVideoImage = @"kLFFetchImageTransactionResultInfoKeyVideoImage";

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

- (void)fetchImageWithInfo:(NSDictionary *)info
{
    self.info = info;
    
    PHAsset *selectedAsset = info[kLFFetchImageTransactionInfoKeyAsset];
    
    if (selectedAsset.mediaType == PHAssetMediaTypeImage) {
        [self imageOperation];
    }
    
    if (selectedAsset.mediaType == PHAssetMediaTypeVideo) {
        [self videoOperation];
    }
    
    while (self.shouldWaiting) {
    }
}

#pragma mark - private methods
- (void)imageOperation
{
    PHAsset *selectedAsset = self.info[kLFFetchImageTransactionInfoKeyAsset];
    [self.cachingImageManager requestImageForAsset:selectedAsset
                                        targetSize:PHImageManagerMaximumSize
                                       contentMode:PHImageContentModeDefault
                                           options:nil
                                     resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
                                         
                                         if ([info[PHImageResultIsDegradedKey] boolValue] == NO) {
                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                 BOOL shouldCompress = YES;
                                                 UIImage *compressedImage = image;
                                                 NSData *data = UIImageJPEGRepresentation(compressedImage, 1.0f);
                                                 NSUInteger length = [data length];
                                                 if (length / 1024.0f / 1024.0f < 1) {
                                                     shouldCompress = NO;
                                                 }
                                                 
                                                 if (shouldCompress) {
                                                     CGFloat preferredWidth = 1080.0f;
                                                     CGFloat factor = preferredWidth / image.size.width;
                                                     if (factor < 1) {
                                                         compressedImage = [image lf_compressImageWithNewSize:CGSizeMake(image.size.width * factor, image.size.height * factor) interpolationQuality:kCGInterpolationHigh];
                                                     }
                                                     data = UIImageJPEGRepresentation(compressedImage, 1.0f);
                                                 }
                                                 
                                                 NSString *secId = [[NSUUID UUID] UUIDString];
                                                 NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:secId];
                                                 [data writeToFile:imagePath atomically:YES];
                                                 
                                                 LFFetchImageCallbackBlock progress = self.info[kLFFetchImageTransactionInfoKeyProgressCallback];
                                                 if (progress) {
                                                     progress(@{
                                                                kLFFetchImageTransactionResultInfoKeyType:@"image",
                                                                kLFFetchImageTransactionResultInfoKeyContent:[NSURL fileURLWithPath:imagePath]
                                                                });
                                                 }
                                                 self.shouldWaiting = NO;
                                             });
                                         }
                                     }];
}

- (void)videoOperation
{
    PHAsset *selectedAsset = self.info[kLFFetchImageTransactionInfoKeyAsset];
    [self.cachingImageManager requestAVAssetForVideo:selectedAsset options:nil resultHandler:^(AVAsset * _Nullable originAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        NSString *fileName = [NSString stringWithFormat:@"%@.mp4", uuid];
        NSString *outPutFilepath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
        NSURL *outputUrl = [NSURL fileURLWithPath:outPutFilepath];
        
        if ([originAsset isKindOfClass:[AVURLAsset class]]) {
            [self normalVideoOperationWithAsset:(AVURLAsset *)originAsset outputUrl:outputUrl uuid:uuid];
        } else if ([originAsset isKindOfClass:[AVComposition class]]) {
            [self slowMotionVideoOperationWithVideoAsset:(AVComposition *)originAsset outputUrl:outputUrl uuid:uuid];
        } else {
            // 跳过不可识别的Video
            LFFetchImageCallbackBlock progress = self.info[kLFFetchImageTransactionInfoKeyProgressCallback];
            if (progress) {
                progress(nil);
            }
            self.shouldWaiting = NO;
        }
    }];
}

- (void)slowMotionVideoOperationWithVideoAsset:(AVComposition *)videoAsset outputUrl:(NSURL *)outputUrl uuid:(NSString *)uuid
{
    CGFloat seconds = CMTimeGetSeconds(videoAsset.duration);
    if (seconds < 20) {
        AVMutableComposition *mixComposition = [AVMutableComposition composition];
        
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
        NSError *videoInsertError = nil;
        BOOL videoInsertResult = [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                                                ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                                                 atTime:kCMTimeZero
                                                                  error:&videoInsertError];
        if (!videoInsertResult || nil != videoInsertError) {
            //handle error
            self.shouldWaiting = NO;
            return;
        }
        
        //slow down whole video by 2.0
        double videoScaleFactor = 2.0;
        CMTime videoDuration = videoAsset.duration;
        
        [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration)
                                   toDuration:CMTimeMake(videoDuration.value*videoScaleFactor, videoDuration.timescale)];
        
        // calculate vide size
        NSArray *tracks = [mixComposition tracks];
        float estimatedSize = 0.0 ;
        for (AVAssetTrack * track in tracks) {
            float rate = ([track estimatedDataRate] / 8); // convert bits per second to bytes per second
            float seconds = CMTimeGetSeconds([track timeRange].duration);
            estimatedSize += seconds * rate;
        }
        float sizeInMB = estimatedSize / 1024.0f / 1024.0f;
        
        // export video
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
        if (sizeInMB < 10) {
            exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        }
        
        exportSession.outputURL = outputUrl;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
            LFFetchImageCallbackBlock progress = self.info[kLFFetchImageTransactionInfoKeyProgressCallback];
            if (progress) {
                AVURLAsset *videoAsset = [AVURLAsset assetWithURL:outputUrl];
                NSURL *videoImageUrl = [self imageWithVideoAsset:videoAsset uuid:uuid];
                progress(@{
                           kLFFetchImageTransactionResultInfoKeyType:@"video",
                           kLFFetchImageTransactionResultInfoKeyContent:outputUrl,
                           kLFFetchImageTransactionResultInfoKeyVideoImage:videoImageUrl
                           });
            }
            self.shouldWaiting = NO;
        }];
    } else {
        // 视频不能超过20秒
        LFFetchImageCallbackBlock progress = self.info[kLFFetchImageTransactionInfoKeyProgressCallback];
        if (progress) {
            progress(nil);
        }
        self.shouldWaiting = NO;
    }
}

- (void)normalVideoOperationWithAsset:(AVURLAsset *)urlAsset outputUrl:(NSURL *)outputUrl uuid:(NSString *)uuid
{
    CGFloat seconds = CMTimeGetSeconds(urlAsset.duration);
    if (seconds < 20) {
        NSArray *tracks = [urlAsset tracks];
        
        // calculate vide size
        float estimatedSize = 0.0 ;
        for (AVAssetTrack * track in tracks) {
            float rate = ([track estimatedDataRate] / 8); // convert bits per second to bytes per second
            float seconds = CMTimeGetSeconds([track timeRange].duration);
            estimatedSize += seconds * rate;
        }
        float sizeInMB = estimatedSize / 1024.0f / 1024.0f;
        
        // export video
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
        if (sizeInMB < 10) {
            exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetHighestQuality];
        }
        exportSession.outputURL = outputUrl;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
            LFFetchImageCallbackBlock progress = self.info[kLFFetchImageTransactionInfoKeyProgressCallback];
            if (progress) {
                AVURLAsset *videoAsset = [AVURLAsset assetWithURL:outputUrl];
                NSURL *videoImageUrl = [self imageWithVideoAsset:videoAsset uuid:uuid];
                progress(@{
                           kLFFetchImageTransactionResultInfoKeyType:@"video",
                           kLFFetchImageTransactionResultInfoKeyContent:outputUrl,
                           kLFFetchImageTransactionResultInfoKeyVideoImage:videoImageUrl
                           });
            }
            self.shouldWaiting = NO;
        }];
    } else {
        // 视频不能超过20秒
        LFFetchImageCallbackBlock progress = self.info[kLFFetchImageTransactionInfoKeyProgressCallback];
        if (progress) {
            progress(nil);
        }
        self.shouldWaiting = NO;
    }
}

- (NSURL *)imageWithVideoAsset:(AVAsset *)asset uuid:(NSString *)uuid;
{
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime startTime = kCMTimeZero;
    CMTime actualTime;
    NSError *error = nil;
    CGImageRef videoImage = [imageGenerator copyCGImageAtTime:startTime actualTime:&actualTime error:&error];
    NSURL *resultUrl = nil;
    if (videoImage != NULL) {
        UIImage *image = [UIImage imageWithCGImage:videoImage];
        NSData *jpgData = UIImageJPEGRepresentation(image, 0.9f);
        NSString *outPutFilepath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:uuid];
        [jpgData writeToFile:outPutFilepath atomically:NO];
        resultUrl = [NSURL fileURLWithPath:outPutFilepath isDirectory:NO];
    } else {
#warning todo 使用默认图片
        resultUrl = [[NSURL alloc] init];
    }
    return resultUrl;
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
