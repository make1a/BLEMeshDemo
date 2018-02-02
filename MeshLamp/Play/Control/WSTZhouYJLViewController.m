//
//  WSTZhouYJLViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/11/14.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTZhouYJLViewController.h"
#import "WSTSettingZYJLViewController.h"
@interface WSTZhouYJLViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *zSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *ySwitch;
@property (weak, nonatomic) IBOutlet UILabel *ztimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *zdurationLabel;

@property (weak, nonatomic) IBOutlet UILabel *ytimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ydurationLabel;
@end

@implementation WSTZhouYJLViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
}
- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("dayAndNight") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
}

#pragma mark - data
- (void)getInfo{

    NSString *zStr = [NSString stringWithFormat:@"where sceneId = '15' and homeName = '%@' and addrL = '%d'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],self.devAddr];
    NSString *yStr = [NSString stringWithFormat:@"where sceneId = '16' and homeName = '%@' and addrL = '%d'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],self.devAddr];
    NSArray *zArray = [AlarmInfo selectFromClassPredicateWithFormat:zStr];
    NSArray *yArray = [AlarmInfo selectFromClassPredicateWithFormat:yStr];
    if (zArray.count > 0) { //存在
        AlarmInfo *zInfo = zArray.firstObject;
        NSString *enableBinary = [NSString decimalToBinary:[zArray.firstObject actionAndModel]];
        NSString *bit7 = [enableBinary substringWithRange:NSMakeRange(0, 1)]; //使能
        [self.zSwitch setOn:[bit7 intValue] animated:YES];
        if (zInfo.hour == -1) {
            self.ztimeLabel.text = LCSTR("please_choose");
        }else{
            self.ztimeLabel.text =  [NSString stringWithFormat:@"%@:%@",[NSString padingZero:[NSString stringWithFormat:@"%d",zInfo.hour] length:2],[NSString padingZero:[NSString stringWithFormat:@"%d",zInfo.minute] length:2]];
        }
        if (zInfo.duration == -1) {
            self.zdurationLabel.text = @"";
        }else{
            self.zdurationLabel.text = [NSString stringWithFormat:@"%@%d%@",LCSTR("day_durtime_time"),zInfo.duration,LCSTR("minute")];
            
        }
        
    }else{ //为空
        self.ztimeLabel.text = LCSTR("please_choose");
        [self.zSwitch setOn:NO];
        self.zdurationLabel.text = @"";
    }
    AlarmInfo *yInfo = yArray.firstObject;
    
    if (yInfo) { //存在
        NSString *enableBinary = [NSString decimalToBinary:[yArray.firstObject actionAndModel]];
        NSString *bit7 = [enableBinary substringWithRange:NSMakeRange(0, 1)]; //使能
        [self.ySwitch setOn:[bit7 intValue] animated:YES];
        if (yInfo.hour == -1) {
            self.ytimeLabel.text = LCSTR("please_choose");
        }else{
            self.ytimeLabel.text =  [NSString stringWithFormat:@"%@:%@",[NSString padingZero:[NSString stringWithFormat:@"%d",yInfo.hour] length:2],[NSString padingZero:[NSString stringWithFormat:@"%d",yInfo.minute] length:2]];
        }
        if (yInfo.duration == -1) {
            self.ydurationLabel.text = @"";
        }else{
            self.ydurationLabel.text = [NSString stringWithFormat:@"%@%d%@",LCSTR("day_durtime_time"),yInfo.duration,LCSTR("minute")];
        }
        
    }else{  //为空
        self.ytimeLabel.text = LCSTR("please_choose");
        [self.ySwitch setOn:NO];
        self.ydurationLabel.text = @"";
    }
}
#pragma mark - actions
- (IBAction)clickZhouJL:(UIControl *)sender {
    WSTSettingZYJLViewController *vc = [[WSTSettingZYJLViewController alloc]initWithNibName:@"WSTSettingZYJLViewController" bundle:nil];
    vc.isDay = YES;
    vc.isRoom = self.isRoom;
    vc.devAddr = self.devAddr;
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)clickYeJL:(id)sender {
    WSTSettingZYJLViewController *vc = [[WSTSettingZYJLViewController alloc]initWithNibName:@"WSTSettingZYJLViewController" bundle:nil];
    vc.isDay = NO;
    vc.isRoom = self.isRoom;
    vc.devAddr = self.devAddr;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)zOnOff:(UISwitch *)sender {
    NSString *zStr = [NSString stringWithFormat:@"where sceneId = '15' and homeName = '%@' and addrL = '%d'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],self.devAddr];
    AlarmInfo *zInfo = [AlarmInfo selectFromClassPredicateWithFormat:zStr].firstObject;
    
    if (zInfo && zInfo.hour!=-1 && zInfo.duration != -1) { //存在
        if (sender.isOn) {
            zInfo.actionAndModel = 18;
        }else{
            zInfo.actionAndModel = 146;
        }
        [zInfo updateObject];
        [[WZBlueToothDataManager shareInstance]setTheDeviceTime:self.devAddr isGroup:self.isRoom];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[WZBlueToothDataManager shareInstance]modifyAlarmToDevice:self.devAddr isGroup:self.isRoom WithAlarmInfo:zInfo];
        });
    }else{
        sender.on = NO;
    }
}
- (IBAction)yOnOff:(UISwitch *)sender {
    NSString *zStr = [NSString stringWithFormat:@"where sceneId = '16' and homeName = '%@' and addrL = '%d'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],self.devAddr];
    AlarmInfo *zInfo = [AlarmInfo selectFromClassPredicateWithFormat:zStr].firstObject;
    
    if (zInfo && zInfo.hour!=-1 && zInfo.duration != -1) { //存在
        if (sender.isOn) {
            zInfo.actionAndModel = 18;
        }else{
            zInfo.actionAndModel = 146;
        }
        [zInfo updateObject];
        [[WZBlueToothDataManager shareInstance]setTheDeviceTime:self.devAddr isGroup:self.isRoom];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[WZBlueToothDataManager shareInstance]modifyAlarmToDevice:self.devAddr isGroup:self.isRoom WithAlarmInfo:zInfo];
        });
    }else{
        sender.on = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
