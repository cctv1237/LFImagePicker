//
//  BSLogoIndicatorView.h
//  yili
//
//  Created by LongFan on 16/1/11.
//  Copyright © 2016年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BSLogoIndicatorViewStyle) {
    BSLogoIndicatorViewStyleNormal,
    BSLogoIndicatorViewStyleFillScreen,
    BSLogoIndicatorViewStyleProgress,
};

@interface LFPickerLogoIndicatorView : UIView

@property (nonatomic, assign) BSLogoIndicatorViewStyle logoIndicatorViewStyle; // default is BSLogoIndicatorViewStyleNormal
@property (nonatomic, assign) BOOL hidesWhenStopped;           // default is YES. calls -setHidden when animating gets set to NO
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) UIColor *color;

- (instancetype)initWithStyle:(BSLogoIndicatorViewStyle)style;

- (void)startAnimating;
- (void)stopAnimating;

- (void)startAnimatingWithProgress:(float)progress animated:(BOOL)animated;

@end
