//
//  LFFetchSelectedImageTransaction.h
//  LFImagePicker
//
//  Created by LongFan on 15/10/9.
//  Copyright © 2015年 LongFan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LFFetchImageCallbackBlock)(NSDictionary *info);

extern NSString * const kLFFetchImageTransactionInfoKeySuccessCallback;
extern NSString * const kLFFetchImageTransactionInfoKeyFailCallback;
extern NSString * const kLFFetchImageTransactionInfoKeyProgressCallback;
extern NSString * const kLFFetchImageTransactionInfoKeyAsset;

extern NSString * const kLFFetchImageTransactionResultInfoKeyType;
extern NSString * const kLFFetchImageTransactionResultInfoKeyContent;
extern NSString * const kLFFetchImageTransactionResultInfoKeyVideoImage;
extern NSString * const kLFFetchImageTransactionResultInfoKeyVideoLatitude;
extern NSString * const kLFFetchImageTransactionResultInfoKeyVideoLongitude;

@interface LFFetchSelectedImageTransaction : NSObject

- (void)fetchImageWithInfo:(NSDictionary *)info;

@end
