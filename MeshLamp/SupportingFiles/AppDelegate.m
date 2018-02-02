//
//  AppDelegate.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/29.
//  Copyright © 2017年 make. All rights reserved.
//

#import "AppDelegate.h"
#import "WSTHomeViewController.h"

#import <Bugly/Bugly.h>
#import "AppDelegate+Language.h"
#import "MLSignInViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        WSTHomeViewController *vc = [[WSTHomeViewController alloc]init];
        RTRootNavigationController *nav = [[RTRootNavigationController alloc]initWithRootViewController:vc];
        self.window.rootViewController = nav;
    /*
    if ([TuyaSmartUser sharedInstance].isLogin) {
    }else{
        MLSignInViewController * vc = [[MLSignInViewController alloc]init];
        RTRootNavigationController *nav = [[RTRootNavigationController alloc]initWithRootViewController:vc];
        self.window.rootViewController = nav;
    }
     */
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setLanguage];
    [self setIFlySetting];
    [self sbCode];
    
    [[TuyaSmartSDK sharedInstance] startWithAppKey:@"7pqfj5m77jpt8aq74hwa" secretKey:@"enpp4jfqxndthrxepjvpfcfmf7us5wme"];
    [Bugly startWithAppId:@"09c3ef972e"];
    return YES;
}

- (void)sbCode{
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    CGFloat sizeInch = sqrt((pow(sw / 163, 2) + pow(sh / 163, 2)));
    
    if (sizeInch < 4.8) {
        _scale = 1.0;
    } else if (sizeInch < 5.6) {
        _scale = 1.1;
    } else if (sizeInch < 8.0) {
        _scale = 1.3;
    } else if (sizeInch < 11.0) {
        _scale = 1.5;
    } else if (sizeInch < 14.0) {
        _scale = 1.6;
    } else if (sizeInch < 20.0) {
        _scale = 2.0;
    } else {
        _scale = 2.4;
    }
}
+ (AppDelegate *)instance {
    return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationUpdateDeviceStatus object:nil];
    });
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
