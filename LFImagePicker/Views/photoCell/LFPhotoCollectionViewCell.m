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
    }
    return self;
}

- (void)layoutSubviews
{
    [self.contentImageView fill];
}

#pragma mark - public

- (void)configWithDataWithAsset:(PHAsset *)asset
{
    [self.cachingImageManager requestImageForAsset:asset
                                        targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                                       contentMode:PHImageContentModeAspectFit
                                           options:nil
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                         self.contentImageView.image = result;
                                     }];
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

- (PHCachingImageManager *)cachingImageManager
{
    if (_cachingImageManager == nil) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

@end
