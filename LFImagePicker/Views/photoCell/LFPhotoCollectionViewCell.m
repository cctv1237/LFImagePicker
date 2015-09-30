//
//  LFPhotoCollectionViewCell.m
//  LFImagePicker
//
//  Created by LongFan on 15/9/25.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFPhotoCollectionViewCell.h"

#import "UIView+LayoutMethods.h"

@interface LFPhotoCollectionViewCell ()

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) UIView *indexBadge;
@property (nonatomic, strong) UILabel *indexLabel;

@property (nonatomic, assign) CGFloat gap;
@property (nonatomic, strong) UIColor *themeColor;

@end

@implementation LFPhotoCollectionViewCell

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.contentImageView];
        [self.contentImageView addSubview:self.indexBadge];
        self.gap = 2.0f;
    }
    return self;
}

- (void)layoutSubviews
{
    self.contentImageView.width = self.width - self.gap;
    self.contentImageView.height = self.height - self.gap;
    [self.contentImageView centerXEqualToView:self];
    [self.contentImageView centerYEqualToView:self];
    
    [self.indexBadge topInContainer:8 shouldResize:NO];
    [self.indexBadge rightInContainer:8 shouldResize:NO];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.contentImageView.image = nil;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        [self addSelectionSign];
    } else {
        [self removeSelectionSign];
    }

}

#pragma mark - public

- (void)configWithDataWithAsset:(PHAsset *)asset themeColor:(UIColor *)color
{
    self.themeColor = color;
    CGFloat scale = [UIScreen mainScreen].scale;
    [self.cachingImageManager requestImageForAsset:asset
                                        targetSize:CGSizeMake((self.width - self.gap) * scale, (self.height - self.gap) * scale)
                                       contentMode:PHImageContentModeAspectFit
                                           options:nil
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                         self.contentImageView.image = result;
                                     }];
}

- (void)bounceAnimation
{
    self.contentImageView.transform = CGAffineTransformMakeScale(0.97, 0.97);
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.contentImageView.transform = CGAffineTransformIdentity;
    } completion:nil];
    
}

- (void)addSelectionSign
{
    self.contentImageView.layer.borderColor = self.themeColor.CGColor;
    self.contentImageView.layer.borderWidth = 2;
    self.indexBadge.backgroundColor = self.themeColor;
}

- (void)removeSelectionSign
{
    self.contentImageView.layer.borderWidth = 0;
    self.indexBadge.backgroundColor = [UIColor clearColor];
}

#pragma mark - getters & setters

- (UIImageView *)contentImageView
{
    if (_contentImageView == nil) {
        _contentImageView = [[UIImageView alloc] init];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.clipsToBounds = YES;
    }
    return _contentImageView;
}

- (UIView *)indexBadge
{
    if (_indexBadge == nil) {
        _indexBadge = [[UIView alloc] init];
        _indexBadge.backgroundColor = self.themeColor;
        _indexBadge.size = CGSizeMake(20, 20);
        _indexBadge.layer.cornerRadius = 10;
    }
    return _indexBadge;
}

- (UILabel *)indexLabel
{
    if (_indexLabel == nil) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.textColor = [UIColor whiteColor];
    }
    return _indexLabel;
}

- (PHCachingImageManager *)cachingImageManager
{
    if (_cachingImageManager == nil) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

@end
