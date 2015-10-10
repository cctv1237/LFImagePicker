//
//  BSImageCompressViewController.h
//  yili
//
//  Created by casa on 15/7/31.
//  Copyright (c) 2015年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BSImageCompressViewDelegate;

@interface BSImageCompressView : UIView

@property (nonatomic, weak) id<BSImageCompressViewDelegate> delegate;

- (void)showCompressingProgress:(NSDictionary *)progress;

@end

@protocol BSImageCompressViewDelegate <NSObject>

- (void)imageCompressViewController:(BSImageCompressView *)compressView didFinishedCompressedImage:(NSArray *)compressedImage;

@end