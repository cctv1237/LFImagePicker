//
//  LFImagePickerTopBar.h
//  LFImagePicker
//
//  Created by LongFan on 15/9/29.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LFImagePickerTopBarDelegate;

@interface LFImagePickerTopBar : UIView

@property (nonatomic, strong) UIButton *importButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, weak) id<LFImagePickerTopBarDelegate> delegate;

- (instancetype)initWithThemeColor:(UIColor *)color;
- (void)refreshAlbumsName:(NSString *)name;

@end

@protocol LFImagePickerTopBarDelegate <NSObject>

- (void)topBar:(LFImagePickerTopBar *)bar didTappedImportButton:(UIButton *)button;
- (void)topBar:(LFImagePickerTopBar *)bar didTappedCancelButton:(UIButton *)button;
- (void)topBar:(LFImagePickerTopBar *)bar didTappedAlbumsButton:(UIButton *)button;

@end
