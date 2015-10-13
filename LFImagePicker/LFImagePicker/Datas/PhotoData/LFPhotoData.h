//
//  LFPhotoData.h
//  LFImagePicker
//
//  Created by LongFan on 15/9/28.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface LFPhotoData : NSObject

@property (nonatomic, strong) PHFetchResult *smartAlbums;
@property (nonatomic, strong) PHAssetCollection *album;
@property (nonatomic, strong) PHFetchResult *assets;

- (void)configAlbums:(void (^)(void))complete;
- (void)configAlbumByAlbums:(PHFetchResult *)albums;
- (void)configPhotosByAlbum:(PHFetchResult *)album;

@end
