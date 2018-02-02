//
//  TuyaSmartBlueMesh.h
//  TuyaSmartKit
//
//  Created by XuChengcheng on 2017/6/7.
//  Copyright © 2017年 Tuya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuyaSmartBlueMeshModel.h"
#import "TuyaSmartBlueMeshGroupModel.h"
#import "TuyaSmartBlueMeshRoomModel.h"

@protocol TuyaSmartBlueMeshDelegate<NSObject>
@optional

/// dp数据更新
- (void)subDeviceDpsUpdate:(NSDictionary *)dic;

/// 子设备信息变更（上下线）
- (void)deviceInfoOnlineListUpdate:(NSDictionary *)dic;

/// 收到raw透传指令
- (void)blueMeshReceiveRawDataDic:(NSDictionary *)rawDic;

@end

@interface TuyaSmartBlueMesh : NSObject

@property (nonatomic, strong, readonly) TuyaSmartBlueMeshModel *blueMeshModel;
@property (nonatomic, strong) NSArray <TuyaSmartBlueMeshSubDeviceModel *> *subDeviceList;
@property (nonatomic, strong) NSArray <TuyaSmartBlueMeshGroupModel *> *meshGroupList;
@property (nonatomic, strong) NSArray <TuyaSmartBlueMeshRoomModel *> *roomList;
@property (nonatomic, weak) id<TuyaSmartBlueMeshDelegate> delegate;

/** 
 获取设备对象
 
 @param devId 设备Id
 */
+ (instancetype)blueMeshWithMeshId:(NSString *)meshId;

/** 
 获取设备对象
 
 @param devId 设备Id
 */
- (instancetype)initWithMeshId:(NSString *)meshId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 创建mesh
 
 @param meshName mesh名字
 @param success 操作成功回调 meshId
 @param failure 操作失败回调
 */
+ (void)createBlueMeshWithMeshName:(NSString *)meshName success:(void(^)(NSString *meshId))success failure:(TYFailureError)failure;

/** 
 获取mesh的子设备信息
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)getSubDeviceListFromCloudWithSuccess:(void (^)(NSArray <TuyaSmartBlueMeshSubDeviceModel *> *subDeviceList))success failure:(TYFailureError)failure;

/**
 获取单个网关下的子设备信息
 
 @param DeviceId 网关ID
 查询设备的标识，如果mesh子设备，填短地址，wifi单品填设备的id
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)getSubDeviceFromCloudWithDeviceId:(NSString *)deviceId success:(void (^)(TuyaSmartBlueMeshSubDeviceModel *subDeviceModel))success failure:(TYFailureError)failure;

/** 
 单个子设备dps命令下发
 
 @param nodeId 蓝牙子设备短地址标识
 @param dps 命令字典
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)publishNodeId:(NSString *)nodeId
                  dps:(NSDictionary *)dps
              success:(TYSuccessHandler)success
              failure:(TYFailureError)failure;

/**
 广播dps命令下发
 
 @param dps 命令字典
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)broadcastDps:(NSDictionary *)dps
             success:(TYSuccessHandler)success
             failure:(TYFailureError)failure;



/** 
 获取子设备的最新dps信息
 
 @param nodeId 蓝牙子设备短地址标识
 @param dpIdList dps 中 key 的 list
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)getSubDeviceDpsWithNodeId:(NSString *)nodeId
                         dpIdList:(NSArray <NSNumber *> *)dpIdList
                          success:(TYSuccessHandler)success
                          failure:(TYFailureError)failure;


/**
 给设备发送透传指令

 @param raw 透传值
 @param success 操作成功的回调
 @param failure 操作失败的回调
 */
- (void)publishRawDataWithRaw:(NSString *)raw
                      success:(TYSuccessHandler)success
                      failure:(TYFailureError)failure;

/**
 群控设备
 
 @param 群控id    localId
 @param dps      命令字典
 @param success 操作成功的回调
 @param failure 操作失败的回调
 */
- (void)multiPublishWithLocalId:(NSString *)localId
                            dps:(NSDictionary *)dps
                        success:(TYSuccessHandler)success
                        failure:(TYFailureError)failure;

/** 
 修改mesh名称
 
 @param meshName mesh名称
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)updateMeshName:(NSString *)meshName success:(TYSuccessHandler)success failure:(TYFailureError)failure;

/** 
 删除mesh，如果mesh组下有设备，子设备也移除掉。wifi连接器也一并移除掉。
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)removeMeshWithSuccess:(TYSuccessHandler)success failure:(TYFailureError)failure;

/**
 蓝牙设备入网

 @param uuid        蓝牙子设备短地址标识
 @param nodeId      mesh节点id（短地址）
 @param productKey  产品ID
 @param ver         版本号
 @param success     操作成功回调
 @param failure     操作失败回调
 */
- (void)addSubDeviceWithUuid:(NSString *)uuid
                      nodeId:(NSString *)nodeId
                  productKey:(NSString *)productKey
                         ver:(NSString *)ver
                     success:(void (^)(NSString *devId, NSString *name))success
                     failure:(TYFailureError)failure;

/**
 重命名mesh子设备
 
 @param deviceId    设备ID
 @param name        新的名字
 @param success     操作成功回调
 @param failure     操作失败回调
 */
- (void)renameMeshSubDeviceWithDeviceId:(NSString *)deviceId name:(NSString *)name success:(TYSuccessHandler)success failure:(TYFailureError)failure;

/**
 移除mesh子设备
 
 @param deviceId    设备ID
 @param success     操作成功回调
 @param failure     操作失败回调
 */
- (void)removeMeshSubDeviceWithDeviceId:(NSString *)deviceId success:(TYSuccessHandler)success failure:(TYFailureError)failure;

/**
 获取mesh中群组和房间的list信息
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)getMeshGroupRoomInfoWithSuccess:(void (^)(NSArray <TuyaSmartBlueMeshGroupModel *> *groupList, NSArray <TuyaSmartBlueMeshRoomModel *> *roomList))success failure:(TYFailureError)failure;



@end
