//
//  TuyaSmartBlueMeshRoomModel.h
//  TuyaSmartKit
//
//  Created by XuChengcheng on 2017/7/10.
//  Copyright © 2017年 Tuya. All rights reserved.
//

#import "TYModel.h"

@interface TuyaSmartBlueMeshRoomModel : TYModel

//meshRoom名称
@property (nonatomic, strong) NSString     *name;

//mesh Group 云端标识
@property (nonatomic, assign) NSInteger    roomId;


@end
