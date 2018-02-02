//
//  TuyaSmartBlueMeshModel.h
//  TuyaSmartKit
//
//  Created by XuChengcheng on 2017/6/7.
//  Copyright © 2017年 Tuya. All rights reserved.
//

#ifndef TuyaSmart_TuyaSmartBlueMeshModel
#define TuyaSmart_TuyaSmartBlueMeshModel

#import "TYModel.h"

@interface TuyaSmartBlueMeshModel : TYModel

//mesh网络名称
@property (nonatomic, strong) NSString     *name;

//mesh网络云端标识
@property (nonatomic, strong) NSString     *meshId;

//localKey
@property (nonatomic, strong) NSString     *localKey;

//pv
@property (nonatomic, strong) NSString     *pv;


@end

#endif
