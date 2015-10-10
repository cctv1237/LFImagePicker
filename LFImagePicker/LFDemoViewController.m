//
//  LFDemoViewController.m
//  LFImagePicker
//
//  Created by LongFan on 15/10/8.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFDemoViewController.h"
#import "LFImagePickerViewController.h"

@interface LFDemoViewController () <LFimagePickerDelegate>

@property (nonatomic, strong) LFImagePickerViewController *e;

@end

@implementation LFDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *a = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [a setTitle:@"start" forState:UIControlStateNormal];
    [a setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [a addTarget:self action:@selector(didTappeds) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:a];
}

- (void)didTappeds
{
    [self presentViewController:self.e animated:YES completion:nil];
}

- (void)imagePicker:(LFImagePickerViewController *)picker didImportImages:(NSArray *)imageList
{
    NSLog(@"%@", imageList);
}
- (void)imagePicker:(LFImagePickerViewController *)picker didSelectDefaultAlbumName:(NSString *)albumName
{
    
}
- (void)imagePicker:(LFImagePickerViewController *)picker didReachMaxSelectedCount:(NSInteger)maxCount
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"提醒") message:[NSString stringWithFormat:NSLocalizedString(@"You can select no more than %lu images", @"你最多只能选择 {number} 张图片"), maxCount] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

- (LFImagePickerViewController *)e
{
    if (_e == nil) {
        _e = [[LFImagePickerViewController alloc] init];
        _e.maxSelectedCount = 12;
        _e.delegate = self;
    }
    return _e;
}


@end
