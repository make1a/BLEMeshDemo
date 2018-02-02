//
//  NSTimer+MKTimer.m
//  NSTimerDemo
//
//  Created by make on 2017/8/31.
//  Copyright © 2017年 make. All rights reserved.
//

#import "NSTimer+MKTimer.h"

@implementation NSTimer (MKTimer)

+ (NSTimer *)mk_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(MKTimerBlock)block{

   return  [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(action:) userInfo:[block copy] repeats:repeats];

}

+ (NSTimer *)mk_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(MKTimerBlock)block{

    return [self timerWithTimeInterval:interval target:self selector:@selector(action:) userInfo:[block copy] repeats:repeats];

}

//+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo

+ (void)action:(NSTimer *)userInfo{

   MKTimerBlock block = userInfo.userInfo;
    if (block) {
        block();
    }

}
@end
