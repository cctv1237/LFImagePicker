//
//  LFImagePickerBottomBar.h
//  LFImagePicker
//
//  Created by LongFan on 15/10/10.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFImagePickerBottomBar : UIView

@property (nonatomic, strong) UILabel *infoLabel;

- (instancetype)initWithThemeColor:(UIColor *)color maxCount:(NSInteger)count;
- (void)refreshSelectedCount:(NSInteger)count;

@end
