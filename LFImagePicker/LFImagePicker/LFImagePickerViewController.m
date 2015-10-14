//
//  ViewController.m
//  LFImagePicker
//
//  Created by LongFan on 15/9/24.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFImagePickerViewController.h"
#import "LFPhotoCollectionViewCell.h"
#import "LFImagePickerTopBar.h"
#import "LFImagePickerBottomBar.h"
#import "LFAlbumListViewController.h"
#import "LFImageCompressView.h"

#import "UIView+PickerLayoutMethods.h"

#import <Photos/Photos.h>
#import "LFTransactionManager.h"
#import "LFPhotoData.h"

NSString * const kLFPhotoCollectionViewCellIdentifier = @"LFPhotoCollectionViewCell";

@interface LFImagePickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, LFImagePickerTopBarDelegate, LFAlbumListViewControllerDelegate, LFImageCompressViewDelegate>

@property (nonatomic, strong) LFPhotoData *photoData;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) NSMutableSet *selectedIndexPath;
@property (nonatomic, strong) UIImage *captureImage;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LFImagePickerTopBar *topBar;
@property (nonatomic, strong) LFImagePickerBottomBar *bottomBar;
@property (nonatomic, strong) LFImageCompressView *compressView;

@end

@implementation LFImagePickerViewController

#pragma mark - life cycle

- (instancetype)init
{
    if (self = [super init]) {
        self.maxSelectedCount = 10;
        self.themeColor = [UIColor blueColor];
        self.videoAvailable = NO;
        self.audioAvailable = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.bottomBar];
    [self.view addSubview:self.compressView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.topBar.size = CGSizeMake(SCREEN_WIDTH, 44);
    [self.topBar topInContainer:0 shouldResize:NO];
    [self.topBar centerXEqualToView:self.view];
    
    [self.bottomBar sizeEqualToView:self.topBar];
    [self.bottomBar bottomInContainer:0 shouldResize:NO];
    [self.bottomBar centerXEqualToView:self.view];
    
    [self.collectionView fill];
    
    [self.compressView fill];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.photoData configAlbums:^{
        [self.collectionView reloadData];
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - LFImagePickerTopBarDelegate

- (void)topBar:(LFImagePickerTopBar *)bar didTappedImportButton:(UIButton *)button
{
    
    [UIView animateWithDuration:0.3f animations:^{
        self.navigationController.navigationBar.alpha = 0.0f;
        self.compressView.alpha = 1.0f;
    }];
    
    [[LFTransactionManager sharedInstance] fetchSelectedImage:self.selectedPhotos
                                                  cameraImage:self.captureImage
                                                      success:^(NSDictionary *info) {
                                                          if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didImportImages:)]) {
                                                              [self.delegate imagePicker:self didImportImages:info[@"processedImageList"]];
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                              self.compressView.alpha = 0.0f;
                                                          }
                                                      }
                                                         fail:^(NSDictionary *info) {}
                                                     progress:^(NSDictionary *info) {
                                                         [self.compressView showCompressingProgress:info];
                                                     }];
    
}

- (void)topBar:(LFImagePickerTopBar *)bar didTappedCancelButton:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)topBar:(LFImagePickerTopBar *)bar didTappedAlbumsButton:(UIButton *)button
{
    LFAlbumListViewController *albumListTable = [[LFAlbumListViewController alloc] init];
    albumListTable.popoverPresentationController.sourceView = self.topBar;
    albumListTable.popoverPresentationController.sourceRect = self.topBar.bounds;
    albumListTable.popoverPresentationController.popoverLayoutMargins = UIEdgeInsetsMake(50, 50, 50, 50);
    albumListTable.smartAlbums = self.photoData.smartAlbums;
    albumListTable.delegate = self;
    [self presentViewController:albumListTable animated:YES completion:nil];
}

#pragma mark - LFAlbumListViewControllerDelegate

