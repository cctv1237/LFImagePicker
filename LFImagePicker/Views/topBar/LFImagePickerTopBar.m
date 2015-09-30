//
//  LFImagePickerTopBar.m
//  LFImagePicker
//
//  Created by LongFan on 15/9/29.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFImagePickerTopBar.h"
#import "UIView+LayoutMethods.h"

@interface LFImagePickerTopBar ()

@property (nonatomic, strong) UIButton *importButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *albumsButton;

@end

@implementation LFImagePickerTopBar

#pragma mark - life cycle
- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        
        [self addSubview:self.importButton];
        [self addSubview:self.cancelButton];
        [self addSubview:self.albumsButton];
    }
    return self;
}

- (void)layoutSubviews
{
    self.importButton.size = CGSizeMake(100, 40);
    [self.importButton centerYEqualToView:self];
    [self.importButton rightInContainer:10 shouldResize:NO];
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

- (UIButton *)importButton
{
    if (_importButton == nil) {
        _importButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_importButton addTarget:self action:@selector(didTappedImportButton:) forControlEvents:UIControlEventTouchUpInside];
        _importButton.backgroundColor = [UIColor redColor];
        _importButton.titleLabel.text = @"import";
        _importButton.titleLabel.textColor = [UIColor whiteColor];
    }
    return _importButton;
}

- (UIButton *)cancelButton
{
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton addTarget:self action:@selector(didTappedCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.titleLabel.text = @"cancel";
        _cancelButton.titleLabel.textColor = [UIColor whiteColor];
    }
    return _cancelButton;
}

- (UIButton *)albumsButton
{
    if (_albumsButton == nil) {
        _albumsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_albumsButton addTarget:self action:@selector(didTappedAlbumsButton:) forControlEvents:UIControlEventTouchUpInside];
        _albumsButton.titleLabel.text = @"albums";
        _albumsButton.titleLabel.textColor = [UIColor whiteColor];
    }
    return _albumsButton;
}

@end
