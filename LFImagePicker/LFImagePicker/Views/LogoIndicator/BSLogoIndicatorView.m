//
//  BSLogoIndicatorView.m
//  yili
//
//  Created by LongFan on 16/1/11.
//  Copyright © 2016年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "BSLogoIndicatorView.h"
#import "UIView+PickerLayoutMethods.h"

@interface BSLogoIndicatorView ()

@property (nonatomic, strong) UIVisualEffectView *blurBackground;
@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) UILabel *progressLable;

@property (nonatomic, strong) CALayer *animationLayer;

@property (nonatomic, strong) CAShapeLayer *pathLayer;

@property (nonatomic, strong) CABasicAnimation *pathStrokeAnimation;
@property (nonatomic, strong) CABasicAnimation *pathBackStrokeAnimation;

@property (nonatomic, assign) CGRect logoPathRect;
@property (nonatomic, strong) UIBezierPath *logoPath;

@end

@implementation BSLogoIndicatorView

#pragma mark - life circle
- (instancetype)initWithStyle:(BSLogoIndicatorViewStyle)style
{
    if (self = [super init]) {
        self.logoIndicatorViewStyle = style;
        self.hidesWhenStopped = YES;
        self.alpha = 0;
        if (style == BSLogoIndicatorViewStyleNormal) {
            self.animationLayer.frame = CGRectMake(0, 0, 30.0f, 22.5f);
            self.size = CGSizeMake(30.0f, 22.5f);
            [self.layer addSublayer:self.animationLayer];
            [self.animationLayer addSublayer:self.pathLayer];
        }
        if (style == BSLogoIndicatorViewStyleFillScreen) {
            self.animationLayer.frame = CGRectMake(0, 0, 30.0f, 22.5f);
            self.animationView.size = CGSizeMake(30.0f, 22.5f);
            [self.animationView.layer addSublayer:self.animationLayer];
            [self.animationLayer addSublayer:self.pathLayer];
            
            [self addSubview:self.blurBackground];
            [self addSubview:self.animationView];
        }
        if (style == BSLogoIndicatorViewStyleProgress) {
            self.animationLayer.frame = CGRectMake(0, 0, 30.0f, 22.5f);
            self.size = CGSizeMake(70.0f, 22.5f);
            [self.layer addSublayer:self.animationLayer];
            [self.animationLayer addSublayer:self.pathLayer];
            [self addSubview:self.progressLable];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    if (self.logoIndicatorViewStyle == BSLogoIndicatorViewStyleFillScreen) {
        [self.blurBackground fill];
        
        [self.animationView centerXEqualToView:self];
        [self.animationView centerYEqualToView:self];
    }
    if (self.logoIndicatorViewStyle == BSLogoIndicatorViewStyleProgress) {
        [self.progressLable sizeToFit];
        [self.progressLable centerYEqualToView:self];
        [self.progressLable rightInContainer:0 shouldResize:NO];
    }
}

#pragma mark - public
- (void)startAnimating
{
    if (!self.isAnimating) {
        self.isAnimating = YES;
        
        if (self.logoIndicatorViewStyle == BSLogoIndicatorViewStyleNormal) {
            self.alpha = 1;
            [self.pathLayer removeAllAnimations];
            [self.pathLayer addAnimation:self.pathBackStrokeAnimation forKey:@"backStroke"];
        }
        if (self.logoIndicatorViewStyle == BSLogoIndicatorViewStyleFillScreen) {
            [[self getCurrentVC].view addSubview:self];
            [self fill];
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.2 animations:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.alpha = 1;
            } completion:^(BOOL finished) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.pathLayer removeAllAnimations];
                [strongSelf.pathLayer addAnimation:strongSelf.pathBackStrokeAnimation forKey:@"backStroke"];
            }];
        }
        if (self.logoIndicatorViewStyle == BSLogoIndicatorViewStyleProgress) {
            //do nothing
        }
    }
}

- (void)stopAnimating
{
    self.isAnimating = NO;
    
    if (self.logoIndicatorViewStyle == BSLogoIndicatorViewStyleNormal) {
        if (self.hidesWhenStopped) {
            self.alpha = 0;
        }
        [self.pathLayer removeAllAnimations];
        
    }
    if (self.logoIndicatorViewStyle == BSLogoIndicatorViewStyleFillScreen) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.hidesWhenStopped) {
                strongSelf.alpha = 0;
            }
        } completion:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.pathLayer removeAllAnimations];
        }];
    }
    if (self.logoIndicatorViewStyle == BSLogoIndicatorViewStyleProgress) {
        if (self.hidesWhenStopped) {
            self.alpha = 0;
        }
        [self.pathLayer removeAllAnimations];
    }
    
}

