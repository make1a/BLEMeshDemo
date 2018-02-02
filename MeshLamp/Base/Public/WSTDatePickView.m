//
//  WSTDatePickView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/18.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTDatePickView.h"

@implementation WSTDatePickView
- (instancetype)init
{
    self = [super initWithType:WSTAlertTypeDatePicker];
    if (self) {
        [self masLayoutSubViews];
    }
    return self;
}

- (void)masLayoutSubViews{
    
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.centerView);
    }];

}


- (UIDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc]init];
        _datePicker.datePickerMode = UIDatePickerModeTime;
//        [_datePicker setValue:[UIColor grayColor] forKey:@"textColor"];
//        SEL selector = NSSelectorFromString(@"setHighlightsToday:");
//        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDatePicker instanceMethodSignatureForSelector:selector]];
//        BOOL no = NO;
//        [invocation setSelector:selector];
//        [invocation setArgument:&no atIndex:2];
//        [invocation invokeWithTarget:_datePicker];
        [self.centerView addSubview:_datePicker];
    }
    return _datePicker;
}
@end
