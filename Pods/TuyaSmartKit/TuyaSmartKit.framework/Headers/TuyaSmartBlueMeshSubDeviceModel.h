//
//  TuyaSmartBlueMeshSubDeviceModel.h
//  TuyaSmartKit
//
//  Created by XuChengcheng on 2017/6/8.
//  Copyright © 2017年 Tuya. All rights reserved.
//

#ifndef TuyaSmart_TuyaSmartBlueMeshSubDeviceModel
#define TuyaSmart_TuyaSmartBlueMeshSubDeviceModel

#import "TYModel.h"

@interface TuyaSmartBlueMeshSubDeviceBluetoothModel : TYModel

@property (nonatomic, assign) BOOL     isOnline;
@property (nonatomic, strong) NSString *verSw;

@end

@interface TuyaSmartBlueMeshSubDeviceWifiModel : TYModel

@property (nonatomic, assign) BOOL         isOnline;
@property (nonatomic, strong) NSString     *bv;
@property (nonatomic, strong) NSString     *pv;
@property (nonatomic, strong) NSString     *verSw;

@end

@interface TuyaSmartBlueMeshSubDeviceModuleModel : TYModel

@property (nonatomic, strong) TuyaSmartBlueMeshSubDeviceWifiModel           *wifi;
@property (nonatomic, strong) TuyaSmartBlueMeshSubDeviceBluetoothModel      *bluetooth;

@end


@interface TuyaSmartBlueMeshSubDeviceModel : TYModel

@property (nonatomic, assign) long long    activeTime;

@property (nonatomic, strong) NSString     *devId;

@property (nonatomic, strong) NSDictionary *dps;

@property (nonatomic, strong) NSString     *icon;

@property (nonatomic, strong) NSString     *localKey;

@property (nonatomic, strong) NSString     *name;

@property (nonatomic, strong) NSString     *nodeId;

@property (nonatomic, strong) NSString     *productId;

@property (nonatomic, strong) TuyaSmartBlueMeshSubDeviceModuleModel *moduleMap;


@end

#endif
