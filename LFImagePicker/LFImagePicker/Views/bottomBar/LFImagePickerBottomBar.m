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

@end

@implementation LFImagePickerBottomBar

#pragma mark - life cycle
- (instancetype)initWithThemeColor:(UIColor *)color
{
    if (self = [super init]) {
        self.themeColor = color;
        [self addSubview:self.blurBackground];
        [self addSubview:self.selectedCountLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.blurBackground fill];
    
    [self.selectedCountLabel sizeToFit];
    [self.selectedCountLabel leftInContainer:18 shouldResize:NO];
    [self.selectedCountLabel centerYEqualToView:self];
}

#pragma mark - public
- (void)refreshSelectedCount:(NSInteger)count
{
    self.selectedCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"selected:%lu", @"count label text"), (long)count];
    [self layoutSubviews];
}

#pragma mark - getters & setters
- (UILabel *)selectedCountLabel
{
    if (_selectedCountLabel == nil) {
        _selectedCountLabel = [[UILabel alloc] init];
        _selectedCountLabel.text = NSLocalizedString(@"selected:0", @"count label text");
        _selectedCountLabel.textColor = self.themeColor;
        _selectedCountLabel.font = [UIFont systemFontOfSize:13];
    }
    return _selectedCountLabel;
}

- (UIVisualEffectView *)blurBackground
{
    if (_blurBackground == nil) {
        _blurBackground = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        
    }
    return _blurBackground;
}

@end
