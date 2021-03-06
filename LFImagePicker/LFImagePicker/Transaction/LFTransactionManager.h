//
//  BSImageUploader.h
//  yili
//
//  Created by casa on 15/7/23.
//  Copyright (c) 2015年 casa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface LFTransactionManager : NSObject

+ (instancetype)sharedInstance;

- (void)fetchSelectedImage:(NSArray <PHAsset *> *)selectedImage cameraImage:(UIImage *)cameraImage success:(void(^)(NSDictionary *info))success fail:(void(^)(NSDictionary *info))fail progress:(void(^)(NSDictionary *info))progress;


@end
