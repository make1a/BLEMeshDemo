//
//  WSTAddAlarmViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTAddAlarmViewController.h"
#import "WSTAddAlarmContainerView.h"
@interface WSTAddAlarmViewController ()
/**containerView*/
@property (nonatomic,strong) WSTAddAlarmContainerView *containerView;
/**闹钟的开关 */
@property (nonatomic,assign) BOOL isOn;

@end

@implementation WSTAddAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    self.isOn = YES;
    [self refreshViewWithCurrentAlarm];
}
- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("alarm") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setRightButtonTitle:LCSTR("Save")];
}
-(void)refreshViewWithCurrentAlarm{
    if (self.isEdit == YES) {
        [self.containerView refreshViewWith:self.currentAlarm];
    }
}

#pragma mark - actions
- (void)onRightButtonClick:(id)sender{
    [SVProgressHUD setContainerView:nil];
    int week = [self.containerView getWeekStr];
    
    if (week == 0) {
        [SVProgressHUD showErrorWithStatus:LCSTR("choose_week_reminder")];
        return;
    }
    if (self.isRoom == YES) {
        NSString *str = [NSString stringWithFormat:@"where homeName = '%@'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName]];
        NSArray *array = [AlarmInfo selectFromClassPredicateWithFormat:str];

        if (array.count >= 10) {
            [SVProgressHUD showErrorWithStatus:LCSTR("max_alarm_reminder")];
            return;
        }
    }else{
        NSString *str = [NSString stringWithFormat:@"where homeName = '%@' and addrL = '%d'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],self.devAddr];
        NSArray *array = [AlarmInfo selectFromClassPredicateWithFormat:str];

        if (array.count >= 4) {
            [SVProgressHUD showErrorWithStatus:LCSTR("max_alarm_reminder")];
            return;
        }
    }
    NSDate *date = _containerView.datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH"];
    
    NSString *hString = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"mm"];
    NSString *mString = [dateFormatter stringFromDate:date];
    
    //校准时间
    [[WZBlueToothDataManager shareInstance]setTheDeviceTime:self.devAddr isGroup:self.isRoom];
    AlarmInfo *alarm;
    if (self.isEdit == YES) {
        alarm = self.currentAlarm;
    }else{
        alarm = [[AlarmInfo alloc]init];
    }

    alarm.addrL = self.devAddr;
    alarm.alarmId = [alarm getAlarmId];
    alarm.actionAndModel = self.isOn == YES?145:144; //开关
    alarm.dayOrCycle = week;
    alarm.hour = [hString intValue];
    alarm.minute = [mString intValue];
    
    if (self.isEdit == YES) {
        [alarm updateObject];
    }else{
        [alarm insertObject];
    }
    [[WZBlueToothDataManager shareInstance]modifyAlarmToDevice:self.devAddr isGroup:self.isRoom  WithAlarmInfo:alarm];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
    
}

#pragma mark - 布局
- (void)masLayoutSubview{
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
           make.edges.equalTo(self.view);
        }
    }];
}

#pragma mark - 懒加载
- (WSTAddAlarmContainerView *)containerView{
    if (!_containerView) {
        _containerView = [[NSBundle mainBundle]loadNibNamed:@"WSTAddAlarmContainerView" owner:self options:nil].firstObject;
        __weak typeof (self)weakSelf = self;

        _containerView.pressButton = ^{
            UIAlertAction *onAction = [UIAlertAction actionWithTitle:LCSTR("on") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                weakSelf.isOn = YES;
                weakSelf.containerView.onLabel.text = LCSTR("on");
            }];
            UIAlertAction *offAction = [UIAlertAction actionWithTitle:LCSTR("off") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                weakSelf.isOn = NO;
                weakSelf.containerView.onLabel.text = LCSTR("off");
            }];
            
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:LCSTR("Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:LCSTR("Events") message:LCSTR("choose_event_reminder")preferredStyle:UIAlertControllerStyleAlert];
            
            [ac addAction:onAction];
            [ac addAction:offAction];
            [ac addAction:cancleAction];

            [weakSelf presentViewController:ac animated:YES completion:nil];
        };
        [self.view addSubview:_containerView];
    }
    return _containerView;
}
@end
