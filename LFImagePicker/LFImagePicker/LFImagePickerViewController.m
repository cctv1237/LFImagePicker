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
#import "LFPickerProgressView.h"

#import "UIView+PickerLayoutMethods.h"

#import <Photos/Photos.h>
#import "LFTransactionManager.h"
#import "LFPhotoData.h"

NSString * const kLFPhotoCollectionViewCellIdentifier = @"LFPhotoCollectionViewCell";

@interface LFImagePickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, LFImagePickerTopBarDelegate, LFAlbumListViewControllerDelegate, LFPickerProgressViewDelegate>

@property (nonatomic, strong) LFPhotoData *photoData;
@property (nonatomic, strong) NSMutableArray *selectedMedia;
@property (nonatomic, assign) NSInteger selectedVideoCount;
@property (nonatomic, strong) NSMutableSet *selectedIndexPath;
@property (nonatomic, strong) UIImage *captureImage;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LFImagePickerTopBar *topBar;
@property (nonatomic, strong) LFImagePickerBottomBar *bottomBar;
@property (nonatomic, strong) LFPickerProgressView *progressView;

@end

@implementation LFImagePickerViewController
#pragma mark - rotation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - life cycle

- (instancetype)init
{
    if (self = [super init]) {
        self.maxSelectedCount = 10;
        self.maxVideoCount = 10;
        self.selectedVideoCount = 0;
        self.tintColor = [UIColor colorWithRed:3/255.0f green:196/255.0f blue:255/255.0f alpha:1];
        self.videoAvailable = NO;
        self.audioAvailable = NO;
    }
    return self;
}

- (instancetype)initWithThemeColor:(UIColor *)color
{
    if (self = [super init]) {
        self.maxSelectedCount = 10;
        self.tintColor = color;
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
    [self.view addSubview:self.progressView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.topBar.size = CGSizeMake(SCREEN_WIDTH, 44);
    [self.topBar topInContainer:0 shouldResize:NO];
    [self.topBar centerXEqualToView:self.view];
    
    self.bottomBar.size = CGSizeMake(SCREEN_WIDTH, 50);
    [self.bottomBar bottomInContainer:0 shouldResize:NO];
    [self.bottomBar centerXEqualToView:self.view];
    
    [self.collectionView fill];
    
    [self.progressView fill];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    __weak __typeof(self)weakSelf = self;
    [self.photoData configAlbums:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.collectionView reloadData];
        [strongSelf.topBar refreshAlbumsName:self.photoData.album.localizedTitle];
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
        self.progressView.alpha = 1.0f;
    }];
    
    [self.progressView startProgress:@{@"finishedCount": @0, @"totalCount": @1}];
    [[LFTransactionManager sharedInstance] fetchSelectedImage:self.selectedMedia
                                                  cameraImage:self.captureImage
                                                      success:^(NSDictionary *info) {
                                                          if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didImportImages:)]) {
                                                              [self.delegate imagePicker:self didImportImages:info[@"processedImageList"]];
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                              [self.progressView startProgress:@{@"finishedCount": @1, @"totalCount": @1}];
                                                              self.progressView.alpha = 0.0f;
                                                          }
                                                      }
                                                         fail:^(NSDictionary *info) {
                                                             
                                                             UIAlertController *fail = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"错误")
                                                                                                 message:NSLocalizedString(@"Video is Longer than 20s or Video type not support", @"视频太长或者无法被支持")
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                                                             UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"好")
                                                                                      style:UIAlertActionStyleCancel
                                                                                    handler:^(UIAlertAction * _Nonnull action) {}];
                                                             [fail addAction:cancel];
                                                             [self presentViewController:fail animated:YES completion:nil];
                                                             
                                                             [UIView animateWithDuration:0.3f animations:^{
                                                                 self.progressView.alpha = 0.0f;
                                                             }];
                                                         }
                                                     progress:^(NSDictionary *info) {
                                                         [self.progressView startProgress:info];
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
    albumListTable.userAlbums = self.photoData.userAlbums;
    albumListTable.syncedAlbums = self.photoData.syncedAlbums;
    albumListTable.delegate = self;
    [self presentViewController:albumListTable animated:YES completion:nil];
}

#pragma mark - LFAlbumListViewControllerDelegate

