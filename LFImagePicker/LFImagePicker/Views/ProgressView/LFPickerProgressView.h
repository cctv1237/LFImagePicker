//
//  BSFilterSycProgressView.h
//  yili
//
//  Created by LongFan on 16/1/14.
//  Copyright © 2016年 Beauty Sight Network Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LFPickerProgressViewDelegate;

@interface LFPickerProgressView : UIView

@property (nonatomic, weak) id<LFPickerProgressViewDelegate> delegate;

- (void)startProgress:(NSDictionary *)progress;
- (void)endProgress;

@end

@protocol LFPickerProgressViewDelegate <NSObject>

- (void)pickerProgressView:(LFPickerProgressView *)progressView didFinishedCompressedImage:(NSArray *)compressedImage;

@optional
- (void)pickerProgressView:(LFPickerProgressView *)progressView didTappedDoneButton:(UIButton *)button;
- (void)pickerProgressView:(LFPickerProgressView *)progressView didTappedExitButton:(UIButton *)button;

@end