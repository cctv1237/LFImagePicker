//
//  ViewController.h
//  LFImagePicker
//
//  Created by LongFan on 15/9/24.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LFimagePickerDelegate, LFImagePickerCompressorProtocol;

@interface LFImagePickerViewController : UIViewController

@property (nonatomic, assign) NSInteger maxSelectedCount;

@property (nonatomic, weak) id<LFimagePickerDelegate> delegate;

@end

@protocol LFimagePickerDelegate <NSObject>

- (void)imagePicker:(LFImagePickerViewController *)picker didImportImages:(NSArray *)imageList;
- (void)imagePicker:(LFImagePickerViewController *)picker didSelectDefaultAlbumName:(NSString *)albumName;
- (void)imagePicker:(LFImagePickerViewController *)picker didReachMaxSelectedCount:(NSInteger)maxCount;

@end

@protocol LFImagePickerCompressorProtocol <NSObject>



@end

