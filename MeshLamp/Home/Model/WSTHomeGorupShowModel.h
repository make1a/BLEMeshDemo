//
//  WSTHomeGorupShowModel.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/30.
//  Copyright © 2017年 make. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSTHomeGorupShowModel : FFDataBaseModel
/**显示item个数 */
@property (nonatomic,assign) int item;
/**名称 */
@property (nonatomic,copy) NSString *name;
/**图片name */
@property (nonatomic,copy) NSString *imageStr;
/** 序列号从0开始 */
@property (nonatomic,assign) NSInteger serialNumber;
/**群组地址*/
@property (nonatomic,assign) int groupAddress;
/**成员 */
@property (nonatomic,assign) BOOL isMembership;
/**home*/
@property (nonatomic,strong) NSString *homeName;
//self.groupAddress = (int)(0x8011+count);

+ (WSTHomeGorupShowModel *)insertDefaultGroup;

/**
 删除群组以及群组内的所有设备

 @param model 要删除的群组
 */
+ (void)deleteGroup:(WSTHomeGorupShowModel*)model;
/**
 添加自定义群组
 */
+ (WSTHomeGorupShowModel *)addGroupAndInsertDB;
@end

@interface WSTGroupDevice :FFDataBaseModel
/**群组地址*/
@property (nonatomic,assign) int groupAddress;
/**device mesh id*/
@property (nonatomic,assign) int deviceAddress;
/**device home name */
@property (nonatomic,copy)  NSString *homeName;
+(void)deleteFromDB:(int)deviceAddress;
+(void)insertFromDB:(int)deviceAddress;
+(NSArray<WZBLEDataModel*> *)getCurrentGroupDevices;
+(NSArray *)getCureentGroupNotAddDevices:(NSArray*)currenDevices allDevices:(NSArray*)allDevices;
@end


#pragma mark - 遥控器按键
@interface WSTGroupKey :FFDataBaseModel
/**群组地址*/
@property (nonatomic,assign) int groupAddress;
/**device mesh id*/
@property (nonatomic,assign) int deviceAddress;
/**device home name */
@property (nonatomic,copy)  NSString *homeName;
+(void)deleteFromDB:(int)deviceAddress;
+(void)insertFromDB:(int)deviceAddress;
+(NSArray<WSTGroupKey*> *)getCurrentKeyDevices;

@end
