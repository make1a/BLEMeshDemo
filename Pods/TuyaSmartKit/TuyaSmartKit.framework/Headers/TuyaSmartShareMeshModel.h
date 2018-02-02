//
//  TuyaSmartShareMeshModel.h
//  TuyaSmartKit
//
//  Created by XuChengcheng on 2017/9/20.
//  Copyright © 2017年 Tuya. All rights reserved.
//


@interface TuyaSmartShareMeshModel : TYModel

/**
 *  设备图标地址
 */
@property (nonatomic, strong) NSString *iconUrl;

/**
 *  mesh Id
 */
@property (nonatomic, strong) NSString *meshId;

/**
 *  名称
 */
@property (nonatomic, strong) NSString *name;

/**
 *  是否分享
 */
@property (nonatomic, assign) BOOL share;

@end
