//
//  BSFilterSycProgressView.m
//  yili
//
//  Created by LongFan on 16/1/14.
//  Copyright © 2016年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import "LFPickerProgressView.h"
#import "LFPickerLogoIndicatorView.h"

#import "UIView+PickerLayoutMethods.h"

@interface LFPickerProgressView ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) LFPickerLogoIndicatorView *logoIndicator;

@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *exitButton;

@property (nonatomic, strong) NSMutableArray *compressedImageList;

@end

@implementation LFPickerProgressView
#pragma mark - life circle
- (instancetype)init
{
    if (self = [super init]) {
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.centerView];
        [self.centerView addSubview:self.logoIndicator];
        [self.centerView addSubview:self.exitButton];
        [self.centerView addSubview:self.doneButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [self.backgroundView fill];
    
    self.centerView.size = CGSizeMake(106, 100);
    [self.centerView centerXEqualToView:self];
    [self.centerView centerYEqualToView:self];
    
    [self.logoIndicator centerXEqualToView:self.centerView];
    [self.logoIndicator centerYEqualToView:self.centerView];
    
    [self.exitButton leftInContainer:0 shouldResize:NO];
    [self.exitButton bottomInContainer:0 shouldResize:NO];
    
    [self.doneButton rightInContainer:0 shouldResize:NO];
    [self.doneButton bottomInContainer:0 shouldResize:NO];
}

#pragma mark - public
- (void)startProgress:(NSDictionary *)progress
{
    NSInteger currentCount = [progress[@"finishedCount"] floatValue];
    NSInteger totalCount = [progress[@"totalCount"] floatValue];
    
    [self.logoIndicator startAnimatingWithProgress:(CGFloat)currentCount/(CGFloat)totalCount animated:YES];
    
    if (currentCount == totalCount) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerProgressView:didFinishedCompressedImage:)]) {
            [self.delegate pickerProgressView:self didFinishedCompressedImage:self.compressedImageList];
        }
    }
}

- (void)endProgress
{
    [self.logoIndicator stopAnimating];
}

#pragma mark - event response
- (void)didTappedDoneButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerProgressView:didTappedDoneButton:)]) {
        [self.delegate pickerProgressView:self didTappedDoneButton:button];
    }
}

- (void)didTappedExitButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerProgressView:didTappedExitButton:)]) {
        [self.delegate pickerProgressView:self didTappedExitButton:button];
    }
}

#pragma mark - animations
- (void)progressEndAnimation
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.logoIndicator topInContainer:0 shouldResize:NO];
        strongSelf.doneButton.alpha = 1;
        strongSelf.exitButton.alpha = 1;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.doneButton.enabled = YES;
        strongSelf.exitButton.enabled = YES;
    }];
}

#pragma mark - getters & setters
- (UIView *)backgroundView
{
    if (_backgroundView == nil) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.9;
    }
    return _backgroundView;
}

- (UIView *)centerView
{
    if (_centerView == nil) {
        _centerView = [[UIView alloc] init];
        
    }
    return _centerView;
}

- (LFPickerLogoIndicatorView *)logoIndicator
{
    if (_logoIndicator == nil) {
        _logoIndicator = [[LFPickerLogoIndicatorView alloc] initWithStyle:BSLogoIndicatorViewStyleProgress];
        _logoIndicator.hidesWhenStopped = NO;
    }
    return _logoIndicator;
}

- (NSMutableArray *)compressedImageList
{
    if (_compressedImageList == nil) {
        _compressedImageList = [[NSMutableArray alloc] init];
    }
    return _compressedImageList;
}

- (UIButton *)doneButton
{
    if (_doneButton == nil) {
        _doneButton = [[UIButton alloc] init];
        [_doneButton addTarget:self action:@selector(didTappedDoneButton:) forControlEvents:UIControlEventTouchUpInside];
        [_doneButton setImage:[UIImage imageNamed:@"btn_process_done"] forState:UIControlStateNormal];
        [_doneButton setImageEdgeInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
        _doneButton.adjustsImageWhenHighlighted = YES;
        _doneButton.size = CGSizeMake(49, 49);
        _doneButton.alpha = 0;
        _doneButton.enabled = NO;
    }
    return _doneButton;
}

- (UIButton *)exitButton
{
    if (_exitButton == nil) {
        _exitButton = [[UIButton alloc] init];
        [_exitButton addTarget:self action:@selector(didTappedExitButton:) forControlEvents:UIControlEventTouchUpInside];
        [_exitButton setImage:[UIImage imageNamed:@"btn_process_close"] forState:UIControlStateNormal];
        [_exitButton setImageEdgeInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
        _exitButton.adjustsImageWhenHighlighted = YES;
        _exitButton.size = CGSizeMake(49, 49);
        _exitButton.alpha = 0;
        _exitButton.enabled = NO;
    }
    return _exitButton;
}

@end