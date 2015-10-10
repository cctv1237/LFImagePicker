//
//  BSImageCompressViewController.h
//  yili
//
//  Created by casa on 15/7/31.
//  Copyright (c) 2015年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LFImageCompressViewDelegate;

@interface LFImageCompressView : UIView

@property (nonatomic, weak) id<LFImageCompressViewDelegate> delegate;

- (void)showCompressingProgress:(NSDictionary *)progress;

@end

@protocol LFImageCompressViewDelegate <NSObject>

- (void)imageCompressViewController:(LFImageCompressView *)compressView didFinishedCompressedImage:(NSArray *)compressedImage;

@end
