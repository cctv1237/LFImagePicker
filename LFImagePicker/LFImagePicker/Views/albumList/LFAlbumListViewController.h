//
//  LFAlbumListViewController.h
//  LFImagePicker
//
//  Created by LongFan on 15/10/8.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol LFAlbumListViewControllerDelegate;

@interface LFAlbumListViewController : UIViewController

@property (nonatomic, weak) id<LFAlbumListViewControllerDelegate> delegate;

@property (nonatomic, weak) PHFetchResult *smartAlbums;
@property (nonatomic, weak) PHFetchResult *userAlbums;
@property (nonatomic, strong) PHFetchResult *syncedAlbums;

@end

@protocol LFAlbumListViewControllerDelegate <NSObject>

- (void)albumListViewController:(LFAlbumListViewController *)albumListViewController didSelectAlbumIndex:(NSInteger)index;

@end
