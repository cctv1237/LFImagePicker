//
//  LFDemoViewController.m
//  LFImagePicker
//
//  Created by LongFan on 15/10/8.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFDemoViewController.h"
#import "LFImagePickerViewController.h"
#import "UIView+PickerLayoutMethods.h"

@interface LFDemoViewController () <LFimagePickerDelegate>

@property (nonatomic, strong) LFImagePickerViewController *picker;

@end

@implementation LFDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *a = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [a centerXEqualToView:self.view];
    [a centerYEqualToView:self.view];
    [a setTitle:@"start" forState:UIControlStateNormal];
    [a setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [a addTarget:self action:@selector(didTappeds) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:a];
}

- (void)didTappeds
{
    [self presentViewController:self.picker animated:YES completion:nil];
}

- (void)imagePicker:(LFImagePickerViewController *)picker didImportImages:(NSArray *)imageList
{
    NSLog(@"%@", imageList);
    self.picker = nil;
}
- (void)imagePicker:(LFImagePickerViewController *)picker didReachMaxSelectedCount:(NSInteger)maxCount
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"提醒") message:[NSString stringWithFormat:NSLocalizedString(@"You can select no more than %lu images", @"你最多只能选择 {number} 张图片"), maxCount] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

- (LFImagePickerViewController *)picker
{
    if (_picker == nil) {
        _picker = [[LFImagePickerViewController alloc] init];
        _picker.maxSelectedCount = 12;
        _picker.themeColor = [UIColor cyanColor];
        _picker.delegate = self;
    }
    return _picker;
}


@end
