# LFImagePicker

[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-0.4.8-green.svg?style=flat)](https://cocoapods.org) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://opensource.org/licenses/MIT)

`LFImagePicker` is an Image/Video Picker whitch support Image/Video compress in Multiple threads.

## Requirements

`LFImagePicker` works on iOS 8.0+ and requires ARC to build. It depends on the following Apple frameworks, which should already be included with most Xcode templates:

* Foundation.framework
* UIKit.framework
* MobileCoreServices.framework
* AVFoundation.framework
* Photos.framework

You will need the latest developer tools in order to build `LFImagePicker`. Old Xcode versions might work, but compatibility will not be explicitly maintained.

## Adding LFImagePicker to your project

### CocoaPods

[CocoaPods](http://cocoapods.org) is the recommended way to add LFImagePicker to your project.

1. Add a pod entry for LFImagePicker to your Podfile `pod 'LFImagePicker'`
2. Install the pod(s) by running `pod install`.
3. Include LFImagePicker wherever you need it with `#import <LFImagePicker/LFImagePickerViewController.h>`.

## Usage

You can simply use it as follow. 

```objective-c
- (void)didTappedStartButton:(UIButton *)button
{
    [self presentViewController:self.picker animated:YES completion:nil];
}

- (LFImagePickerViewController *)picker
{
    if (_picker == nil) {
        _picker = [[LFImagePickerViewController alloc] init];
        _picker.maxSelectedCount = 12;
        _picker.delegate = self;
        _picker.videoAvailable = YES;
    }
    return _picker;
}
```
and play with the Delegate methods

```objective-c
@protocol LFimagePickerDelegate <NSObject>

- (void)imagePicker:(LFImagePickerViewController *)picker didImportImages:(NSArray *)imageList;
- (void)imagePicker:(LFImagePickerViewController *)picker didImportFailedInfo:(NSDictionary *)info;
- (void)imagePicker:(LFImagePickerViewController *)picker didReachMaxSelectedCount:(NSInteger)maxCount;
- (void)imagePicker:(LFImagePickerViewController *)picker didReachMaxVideoCount:(NSInteger)maxCount;

@optional
- (void)imagePicker:(LFImagePickerViewController *)picker didTappedImportButton:(UIButton *)button;
- (void)imagePicker:(LFImagePickerViewController *)picker didRejectSelectVideoAtIndexPath:(NSIndexPath *)indexPath;
- (void)imagePicker:(LFImagePickerViewController *)picker didRejectSelectAudioAtIndexPath:(NSIndexPath *)indexPath;
```

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).
