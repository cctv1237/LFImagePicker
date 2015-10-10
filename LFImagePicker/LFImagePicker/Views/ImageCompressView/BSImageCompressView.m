//
//  BSImageCompressViewController.m
//  yili
//
//  Created by casa on 15/7/31.
//  Copyright (c) 2015年 casa. All rights reserved.
//

#import "BSImageCompressView.h"
#import "UIView+LayoutMethods.h"

@interface BSImageCompressView ()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UIImage *cameraImage;
@property (nonatomic, strong) NSArray *imageList;
@property (nonatomic, strong) NSMutableArray *compressedImageList;

@end

@implementation BSImageCompressView

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        [self addSubview:self.tipLabel];
        [self addSubview:self.progressView];
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

@end