- (void)startAnimatingWithProgress:(float)progress animated:(BOOL)animated
{
    if (self.logoIndicatorViewStyle == BSLogoIndicatorViewStyleProgress) {
        if (!self.isAnimating) {
            self.isAnimating = YES;
            self.alpha = 1;
            [self.pathLayer removeAllAnimations];
            [self.pathLayer addAnimation:self.pathBackStrokeAnimation forKey:@"backStroke"];
        }
        NSString *progressString = [NSString stringWithFormat:@"%2.0f", progress*100];
        self.progressLable.text = [NSString stringWithFormat:@"%@%%",progressString];
        [self layoutSubviews];
        
    } else {
        [self startAnimating];
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        if ([[anim valueForKey:@"animationID"] isEqualToString:@"pathStrokeAnimation"]) {
            [self.pathLayer addAnimation:self.pathBackStrokeAnimation forKey:@"backStroke"];
            [self.pathLayer removeAnimationForKey:@"stroke"];
        }
        if ([[anim valueForKey:@"animationID"] isEqualToString:@"pathBackStrokeAnimation"]) {
            [self.pathLayer addAnimation:self.pathStrokeAnimation forKey:@"stroke"];
            [self.pathLayer removeAnimationForKey:@"backStroke"];
        }
    }
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

#pragma mark - getters & setters
- (UIVisualEffectView *)blurBackground
{
    if (_blurBackground == nil) {
        _blurBackground = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    }
    return _blurBackground;
}

- (UIView *)animationView
{
    if (_animationView == nil) {
        _animationView = [[UIView alloc] init];
        
    }
    return _animationView;
}

- (UILabel *)progressLable
{
    if (_progressLable == nil) {
        _progressLable = [[UILabel alloc] init];
        _progressLable.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
        _progressLable.textColor = [UIColor whiteColor];
    }
    return _progressLable;
}

- (CALayer *)animationLayer
{
    if (_animationLayer == nil) {
        _animationLayer = [CALayer layer];
        
    }
    return _animationLayer;
}

- (CAShapeLayer *)pathLayer
{
    if (_pathLayer == nil) {
        
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        pathLayer.frame = self.animationLayer.bounds;
        pathLayer.bounds = self.logoPathRect;
        pathLayer.geometryFlipped = YES;
        pathLayer.path = self.logoPath.CGPath;
        pathLayer.strokeColor = [[UIColor colorWithRed:2.0f/255.0f green:196.0f/255.0f blue:253.0f/255.0f alpha:1] CGColor];
        pathLayer.fillColor = nil;
        pathLayer.lineWidth = 4.0f;
        pathLayer.lineJoin = kCALineJoinBevel;
        pathLayer.lineCap = kCALineCapRound;
        
        _pathLayer = pathLayer;
        
    }
    return _pathLayer;
}

- (CABasicAnimation *)pathStrokeAnimation
{
    if (_pathStrokeAnimation == nil) {
        _pathStrokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _pathStrokeAnimation.duration = 1;
        _pathStrokeAnimation.fromValue = [NSNumber numberWithFloat:-0.1f];
        _pathStrokeAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        _pathStrokeAnimation.repeatCount = 1;
        _pathStrokeAnimation.fillMode = kCAFillModeForwards;
        _pathStrokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _pathStrokeAnimation.removedOnCompletion = NO;
        _pathStrokeAnimation.delegate = self;
        [_pathStrokeAnimation setValue:@"pathStrokeAnimation" forKey:@"animationID"];
    }
    return _pathStrokeAnimation;
}

- (CABasicAnimation *)pathBackStrokeAnimation
{
    if (_pathBackStrokeAnimation == nil) {
        _pathBackStrokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        _pathBackStrokeAnimation.duration = 1;
        _pathBackStrokeAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
        _pathBackStrokeAnimation.toValue = [NSNumber numberWithFloat:-0.1f];
        _pathBackStrokeAnimation.repeatCount = 1;
        _pathBackStrokeAnimation.fillMode = kCAFillModeForwards;
        _pathBackStrokeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _pathBackStrokeAnimation.removedOnCompletion = NO;
        _pathBackStrokeAnimation.delegate = self;
        [_pathBackStrokeAnimation setValue:@"pathBackStrokeAnimation" forKey:@"animationID"];
    }
    return _pathBackStrokeAnimation;
}

- (CGRect)logoPathRect
{
    _logoPathRect = CGRectInset(self.animationLayer.bounds, 1.5, 1);
    
    return _logoPathRect;
}

- (UIBezierPath *)logoPath
{
    if (_logoPath == nil) {
        _logoPath = [UIBezierPath bezierPath];
        
        CGRect pathRect = self.logoPathRect;
        CGPoint point_1 = CGPointMake(0, pathRect.size.height * 0.8f / 4.0f);
        CGPoint point_2 = CGPointMake(pathRect.size.width * 2.75f / 5.0f, pathRect.size.height * 3.75f / 4.0f);
        CGPoint point_3 = CGPointMake(pathRect.size.width * 3.25f / 5.0f, pathRect.size.height * 3.75f / 4.0f);
        CGPoint point_4 = CGPointMake(pathRect.size.width * 4.75f / 5.0f, pathRect.size.height * 2.25f / 4.0f);
        CGPoint point_5 = CGPointMake(pathRect.size.width * 4.75f / 5.0f, pathRect.size.height * 1.75f / 4.0f);
        CGPoint point_6 = CGPointMake(pathRect.size.width * 3.25f / 5.0f, pathRect.size.height * 0.25f / 4.0f);
        CGPoint point_7 = CGPointMake(pathRect.size.width * 2.75f / 5.0f, pathRect.size.height * 0.25f / 4.0f);
        CGPoint point_8 = CGPointMake(0, pathRect.size.height * 3.2f / 4.0f);
        
        [_logoPath moveToPoint:point_1];
        [_logoPath addLineToPoint:point_2];
        [_logoPath addLineToPoint:point_3];
        [_logoPath addLineToPoint:point_4];
        [_logoPath addLineToPoint:point_5];
        [_logoPath addLineToPoint:point_6];
        [_logoPath addLineToPoint:point_7];
        [_logoPath addLineToPoint:point_8];
    }
    return _logoPath;
}


@end
