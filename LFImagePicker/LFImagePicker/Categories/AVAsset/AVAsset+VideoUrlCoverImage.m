//
//  AVAsset+VideoUrlCoverImage.m
//  LFImagePicker
//
//  Created by LongFan on 16/4/25.
//  Copyright © 2016年 LongFan. All rights reserved.
//

#import "AVAsset+VideoUrlCoverImage.h"

@implementation AVAsset (VideoUrlCoverImage)

- (NSURL *)imageUrlWithUUID:(NSString *)uuid
{
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self];
    CMTime startTime = kCMTimeZero;
    CMTime actualTime;
    NSError *error = nil;
    CGImageRef videoImage = [imageGenerator copyCGImageAtTime:startTime actualTime:&actualTime error:&error];
    imageGenerator.appliesPreferredTrackTransform = YES;
    UIImage *image = nil;
    if (videoImage != NULL) {
        image = [UIImage imageWithCGImage:videoImage];
    } else {
        image = [UIImage imageNamed:@"default_video_cover"];
    }
    NSData *jpgData = UIImageJPEGRepresentation(image, 0.9f);
    NSString *outPutFilepath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:uuid];
    [jpgData writeToFile:outPutFilepath atomically:NO];
    NSURL *resultUrl = [NSURL fileURLWithPath:outPutFilepath isDirectory:NO];
    return resultUrl;
}

@end
