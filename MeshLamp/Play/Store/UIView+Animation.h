//
//  UIView+Animation.h
//  we-smart
//
//  Created by new on 15/6/19.
//  Copyright (c) 2015年 we-smart. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Helper.h"
@interface UIView (Animation)

/**
 摁键点击放大缩小动画
 */
-(void)zoomAnimation;


/**
 定义开始时间长度动画

 @param duration 开始时间长度
 */
- (void)zoomAnimationWithStartDuration:(NSTimeInterval)duration;


/**
 定义结束时间长度动画

 @param duration 结束时间长度
 */
- (void)zoomAnimationWithEndDuration:(NSTimeInterval)duration;


/**
 定义开始结束时间长度的点击动画

 @param sDuration 开始时间长度
 @param eDuration 结束时间长度
 */
- (void)zoomAnimationWithStartDuration:(NSTimeInterval)sDuration End:(NSTimeInterval)eDuration;

- (void)zoomAnimationPop;

- (void)zoomAnimationQuick;
@end
