//
//  MKBlueToothDataManager.h
//  MKBabyBlueDemo
//
//  Created by 微智电子 on 2017/9/7.
//  Copyright © 2017年 微智电子. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WZBlueToothManager.h"
#import "WZBLEDataModel.h"

@protocol WZBlueToothDataSource

@optional
/**
 设备状态更新
 */
- (void)updateDeviceStatus;

/**
 设备状态更新 需两个方法一起调用
 */
- (void)responseOfUserCustomData;

- (void)responseOfDeviceHasGroupsArray:(GroupInfo*)info;

/**
 设备灯珠状态的通知信息

 @param status [tempArr addObject:@(status)];
 */
- (void)responseOfDeviceStatus:(NSArray *)status;


/**
 获取场景信息的回调
 */
- (void)responseOfSceneInfo:(SceneInfo *)info;

/**
  接收到设备的firewareVersion

 @param data data
 */
- (void)deviceFirmWareData:(NSData *)data;
@end


@interface WZBlueToothDataManager : NSObject

/**登陆状态 */
@property (nonatomic,assign,readonly) BOOL isLogin;

//@property (nonatomic, assign) BTCommand btCMDType;
/**新网络的名称 */
@property (nonatomic,copy) NSString *netWorkNameNew;
/**新密码 */
@property (nonatomic,copy) NSString *netWorkPwdNew;

/**WZBlueToothDataSource */
@property (nonatomic,weak) id delegate;

+ (WZBlueToothDataManager *)shareInstance;

/**
 处理UpdateValueForCharacteristicDataf返回的数据
 */
- (void)handleUpdateValueForCharacteristicData:(CBCharacteristic *)characteristic perpheral:(CBPeripheral *)perpheral;


/**
 登陆
 
 @param peripheral 当前外设
 @param userName userName
 @param pwd pwd
 */
-(void)loginPeripheral:(CBPeripheral *)peripheral withUserName:(NSString *)userName pwd:(NSString *)pwd;

/**
 设置新网络

 @param name 新网络名字
 @param pwd pwd
 */
- (void)setNewNetworkName:(NSString *)name andPwd:(NSString *)pwd;

/**
 获取当前mesh网络内的设备
 
 @param on 是否按照在带线状态过滤
 @return YES- 只获取在线设备 NO-获取所有设备
 */
- (NSArray <WZBLEDataModel *> *)getCurrentDevicesWithOnlie:(BOOL)on;

/**
 主动去获取用户自定义数据，设备类型、等亮度等等
 */
- (void)getModelWithDataBaseOrDevice;


/** 获取用户自定义数据，设备类型、等亮度等等 */
- (void)getUserCustomDataWith:(uint32_t)u_Address;

/**
 踢出网络

 @param destinateAddress 地址
 */
- (void)kickoutLightFromMeshWithDestinateAddress:(uint32_t)destinateAddress;
/**
 定位灯

 @param u_Address 地址
 */
- (void)locateTheDevice:(uint32_t)u_Address;

/**
 获取设备状态

 @param peripheral 当前外设
 */
- (void)openMeshLightStatus:(CBPeripheral *)peripheral;

/**
 *单灯的开灯－－－传入设备地址
 */

-(void)turnOnCertainLightWithAddress:(uint32_t )u_DevAddress;
-(void)turnOffCertainLightWithAddress:(uint32_t )u_DevAddress;


/**
 获取设备的地址，或者获取群组内的设备地址

 @param u_Address 设备地址 or 群组地址
 @param isGroup BOOL
 */
- (void)getDeviceAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup;

/**
 *组的开灯－－－传入组地址
 */
-(void)turnOnCertainGroupWithAddress:(uint32_t )u_GroupAddress;
-(void)turnOffCertainGroupWithAddress:(uint32_t )u_GroupAddress;

/**
 *加组－－－传入待加灯的地址，和 待加入的组的地址
 */
-(void)addDevice:(uint32_t)targetDeviceAddress isGroup:(BOOL)isGroup ToDestinateGroupAddress:(uint32_t)groupAddress;
- (void)deleteDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup ToDestinateGroupAddress:(uint32_t)groupAddress;

/**
 获取设备加入的所有群组

 @param u_Address 设备的地址
 */
- (void)getAllGroupAddressWithDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup;

/**
 将所有设备置为离线状态
 */
- (void)setAllDeviceOffline;
- (void)turnOnAllLight;
- (void)turnOffAllLight;

