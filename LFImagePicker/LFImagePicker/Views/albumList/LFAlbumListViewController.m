//
//  LFAlbumListViewController.m
//  LFImagePicker
//
//  Created by LongFan on 15/10/8.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFAlbumListViewController.h"
#import "UIView+LayoutMethods.h"

@interface LFAlbumListViewController () <UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

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
    
//    UIButton *a = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    a.backgroundColor = [UIColor redColor];
//    [a addTarget:self action:@selector(didTappeds) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:a];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView fill];
}

- (void)didTappeds
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.smartAlbums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumListreuseIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = [self.smartAlbums[indexPath.item] localizedTitle];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(albumListViewController:didSelectAlbumIndex:)]) {
        [self.delegate albumListViewController:self didSelectAlbumIndex:indexPath.item];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

#pragma mark - getters & setters

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AlbumListreuseIdentifier"];
    }
    return _tableView;
}

@end
