//
//  LFAlbumListViewController.m
//  LFImagePicker
//
//  Created by LongFan on 15/10/8.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFAlbumListViewController.h"

@interface LFAlbumListViewController () <UIPopoverPresentationControllerDelegate>

@end

@implementation LFAlbumListViewController

#pragma mark - life cycle

- (instancetype)init
{
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        self.popoverPresentationController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *a = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    a.backgroundColor = [UIColor redColor];
    [a addTarget:self action:@selector(didTappeds) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:a];
}

- (void)didTappeds
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
