//
//  LFImagePickerBottomBar.h
//  LFImagePicker
//
//  Created by LongFan on 15/10/10.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFImagePickerBottomBar : UIView

- (instancetype)initWithThemeColor:(UIColor *)color;
- (void)refreshSelectedCount:(NSInteger)count;

@end
