//
//  LFImagePickerTopBar.m
//  LFImagePicker
//
//  Created by LongFan on 15/9/29.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFImagePickerTopBar.h"
#import "UIView+PickerLayoutMethods.h"

@interface LFImagePickerTopBar ()

@property (nonatomic, strong) UIVisualEffectView *blurBackground;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *albumsButton;

@end

@implementation LFImagePickerTopBar

#pragma mark - life cycle
- (instancetype)init
{
    if (self = [super init]) {
        [self addSubview:self.blurBackground];
        [self addSubview:self.importButton];
        [self addSubview:self.cancelButton];
        [self addSubview:self.albumsButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [self.blurBackground fill];
    
    self.cancelButton.size = CGSizeMake(100, 44);
    [self.cancelButton centerYEqualToView:self];
    [self.cancelButton leftInContainer:0 shouldResize:NO];
    
    [self.importButton sizeEqualToView:self.cancelButton];
    [self.importButton centerYEqualToView:self];
    [self.importButton rightInContainer:0 shouldResize:NO];
    
    self.albumsButton.width = SCREEN_WIDTH - self.cancelButton.width - self.importButton.width;
    [self.albumsButton heightEqualToView:self.cancelButton];
    [self.albumsButton centerXEqualToView:self];
    [self.albumsButton centerYEqualToView:self];
}

#pragma mark - event response

- (void)didTappedImportButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:didTappedImportButton:)]) {
        [self.delegate topBar:self didTappedImportButton:button];
    }
}

- (void)didTappedCancelButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:didTappedCancelButton:)]) {
        [self.delegate topBar:self didTappedCancelButton:button];
    }
}

- (void)didTappedAlbumsButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:didTappedAlbumsButton:)]) {
        [self.delegate topBar:self didTappedAlbumsButton:button];
    }
}

#pragma mark - getters & setters

- (UIVisualEffectView *)blurBackground
{
    if (_blurBackground == nil) {
        _blurBackground = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        
    }
    return _blurBackground;
}


- (UIButton *)importButton
{
    if (_importButton == nil) {
        _importButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_importButton addTarget:self action:@selector(didTappedImportButton:) forControlEvents:UIControlEventTouchUpInside];
        [_importButton setTitle:NSLocalizedString(@"Import", @"importButton") forState:UIControlStateNormal];
        [_importButton setTitleColor:self.themeColor forState:UIControlStateNormal];
        [_importButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_importButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        _importButton.enabled = NO;
    }
    return _importButton;
}

- (UIButton *)cancelButton
{
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton addTarget:self action:@selector(didTappedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitle:NSLocalizedString(@"Cancel", @"cancelButton") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    }
    return _cancelButton;
}

- (UIButton *)albumsButton
{
    if (_albumsButton == nil) {
        _albumsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_albumsButton addTarget:self action:@selector(didTappedAlbumsButton:) forControlEvents:UIControlEventTouchUpInside];
        [_albumsButton setTitle:NSLocalizedString(@"Albums", @"albumsButton") forState:UIControlStateNormal];
        [_albumsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_albumsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    }
    return _albumsButton;
}

@end
