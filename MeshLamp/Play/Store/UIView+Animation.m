//
//  UIView+Animation.m
//  we-smart
//
//  Created by new on 15/6/19.
//  Copyright (c) 2015年 we-smart. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)
- (void)zoomAnimation {
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.35 animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
}

- (void)zoomAnimationWithStartDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformMakeScale(1.15, 1.15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
}

- (void)zoomAnimationWithEndDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.15, 1.15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
}

- (void)zoomAnimationWithStartDuration:(NSTimeInterval)sDuration End:(NSTimeInterval)eDuration {
    [UIView animateWithDuration:sDuration animations:^{
        self.transform = CGAffineTransformMakeScale(1.15, 1.15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:eDuration animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
}

- (void)zoomAnimationPop {
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
}

- (void)zoomAnimationQuick {
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }];
    }];
}


@end
