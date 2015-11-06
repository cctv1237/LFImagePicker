//
//  LFPhotoCollectionViewCell.m
//  LFImagePicker
//
//  Created by LongFan on 15/9/25.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFPhotoCollectionViewCell.h"
#import "UIView+PickerLayoutMethods.h"

@interface LFPhotoCollectionViewCell ()

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) UIImageView *indexBadge;
@property (nonatomic, strong) UIImageView *cameraButton;
@property (nonatomic, strong) UILabel *videoLabel;

@property (nonatomic, assign) CGFloat gap;
@property (nonatomic, strong) UIColor *themeColor;

@end

@implementation LFPhotoCollectionViewCell

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.contentImageView];
        [self.contentImageView addSubview:self.cameraButton];
        [self.contentImageView addSubview:self.indexBadge];
        [self.contentImageView addSubview:self.videoLabel];
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
    
    [self.cameraButton fill];
    
    [self.indexBadge topInContainer:8 shouldResize:NO];
    [self.indexBadge rightInContainer:8 shouldResize:NO];
    
    [self.videoLabel sizeToFit];
    [self.videoLabel bottomInContainer:3 shouldResize:NO];
    [self.videoLabel leftInContainer:3 shouldResize:NO];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.contentImageView.image = nil;
    self.cameraButton.alpha = 0;
    self.videoLabel.alpha = 0;
}

#pragma mark - public

- (void)configDataWithAsset:(PHAsset *)asset themeColor:(UIColor *)color
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
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        NSUInteger seconds = asset.duration;
        NSUInteger minutes = seconds / 60;
        seconds = seconds - minutes * 60;
        if (asset.mediaSubtypes == PHAssetMediaSubtypeVideoStreamed) {
            self.videoLabel.text = [NSString stringWithFormat:@" Stream:%02lu:%02lu ", (unsigned long)minutes, (unsigned long)seconds];
        } else if (asset.mediaSubtypes == PHAssetMediaSubtypeVideoHighFrameRate) {
            self.videoLabel.text = [NSString stringWithFormat:@" Slo-mo:%02lu:%02lu ", (unsigned long)minutes, (unsigned long)seconds];
        } else if (asset.mediaSubtypes == PHAssetMediaSubtypeVideoTimelapse) {
            self.videoLabel.text = [NSString stringWithFormat:@" Tim-la:%02lu:%02lu ", (unsigned long)minutes, (unsigned long)seconds];
        } else {
            self.videoLabel.text = [NSString stringWithFormat:@" Video:%02lu:%02lu ", (unsigned long)minutes, (unsigned long)seconds];
        }
        self.videoLabel.alpha = 0.9;
        self.videoLabel.backgroundColor = color;
        [self layoutSubviews];
    }
}

- (void)configDataWithImage:(UIImage *)image themeColor:(UIColor *)color
{
    self.themeColor = color;
    self.contentImageView.image = image;
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
    self.indexBadge.alpha = 1;
}

- (void)removeSelectionSign
{
    self.contentImageView.layer.borderWidth = 0;
    self.indexBadge.alpha = 0;
}

- (void)isCameraButton
{
    self.cameraButton.alpha = 0.4;
}

#pragma mark - getters & setters
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        [self addSelectionSign];
    } else {
        [self removeSelectionSign];
    }
    
}

- (UIImageView *)contentImageView
{
    if (_contentImageView == nil) {
        _contentImageView = [[UIImageView alloc] init];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.clipsToBounds = YES;
    }
    return _contentImageView;
}

- (UIImageView *)cameraButton
{
    if (_cameraButton == nil) {
        _cameraButton = [[UIImageView alloc] init];
        _cameraButton.backgroundColor = [UIColor blackColor];
        _cameraButton.alpha = 0;
        
    }
    return _cameraButton;
}

- (UIImageView *)indexBadge
{
    if (_indexBadge == nil) {
        _indexBadge = [[UIImageView alloc] init];
        _indexBadge.backgroundColor = self.themeColor;
        _indexBadge.alpha = 0;
        _indexBadge.image = [UIImage imageNamed:@"content_btn_selected_40"];
        _indexBadge.size = CGSizeMake(20, 20);
        _indexBadge.layer.cornerRadius = 10;
    }
    return _indexBadge;
}

- (UILabel *)videoLabel
{
    if (_videoLabel == nil) {
        _videoLabel = [[UILabel alloc] init];
        _videoLabel.textColor = [UIColor whiteColor];
        _videoLabel.font = [UIFont systemFontOfSize:13];
        _videoLabel.alpha = 0;
        _videoLabel.layer.cornerRadius = 3.0f;
        _videoLabel.clipsToBounds = YES;
    }
    return _videoLabel;
}

- (PHCachingImageManager *)cachingImageManager
{
    if (_cachingImageManager == nil) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

@end
