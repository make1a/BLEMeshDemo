//
//  WSTAddAlarmContainerView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTAddAlarmContainerView.h"

@implementation WSTAddAlarmContainerView
- (void)awakeFromNib{
    [super awakeFromNib];
    [self.datePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    SEL selector = NSSelectorFromString(@"setHighlightsToday:");
    //创建NSInvocation
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDatePicker instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    //setArgument中第一个参数的类picker，第二个参数是SEL，
    [invocation setArgument:&no atIndex:2];
    //让invocation执行setHighlightsToday方法
    [invocation invokeWithTarget:self.datePicker];
    
    
    NSArray *nameArray = [NSArray arrayWithObjects:@"sun", @"mon", @"tus", @"wed", @"thur", @"fri", @"sat", nil];
    for (int i = 0; i<self.buttonArray.count; i++) {
        [self setConerAndBorder:self.buttonArray[i]];
        UIButton *button = self.buttonArray[i];
        [button setTitle:nameArray[button.tag-100] forState:UIControlStateNormal];
    }
    
    self.onLabel.text = LCSTR("on");
    
    self.leftLabel.text = LCSTR("Events");
}

- (void)setConerAndBorder:(UIButton *)sendr{
    sendr.layer.borderColor = [UIColor whiteColor].CGColor;
    sendr.layer.borderWidth = 1.f;
    sendr.layer.cornerRadius = sendr.frame.size.height/2;
    sendr.layer.masksToBounds = YES;
}
#pragma mark - actions
- (IBAction)buttonClick:(UIButton *)sender {
    [sender zoomAnimationPop];
    sender.selected = !sender.selected;
    if (self.pressWeekButton) {
        self.pressWeekButton(sender.tag-100);
    }
}

- (IBAction)clickControl:(id)sender {
    if (self.pressButton) {
        self.pressButton();
    }
}
#pragma mark - refreshUI
- (void)refreshViewWith:(AlarmInfo*)info{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *timeStr = [NSString stringWithFormat:@"2017-01-01 %d:%d",info.hour,info.minute];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [formatter dateFromString:timeStr];
    [self.datePicker setDate:date animated:YES];
    
    NSString *binary = [NSString decimalToBinary:info.actionAndModel];
    NSString *bit03 = [binary substringWithRange:NSMakeRange(5, 3)];
    NSString *on; //开关
    if ([bit03 intValue] == 0) {
        on = LCSTR("off");
    }else{
        on = LCSTR("on");
    }
    self.onLabel.text = on;
    
    NSString *weekBinary = [NSString decimalToBinary:info.dayOrCycle];
    for (int i=100; i<107; i++) {
        int y = [[weekBinary substringWithRange:NSMakeRange(7-(i-100), 1)] intValue];
        [(UIButton *)[self viewWithTag:i] setSelected:y == 1?YES:NO];
    }
}
#pragma mark - tool
- (int)getWeekStr{
    NSMutableString *str = [@"00000000" mutableCopy];
    
    for (int i = 0; i<self.buttonArray.count; i++) {
        UIButton *button = self.buttonArray[i];
        if (button.selected) {
            [str replaceCharactersInRange:NSMakeRange(7 - (button.tag - 100), 1) withString:@"1"];

        }
    }
    
    return [[NSString binaryTodecimal:str] intValue];
}
@end
