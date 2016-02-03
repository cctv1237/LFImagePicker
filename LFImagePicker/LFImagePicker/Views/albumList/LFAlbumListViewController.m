//
//  LFAlbumListViewController.m
//  LFImagePicker
//
//  Created by LongFan on 15/10/8.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFAlbumListViewController.h"
#import "UIView+PickerLayoutMethods.h"

@interface LFAlbumListViewController () <UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LFAlbumListViewController

#pragma mark - life cycle

- (instancetype)init
{
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    return self.smartAlbums.count + self.userAlbums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AlbumListreuseIdentifier"];
    if (indexPath.row < self.smartAlbums.count) {
        cell.textLabel.text = [self.smartAlbums[indexPath.row] localizedTitle];
    } else {
        cell.textLabel.text = [self.userAlbums[indexPath.row - self.smartAlbums.count] localizedTitle];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(albumListViewController:didSelectAlbumIndex:)]) {
        [self.delegate albumListViewController:self didSelectAlbumIndex:indexPath.row];
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