- (void)albumListViewController:(LFAlbumListViewController *)albumListViewController didSelectAlbumIndex:(NSInteger)index
{
    PHFetchResult *albums;
    if (index < self.photoData.smartAlbums.count) {
        albums = self.photoData.smartAlbums;
    } else if (index < self.photoData.smartAlbums.count + self.photoData.userAlbums.count) {
        albums = self.photoData.userAlbums;
    } else {
        albums = self.photoData.syncedAlbums;
    }
    
    [albums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((idx == index && albums == self.photoData.smartAlbums) ||
            (idx == index - self.photoData.smartAlbums.count && albums == self.photoData.userAlbums) ||
            (idx == index - self.photoData.smartAlbums.count - self.photoData.userAlbums.count && albums == self.photoData.syncedAlbums)) {
            self.photoData.album = collection;
            [self.topBar refreshAlbumsName:collection.localizedTitle];
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            [self.photoData configPhotosByAlbum:assetsFetchResult];
            
            [self.selectedMedia removeAllObjects];
            [self.selectedIndexPath removeAllObjects];
            [self.collectionView reloadData];
            if (self.captureImage) {
                [self.bottomBar refreshSelectedCount:self.selectedMedia.count + 1];
            } else {
                [self.bottomBar refreshSelectedCount:self.selectedMedia.count];
            }
            if (self.selectedMedia.count) {
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
    [self.bottomBar refreshSelectedCount:self.selectedMedia.count + 1];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LFPickerProgressViewDelegate
- (void)pickerProgressView:(LFPickerProgressView *)progressView didFinishedCompressedImage:(NSArray *)compressedImage
{
    [UIView animateWithDuration:0.3f animations:^{
        progressView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [progressView removeFromSuperview];
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
            [cell configDataWithImage:self.captureImage themeColor:self.tintColor];
            [cell addSelectionSign];
        } else {
            [cell configDataWithImage:[UIImage imageNamed:@"pictures_take-photo_209"] themeColor:self.tintColor];
        }
    } else {
        [cell configDataWithAsset:self.photoData.assets[[self.photoData.assets count] - indexPath.item] themeColor:self.tintColor];
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
        PHAsset *asset = (PHAsset *)self.photoData.assets[[self.photoData.assets count] - indexPath.item];
        if (asset.mediaType != PHAssetMediaTypeImage) {
            if (!self.videoAvailable && asset.mediaType == PHAssetMediaTypeVideo) {
                [collectionView deselectItemAtIndexPath:indexPath animated:NO];
                if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didRejectSelectVideoAtIndexPath:)]) {
                    [self.delegate imagePicker:self didRejectSelectVideoAtIndexPath:indexPath];
                }
                return;
            }
            if (!self.audioAvailable && asset.mediaType == PHAssetMediaTypeAudio) {
                [collectionView deselectItemAtIndexPath:indexPath animated:NO];
                if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didRejectSelectAudioAtIndexPath:)]) {
                    [self.delegate imagePicker:self didRejectSelectAudioAtIndexPath:indexPath];
                }
                return;
            }
        }
        
        if (self.selectedMedia.count == self.maxSelectedCount) {
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
            if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didReachMaxSelectedCount:)]) {
                [self.delegate imagePicker:self didReachMaxSelectedCount:self.maxSelectedCount];
            }
        } else if (self.selectedVideoCount == self.maxVideoCount && asset.mediaType == PHAssetMediaTypeVideo) {
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
            if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didReachMaxVideoCount:)]) {
                [self.delegate imagePicker:self didReachMaxVideoCount:self.maxVideoCount];
            }
        } else {
            LFPhotoCollectionViewCell *cell = (LFPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            if (asset.mediaType == PHAssetMediaTypeVideo) {
                self.selectedVideoCount++;
            }
            [self.selectedMedia addObject:asset];
            [self.selectedIndexPath addObject:indexPath];
            [cell bounceAnimation];
            
            [self.bottomBar refreshSelectedCount:self.selectedMedia.count];
            if (self.selectedMedia.count) {
                self.topBar.importButton.enabled = YES;
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LFPhotoCollectionViewCell *cell = (LFPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedMedia removeObject:self.photoData.assets[[self.photoData.assets count] - indexPath.item]];
    [self.selectedIndexPath removeObject:indexPath];
    [cell bounceAnimation];
    
    [self.bottomBar refreshSelectedCount:self.selectedMedia.count];
    if (!self.selectedMedia.count) {
        self.topBar.importButton.enabled = NO;
    }
}

#pragma mark - getters & setters
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 36) / 3, (SCREEN_WIDTH - 36) / 3);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.contentInset = UIEdgeInsetsMake(62, 18, 68, 18);
        [_collectionView registerClass:[LFPhotoCollectionViewCell class] forCellWithReuseIdentifier:kLFPhotoCollectionViewCellIdentifier];
    }
    return _collectionView;
}

- (LFImagePickerTopBar *)topBar
{
    if (_topBar == nil) {
        _topBar = [[LFImagePickerTopBar alloc] initWithThemeColor:self.tintColor];
        _topBar.delegate = self;
    }
    return _topBar;
}

- (LFImagePickerBottomBar *)bottomBar
{
    if (_bottomBar == nil) {
        _bottomBar = [[LFImagePickerBottomBar alloc] initWithThemeColor:self.tintColor];
        
    }
    return _bottomBar;
}

- (LFPickerProgressView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[LFPickerProgressView alloc] init];
        _progressView.delegate = self;
        _progressView.alpha = 0.0f;
    }
    return _progressView;
}

- (LFPhotoData *)photoData
{
    if (_photoData == nil) {
        _photoData = [[LFPhotoData alloc] init];
        
    }
    return _photoData;
}

- (NSMutableArray *)selectedMedia
{
    if (_selectedMedia == nil) {
        _selectedMedia = [NSMutableArray array];
    }
    return _selectedMedia;
}

- (NSMutableSet *)selectedIndexPath
{
    if (_selectedIndexPath == nil) {
        _selectedIndexPath = [NSMutableSet set];
        
    }
    return _selectedIndexPath;
}

@end
