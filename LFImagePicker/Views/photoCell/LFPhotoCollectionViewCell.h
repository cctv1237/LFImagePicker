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

@property (nonatomic, assign) BOOL isChose;
@property (nonatomic, strong) UIImageView *contentImageView;

- (void)configWithDataWithAsset:(PHAsset *)asset;
- (void)addChosen;
- (void)removeChosen;


@end
