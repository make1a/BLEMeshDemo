//
//  TuyaSmartBlueMeshRoom.h
//  TuyaSmartKit
//
//  Created by XuChengcheng on 2017/7/10.
//  Copyright © 2017年 Tuya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TuyaSmartBlueMeshRoom : NSObject

/**
 获取mesh room 对象
 
 @param roomId
 */
+ (instancetype)meshRoomWithRoomId:(NSInteger)roomId;

/**
 获取room 对象
 
 @param roomId
 */
- (instancetype)initWithRoomId:(NSInteger)roomId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

+ (void)createMeshRoomWithName:(NSString *)name meshId:(NSString *)meshId success:(TYSuccessInt)success failure:(TYFailureError)failure;

/**
 修改room
 
 @param meshRoomName meshRoom名称
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)updateMeshRoomName:(NSString *)meshRoomName success:(TYSuccessHandler)success failure:(TYFailureError)failure;


/**
 删除room
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)removeMeshRoomWithSuccess:(TYSuccessHandler)success failure:(TYFailureError)failure;

/**
 添加群组
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)addMeshGroupWithGroupId:(NSInteger)groupId success:(TYSuccessHandler)success failure:(TYFailureError)failure;

/**
 移除群组
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)removeMeshGroupWithGroupId:(NSInteger)groupId success:(TYSuccessHandler)success failure:(TYFailureError)failure;

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
 获取room中群组和设备list信息
 
 @param success 操作成功回调
 @param failure 操作失败回调
 */
- (void)getDeviceGroupInfoWithSuccess:(void (^)(NSArray <TuyaSmartBlueMeshGroupModel *> *groupList, NSArray <TuyaSmartBlueMeshSubDeviceModel *> *deviceList))success failure:(TYFailureError)failure;

@end
