//
//  WSTCircadianViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/18.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTCircadianViewController.h"
#import "WSTDatePickView.h"
#import "WSTTimePickerView.h"
#import "WSTCircadianTimeCell.h"
#import "WSTCircadianSwitchCell.h"
#import "WSTCircadianInfo.h"

@interface WSTCircadianViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
/**WSTDatePickView*/
@property (nonatomic,strong) WSTDatePickView *datePickerView;
/**WSTTimePickerView*/
@property (nonatomic,strong) WSTTimePickerView *timePickerView;
/**当前row */
@property (nonatomic,assign) NSInteger currentSection;
/**昼节律*/
@property (nonatomic,strong) AlarmInfo *zInfo;
/**夜节律*/
@property (nonatomic,strong) AlarmInfo *yInfo;
/**是否编辑 */
@property (nonatomic,assign) BOOL isZEdit;
@property (nonatomic,assign) BOOL isYEdit;
@end

@implementation WSTCircadianViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    [self getCurrentInfo];
}
- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("dayAndNight") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setRightButtonTitle:LCSTR("Save")];
}

- (void)getCurrentInfo{
    //昼节律
    NSString *zStr = [NSString stringWithFormat:@"where sceneId = '15' and homeName = '%@' and addrL = '%d'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],self.devAddr];
//    NSArray *aa = [AlarmInfo selectFromClassAllObject];
    NSArray *zArray = [AlarmInfo selectFromClassPredicateWithFormat:zStr];
    if (zArray.count > 0) {
        self.zInfo = zArray.firstObject;
    }else{
        self.zInfo = [[AlarmInfo alloc]init];
        self.zInfo.sceneId = 15;
        self.zInfo.addrL = self.devAddr;
        self.zInfo.alarmId = [self.zInfo getAlarmId];
        self.zInfo.duration = -1;
        self.zInfo.hour = -1;
        [self.zInfo insertObject];
        self.zInfo = [AlarmInfo selectFromClassPredicateWithFormat:zStr].lastObject;
    }
    
    //夜节律
    NSString *yStr = [NSString stringWithFormat:@"where sceneId = '16' and homeName = '%@' and addrL = '%d'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],self.devAddr];
    NSArray *yArray = [AlarmInfo selectFromClassPredicateWithFormat:yStr];
    if (yArray.count > 0) { //存在
        self.yInfo = yArray.firstObject;
    }else{
        self.yInfo = [[AlarmInfo alloc]init];
        self.yInfo.sceneId = 16;
        self.yInfo.addrL = self.devAddr;
        self.yInfo.alarmId = [self.yInfo getAlarmId];
        self.yInfo.duration = -1;
        self.yInfo.hour = -1;
        [self.yInfo insertObject];
        self.yInfo = [AlarmInfo selectFromClassPredicateWithFormat:yStr].lastObject;
    }
    [self.tableView reloadData];
    
}
#pragma mark - 点击
- (void)alertBeginTime{
    
    [self.datePickerView removeFromSuperview];
    
    NSDate *date = self.datePickerView.datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH"];
    
    NSString *hString = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"mm"];
    NSString *mString = [dateFormatter stringFromDate:date];
    
    if (self.currentSection == 0) { //昼节律
        self.zInfo.hour = [hString intValue];
        self.zInfo.minute = [mString intValue];
    }else{
        self.yInfo.hour = [hString intValue];
        self.yInfo.minute = [mString intValue];
    }
    [self.tableView reloadData];
}

- (void)setDurationTime{
    [self.timePickerView removeFromSuperview];
    if (self.currentSection == 0) { //昼节律
       self.zInfo.duration =  [self.timePickerView.currentTime intValue];
    }else{
        self.yInfo.duration = [self.timePickerView.currentTime intValue];
    }
    [self.tableView reloadData];
}

//保存发送指令
- (void)onRightButtonClick:(id)sender{
    
    [SVProgressHUD setContainerView:nil];
        
    if (self.zInfo.hour == -1 || self.zInfo.duration == -1) {
        [SVProgressHUD showErrorWithStatus:LCSTR("请选择昼节律时间")];
    }else{
        WSTCircadianSwitchCell *cell0 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        self.zInfo.actionAndModel = cell0.sswitch.isOn == YES?146:18; //开关
        self.zInfo.dayOrCycle = 127; //0111 1111
        [self.zInfo updateObject];
        [[WZBlueToothDataManager shareInstance]setTheDeviceTime:self.devAddr isGroup:self.isRoom];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[WZBlueToothDataManager shareInstance]modifyAlarmToDevice:self.devAddr isGroup:self.isRoom WithAlarmInfo:self.zInfo];
        });
        [SVProgressHUD showSuccessWithStatus:LCSTR("昼节律设置成功")];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.yInfo.hour == -1 || self.yInfo.duration == -1) {
            [SVProgressHUD showErrorWithStatus:LCSTR("请选择夜节律时间")];
        }else{
            WSTCircadianSwitchCell *cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            self.yInfo.actionAndModel = cell1.sswitch.isOn == YES?146:18; //开关
            self.yInfo.dayOrCycle = 127; //0111 1111
            [self.yInfo updateObject];
            [[WZBlueToothDataManager shareInstance]setTheDeviceTime:self.devAddr isGroup:self.isRoom];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[WZBlueToothDataManager shareInstance]modifyAlarmToDevice:self.devAddr isGroup:self.isRoom WithAlarmInfo:self.yInfo];
            });
            [SVProgressHUD showSuccessWithStatus:LCSTR("夜节律设置成功")];
        }
    });


}

- (void)setAlarmInfo:(AlarmInfo *)info{


   
}
#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        WSTCircadianSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSTCircadianSwitchCell" forIndexPath:indexPath];
        [cell cellRefreshWith:indexPath andZinfo:self.zInfo yInfo:self.yInfo];
        cell.pressSwitch = ^(BOOL isOn) {
            if (indexPath.section == 0) {
                self.zInfo.actionAndModel = isOn == YES?146:18; //开关
            }else{
                self.yInfo.actionAndModel = isOn == YES?146:18; //开关
            }
        };
        return cell;
    }else{
        WSTCircadianTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSTCircadianTimeCell" forIndexPath:indexPath];
        [cell cellRefreshWith:indexPath andZInfo:self.zInfo yInfo:self.yInfo];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.currentSection = indexPath.section;
    if (indexPath.row == 1) {
        if (self.datePickerView) {
            [self.datePickerView addWithSuperView:self.view];
            [_datePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }
    }else if (indexPath.row ==2){
        if (self.timePickerView) {
            [self.timePickerView addWithSuperView:self.view];
            [_timePickerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
#pragma mark - 布局
- (void)masLayoutSubview{
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).mas_offset(10);
        make.right.equalTo(self.view).mas_offset(-10);
        if (@available(iOS 11.0, *)) {
            make.top.bottom.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
            make.top.bottom.equalTo(self.view);
        }
    }];
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
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
        
        [_tableView registerNib:[UINib nibWithNibName:@"WSTCircadianTimeCell" bundle:nil] forCellReuseIdentifier:@"WSTCircadianTimeCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"WSTCircadianSwitchCell" bundle:nil] forCellReuseIdentifier:@"WSTCircadianSwitchCell"];
    }
    return _tableView;
}
@end
