//
//  ViewController.h
//  LFImagePicker
//
//  Created by LongFan on 15/9/24.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LFImagePickerTargetType) {
    LFImagePickerTargetTypeCoverImage,
    LFImagePickerTargetTypeItemImage
};

@protocol LFimagePickerDelegate, LFImagePickerCompressorProtocol;

@interface LFImagePickerViewController : UIViewController

@property (nonatomic, assign) NSInteger maxSelectedCount;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, assign) LFImagePickerTargetType targetType;

@property (nonatomic, weak) id<LFimagePickerDelegate> delegate;

@end

@protocol LFimagePickerDelegate <NSObject>

- (void)imagePicker:(LFImagePickerViewController *)picker didImportImages:(NSArray *)imageList;
- (void)imagePicker:(LFImagePickerViewController *)picker didReachMaxSelectedCount:(NSInteger)maxCount;

@end

@protocol LFImagePickerCompressorProtocol <NSObject>



@end

