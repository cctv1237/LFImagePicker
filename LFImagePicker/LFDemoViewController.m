//
//  LFDemoViewController.m
//  LFImagePicker
//
//  Created by LongFan on 15/10/8.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFDemoViewController.h"
#import "LFImagePickerViewController.h"

@interface LFDemoViewController ()

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
    LFImagePickerViewController *e = [[LFImagePickerViewController alloc] init];
    [self presentViewController:e animated:YES completion:nil];
}

@end
