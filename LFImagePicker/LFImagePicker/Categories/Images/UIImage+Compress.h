//
//  UIImage+Compress.h
//  yili
//
//  Created by casa on 15/8/22.
//  Copyright (c) 2015年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compress)

- (UIImage *)compressImageWithPreferDataSize:(NSUInteger)dataSize;

- (UIImage *)compressImageWithNewSize:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;

@end
