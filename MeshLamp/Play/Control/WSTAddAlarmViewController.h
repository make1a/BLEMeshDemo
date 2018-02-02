//
//  WSTAddAlarmViewController.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "BaseViewController.h"

@interface WSTAddAlarmViewController : BaseViewController
@property (nonatomic) BOOL          isRoom;
@property (nonatomic) int     devAddr;
/**是否编辑 */
@property (nonatomic,assign) BOOL isEdit;
/**ala*/
@property (nonatomic,strong) AlarmInfo *currentAlarm;

@end
