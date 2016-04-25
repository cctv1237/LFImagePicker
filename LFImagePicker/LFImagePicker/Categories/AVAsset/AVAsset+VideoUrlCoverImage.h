//
//  AVAsset+VideoUrlCoverImage.h
//  LFImagePicker
//
//  Created by LongFan on 16/4/25.
//  Copyright © 2016年 LongFan. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface AVAsset (VideoUrlCoverImage)

- (NSURL *)imageUrlWithUUID:(NSString *)uuid;

@end
