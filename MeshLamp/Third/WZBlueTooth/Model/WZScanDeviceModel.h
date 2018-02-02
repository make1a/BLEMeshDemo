//
//  WZScanDeviceModel.h
//  WZBlueToothDemo
//
//  Created by 微智电子 on 2017/9/14.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WZDeviceModel.h"
#import "FFDataBaseModel.h"
@class CBPeripheral;


@interface WZScanDeviceModel : FFDataBaseModel
@property (nonatomic,strong) CBPeripheral *per;
@property (nonatomic,copy) NSString *compound;
@property (nonatomic, strong) NSString *home; // 设备名称
@property (nonatomic, assign) int address; // meshId
@property (nonatomic, strong) NSString  *devModel;          // Mesh UUID, 设备类型标识， 用来判断设备类型
@end
