//
//  WSTHomeGorupShowModel.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/30.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTHomeGorupShowModel.h"


#pragma mark - WSTHomeGorupShowModel
@implementation WSTHomeGorupShowModel

+(WSTHomeGorupShowModel *)addGroupAndInsertDB{

   WSTHomeGorupShowModel *model = [[WSTHomeGorupShowModel alloc]init];
    model.homeName = [[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
    model.name = @"group";
    model.serialNumber = [WSTHomeGorupShowModel getAddrIndex];
    model.name = [NSString stringWithFormat:@"%@%d",LCSTR("group"),(int)model.serialNumber];
    model.item = 1;
    model.imageStr = @"groupList_icon_allGroup";
    model.groupAddress = (int)(0x8011+model.serialNumber);
    [model insertObject];
    return model;
}

+ (WSTHomeGorupShowModel *)insertDefaultGroup{
    WSTHomeGorupShowModel *model = [[WSTHomeGorupShowModel alloc]init];
    model.homeName = [[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
    model.name = @"all_device";
    model.serialNumber = 0;
    model.item = 1;
    model.imageStr = @"allDevice_icon_on";
    model.groupAddress = 0xffff;
    [model insertObject];
    return model;
}

+ (void)deleteGroup:(WSTHomeGorupShowModel*)model{
    NSString *str = [NSString stringWithFormat:@"where groupAddress = '%d' and homeName = '%@'",model.groupAddress,[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName]];
    [WSTGroupDevice deleteFromClassPredicateWithFormat:str];
    [model deleteObject];
    [WSTGroupKey deleteFromClassPredicateWithFormat:str];

    for (int i = 1; i<11; i++) { //删除绑定的遥控器按键
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[WZBlueToothDataManager shareInstance]deleteDevice:model.groupAddress isGroup:YES ToDestinateGroupAddress:0x8000+i];
            if (i ==10) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[WZBlueToothDataManager shareInstance]deleteDevice:model.groupAddress isGroup:YES ToDestinateGroupAddress:model.groupAddress];
                });
            }
        });

    }
    
}


+ (NSInteger)getAddrIndex {
    NSArray *array = [[WSTHomeGorupShowModel selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where homeName = '%@'",[[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName]]] mutableCopy];
    if (array.count > 0) {
        int index = 1;
        for (int i = 1; i < 255; i++) {
            BOOL isExist = NO;
            for (WSTHomeGorupShowModel *item in array) {
                if (item.serialNumber == i) {
                    isExist = YES;
                    break;
                }
            }
            if (isExist == NO) {
                index = i;
                break;
            }
        }
        return index;
    } else {
        return 1;
    }
}

+ (NSArray *)memoryPropertys
{
    return @[@"isMembership"];
}


@end

#pragma  mark - WSTGroupDevice
@implementation WSTGroupDevice
+(void)deleteFromDB:(int)deviceAddress{
    WSTHomeGorupShowModel *model = [AppDelegate instance].currentGroup;
    NSString *str = [NSString stringWithFormat:@"where groupAddress = '%d' and homeName = '%@' and deviceAddress = '%d'",model.groupAddress,[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],deviceAddress];
    WSTGroupDevice *device = [WSTGroupDevice selectFromClassPredicateWithFormat:str].firstObject;
    [device deleteObject];

}

+(void)insertFromDB:(int)deviceAddress {
   WSTGroupDevice *g = [[WSTGroupDevice alloc]init];
    g.groupAddress = [AppDelegate instance].currentGroup.groupAddress;
    g.homeName = [[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
    g.deviceAddress = deviceAddress;
    [g insertObject];
}

+ (NSArray<WZBLEDataModel *> *)getCurrentGroupDevices{
    NSMutableArray *array = [@[]mutableCopy];
    WSTHomeGorupShowModel *model = [AppDelegate instance].currentGroup;
    NSString *str = [NSString stringWithFormat:@"where groupAddress = '%d' and homeName = '%@'",model.groupAddress,[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName]];
    NSArray *devices = [WSTGroupDevice selectFromClassPredicateWithFormat:str]; //获取当前群组的所有meshid
    NSArray *bleDevices = [[WZBlueToothDataManager shareInstance]getCurrentDevicesWithOnlie:YES]; //获取当前mesh网络的设备
    
    //通过meshid 匹配BleModel
    for (WSTGroupDevice *device in devices) {
        for (WZBLEDataModel *model in bleDevices) {
            if ((device.deviceAddress == model.address) && [device.homeName isEqualToString:model.home]) {
                [array addObject:model];
            }
        }
    }
    return array;
}

+ (NSArray *)getCureentGroupNotAddDevices:(NSArray *)currenDevices allDevices:(NSArray *)allDevices{

    NSMutableArray *array = [allDevices mutableCopy];
    for (WZBLEDataModel *model in allDevices) {
        for (WZBLEDataModel *device in currenDevices) {
            if (model.address == device.address && [model.home isEqualToString:device.home]) {
                [array removeObject:model];
            }
        }
    }
    return array;
}
@end

#pragma mark -

@implementation WSTGroupKey
+(void)deleteFromDB:(int)deviceAddress{
    WSTHomeGorupShowModel *model = [AppDelegate instance].currentGroup;
    NSString *str = [NSString stringWithFormat:@"where groupAddress = '%d' and homeName = '%@' and deviceAddress = '%d'",model.groupAddress,[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName],deviceAddress];
    WSTGroupKey *key = [WSTGroupKey selectFromClassPredicateWithFormat:str].firstObject;
    [key deleteObject];
}

+(void)insertFromDB:(int)deviceAddress {
    WSTGroupKey *g = [[WSTGroupKey alloc]init];
    g.groupAddress = [AppDelegate instance].currentGroup.groupAddress;
    g.homeName = [[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
    g.deviceAddress = deviceAddress;
    [g insertObject];
}

+ (NSArray<WSTGroupKey *> *)getCurrentKeyDevices{
    WSTHomeGorupShowModel *model = [AppDelegate instance].currentGroup;
    NSString *str = [NSString stringWithFormat:@"where groupAddress = '%d' and homeName = '%@'",model.groupAddress,[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName]];
    NSArray *devices = [WSTGroupKey selectFromClassPredicateWithFormat:str];
    return devices;
}
@end
