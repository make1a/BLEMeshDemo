//
//  AppDelegate.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/29.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSTHomeGorupShowModel.h"
#import "WZBLEDataModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**当前编辑的群组*/
@property (nonatomic,strong) WSTHomeGorupShowModel *currentGroup;
/**当前编辑的设备*/
@property (nonatomic,strong) WZBLEDataModel *currentDevice;
//适配copy的一些代码
@property (nonatomic)CGFloat scale;
+ (AppDelegate *)instance;
@end

