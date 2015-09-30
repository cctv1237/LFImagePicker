//
//  ViewController.m
//  LFImagePicker
//
//  Created by LongFan on 15/9/24.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import "LFImagePickerViewController.h"
#import "LFPhotoCollectionViewCell.h"

#import "UIView+LayoutMethods.h"

#import <Photos/Photos.h>

NSString * const kLFPhotoCollectionViewCellIdentifier = @"LFPhotoCollectionViewCell";

@interface LFImagePickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) PHFetchResult *smartAlbums;
@property (nonatomic, strong) PHAssetCollection *album;
@property (nonatomic, strong) PHFetchResult *photos;
@property (nonatomic, assign) PHAuthorizationStatus authorizationStatus;

@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation LFImagePickerViewController

#pragma mark - life cycle

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView fill];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configAlbums];
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
        [cell configWithDataWithAsset:self.photos[[self.photos count] - indexPath.item] themeColor:[UIColor cyanColor]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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

@end
