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
@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, assign) LFImagePickerTargetType targetType;

@property (nonatomic, assign) BOOL videoAvailable;
@property (nonatomic, assign) BOOL audioAvailable;

@property (nonatomic, weak) id<LFimagePickerDelegate> delegate;

- (instancetype)initWithThemeColor:(UIColor *)color;

@end

@protocol LFimagePickerDelegate <NSObject>

- (void)imagePicker:(LFImagePickerViewController *)picker didImportImages:(NSArray *)imageList;
- (void)imagePicker:(LFImagePickerViewController *)picker didReachMaxSelectedCount:(NSInteger)maxCount;

@optional
- (void)imagePicker:(LFImagePickerViewController *)picker didRejectSelectVideoAtIndexPath:(NSIndexPath *)indexPath;
- (void)imagePicker:(LFImagePickerViewController *)picker didRejectSelectAudioAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol LFImagePickerCompressorProtocol <NSObject>



@end

