//
//  WSTSettingZYJLViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/11/14.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTSettingZYJLViewController.h"
#import "WSTDatePickView.h"
#import "WSTTimePickerView.h"

@interface WSTSettingZYJLViewController ()
@property (weak, nonatomic) IBOutlet UILabel *beginLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (nonatomic,strong) WSTDatePickView *datePickerView;
@property (nonatomic,strong) WSTTimePickerView *timePickerView;

@property (nonatomic,strong) AlarmInfo *currentInfo;
@end

@implementation WSTSettingZYJLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    [self refreshView];
}

- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("dayAndNight") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setRightButtonTitle:LCSTR("Save")];
}

- (void)refreshView{
    if (self.isDay) { //昼
        [self dayModelAction];
    }else{
        [self nightModelAction];
    }
    
    if (self.currentInfo.hour == -1) {
        self.beginLabel.text = LCSTR("please_choose");
    }else{
        self.beginLabel.text = [NSString stringWithFormat:@"%@:%@",[NSString padingZero:[NSString stringWithFormat:@"%d",self.currentInfo.hour] length:2],[NSString padingZero:[NSString stringWithFormat:@"%d",self.currentInfo.minute] length:2]];
    }
    
    if (self.currentInfo.duration == -1) {
        self.durationLabel.text = LCSTR("please_choose");
    }else{
        self.durationLabel.text = [NSString stringWithFormat:@"%@%d%@",LCSTR("day_durtime_time"),self.currentInfo.duration,LCSTR("minute")];

    }
}

#pragma mark - actions
- (void)onRightButtonClick:(id)sender{
    [SVProgressHUD setContainerView:nil];

    if (self.currentInfo.hour == -1) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@%@",LCSTR("please_choose"),LCSTR("Time")]];
    }else if (self.currentInfo.duration == -1){
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@%@",LCSTR("please_choose"),LCSTR("day_durtime_time")]];
    }else{
        //18 关
        self.currentInfo.actionAndModel = 146;
        self.currentInfo.dayOrCycle = 127; //0111 1111
        [self.currentInfo updateObject];
        [[WZBlueToothDataManager shareInstance]setTheDeviceTime:self.devAddr isGroup:self.isRoom];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[WZBlueToothDataManager shareInstance]modifyAlarmToDevice:self.devAddr isGroup:self.isRoom WithAlarmInfo:self.currentInfo];
            [SVProgressHUD showSuccessWithStatus:LCSTR("success")];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
    }
}

- (void)dayModelAction{
    NSString *zStr = [NSString stringWithFormat:@"where sceneId = '15' and homeName = '%@' and addrL = '%d'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],self.devAddr];
     NSArray *zArray = [AlarmInfo selectFromClassPredicateWithFormat:zStr];
    AlarmInfo *zInfo;
    if (zArray.count > 0) {
        zInfo = zArray.firstObject;
    }else{
        zInfo = [[AlarmInfo alloc]init];
        zInfo.sceneId = 15;
        zInfo.addrL = self.devAddr;
        zInfo.alarmId = [zInfo getAlarmId];
        zInfo.duration = -1;
        zInfo.hour = -1;
        [zInfo insertObject];
        zInfo = [AlarmInfo selectFromClassPredicateWithFormat:zStr].lastObject;
    }
    self.currentInfo = zInfo;
}

- (void)nightModelAction{
    NSString *yStr = [NSString stringWithFormat:@"where sceneId = '16' and homeName = '%@' and addrL = '%d'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],self.devAddr];
    NSArray *yArray = [AlarmInfo selectFromClassPredicateWithFormat:yStr];
    AlarmInfo *yInfo;
    if (yArray.count > 0) { //存在
        yInfo = yArray.firstObject;
    }else{
        yInfo = [[AlarmInfo alloc]init];
        yInfo.sceneId = 16;
        yInfo.addrL = self.devAddr;
        yInfo.alarmId = [yInfo getAlarmId];
        yInfo.duration = -1;
        yInfo.hour = -1;
        [yInfo insertObject];
        yInfo = [AlarmInfo selectFromClassPredicateWithFormat:yStr].lastObject;
    }
    self.currentInfo = yInfo;
}

- (IBAction)beginAction:(id)sender {
    if (self.datePickerView) {
        [self.datePickerView addWithSuperView:self.view];
        [_datePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (IBAction)durationAction:(id)sender {
    if (self.timePickerView) {
        [self.timePickerView addWithSuperView:self.view];
        [_timePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }

}
- (void)alertBeginTime{
    [self.datePickerView removeFromSuperview];
    
    NSDate *date = self.datePickerView.datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH"];
    
    NSString *hString = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"mm"];
    NSString *mString = [dateFormatter stringFromDate:date];

    self.currentInfo.hour = [hString intValue];
    self.currentInfo.minute = [mString intValue];
    self.beginLabel.text = [NSString stringWithFormat:@"%@:%@",[NSString padingZero:hString length:2],[NSString padingZero:mString length:2]];
    
}
- (void)setDurationTime{
    [self.timePickerView removeFromSuperview];
    self.currentInfo.duration = [self.timePickerView.currentTime intValue];
    self.durationLabel.text = [NSString stringWithFormat:@"%d%@",self.currentInfo.duration,LCSTR("minute")];
}


#pragma mark - 懒加载
- (WSTDatePickView *)datePickerView{
    if (!_datePickerView) {
        _datePickerView = [[WSTDatePickView alloc]init];
        _datePickerView.title = LCSTR("day_start_time");
        [_datePickerView.rightButton addTarget:self action:@selector(alertBeginTime) forControlEvents:UIControlEventTouchDown];
        [ _datePickerView addWithSuperView:self.view];
        [_datePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _datePickerView;
}
- (WSTTimePickerView *)timePickerView{
    if (!_timePickerView) {
        _timePickerView = [[WSTTimePickerView alloc]init];
        _timePickerView.title = LCSTR("day_durtime_time");
        [_timePickerView.rightButton addTarget:self action:@selector(setDurationTime) forControlEvents:UIControlEventTouchDown];
        [_timePickerView addWithSuperView:self.view];
        [_timePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _timePickerView;
}
@end
