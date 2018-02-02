//
//  WSTControlViewController.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/12.
//  Copyright © 2017年 make. All rights reserved.
//

#import "BaseViewController.h"

@interface WSTControlViewController : BaseViewController
/**是否是群组 */
@property (nonatomic,assign) BOOL isRoom;
@property (nonatomic) int     devAddr;

@end
