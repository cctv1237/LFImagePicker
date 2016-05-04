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
@property (nonatomic, strong) UIButton *startButton;

@end

@implementation LFDemoViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.startButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.startButton centerXEqualToView:self.view];
    [self.startButton centerYEqualToView:self.view];
}

#pragma mark - LFimagePickerDelegate

- (void)imagePicker:(LFImagePickerViewController *)picker didImportImages:(NSArray *)imageList
{
    NSLog(@"%@", imageList);
    self.picker = nil;
}

- (void)imagePicker:(LFImagePickerViewController *)picker didImportFailedInfo:(NSDictionary *)info
{
    
}

- (void)imagePicker:(LFImagePickerViewController *)picker didReachMaxSelectedCount:(NSInteger)maxCount
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"提醒") message:[NSString stringWithFormat:NSLocalizedString(@"You can select no more than %lu media", @"你最多只能选择 {number} 个媒体"), maxCount] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

- (void)imagePicker:(LFImagePickerViewController *)picker didReachMaxVideoCount:(NSInteger)maxCount
{
    
}

- (void)imagePicker:(LFImagePickerViewController *)picker didTappedImportButton:(UIButton *)button
{
    
}

#pragma mark - event response

- (void)didTappedStartButton:(UIButton *)button
{
    [self presentViewController:self.picker animated:YES completion:nil];
}

#pragma mark - getters & setters

- (LFImagePickerViewController *)picker
{
    if (_picker == nil) {
        _picker = [[LFImagePickerViewController alloc] initWithThemeColor:[UIColor colorWithRed:1 green:211.0/255.0 blue:105.0/255.0 alpha:1]
                                                                themeType:LFImagePickerThemeTypeYuJian];
//        _picker = [[LFImagePickerViewController alloc] init];
        _picker.maxSelectedCount = 12;
        _picker.delegate = self;
        _picker.videoAvailable = YES;
    }
    return _picker;
}

- (UIButton *)startButton
{
    if (_startButton == nil) {
        _startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_startButton setTitle:@"start" forState:UIControlStateNormal];
        [_startButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_startButton addTarget:self action:@selector(didTappedStartButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}


@end
