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

@end

@implementation LFPhotoCollectionViewCell

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.contentImageView];
        self.isChose = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    self.contentImageView.width = self.width - 2;
    self.contentImageView.height = self.height - 2;
    [self.contentImageView centerXEqualToView:self];
    [self.contentImageView centerYEqualToView:self];
}

- (void)prepareForReuse
{
    self.contentImageView.image = nil;
    self.contentImageView.layer.borderWidth = 0;
}

#pragma mark - public

- (void)configWithDataWithAsset:(PHAsset *)asset
{
    CGFloat scale = [UIScreen mainScreen].scale;
    [self.cachingImageManager requestImageForAsset:asset
                                        targetSize:CGSizeMake((self.width - 2) * scale, (self.height - 2) * scale)
                                       contentMode:PHImageContentModeAspectFit
                                           options:nil
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                         self.contentImageView.image = result;
                                     }];
}

- (void)addChosen
{
    self.contentImageView.layer.borderWidth = 2;
    self.isChose = YES;
    [self bounce];
}

- (void)removeChosen
{
    self.contentImageView.layer.borderWidth = 0;
    self.isChose = NO;
    [self bounce];
}

- (void)bounce
{
    self.contentImageView.transform = CGAffineTransformMakeScale(0.97, 0.97);
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.contentImageView.transform = CGAffineTransformIdentity;
    } completion:nil];
    
}

#pragma mark - getters & setters

- (UIImageView *)contentImageView
{
    if (_contentImageView == nil) {
        _contentImageView = [[UIImageView alloc] init];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.clipsToBounds = YES;
        _contentImageView.layer.borderColor = [UIColor cyanColor].CGColor;
    }
    return _contentImageView;
}

- (PHCachingImageManager *)cachingImageManager
{
    if (_cachingImageManager == nil) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

@end
