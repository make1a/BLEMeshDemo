//
//  AppDelegate+Language.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/31.
//  Copyright © 2017年 make. All rights reserved.
//

#import "AppDelegate+Language.h"
#import "IQKeyboardManager.h"
#import "NSBundle+Language.h"
#import <iflyMSC/iflyMSC.h>
@implementation AppDelegate (Language)
- (void)setLanguage{
    // 加载用户设置的语言
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"] && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"] isEqualToString:@""]) {
        [NSBundle setLanguage:[[NSUserDefaults standardUserDefaults] objectForKey:@"myLanguage"]];
    }
    
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 70;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:0.5];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
}
- (void)setIFlySetting{
    [IFlySpeechUtility createUtility:@"appid=59f7e41d"];
}
@end
