//
//  TuyaSmartBlueMeshGroupModel.h
//  TuyaSmartKit
//
//  Created by XuChengcheng on 2017/7/10.
//  Copyright © 2017年 Tuya. All rights reserved.
//

#import "TYModel.h"

@interface TuyaSmartBlueMeshGroupModel : TYModel

//meshGroup名称
@property (nonatomic, strong) NSString     *name;

//mesh Group 云端标识
@property (nonatomic, assign) NSInteger    groupId;

//产品ID
@property (nonatomic, strong) NSString     *productId;

//群组的本地短地址
@property (nonatomic, strong) NSString     *localId;


@end