- (void)albumListViewController:(LFAlbumListViewController *)albumListViewController didSelectAlbumIndex:(NSInteger)index
{
    [self.photoData.smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == index) {
            self.photoData.album = collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            [self.photoData configPhotosByAlbum:assetsFetchResult];
            
            [self.selectedPhotos removeAllObjects];
            [self.selectedIndexPath removeAllObjects];
            [self.collectionView reloadData];
            if (self.captureImage) {
                [self.bottomBar refreshSelectedCount:self.selectedPhotos.count + 1];
            } else {
                [self.bottomBar refreshSelectedCount:self.selectedPhotos.count];
            }
            if (self.selectedPhotos.count) {
                self.topBar.importButton.enabled = YES;
            } else {
                self.topBar.importButton.enabled = NO;
            }
        }
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info
{
    self.captureImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!self.captureImage) {
        self.captureImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [self.collectionView reloadData];
    [self.bottomBar refreshSelectedCount:self.selectedPhotos.count + 1];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BSImageCompressViewDelegate

- (void)imageCompressViewController:(LFImageCompressView *)compressView didFinishedCompressedImage:(NSArray *)compressedImage
{
    if ([self.delegate respondsToSelector:@selector(imagePicker:didImportImages:)]) {
        [self.delegate imagePicker:self didImportImages:compressedImage];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        compressView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [compressView removeFromSuperview];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photoData.assets count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LFPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLFPhotoCollectionViewCellIdentifier forIndexPath:indexPath];
    if (indexPath.item == 0) {
        [cell isCameraButton];
        if (self.captureImage) {
            [cell configDataWithImage:self.captureImage themeColor:self.themeColor];
            [cell addSelectionSign];
        } else {
            [cell configDataWithImage:[UIImage imageNamed:@"LFImagePickerImage.bundle/pictures_take-photo_209"] themeColor:self.themeColor];
        }
    } else {
        [cell configDataWithAsset:self.photoData.assets[[self.photoData.assets count] - indexPath.item] themeColor:self.themeColor];
        if ([self.selectedIndexPath containsObject:indexPath]) {
            [cell addSelectionSign];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        if ([(PHAsset *)(self.photoData.assets[[self.photoData.assets count] - indexPath.item]) mediaType] != PHAssetMediaTypeImage) {
            if (!self.videoAvailable) {
                [collectionView deselectItemAtIndexPath:indexPath animated:NO];
                if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didRejectSelectVideoAtIndexPath:)]) {
                    [self.delegate imagePicker:self didRejectSelectVideoAtIndexPath:indexPath];
                }
                return;
            }
            if (!self.audioAvailable) {
                [collectionView deselectItemAtIndexPath:indexPath animated:NO];
                if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didRejectSelectAudioAtIndexPath:)]) {
                    [self.delegate imagePicker:self didRejectSelectAudioAtIndexPath:indexPath];
                }
                return;
            }
        }
        
        if (self.selectedPhotos.count == self.maxSelectedCount) {
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
            if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didReachMaxSelectedCount:)]) {
                [self.delegate imagePicker:self didReachMaxSelectedCount:self.maxSelectedCount];
            }
        } else {
            LFPhotoCollectionViewCell *cell = (LFPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            [self.selectedPhotos addObject:self.photoData.assets[[self.photoData.assets count] - indexPath.item]];
            [self.selectedIndexPath addObject:indexPath];
            [cell bounceAnimation];
            
            [self.bottomBar refreshSelectedCount:self.selectedPhotos.count];
            if (self.selectedPhotos.count) {
                self.topBar.importButton.enabled = YES;
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LFPhotoCollectionViewCell *cell = (LFPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedPhotos removeObject:self.photoData.assets[[self.photoData.assets count] - indexPath.item]];
    [self.selectedIndexPath removeObject:indexPath];
    [cell bounceAnimation];
    
    [self.bottomBar refreshSelectedCount:self.selectedPhotos.count];
    if (!self.selectedPhotos.count) {
        self.topBar.importButton.enabled = NO;
    }
}

#pragma mark - getters & setters
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH / 3, SCREEN_WIDTH / 3);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.contentInset = UIEdgeInsetsMake(44, 0, 44, 0);
        [_collectionView registerClass:[LFPhotoCollectionViewCell class] forCellWithReuseIdentifier:kLFPhotoCollectionViewCellIdentifier];
    }
    return _collectionView;
}

- (LFImagePickerTopBar *)topBar
{
    if (_topBar == nil) {
        _topBar = [[LFImagePickerTopBar alloc] init];
        _topBar.themeColor = self.themeColor;
        _topBar.delegate = self;
    }
    return _topBar;
}

- (LFImagePickerBottomBar *)bottomBar
{
    if (_bottomBar == nil) {
        _bottomBar = [[LFImagePickerBottomBar alloc] init];
        
    }
    return _bottomBar;
}

- (LFImageCompressView *)compressView
{
    if (_compressView == nil) {
        _compressView = [[LFImageCompressView alloc] init];
        _compressView.delegate = self;
        _compressView.alpha = 0.0f;
    }
    return _compressView;
}

- (LFPhotoData *)photoData
{
    if (_photoData == nil) {
        _photoData = [[LFPhotoData alloc] init];
        
    }
    return _photoData;
}

- (NSMutableArray *)selectedPhotos
{
    if (_selectedPhotos == nil) {
        _selectedPhotos = [NSMutableArray array];
    }
    return _selectedPhotos;
}

- (NSMutableSet *)selectedIndexPath
{
    if (_selectedIndexPath == nil) {
        _selectedIndexPath = [NSMutableSet set];
        
    }
    return _selectedIndexPath;
}

@end
