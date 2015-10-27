//
//  BSImageCompressViewController.m
//  yili
//
//  Created by casa on 15/7/31.
//  Copyright (c) 2015年 casa. All rights reserved.
//

#import "LFImageCompressView.h"
#import "UIView+PickerLayoutMethods.h"

@interface LFImageCompressView ()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, weak) UIColor *themeColor;

@property (nonatomic, strong) UIImage *cameraImage;
@property (nonatomic, strong) NSArray *imageList;
@property (nonatomic, strong) NSMutableArray *compressedImageList;

@end

@implementation LFImageCompressView

#pragma mark - life cycle
- (instancetype)initWithThemeColor:(UIColor *)color
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        self.themeColor = color;
        [self addSubview:self.tipLabel];
        [self addSubview:self.progressView];
        [self addSubview:self.activityIndicatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [self.tipLabel sizeToFit];
    [self.tipLabel centerXEqualToView:self];
    [self.tipLabel centerYEqualToView:self];
    
    self.progressView.height = 3.0f;
    [self.progressView leftInContainer:50 shouldResize:YES];
    [self.progressView rightInContainer:50 shouldResize:YES];
    [self.progressView top:10 FromView:self.tipLabel];
    [self.progressView centerXEqualToView:self];
    
    self.activityIndicatorView.size = CGSizeMake(50, 50);
    [self.activityIndicatorView centerXEqualToView:self];
    [self.activityIndicatorView top:5 FromView:self.progressView];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
}

#pragma mark - public

- (void)showCompressingProgress:(NSDictionary *)progress
{
    NSInteger currentCount = [progress[@"finishedCount"] floatValue];
    NSInteger totalCount = [progress[@"totalCount"] floatValue];
    
    [self.progressView setProgress:(CGFloat)currentCount/(CGFloat)totalCount animated:YES];
    
    self.tipLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Importing %lu of %lu items", @"当前Count: {number} 总共Count：{total number}"), currentCount, totalCount];
    [self.tipLabel sizeToFit];
    [self.tipLabel centerXEqualToView:self];
    [self.tipLabel centerYEqualToView:self];
    
    if (currentCount == totalCount) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageCompressViewController:didFinishedCompressedImage:)]) {
            [self.delegate imageCompressViewController:self didFinishedCompressedImage:self.compressedImageList];
        }
    }
}

#pragma mark - getters and setters
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = NSLocalizedString(@"Importing", nil);
    }
    return _tipLabel;
}

- (UIProgressView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.progressTintColor = self.themeColor;
    }
    return _progressView;
}

- (NSMutableArray *)compressedImageList
{
    if (_compressedImageList == nil) {
        _compressedImageList = [[NSMutableArray alloc] init];
    }
    return _compressedImageList;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityIndicatorView startAnimating];
    }
    return _activityIndicatorView;
}

@end
