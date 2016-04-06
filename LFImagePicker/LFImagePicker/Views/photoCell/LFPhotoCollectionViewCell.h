//
//  LFPhotoCollectionViewCell.h
//  LFImagePicker
//
//  Created by LongFan on 15/9/25.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface LFPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) CGFloat gap;

@property (nonatomic, strong, readonly) UIImageView *indexBadge;

- (void)configDataWithAsset:(PHAsset *)asset themeColor:(UIColor *)color;
- (void)configDataWithImage:(UIImage *)image themeColor:(UIColor *)color;
- (void)bounceAnimation;
- (void)addSelectionSign;
- (void)removeSelectionSign;
- (void)isCameraButton;


@end
