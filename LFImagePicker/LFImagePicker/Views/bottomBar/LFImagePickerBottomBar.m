//
//  LFImagePickerBottomBar.m
//  LFImagePicker
//
//  Created by LongFan on 15/10/10.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFImagePickerBottomBar.h"
#import "UIView+PickerLayoutMethods.h"

@interface LFImagePickerBottomBar ()

@property (nonatomic, strong) UILabel *selectedCountLabel;
@property (nonatomic, strong) UIVisualEffectView *blurBackground;

@property (nonatomic, weak) UIColor *themeColor;

@property (nonatomic, assign) NSInteger maxCountNumber;

@end

@implementation LFImagePickerBottomBar

#pragma mark - life cycle
- (instancetype)initWithThemeColor:(UIColor *)color maxCount:(NSInteger)count
{
    if (self = [super init]) {
        self.themeColor = color;
        self.maxCountNumber = count;
        [self addSubview:self.blurBackground];
        [self addSubview:self.selectedCountLabel];
        [self addSubview:self.infoLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.blurBackground fill];
    
    [self.selectedCountLabel sizeToFit];
    [self.selectedCountLabel rightInContainer:18 shouldResize:NO];
    [self.selectedCountLabel centerYEqualToView:self];
    
    [self.infoLabel sizeToFit];
    [self.infoLabel leftInContainer:18 shouldResize:NO];
    [self.infoLabel centerYEqualToView:self];
}

#pragma mark - public
- (void)refreshSelectedCount:(NSInteger)count
{
    self.selectedCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"selected:%lu/%lu", @"已选择:%lu/%lu"), (long)count, (long)self.maxCountNumber];
    [self layoutSubviews];
}

#pragma mark - getters & setters
- (UILabel *)selectedCountLabel
{
    if (_selectedCountLabel == nil) {
        _selectedCountLabel = [[UILabel alloc] init];
        _selectedCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"selected:0/%lu", @"已选择:0/%lu"), (long)self.maxCountNumber];
        _selectedCountLabel.textColor = self.themeColor;
        _selectedCountLabel.font = [UIFont systemFontOfSize:13];
    }
    return _selectedCountLabel;
}

- (UILabel *)infoLabel
{
    if (_infoLabel == nil) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.text = NSLocalizedString(@"better to choose more than 15", @"选择15张以上效果更佳");
        _infoLabel.textColor = self.themeColor;
        _infoLabel.font = [UIFont systemFontOfSize:13];
    }
    return _infoLabel;
}

- (UIVisualEffectView *)blurBackground
{
    if (_blurBackground == nil) {
        _blurBackground = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        
    }
    return _blurBackground;
}

@end
