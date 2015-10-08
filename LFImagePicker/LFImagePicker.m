//
//  ViewController.m
//  LFImagePicker
//
//  Created by LongFan on 15/9/24.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFImagePicker.h"
#import "LFPhotoCollectionViewCell.h"
#import "LFImagePickerTopBar.h"

#import "UIView+LayoutMethods.h"

#import <Photos/Photos.h>

NSString * const kLFPhotoCollectionViewCellIdentifier = @"LFPhotoCollectionViewCell";

@interface LFImagePicker () <UICollectionViewDataSource, UICollectionViewDelegate, LFImagePickerTopBarDelegate>

@property (nonatomic, strong) PHFetchResult *smartAlbums;
@property (nonatomic, strong) PHAssetCollection *album;
@property (nonatomic, strong) PHFetchResult *photos;
@property (nonatomic, assign) PHAuthorizationStatus authorizationStatus;
@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LFImagePickerTopBar *topBar;

@end

@implementation LFImagePicker

#pragma mark - life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.maxSelectedCount = 10;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.collectionView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.topBar.size = CGSizeMake(SCREEN_WIDTH, 44);
    [self.topBar topInContainer:0 shouldResize:NO];
    [self.topBar centerXEqualToView:self.view];
    
    [self.collectionView fillWidth];
    [self.collectionView top:0 FromView:self.topBar];
    [self.collectionView bottomInContainer:0 shouldResize:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self configAlbums];
}

#pragma mark - LFImagePickerTopBarDelegate

- (void)topBar:(LFImagePickerTopBar *)bar didTappedImportButton:(UIButton *)button
{
    NSMutableArray *exportImageList = [NSMutableArray array];
    [self.selectedPhotos enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.cachingImageManager requestImageForAsset:asset
                                            targetSize:PHImageManagerMaximumSize
                                           contentMode:PHImageContentModeDefault
                                               options:nil
                                         resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                             [exportImageList addObject:result];
                                         }];
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:didImportImages:)]) {
        [self.delegate imagePicker:self didImportImages:exportImageList];
    }
}

- (void)topBar:(LFImagePickerTopBar *)bar didTappedCancelButton:(UIButton *)button
{
    #warning todo
}

- (void)topBar:(LFImagePickerTopBar *)bar didTappedAlbumsButton:(UIButton *)button
{
    #warning todo
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photos count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LFPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLFPhotoCollectionViewCellIdentifier forIndexPath:indexPath];
    if (indexPath.item == 0) {
        
    } else {
        [cell configDataWithAsset:self.photos[[self.photos count] - indexPath.item] themeColor:[UIColor cyanColor]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedPhotos.count == self.maxSelectedCount) {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        return;
    }
    
    LFPhotoCollectionViewCell *cell = (LFPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedPhotos addObject:self.photos[[self.photos count] - indexPath.item]];
    [cell bounceAnimation];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LFPhotoCollectionViewCell *cell = (LFPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedPhotos removeObject:self.photos[[self.photos count] - indexPath.item]];
    [cell bounceAnimation];
}

#pragma mark - private

- (void)configAlbums
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                      subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                                      options:nil];
                self.smartAlbums = smartAlbums;
                [self configAlbumByAlbums:smartAlbums];
                [self.collectionView reloadData];
            });
        }
    }];
}

- (void)configAlbumByAlbums:(PHFetchResult *)albums
{
    [albums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([collection.localizedTitle isEqualToString:@"Camera Roll"]) {
            self.album = collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            [self configPhotosByAlbum:assetsFetchResult];
        }
    }];
}

- (void)configPhotosByAlbum:(PHFetchResult *)album
{
    self.photos = album;
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
        [_collectionView registerClass:[LFPhotoCollectionViewCell class] forCellWithReuseIdentifier:kLFPhotoCollectionViewCellIdentifier];
    }
    return _collectionView;
}

- (LFImagePickerTopBar *)topBar
{
    if (_topBar == nil) {
        _topBar = [[LFImagePickerTopBar alloc] init];
        _topBar.delegate = self;
    }
    return _topBar;
}

- (PHAuthorizationStatus)authorizationStatus
{
    _authorizationStatus = [PHPhotoLibrary authorizationStatus];
    return _authorizationStatus;
}

- (NSMutableArray *)selectedPhotos
{
    if (_selectedPhotos == nil) {
        _selectedPhotos = [NSMutableArray array];
    }
    return _selectedPhotos;
}

- (PHCachingImageManager *)cachingImageManager
{
    if (_cachingImageManager == nil) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

@end
