//
//  TuyaSmartBlueMeshGroup.h
//  TuyaSmartKit
//
//  Created by XuChengcheng on 2017/7/10.
//  Copyright © 2017年 Tuya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuyaSmartBlueMeshSubDeviceModel.h"

@interface TuyaSmartBlueMeshGroup : NSObject

/**
 获取mesh群组对象
 
 @param groupId 群组Id
 */
+ (instancetype)meshGroupWithGroupId:(NSInteger)groupId;

/**
 获取mesh群组对象
 
 @param groupId 群组Id
 */
- (instancetype)initWithGroupId:(NSInteger)groupId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 创建mesh群组
 
 @param groupName mesh群组名字
 @param meshId    meshId
 @param localId   群组的本地短地址
 @param success 操作成功回调 GroupId
 @param failure 操作失败回调
 */
+ (void)createMeshGroupWithGroupName:(NSString *)groupName meshId:(NSString *)meshId localId:(NSString *)localId success:(TYSuccessInt)success failure:(TYFailureError)failure;

///**
// 获取群组下的子设备信息
// 
// @param success 操作成功回调
// @param failure 操作失败回调
// */
//- (void)getSubDeviceListFromGroupWithSuccess:(void (^)(NSArray <TuyaSmartBlueMeshSubDeviceModel *> *subDeviceList))success failure:(TYFailureError)failure;


/**
 修改mesh群组名字
 
 @param meshGroupName meshGroup名称
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)updateMeshGroupName:(NSString *)meshGroupName success:(TYSuccessHandler)success failure:(TYFailureError)failure;


/**
 删除mesh群组
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)removeMeshGroupWithSuccess:(TYSuccessHandler)success failure:(TYFailureError)failure;

/**
 添加设备
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)addDeviceWithDeviceId:(NSString *)deviceId success:(TYSuccessHandler)success failure:(TYFailureError)failure;

/**
 移除设备
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)removeDeviceWithDeviceId:(NSString *)deviceId success:(TYSuccessHandler)success failure:(TYFailureError)failure;

/**
 获取群组中设备list信息
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)getDeviveListInfoWithSuccess:(void (^)(NSArray <TuyaSmartBlueMeshSubDeviceModel *> *deviceList))success failure:(TYFailureError)failure;


@end
