//
//  NSTimer+MKTimer.h
//  NSTimerDemo
//
//  Created by make on 2017/8/31.
//  Copyright © 2017年 make. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MKTimerBlock) (void);

@interface NSTimer (MKTimer)


/**
 定时器

 @param interval 时间
 @param repeats 是否重复
 @param block 回调
 @return NStimer
 */

+ (NSTimer *)mk_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(MKTimerBlock)block;



+ (NSTimer *)mk_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(MKTimerBlock)block;
@end
