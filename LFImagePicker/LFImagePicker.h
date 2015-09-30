//
//  ViewController.h
//  LFImagePicker
//
//  Created by LongFan on 15/9/24.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LFimagePickerDelegate;

@interface LFImagePicker : UIViewController

@property (nonatomic, assign) NSInteger maxSelectedCount;

@property (nonatomic, weak) id<LFimagePickerDelegate> delegate;

@end

@protocol LFimagePickerDelegate <NSObject>

- (void)lf_imagePicker:(LFImagePicker *)picker didImportImages:(NSArray *)imageList;
- (void)lf_imagePicker:(LFImagePicker *)picker didSelectDefaultAlbumName:(NSString *)albumName;
- (void)lf_imagePicker:(LFImagePicker *)picker didReachMaxSelectedCount:(NSInteger)maxCount;

@end