/**
 获取单个灯的详细信息
 
 @param u_Address 设备地址
 */
- (void)getDeviceStatusWith:(uint32_t)u_Address;

/**音乐开始*/
- (void)musicStartWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup;
/**音乐结束*/
- (void)musicStopWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup;


/**
 设置内置模式
 */
- (void)setModeWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup andMode:(float)mode Delay:(NSInteger)delay;
#pragma mark - 设置颜色
//控制所有 u_Address =   0xffff
- (void)setBrightnessWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup Brightness:(CGFloat)brightness;

// 设置 RGBWC 值
- (void)setRGBWCWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue Warm:(CGFloat)warm Cold:(CGFloat)cold Lum:(CGFloat)lum Delay:(NSInteger)delay;
// 根据color值设置
- (void)setRGBWithAddress:(uint32_t)u_Address IsGroup:(BOOL)isGroup color:(UIColor *)color brightness:(CGFloat)brightness warm:(CGFloat)warm cold:(CGFloat)cold lum:(CGFloat)lum Delay:(NSInteger)delay;
// 设置 RGB 值
- (void)setRGBWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue Delay:(NSInteger)delay;

// 根据 HSB 设置 RGBWC 值
- (void)setHSBWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithHue:(CGFloat)hue Saturation:(CGFloat)sat Brightness:(CGFloat)brt Warm:(CGFloat)warm Cold:(CGFloat)cold Lum:(CGFloat)lum Delay:(NSInteger)delay;
// 根据 HSB 设置 RGB 值
- (void)setHSBWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithHue:(CGFloat)hue Saturation:(CGFloat)sat Brightness:(CGFloat)brt Delay:(NSInteger)delay;

// 设置红色
- (void)setRedWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithRed:(CGFloat)red Delay:(NSInteger)delay;

// 设置绿色
- (void)setGreenWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithGreen:(CGFloat)green Delay:(NSInteger)delay;

// 设置蓝色
- (void)setBlueWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithBlue:(CGFloat)blue Delay:(NSInteger)delay;

// 设置暖色值
- (void)setWarmWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithWarm:(CGFloat)warm Delay:(NSInteger)delay;

// 设置冷色值
- (void)setColdWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithCold:(CGFloat)cold Delay:(NSInteger)delay;

// 设置冷暖值
- (void)setWCWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithWarm:(CGFloat)warm Cold:(CGFloat)cold Delay:(NSInteger)delay;

#pragma mark - 闹钟场景
// 设置设备的标准时间
- (void)setTheDeviceTime:(uint32_t)u_Address isGroup:(BOOL)isGroup;
// 获取设备标准时间
- (void)getTheDeviceTime:(uint32_t)u_Address;
/**
 获取闹钟信息
 @param u_Address 设备地址
 @param alarmId 闹钟 ID
 */
- (void)getAlarmInfo:(uint32_t)u_Address isGroup:(BOOL)isGroup AlarmID:(int)alarmId;
// 添加闹钟
- (void)addAlarmToDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup WithAlarmInfo:(AlarmInfo *)info;
// 修改闹钟
- (void)modifyAlarmToDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup WithAlarmInfo:(AlarmInfo *)info;
// 删除闹钟
- (void)deleteAlarmToDevice:(uint32_t)u_Address  isGroup:(BOOL)isGroup WithIndex:(int)index;
// 打开闹钟
- (void)openAlarmToDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup WithIndex:(int)index;
// 关闭闹钟
- (void)closeAlarmToDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup WithIndex:(int)index;
// 添加场景
- (void)addSceneWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithSceneInfo:(SceneInfo *)info;
// 删除场景
- (void)deleteSceneWithAddress:(uint32_t)u_Address  isGroup:(BOOL)isGroup WithSceneId:(int)sceneId;
//将场景从所有设备删除
- (void)deleteSceneFromAllDevice:(int)sceneId;
// 加载场景
- (void)loadSceneWithSceneId:(int)sceneId;
// 获取场景数据
- (void)getSceneDataToDevice:(uint32_t)u_Address  isGroup:(BOOL)isGroup WithSceneId:(int)sceneId;
//- (void)addSensorInfoToDevice:(uint32_t)senAddr With:(SensorInfo *)info;

#pragma mark -OTA
- (void)sendOTAPack:(NSData *)data isFirst:(BOOL)isFirst;
- (void)readDeviceFirmwareVersion:(uint32_t)devAddr;
@end
