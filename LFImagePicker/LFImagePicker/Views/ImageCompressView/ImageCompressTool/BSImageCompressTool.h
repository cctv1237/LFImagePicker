//
//  BSImageCompressTool.h
//  yili
//
//  Created by casa on 15/7/31.
//  Copyright (c) 2015年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BSImageCompressToolDelegate;

@interface BSImageCompressTool : NSObject

@property (nonatomic, weak) id<BSImageCompressToolDelegate> delegate;
- (void)compressWithImageList:(NSArray *)imageList cameraImage:(UIImage *)cameraImage;
- (UIImage *)imageWillShareToWeChat:(UIImage *)image;

@end

@protocol BSImageCompressToolDelegate <NSObject>

- (void)imageCompressTool:(BSImageCompressTool *)imageCompressTool didSuccessedCompressedImage:(UIImage *)compressedImage currentCount:(NSInteger)currentCount totalCount:(NSInteger)totalCount;

@end
