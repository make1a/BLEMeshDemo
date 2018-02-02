//
//  MKBlueToothDataManager.m
//  MKBabyBlueDemo
//
//  Created by 微智电子 on 2017/9/7.
//  Copyright © 2017年 微智电子. All rights reserved.
//

#import "WZBlueToothDataManager.h"

#import "CryptoAction.h"
#import "WZConstantClass.h"
//#import "NSTimer+MKTimer.h"
#import "WZDeviceModel.h"
#import "FFDB.h"
#import "WZBLEDataAnalysisTool.h"
#import "WZScanDeviceModel.h"

#define random(x) (rand() % x)
#define MaxSnValue 0xffffff
#define kCMDInterval 0.32


static NSUInteger addIndex; // 指令递增数字

typedef enum {
    BTCommandCaiYang,
    BTCommandInterval
} BTCommand;



@interface WZBlueToothDataManager ()
{
    // 加密界面用到
    uint8_t loginRand[8];
    uint8_t sectionKey[16];
    uint8_t tempbuffer[20];
    
    NSUInteger otaPackIndex;
    // 发送指令中用到
    //    NSTimer *clickTimer;
    int duration;
    NSTimeInterval clickDate;
    int snNo;
    NSInteger addressNumber;
}

@property (nonatomic, strong) dispatch_source_t clickTimer;
@property (nonatomic, assign) BTCommand btCMDType;
@property (nonatomic, assign) NSTimeInterval containCYDelay;
@property (nonatomic, assign) NSTimeInterval exeCMDDate;
@property (nonatomic, assign) NSTimeInterval clickDate;
/**定时器*/
@property (nonatomic,strong) NSTimer *setHomeTimer;
/**userName */
@property (nonatomic,copy) NSString *userName;
/**password */
@property (nonatomic,copy) NSString *password;
/**登陆成功标识 */
@property (nonatomic,assign) BOOL isLogin;
/**Description*/
@property (nonatomic,strong) NSTimer *addrTime;
/**超时次数 */
@property (nonatomic,assign) NSInteger outNumber;
/**旧网络名 */
@property (nonatomic,copy) NSString *oldName;
@end
@implementation WZBlueToothDataManager
@synthesize clickDate=_clickDate;
#pragma mark - 单例模式
+ (WZBlueToothDataManager *)shareInstance{
    static WZBlueToothDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WZBlueToothDataManager alloc]init];
        
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

#pragma mark - 初始化数据
- (void)initData{
    memset(loginRand, 0, 8);
    memset(sectionKey, 0, 16);
    srand((int) time(0));
    memset(tempbuffer, 0, 20);
    self.isLogin = NO;
    snNo = random(MaxSnValue);
    duration = 300;
    _outNumber = 0;
    otaPackIndex=0;
}



/**
 登陆
 
 @param peripheral peripheral description
 @param userName userName description
 @param pwd pwd description
 */
-(void)loginPeripheral:(CBPeripheral *)peripheral withUserName:(NSString *)userName pwd:(NSString *)pwd {
    uint8_t buffer[17];
    [CryptoAction getRandPro:loginRand Len:8];
    for (int i = 0; i < 8; i++) {
        loginRand[i] = i;
    }
    buffer[0] = 12;
    [CryptoAction encryptPair:userName Pas:pwd Prand:loginRand PResult:buffer + 1];
    self.userName = userName;
    self.password = pwd;
    CBCharacteristic *characteristic = [WZBlueToothManager shareInstance].pairCharacteristic;
    [self writeValueWith:peripheral characteristic:characteristic Buffer:buffer Len:17];
}


/**
 特征值更新后的处理
 
 @param characteristic characteristic description
 @param perpheral perpheral description
 */

- (void)handleUpdateValueForCharacteristicData:(CBCharacteristic *)characteristic perpheral:(CBPeripheral *)perpheral {
    CBCharacteristic *charaPair = [WZBlueToothManager shareInstance].pairCharacteristic;
    CBCharacteristic *charaOTA = [WZBlueToothManager shareInstance].OTACharacteristic;
    CBCharacteristic *charaNotify = [WZBlueToothManager shareInstance].notifyCharacteristic;
    CBCharacteristic *charaCommand = [WZBlueToothManager shareInstance].commandCharacteristic;
    CBCharacteristic *fireWear = [WZBlueToothManager shareInstance].fireWareCharacteristic;
    if ([characteristic isEqual:charaPair]) {
        uint8_t *tempData = (uint8_t *) [characteristic.value bytes];
        if (tempData[0] == 13) {
            uint8_t buffer[16];
            // 解密广播数据
            if ([CryptoAction encryptPair:self.userName Pas:self.password Prand:tempData + 1 PResult:buffer]) {
                [self logByte:buffer Len:16 Str:@"CheckBuffer"];
                memset(buffer, 0, 16);
                [CryptoAction getSectionKey:self.userName Pas:self.password Prandm:loginRand Prands:tempData + 1 PResult:buffer];
                memcpy(sectionKey, buffer, 16);
                [self logByte:buffer Len:16 Str:@"SectionKey"];
                // 解密完成，登陆成功
                self.isLogin = YES;
                NSLog(@"=======================登陆成功====================");
                if ([WZBlueToothManager shareInstance].currentStatus == WZBlueToothScanAndConnectAll){ //加灯状态
                    [self openMeshLightStatus:perpheral];
                    dispatch_queue_t _concurrentQueue = dispatch_queue_create("com.read-write.queue", DISPATCH_QUEUE_SERIAL);
                    dispatch_barrier_sync(_concurrentQueue,^{
                        addressNumber = [self getAddrIndex];
                    });
                    dispatch_async(_concurrentQueue, ^{
                        [self deviceAddToNewNetwork:addressNumber];
                    });
                }else if ([WZBlueToothManager shareInstance].currentStatus == WZBlueToothScanAndConnectOne){
                    //打开状态上传
                    [self openMeshLightStatus:perpheral];
                }
            }else{
                NSLog(@"=======================登陆失败====================");
                [[WZBlueToothManager shareInstance]addNewNetWorkOverTimeAction];
                self.isLogin = NO;
            }
        }else if (tempData[0] == 7) {
            if (self.setHomeTimer) {
                [self.setHomeTimer invalidate];
                self.setHomeTimer = nil;
            }
            //完成配网
            [self saveNewDevice];
            if ([WZBlueToothManager shareInstance].currentStatus == WZBlueToothScanAndConnectAll) {
                [[WZBlueToothManager shareInstance]cancelConnectPeriphral:[WZBlueToothManager shareInstance].currentDevice.peripheral];//连接下一个
                [self initData];
            }
        }
        
    }else if ([characteristic isEqual:charaCommand]) {
        if (self.isLogin == YES) {
            uint8_t *tempData = (uint8_t *) [characteristic.value bytes];
            [self pasterData:tempData IsNotify:NO peripheral:perpheral];
        }
    }else if ([characteristic isEqual:charaNotify]) {
        if (self.isLogin == YES) {
            uint8_t *tempData = (uint8_t *) [characteristic.value bytes];
            [self pasterData:tempData IsNotify:YES peripheral:perpheral];
            
        }
    }else if ([characteristic isEqual:charaOTA]) {

        
    }else if([characteristic isEqual:fireWear]){
        NSData *tempData = [characteristic value];
        if ([_delegate respondsToSelector:@selector(deviceFirmWareData:)] && tempData) {
            [_delegate deviceFirmWareData:tempData];
        }
    }
}

#pragma mark - 设备加入新网络
- (void)setNewNetworkName:(NSString *)name andPwd:(NSString *)pwd{
    if (![name isEqualToString:_netWorkNameNew]) {
        addIndex=0;
    }
    _netWorkPwdNew = pwd;
    _netWorkNameNew = name;
}

/**
 设置网络名称
 
 @param name name description
 @param pwd pwd description
 */
- (void)configNetworkWithNewName:(NSString *)name pwd:(NSString *)pwd{
    
    uint8_t buffer[20];
    memset(buffer, 0, 20);
    
    [CryptoAction getNetworkInfo:buffer Opcode:4 Str:name Psk:sectionKey];
    
    [self writeValueWith:[WZBlueToothManager shareInstance].currentDevice.peripheral characteristic:[WZBlueToothManager shareInstance].pairCharacteristic Buffer:buffer Len:20];
    
    memset(buffer, 0, 20);
    [CryptoAction getNetworkInfo:buffer Opcode:5 Str:pwd Psk:sectionKey];
    [self writeValueWith:[WZBlueToothManager shareInstance].currentDevice.peripheral characteristic:[WZBlueToothManager shareInstance].pairCharacteristic Buffer:buffer Len:20];
    
    uint8_t ltkBuffer[20]={0xc0,0xc1,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xd8,0xd9,0xda,0xdb,0xdc,0xdd,0xde,0xdf,0x0,0x0,0x0,0x0};
    
    [CryptoAction getNetworkInfoByte:buffer Opcode:6 Str:ltkBuffer Psk:sectionKey];
    [self writeValueWith:[WZBlueToothManager shareInstance].currentDevice.peripheral characteristic:[WZBlueToothManager shareInstance].pairCharacteristic Buffer:buffer Len:20];
   
    if (!self.setHomeTimer) {
        self.setHomeTimer = [NSTimer mk_scheduledTimerWithTimeInterval:2.f repeats:NO block:^{
            if ([WZBlueToothManager shareInstance].currentDevice) {
                [[WZBlueToothManager shareInstance]cancelConnectPeriphral:[WZBlueToothManager shareInstance].currentDevice.peripheral];
            }
        }];
    }

    
}

//修改地址
- (void)deviceAddToNewNetwork:(NSInteger)newAddress{
    if (self.isLogin == YES && [WZBlueToothManager shareInstance].currentDevice) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self modifyDeviceAddress:[WZBlueToothManager shareInstance].currentDevice.address WithNewAddress:newAddress per:[WZBlueToothManager shareInstance].currentDevice.peripheral]; //修改地址
            if (!_addrTime) {
                NSLog(@"-=================定时器创建 ===================");
                _addrTime = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(addAddrOutTime) userInfo:nil repeats:NO];
            }
            
        });
    }else{ // 连接下一个
        [[WZBlueToothManager shareInstance]addNewNetWorkOverTimeAction];
    }
}

- (void)addAddrOutTime{
    NSLog(@"-====================================");
    NSLog(@"-================超时了====================");
    NSLog(@"-====================================");
//    NSInteger addr = [self getAddrIndex];
    
    [_addrTime invalidate];
    _addrTime = nil;
    
//    if (_outNumber>1) { //Next
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    if ([WZBlueToothManager shareInstance].currentDevice) {
        [[WZBlueToothManager shareInstance]cancelConnectPeriphral:[WZBlueToothManager shareInstance].currentDevice.peripheral];
    }
//        });
//    }else{
//        [self deviceAddToNewNetwork:addr];
//        _outNumber ++;
//    }
}

- (void)outTime:(NSTimer *)noti{
    [[WZBlueToothManager shareInstance]addNewNetWorkOverTimeAction];
}

/**
 获取没有使用过的addressNumber
 
 @return index
 */

- (NSInteger)getAddrIndex {
    
    NSArray * items =  [WZScanDeviceModel selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where home = '%@'",self.netWorkNameNew]];
    
    if (items.count > 0) {
        int index = 1;
        for (int i = 1; i < 255; i++) {
            BOOL isExist = NO;
            
            for (WZScanDeviceModel *item in items) {
                if (item.address == i) {
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

#pragma mark - 数据库操作
- (void)saveNewDevice{
    WZScanDeviceModel *item = [[WZScanDeviceModel alloc]init];
    item.home = self.netWorkNameNew;
    item.compound = [NSString stringWithFormat:@"%@-%ld", self.netWorkNameNew, (long)(addressNumber << 8)];
    item.address = (int)addressNumber;
    item.devModel = [WZBlueToothManager shareInstance].currentDevice.devModel;
    item.per = [WZBlueToothManager shareInstance].currentDevice.peripheral;
    [item insertObject];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationAtNewDevice object:item];
}

- (NSArray *)getCurrentDevicesWithOnlie:(BOOL)on{
    
    NSString *str;
    if (on) { //在线
        str = [NSString stringWithFormat:@"where home = '%@' And state != '0'",[WZBlueToothManager shareInstance].userName];
    }else{
        str = [NSString stringWithFormat:@"where home = '%@'",[WZBlueToothManager shareInstance].userName];
    }
//    NSArray *array = [WZBLEDataModel selectFromClassPredicateWithFormat:str];

   NSArray *array  = [FFDBTransaction selectObjectWithFFDBClass:[WZBLEDataModel class] format:str];
    
    array = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        WZBLEDataModel *device1 =  obj1;
        WZBLEDataModel *device2 =  obj2;
        return  [@(device1.address)compare:@(device2.address)];
    }];
    
    return array;
}

- (void)setAllDeviceOffline{
    
//    NSArray *array = [WZBLEDataModel selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where home = '%@'",[WZBlueToothManager shareInstance].userName]];
    NSArray *array = [WZBLEDataModel selectFromClassPredicateWithFormat:@"where state != 0"];
    for (WZBLEDataModel *model in array) {
        model.state = DeviceStatusOffLine;
        [model updateObject];
    }
}

//检查获取设备类型
- (void)getModelWithDataBaseOrDevice{
    
    NSArray *array = [WZBLEDataModel selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where home = '%@'",[WZBlueToothManager shareInstance].userName]];
    
    for (WZBLEDataModel *model in array) {
        if ([model.devModel isEqualToString:kDeviceDefaultMode] && model.state != DeviceStatusOffLine) { //默认模式就去主动获取
            [self getUserCustomDataWith:model.addressLong]; //发指令主动获取设备类型
        }
    }
}

#pragma mark - 读写数据
- (void)writeValueWith:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic Buffer:(uint8_t *)buffer Len:(int)len  {
    
    if (peripheral.state == CBPeripheralStateConnected && characteristic) {
        NSData *tempData = [NSData dataWithBytes:buffer length:len];
        [peripheral writeValue:tempData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)readValueWith:(CBPeripheral *)peripheral characteristic:(CBCharacteristic *)characteristic {
    if (peripheral.state == CBPeripheralStateConnected && characteristic) {
        [peripheral readValueForCharacteristic:characteristic];
    }
}
//打开上报状态
- (void)openMeshLightStatus:(CBPeripheral *)peripheral {
    
    uint8_t buffer[1] = {1};
    
    [self writeValueWith:peripheral characteristic:[WZBlueToothManager shareInstance].notifyCharacteristic Buffer:buffer Len:1];
}

#pragma mark - 打印指令
- (void)logByte:(uint8_t *)bytes Len:(int)len Str:(NSString *)str {
    NSMutableString *byteStr = [[NSMutableString alloc] init];
    for (int i = 0; i < len; i++) {
        [byteStr appendFormat:@"%0x ", bytes[i]];
    }
    NSLog(@"指令：%@: %@", str, byteStr);
}

#pragma mark - 指令
/**
 目前的功能是,删除灯的所有参数(mac地址除外),并把password、ltk恢 复为出厂值
 */
- (void)kickoutLightFromMeshWithDestinateAddress:(uint32_t)destinateAddress {
    uint8_t cmd[10] = {
        0x11, 0x61, 0x31, 0x00, 0x00, 0x00, 0x00, 0xe3, 0x11, 0x02,
    };
    cmd[5] = (destinateAddress >> 8) & 0xff;
    cmd[6] = destinateAddress & 0xff;
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    [self sendCommand:cmd Len:10 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}
- (void)getAllGroupAddressWithDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup{
    uint8_t cmd[12] = {0x11,0x11,0x40,0x00,0x00,0x00,0x00,0xdd,0x11,0x02,0x10,0x01};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    [self logByte:cmd Len:12 Str:@"【CMD】Get_All_Group_Address"];
    [self sendCommand:cmd Len:12 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}
- (void)musicStartWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup{
    uint8_t cmd[11] = {0x11, 0x11, 0x13, 0x00, 0x00, 0x00, 0x00, 0xd2, 0x11, 0x02, 0xFE};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    [self logByte:cmd Len:11 Str:@"【CMD】Music_start"];
    [self sendCommand:cmd Len:11 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
    
    
}
- (void)musicStopWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup{
    
    uint8_t cmd[11] = {0x11, 0x11, 0x13, 0x00, 0x00, 0x00, 0x00, 0xd2, 0x11, 0x02, 0xFF};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    [self logByte:cmd Len:11 Str:@"【CMD】Music_stop"];
    [self sendCommand:cmd Len:11 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
    
}
// 设置内置模式
- (void)setModeWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup andMode:(float)mode Delay:(NSInteger)delay {
    uint8_t cmd[14] = {0x11, 0x11, 0x98, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x0a, 0x00, 0x00, 0x00};
    // 序列号
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 是否群组
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    // 内置模式
    cmd[11] = mode;
    // 延时时间
    if (delay > 61) {
        delay = 60;
    }
    if (delay < 0) {
        delay = 0;
    }
    delay = delay * 1000;
    cmd[12] = delay & 0xff;
    cmd[13] = (delay >> 8) & 0xff;
    
    [self logByte:cmd Len:14 Str:@"【CMD】Set_Mode"];
    [self sendCommand:cmd Len:14 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}
// 设置亮度值lum－－传入目的地址和亮度值---可以是单灯或者组的地址
- (void)setBrightnessWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup Brightness:(CGFloat)brightness {
    uint8_t cmd[11] = {0x11, 0x11, 0x13, 0x00, 0x00, 0x00, 0x00, 0xd2, 0x11, 0x02, 0x0A};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    // 设置亮度值
    cmd[10] = brightness * 100.f;
    [self logByte:cmd Len:11 Str:@"【CMD】Change_Brightness"];
    [self sendCommand:cmd Len:11 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

- (void)setRGBWCWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue Warm:(CGFloat)warm Cold:(CGFloat)cold Lum:(CGFloat)lum Delay:(NSInteger)delay {
    uint8_t cmd[18] = {0x11, 0x11, 0x81, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x09, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = red * 255.f;
    cmd[12] = green * 255.f;
    cmd[13] = blue * 255.f;
    cmd[14] = warm * 255.f;
    cmd[15] = cold * 255.f;
    cmd[16] = lum * 100.f;
    cmd[17] = delay;
    [self logByte:cmd Len:18 Str:@"【CMD】Set_RGBWCL"];
    [self sendCommand:cmd Len:18 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

- (void)setRGBWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue Delay:(NSInteger)delay {
    uint8_t cmd[15] = {0x11, 0x11, 0x81, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x02, 0x0, 0x0, 0x0, 0x0};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = red * 255.f;
    cmd[12] = green * 255.f;
    cmd[13] = blue * 255.f;
    cmd[14] = delay;
    
    [self logByte:cmd Len:15 Str:@"【CMD】Set_RGB"];
    [self sendCommand:cmd Len:15 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

- (void)setHSBWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithHue:(CGFloat)hue Saturation:(CGFloat)sat Brightness:(CGFloat)brt Warm:(CGFloat)warm Cold:(CGFloat)cold Lum:(CGFloat)lum Delay:(NSInteger)delay {
    CGFloat red, green, blue;
    UIColor *color = [UIColor colorWithHue:hue saturation:sat brightness:brt alpha:1.0];
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    
    // 0x07,0x18
    uint8_t cmd[19] = {0x11, 0x11, 0x81, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x09, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x00};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = red * 255.f;
    cmd[12] = green * 255.f;
    cmd[13] = blue * 255.f;
    cmd[14] = warm * 255.f;
    cmd[15] = cold * 255.f;
    cmd[16] = lum * 100.f;
    cmd[17] = delay;
    if (red == 0 && blue == 0 && green == 0) {
        cmd[18] = 0x18;
    } else {
        cmd[18] = 0x07;
    }
    [self logByte:cmd Len:19 Str:@"【CMD】Set_HSBWCL"];
    [self sendCommand:cmd Len:19 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

- (void)setHSBWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithHue:(CGFloat)hue Saturation:(CGFloat)sat Brightness:(CGFloat)brt Delay:(NSInteger)delay {
    CGFloat red, green, blue;
    UIColor *color = [UIColor colorWithHue:hue saturation:sat brightness:brt alpha:1.0];
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    
    uint8_t cmd[15] = {0x11, 0x11, 0x81, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x04, 0x0, 0x0, 0x0, 0x0};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = red * 255.f;
    cmd[12] = green * 255.f;
    cmd[13] = blue * 255.f;
    cmd[14] = delay;
    [self logByte:cmd Len:15 Str:@"【CMD】Set_HSB"];
    [self sendCommand:cmd Len:15 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}
// 根据color值设置
- (void)setRGBWithAddress:(uint32_t)u_Address IsGroup:(BOOL)isGroup color:(UIColor *)color brightness:(CGFloat)brightness warm:(CGFloat)warm cold:(CGFloat)cold lum:(CGFloat)lum Delay:(NSInteger)delay{
    CGFloat red, green, blue;
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    uint8_t cmd[18] = {0x11,0x11,0x81,0x00,0x00,0x00,0x00,0xe2,0x11,0x02,0x09,0x0,0x0,0x0,0x0,0x0,0x0,0x0};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = red * 255.f;
    cmd[12] = green * 255.f;
    cmd[13] = blue * 255.f;
    cmd[14] = warm * 255.f;
    cmd[15] = cold * 255.f;
    cmd[16] = lum * 100.f;
    cmd[17] = delay;
    [self logByte:cmd Len:18 Str:@"【CMD】Set_HSBWCL"];
    [self sendCommand:cmd Len:18 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
    
    
}
// 设置红色
- (void)setRedWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithRed:(CGFloat)red Delay:(NSInteger)delay {
    uint8_t cmd[13] = {0x11, 0x11, 0x81, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x01, 0x0, 0x0};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = red * 255.f;
    cmd[12] = delay;
    [self logByte:cmd Len:13 Str:@"【CMD】Set_Red"];
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 设置绿色
- (void)setGreenWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithGreen:(CGFloat)green Delay:(NSInteger)delay {
    uint8_t cmd[13] = {0x11, 0x11, 0x83, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x02, 0x0, 0x0};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = green * 255.f;
    cmd[12] = delay;
    
    [self logByte:cmd Len:13 Str:@"【CMD】Set_Green"];
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 设置蓝色
- (void)setBlueWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithBlue:(CGFloat)blue Delay:(NSInteger)delay {
    uint8_t cmd[13] = {0x11, 0x11, 0x88, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x03, 0x0, 0x0};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = blue * 255.f;
    cmd[12] = delay;
    [self logByte:cmd Len:13 Str:@"【CMD】Set_Blue"];
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 设置暖色
- (void)setWarmWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithWarm:(CGFloat)warm Delay:(NSInteger)delay {
    uint8_t cmd[13] = {0x11, 0x11, 0x88, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x06, 0x0, 0x0};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = warm * 255.f;
    cmd[12] = delay;
    
    [self logByte:cmd Len:13 Str:@"【CMD】Set_Warm"];
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 设置冷色
- (void)setColdWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithCold:(CGFloat)cold Delay:(NSInteger)delay {
    uint8_t cmd[13] = {0x11, 0x11, 0x88, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x07, 0x0, 0x0};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = cold * 255.f;
    cmd[12] = delay;
    [self logByte:cmd Len:13 Str:@"【CMD】Set_Cold"];
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 设置冷暖
- (void)setWCWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithWarm:(CGFloat)warm Cold:(CGFloat)cold Delay:(NSInteger)delay {
    uint8_t cmd[14] = {0x11, 0x11, 0x8b, 0x00, 0x00, 0x00, 0x00, 0xe2, 0x11, 0x02, 0x08, 0x0, 0x0, 0x0};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    cmd[11] = warm * 255.f;
    cmd[12] = cold * 255.f;
    cmd[13] = delay;
    [self logByte:cmd Len:14 Str:@"【CMD】Set_WC"];
    [self sendCommand:cmd Len:14 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

- (void)getDeviceStatusWith:(uint32_t)u_Address {
    uint8_t cmd[11] = {0x11,0x11,0x51,0x00,0x00,0x00,0x00,0xda,0x11,0x02,0x10};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    cmd[5] = (u_Address >> 8) & 0xff;
    cmd[6] = u_Address & 0xff;
    
    [self logByte:cmd Len:11 Str:@"【CMD】Get_Device_Status"];
    [self sendCommand:cmd Len:11 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

- (void)locateTheDevice:(uint32_t)u_Address {
    uint8_t cmd[13] = {0x11, 0x11, 0x12, 0x00, 0x00, 0x00, 0x00, 0xd0, 0x11, 0x02, 0x03, 0x01, 0x00};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    cmd[5] = (u_Address >> 8) & 0xff;
    cmd[6] = u_Address & 0xff;
    [self logByte:cmd Len:13 Str:@"【CMD】Locate_The_Device"]; //控制台日志
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 获取设备或者群组设备地址，通过 Notify 回复
- (void)getDeviceAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup {
    uint8_t cmd[12] = {0x11, 0x11, 0x70, 0x00, 0x00, 0x11, 0x11, 0xe0, 0x11, 0x02, 0xff, 0xff};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 是否分组
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    [self logByte:cmd Len:12 Str:@"【CMD】Get_Device_Address"];
    [self sendCommand:cmd Len:12 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}


/**
 *加组－－－传入待加灯的地址，和 待加入的组的地址
 */
- (void)addDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup ToDestinateGroupAddress:(uint32_t)groupAddress {
    uint8_t cmd[13]={0x11,0x11,0x11,0x00,0x00,0x00,0x00,0xd7,0x11,0x02,0x01,0x01,0x80};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] >= 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 设备地址
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    // 组地址
    cmd[12]=(groupAddress >> 8) & 0xff;
    cmd[11]=groupAddress & 0xff;
    [self logByte:cmd Len:13 Str:@"【CMD】Add_Device_To_Group"];
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

//删除组
- (void)deleteDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup ToDestinateGroupAddress:(uint32_t)groupAddress {
    uint8_t cmd[13]={0x11,0x11,0x11,0x00,0x00,0x00,0x00,0xd7,0x11,0x02,0x00,0x01,0x80};
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] >= 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 设备地址
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    // 组地址
    cmd[12]=(groupAddress >> 8) & 0xff;
    cmd[11]=groupAddress & 0xff;
    
    [self logByte:cmd Len:13 Str:@"【CMD】Delete_Device_To_Group"];
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}
/**
 全开
 */
- (void)turnOnAllLight {
    uint8_t cmd[13] = {0x11, 0x11, 0x11, 0x00, 0x00, 0xff, 0xff, 0xd0, 0x11, 0x02, 0x01, 0x01, 0x00};
    [self logByte:cmd Len:13 Str:@"All_On"];
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

/**
 *一个mesh内部所有灯的all_off
 */
- (void)turnOffAllLight {
    uint8_t cmd[13] = {0x11, 0x11, 0x12, 0x00, 0x00, 0xff, 0xff, 0xd0, 0x11, 0x02, 0x00, 0x01, 0x00};
    [self logByte:cmd Len:13 Str:@"All_Off"];
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

/**
 *单灯的开－--------开灯--squrence no＋2
 */
- (void)turnOnCertainLightWithAddress:(uint32_t)u_DevAddress {
    uint8_t cmd[13] = {0x11, 0x71, 0x11, 0x00, 0x00, 0x66, 0x00, 0xd0, 0x11, 0x02, 0x01, 0x01, 0x00};
    cmd[5] = (u_DevAddress >> 8) & 0xff;
    cmd[6] = u_DevAddress & 0xff;
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    
    addIndex++;
    [self logByte:cmd Len:13 Str:@"Turn_On"]; //控制台日志
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

/**
 *单灯的关－－－关灯--squrence no＋1
 
 */
- (void)turnOffCertainLightWithAddress:(uint32_t)u_DevAddress {
    uint8_t cmd[13] = {0x11, 0x11, 0x11, 0x00, 0x00, 0x66, 0x00, 0xd0, 0x11, 0x02, 0x00, 0x01, 0x00};
    cmd[5] = (u_DevAddress >> 8) & 0xff;
    cmd[6] = u_DevAddress & 0xff;
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    
    addIndex++;
    [self logByte:cmd Len:13 Str:@"Turn_Off"]; //控制台日志
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

/**
 *组的开灯－－－传入组地址
 */
- (void)turnOnCertainGroupWithAddress:(uint32_t)u_GroupAddress {
    uint8_t cmd[13] = {0x11, 0x51, 0x11, 0x00, 0x00, 0x66, 0x00, 0xd0, 0x11, 0x02, 0x01, 0x01, 0x00};
    cmd[6] = (u_GroupAddress >> 8) & 0xff;
    cmd[5] = u_GroupAddress & 0xff;
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    
    addIndex++;
    [self logByte:cmd Len:13 Str:@"Group_On"]; //控制台日志
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

/**
 *组的关灯－－－传入组地址
 */
- (void)turnOffCertainGroupWithAddress:(uint32_t)u_GroupAddress {
    uint8_t cmd[13] = {0x11, 0x31, 0x11, 0x00, 0x00, 0x66, 0x00, 0xd0, 0x11, 0x02, 0x00, 0x01, 0x00};
    cmd[6] = (u_GroupAddress >> 8) & 0xff;
    cmd[5] = u_GroupAddress & 0xff;
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    
    addIndex++;
    [self logByte:cmd Len:13 Str:@"Group_Off"]; //控制台日志
    [self sendCommand:cmd Len:13 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 修改设备地址
- (void)modifyDeviceAddress:(uint32_t)u_Address WithNewAddress:(NSUInteger)newAddress per:(CBPeripheral*)per {
    uint8_t cmd[12] = {0x11, 0x11, 0x70, 0x00, 0x00, 0x00, 0x00, 0xe0, 0x11, 0x02, 0x00, 0x00};
    
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    // 设备原地址
    //    cmd[5] = (u_Address >> 8) & 0xff;
    //    cmd[6] = u_Address & 0xff;
    
    cmd[5] = 0;
    cmd[6] = 0;
    // 设备新地址
    cmd[10] = newAddress;
    addIndex++;
    [self sendCommand:cmd Len:12 per:per];
}

// 获取用户自定义数据，设备类型、等亮度等等
- (void)getUserCustomDataWith:(uint32_t)u_Address {
    uint8_t cmd[11] = {0x11, 0x11, 0x70, 0x00, 0x00, 0x00, 0x00, 0xea, 0x11, 0x02, 0x10};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    cmd[5] = (u_Address >> 8) & 0xff;
    cmd[6] = u_Address & 0xff;
    
    [self sendCommand:cmd Len:11 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}


- (NSArray *)changeCommandToArray:(uint8_t *)cmd len:(int)len {
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < len; i++) {
        [arr addObject:[NSString stringWithFormat:@"%02X", cmd[i]]];
    }
    return arr;
}

#pragma mark - 闹钟场景指令
// 设置设备的标准时间
- (void)setTheDeviceTime:(uint32_t)u_Address isGroup:(BOOL)isGroup{
    uint8_t cmd[17] = {0x11,0x11,0x5a,0x00,0x00,0x00,0x00,0xe4,0x11,0x02,0xdf,0x0,0x0,0x0,0x0,0x0,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    // 目标地址
    //    cmd[5] = (u_Address >> 8) & 0xff;
    //    cmd[6] = u_Address & 0xff;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 获取当前日期
    NSDate *dt = [NSDate date];
    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
    unsigned unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour |  NSCalendarUnitMinute |
    NSCalendarUnitSecond | NSCalendarUnitWeekday;
    // 获取不同时间字段的信息
    NSDateComponents *comp = [gregorian components: unitFlags fromDate:dt];
    cmd[10] = comp.year & 0xff;
    cmd[11] = (comp.year >> 8) & 0xff;
    cmd[12] = comp.month;
    cmd[13] = comp.day;
    cmd[14] = comp.hour;
    cmd[15] = comp.minute;
    cmd[16] = comp.second;
    
    [self logByte:cmd Len:17 Str:@"【CMD】Set_Time"];
    [self sendCommand:cmd Len:17 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 获取设备标准时间
- (void)getTheDeviceTime:(uint32_t)u_Address {
    uint8_t cmd[11] = {0x11,0x11,0x57,0x00,0x00,0x00,0x00,0xe8,0x11,0x02,0x10};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    cmd[5] = (u_Address >> 8) & 0xff;
    cmd[6] = u_Address & 0xff;
    
    [self logByte:cmd Len:11 Str:@"【CMD】Get_Time"];
    [self sendCommand:cmd Len:11 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 获取闹钟信息
- (void)getAlarmInfo:(uint32_t)u_Address isGroup:(BOOL)isGroup AlarmID:(int)alarmId {
    uint8_t cmd[12] = {0x11,0x11,0x5d,0x00,0x00,0x00,0x00,0xe6,0x11,0x02,0x10,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    if (isGroup) {
        cmd[5] = u_Address & 0xff;
        cmd[6] = (u_Address >> 8) & 0xff;
    } else {
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    cmd[11] = alarmId;
    [self logByte:cmd Len:12 Str:@"【CMD】Get_AlarmInfo"];
    [self sendCommand:cmd Len:12 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}



// 添加闹钟
- (void)addAlarmToDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup WithAlarmInfo:(AlarmInfo *)info {
    uint8_t cmd[19] = {0x11,0x11,0x5c,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    if (isGroup) {
        cmd[6] = (u_Address >> 8) & 0xff;
        cmd[5] = u_Address & 0xff;
    }else{
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    // 闹钟数据
    cmd[11] = info.alarmId;
    cmd[12] = info.actionAndModel;
    cmd[13] = info.month;
    cmd[14] = info.dayOrCycle;
    cmd[15] = info.hour;
    cmd[16] = info.minute;
    cmd[17] = info.second;
    cmd[18] = info.sceneId;
    //    cmd[19] = info.duration;
    
    [self logByte:cmd Len:20 Str:@"【CMD】Add_Alarm"];
    [self sendCommand:cmd Len:20 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 修改闹钟
- (void)modifyAlarmToDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup WithAlarmInfo:(AlarmInfo *)info {
    uint8_t cmd[20] = {0x11,0x11,0x64,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,0x02,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    
    // 目标地址
    if (isGroup) {
        cmd[6] = (u_Address >> 8) & 0xff;
        cmd[5] = u_Address & 0xff;
    }else{
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    
    // 闹钟数据
    cmd[11] = info.alarmId;
    cmd[12] = info.actionAndModel;
    cmd[13] = info.month;
    cmd[14] = info.dayOrCycle;
    cmd[15] = info.hour;
    cmd[16] = info.minute;
    cmd[17] = info.second;
    cmd[18] = info.sceneId;
    cmd[19] = info.duration;
    
    [self logByte:cmd Len:20 Str:@"【CMD】Modify_Alarm"];
    [self sendCommand:cmd Len:20 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 删除闹钟
- (void)deleteAlarmToDevice:(uint32_t)u_Address  isGroup:(BOOL)isGroup WithIndex:(int)index {
    uint8_t cmd[18] = {0x11,0x11,0x5d,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,0x01,0x0,0x0,0x0,0x0,0x0,0x0,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    if (isGroup) {
        cmd[6] = (u_Address >> 8) & 0xff;
        cmd[5] = u_Address & 0xff;
    }else{
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    // 闹钟数据
    cmd[11] = index;
    
    [self logByte:cmd Len:18 Str:@"【CMD】Delete_Alarm"];
    [self sendCommand:cmd Len:18 per:[WZBlueToothManager shareInstance].currentDevice.peripheral] ;
}

// 打开闹钟
- (void)openAlarmToDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup WithIndex:(int)index {
    uint8_t cmd[18] = {0x11,0x11,0x60,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,0x03,0x0,0x0,0x0,0x0,0x0,0x0,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    // 目标地址
    if (isGroup) {
        cmd[6] = (u_Address >> 8) & 0xff;
        cmd[5] = u_Address & 0xff;
    }else{
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    // 闹钟数据
    cmd[11] = index;
    
    [self logByte:cmd Len:18 Str:@"【CMD】Open_Alarm"];
    [self sendCommand:cmd Len:18 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 关闭闹钟
- (void)closeAlarmToDevice:(uint32_t)u_Address isGroup:(BOOL)isGroup WithIndex:(int)index {
    uint8_t cmd[18] = {0x11,0x11,0x5d,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,0x04,0x0,0x0,0x0,0x0,0x0,0x0,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    if (isGroup) {
        cmd[6] = (u_Address >> 8) & 0xff;
        cmd[5] = u_Address & 0xff;
    }else{
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    // 闹钟数据
    cmd[11] = index;
    
    [self logByte:cmd Len:18 Str:@"【CMD】Close_Alarm"];
    [self sendCommand:cmd Len:18 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

/**********************************************************************/
// 添加场景
- (void)addSceneWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithSceneInfo:(SceneInfo *)info {
    uint8_t cmd[19] = {0x11,0x11,0x66,0x00,0x00,0x00,0x00,0xee,0x11,0x02,0x01,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    
    if (isGroup) {
        cmd[6] = (u_Address >> 8) & 0xff;
        cmd[5] = u_Address & 0xff;
    }else{
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    // 闹钟数据
    cmd[11] = info.senceId;
    cmd[12] = info.lum*100;
    cmd[13] = info.red*255;
    cmd[14] = info.green*255;
    cmd[15] = info.blue*255;
    cmd[16] = info.warm*255;
    cmd[17] = info.cold*255;
    
    [self logByte:cmd Len:19 Str:@"【CMD】Add_Scene"];
    [self sendCommand:cmd Len:19 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 删除场景
- (void)deleteSceneWithAddress:(uint32_t)u_Address isGroup:(BOOL)isGroup WithSceneId:(int)sceneId {
    uint8_t cmd[12] = {0x11,0x11,0x69,0x00,0x00,0x00,0x00,0xee,0x11,0x02,0x0,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    if (isGroup) {
        cmd[6] = (u_Address >> 8) & 0xff;
        cmd[5] = u_Address & 0xff;
    }else{
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    // 闹钟数据
    cmd[11] = sceneId;
    
    [self logByte:cmd Len:12 Str:@"【CMD】Delete_Scene"];
    [self sendCommand:cmd Len:12 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}
- (void)deleteSceneFromAllDevice:(int)sceneId{
    
    uint8_t cmd[12] = {0x11,0x11,0x69,0x00,0x00,0x00,0x00,0xee,0x11,0x02,0x0,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    
    cmd[5] = 0xff;
    cmd[6] = 0xff;
    
    // 闹钟数据
    cmd[11] = sceneId;
    
    [self logByte:cmd Len:12 Str:@"【CMD】Delete_Scene"];
    [self sendCommand:cmd Len:12 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}
// 加载场景
- (void)loadSceneWithSceneId:(int)sceneId  {
    uint8_t cmd[11] = {0x11,0x11,0x6c,0x00,0x00,0x00,0x00,0xef,0x11,0x02,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    cmd[5] = 0xff;
    cmd[6] = 0xff;

    cmd[10] = sceneId;
    
    [self logByte:cmd Len:11 Str:@"【CMD】Load_Scene"];
    [self sendCommand:cmd Len:11 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

// 获取场景数据
- (void)getSceneDataToDevice:(uint32_t)u_Address  isGroup:(BOOL)isGroup WithSceneId:(int)sceneId {
    uint8_t cmd[12] = {0x11,0x11,0x6e,0x00,0x00,0x00,0x00,0xc0,0x11,0x02,0x10,0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    if (isGroup) {
        cmd[6] = (u_Address >> 8) & 0xff;
        cmd[5] = u_Address & 0xff;
    }else{
        cmd[5] = (u_Address >> 8) & 0xff;
        cmd[6] = u_Address & 0xff;
    }
    
    // 场景 ID
    if (sceneId != 255) {
        cmd[11] = sceneId;
    } else {
        //        DDLogInfo(@"Manage, Get_Scene_Info, 无效的场景 ID");
    }
    
    [self logByte:cmd Len:12 Str:@"【CMD】Get_Scene_Info"];
    [self sendCommand:cmd Len:12 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

/*
 - (void)addSensorInfoToDevice:(uint32_t)senAddr With:(SensorInfo *)info {
 uint8_t cmd[20] = {0x11,0x11,0x58,0x00,0x00,0x00,0x00,0xf0,0x11,0x02,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
 // 序列号
 cmd[2] = cmd[2] + addIndex;
 if (cmd[2] == 254) {
 cmd[2] = 1;
 }
 addIndex++;
 // 目标地址
 cmd[5] = (senAddr >> 8) & 0xff;
 cmd[6] = senAddr & 0xff;
 
 int oneValue = info.oneValue;
 int twoValue = info.twoValue;
 
 // 传感器数据
 cmd[10] = info.relationId;
 cmd[11] = info.isEnable;
 cmd[12] = [WSPublic mergeType:info.oneType AndAction:info.oneAction];
 cmd[13] = (oneValue >> 8) & 0xff;
 cmd[14] = oneValue & 0xff;
 cmd[15] = info.oneSceneId;
 cmd[16] = [WSPublic mergeType:info.twoType AndAction:info.twoAction];
 cmd[17] = (twoValue >> 8) & 0xff;
 cmd[18] = twoValue & 0xff;
 cmd[19] = info.twoSceneId;
 [self logByte:cmd Len:20 Str:@"【CMD】Add_Sensor_info"];
 [self sendCommand:cmd Len:20 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
 }
 */
- (void)setBindingRelationWith:(uint32_t)devAddr SensorAddr:(uint32_t)senAddr RelationId:(NSInteger)relationId IsEnable:(BOOL)isEnable {
    uint8_t cmd[14] = {0x11,0x11,0x59,0x00,0x00,0x00,0x00,0xf1,0x11,0x02,0x00,0x00,0x00,0x00};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    cmd[5] = (devAddr >> 8) & 0xff;
    cmd[6] = devAddr & 0xff;
    
    // 闹钟数据
    cmd[10] = isEnable;
    cmd[11] = (senAddr >> 8) & 0xff;
    cmd[12] = senAddr & 0xff;
    cmd[13] = relationId;
    [self logByte:cmd Len:14 Str:@"【CMD】Set_Binding_Relation"];
    [self sendCommand:cmd Len:14 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}

#pragma mark - 数据解析部分

// 解析广播包
- (void)parsingTheBroadcastPackets:(uint8_t *)bytes peripheral:(CBPeripheral *)peripheral {
    [self logByte:bytes Len:20 Str:@"【Notify】parsingTheBroadcastPackets"];
    
    // MeshLightStatus 指令
    WZBLEDataModel *firstItem = [[WZBLEDataAnalysisTool shareInstance] getDeviceModelWithBytes:bytes isFirst:YES];
    WZBLEDataModel *secondItem = [[WZBLEDataAnalysisTool shareInstance] getDeviceModelWithBytes:bytes isFirst:NO];
    if ([self.delegate respondsToSelector:@selector(updateDeviceStatus)]) {
        if (firstItem) {
            [self.delegate updateDeviceStatus];
        }
        if (secondItem) {
            [self.delegate updateDeviceStatus];
        }
    }
    if (bytes[8] == 0x11 && bytes[9] == 0x02 && bytes[7] == 0xe0) {
        NSLog(@"......................");
    }
    // 解析设备修改地址通知
    if (bytes[8] == 0x11 && bytes[9] == 0x02 && bytes[7] == 0xe1) {
        //        uint32_t address = [self analysisedAddressAfterSettingWithBytes:bytes];
        NSLog(@"-=================销毁定时器 ===================");
        [_addrTime invalidate];
        _addrTime = nil;
        _outNumber = 0;
        NSLog(@"-==============================================");
        NSLog(@"地址也修改成功了...");
        //地址修改成功后 修改网络
        [self configNetworkWithNewName:_netWorkNameNew pwd:kDeviceLoginUserPassword];; //修改网络
        //        [self saveNewDevice];
        //        if ([WZBlueToothManager shareInstance].currentStatus == WZBlueToothScanAndConnectAll) {
        //            [[WZBlueToothManager shareInstance]cancelConnectPeriphral:peripheral];//连接下一个
        //            [self initData];
        //        }
    }
    
    // 解析设备群组状态通知
    if (bytes[8] == 0x11 && bytes[9] == 0x02 && bytes[7] == 0xd4) {
        GroupInfo *info = [[WZBLEDataAnalysisTool shareInstance] notifyDataOfAddToGroup:bytes];
        if ([self.delegate respondsToSelector:@selector(responseOfDeviceHasGroupsArray:)]) {
            [self.delegate responseOfDeviceHasGroupsArray:info];
        }
    }
    
    // 解析设备状态通知
    if (bytes[8] == 0x11 && bytes[9] == 0x02 && bytes[7] == 0xdb) {
        NSArray *status = [[WZBLEDataAnalysisTool shareInstance] notifyDataOfDeviceStatus:bytes];
        if ([_delegate respondsToSelector:@selector(responseOfDeviceStatus:)]) {
            [_delegate responseOfDeviceStatus:status];
        }
    }
    // 解析设备用户自定义数据通知
    if (bytes[8] == 0x11 && bytes[9] == 0x02 && bytes[7] == 0xeb) {
        CustInfo *status = [[WZBLEDataAnalysisTool shareInstance] notifyDataOfUserCustomData:bytes];
        [[WZBLEDataAnalysisTool shareInstance]updateDeviceInfoWithBleUploadModel:status]; //更新数据库模型
        if ([self.delegate respondsToSelector:@selector(responseOfUserCustomData)]) {
            [self.delegate responseOfUserCustomData]; //通知外面数据已更新
        }
    }
    // 解析设备标准时间通知
    if (bytes[8] == 0x11 && bytes[9] == 0x02 && bytes[7] == 0xe9) {
        NSMutableDictionary *status = [[WZBLEDataAnalysisTool shareInstance] notifyDataOfDeviceTimerData:bytes];
        //        if ([delegate respondsToSelector:@selector(responseOfDeviceTimeData:)]) {
        //            [delegate responseOfDeviceTimeData:status];
        //        }
    }
    // 解析设备的闹钟信息
    if (bytes[8] == 0x11 && bytes[9] == 0x02 && bytes[7] == 0xe7) {
        AlarmInfo *info = [[WZBLEDataAnalysisTool shareInstance] notifyDataOfAlarmInfo:bytes];
        //        if ([delegate respondsToSelector:@selector(responseOfAlarmInfo:)]) {
        //            [delegate responseOfAlarmInfo:info];
        //        }
        NSLog(@"%@",info);
    }
    // 解析设备的场景获取信息
    if (bytes[8] == 0x11 && bytes[9] == 0x02 && bytes[7] == 0xc1) {
        SceneInfo *info = [[WZBLEDataAnalysisTool shareInstance] notifyDataOfSceneInfo:bytes];
        if ([_delegate respondsToSelector:@selector(responseOfSceneInfo:)]) {
            [_delegate responseOfSceneInfo:info];
        }
    }
    // 解析指定设备的固件版本信息
    if (bytes[7] == 0xc8 && bytes[8] == 0x11 && bytes[9] == 0x02 && bytes[10] == 0x00) {
        NSData *data = [NSData dataWithBytes:bytes length:20];
        if ([self.delegate respondsToSelector:@selector(deviceFirmWareData:)]) {
            [_delegate deviceFirmWareData:[data subdataWithRange:NSMakeRange(11, 9)]];
        }
    }
}

// 解密数据并代理待外界去
- (void)pasterData:(uint8_t *)buffer IsNotify:(BOOL)isNotify peripheral:(CBPeripheral *)peripheral {
    uint8_t sec_ivm[8];
    uint32_t tempMac = (uint32_t) [WZBlueToothManager shareInstance].currentDevice.mac;
    
    sec_ivm[0] = (tempMac >> 24) & 0xff;
    sec_ivm[1] = (tempMac >> 16) & 0xff;
    sec_ivm[2] = (tempMac >> 8) & 0xff;
    
    memcpy(sec_ivm + 3, buffer, 5);
    if (!(buffer[0] == 0 && buffer[1] == 0 && buffer[2] == 0)) {
        if ([CryptoAction decryptionPpacket:sectionKey Iv:sec_ivm Mic:buffer + 5 MicLen:2 Ps:buffer + 7 Len:13]) {
            NSLog(@"Manager, 解密返回成功, Buffer: %@", [NSData dataWithBytes:buffer length:20]);
            
        } else {
            //            : %@", [NSData dataWithBytes:buffer length:20]
            NSLog(@"Manager, 解密返回失败, Buffer");
        }
    }
    
    if (isNotify) {
        // 通知返回
        [self parsingTheBroadcastPackets:buffer peripheral:peripheral];
    } else {
        // 请求返回
        //        [self sendDevCommandReport:buffer];
    }
    
}
- (void)sendCommand:(uint8_t *)cmd Len:(int)len per:(CBPeripheral *)per{
    NSArray *cmdArr = [self changeCommandToArray:cmd len:len];
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970]; //
    if (clickDate > current) _clickDate = 0;                       //修复手机修改时间错误造成的命令延时执行错误的问题；
    
    //if cmd is nil , return;
    if (!cmdArr) return;
    
    //if _clickDate is equal 0,it means the first time to executor command
    NSTimeInterval count = 0;
    
    if (cmd[7] == 0xd0 || cmd[7] == 0xd2 || cmd[7] == 0xe2) {
        self.containCYDelay = YES;
        self.btCMDType = BTCommandCaiYang;
        if ((current - _clickDate) < kCMDInterval) {
            if (_clickTimer) {
                dispatch_cancel(_clickTimer);
                //                [_clickTimer invalidate];
                _clickTimer = nil;
                addIndex--;
            }
            //            count = kCMDInterval+self.clickDate-current;
            count = (uint64_t)((kCMDInterval + self.clickDate - current) * NSEC_PER_SEC);
            dispatch_queue_t quen = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _clickTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quen);
            dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(count));
            uint64_t interv = (int64_t)(kCMDInterval * NSEC_PER_SEC);
            dispatch_source_set_timer(_clickTimer, start, interv, 0);
            dispatch_source_set_event_handler(_clickTimer, ^{
                [self cmdTimer:cmdArr];
            });
            dispatch_resume(_clickTimer);
        } else {
            [self cmdTimer:cmdArr];
        }
    } else {
        self.btCMDType = BTCommandInterval;
        double temp = current - self.exeCMDDate;
        if (((temp < kCMDInterval) && (temp > 0)) || temp < 0) {
            if (self.exeCMDDate == 0) {
                self.exeCMDDate = current;
            }
            self.exeCMDDate = self.exeCMDDate + kCMDInterval;
            count = self.exeCMDDate + kCMDInterval - current;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(cmdTimer:) withObject:cmdArr afterDelay:count];
            });
        } else {
            [self cmdTimer:cmdArr];
        }
    }
}
- (void)cmdTimer:(id)temp {
    @synchronized(self) {
        if (_clickTimer) {
            dispatch_cancel(_clickTimer);
            //        [_clickTimer invalidate];
            _clickTimer = nil;
            addIndex--;
        }
        int len = (int) [temp count];
        uint8_t cmd[len];
        for (int i = 0; i < len; i++) {
            cmd[i] = strtoul([temp[i] UTF8String], 0, 16);
        }
        NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
        _clickDate = current;
        [self cmd:cmd Len:len];
    }
}

- (void)cmd:(Byte *)cmd Len:(int)len{
    WZDeviceModel *model = [WZBlueToothManager shareInstance].currentDevice;
    
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    if (self.exeCMDDate < current) {
        self.exeCMDDate = current;
    }
    
    if (!self.isLogin|| model.peripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
    //    uint8_t * buffer ;
    uint8_t buffer[20];
    uint8_t sec_ivm[8];
    
    memset(buffer, 0, 20);
    memcpy(buffer, cmd, len);
    memset(sec_ivm, 0, 8);
    
    [self getNextSnNo];
    buffer[0] = snNo & 0xff;
    buffer[1] = (snNo >> 8) & 0xff;
    buffer[2] = (snNo >> 16) & 0xff;
    
    uint32_t tempMac = (uint32_t) model.mac;
    
    sec_ivm[0] = (tempMac >> 24) & 0xff;
    sec_ivm[1] = (tempMac >> 16) & 0xff;
    sec_ivm[2] = (tempMac >> 8) & 0xff;
    sec_ivm[3] = tempMac & 0xff;
    
    sec_ivm[4] = 1;
    sec_ivm[5] = buffer[0];
    sec_ivm[6] = buffer[1];
    sec_ivm[7] = buffer[2];
    
    [CryptoAction encryptionPpacket:sectionKey Iv:sec_ivm Mic:buffer + 3 MicLen:2 Ps:buffer + 5 Len:15];
    [self writeValueWith:model.peripheral characteristic:[WZBlueToothManager shareInstance].commandCharacteristic Buffer:buffer Len:20];
}
- (int)getNextSnNo {
    snNo++;
    if (snNo > MaxSnValue) {
        snNo = 1;
    }
    return snNo;
}

#pragma mark - OTA
- (void)readDeviceFirmwareVersion:(uint32_t)devAddr {
    uint8_t cmd[12] = {0x11, 0x11, 0x12, 0x00, 0x00, 0x00, 0x00, 0xc7, 0x11, 0x02, 0x10, 0x0};
    // 序列号
    cmd[2] = cmd[2] + addIndex;
    if (cmd[2] == 254) {
        cmd[2] = 1;
    }
    addIndex++;
    // 目标地址
    cmd[5] = (devAddr >> 8) & 0xff;
    cmd[6] = devAddr & 0xff;
    // 设置参数
    [self logByte:cmd Len:12 Str:@"【CMD】Read_Device_Firmware_Version"];
    [self sendCommand:cmd Len:12 per:[WZBlueToothManager shareInstance].currentDevice.peripheral];
}
- (void)sendOTAPack:(NSData *)data isFirst:(BOOL)isFirst {

    NSUInteger length = data.length;
    uint8_t *tempData = (uint8_t *) [data bytes]; // 数据包
    uint8_t pack_head[2];
    if (isFirst) {
        otaPackIndex = 0;
    }
    pack_head[1] = (otaPackIndex >> 8) & 0xff; // 从0开始
    pack_head[0] = (otaPackIndex) &0xff;
    
    // 普通数据包
    if (length > 0 && length < 16) {
        length = 16;
    }
    // 总包
    uint8_t otaBuffer[length + 4];
    memset(otaBuffer, 0, length + 4);
    // 待校验包
    uint8_t otaCmd[length + 2];
    memset(otaCmd, 0, length + 2);
    // index指数部分
    for (int i = 0; i < 2; i++) {
        otaBuffer[i] = pack_head[i];
    }
    // bin 文件数据包,
    for (int i = 2; i < length + 2; i++) {
        if (i < [data length] + 2) {
            otaBuffer[i] = tempData[i - 2];
        } else {
            otaBuffer[i] = 0xff;
        }
    }
    for (int i = 0; i < length + 2; i++) {
        otaCmd[i] = otaBuffer[i];
    }
    
    // CRC校验部分
    unsigned short crc_t = crc16(otaCmd, (int) length + 2);
    uint8_t crc[2];
    crc[1] = (crc_t >> 8) & 0xff;
    crc[0] = (crc_t) &0xff;
    for (int i = (int) length + 3; i > (int) length + 1; i--) { //2->4
        otaBuffer[i] = crc[i - length - 2];
    }
    
    [self logByte:otaBuffer Len:(int) length + 4 Str:@"【OTA】Buffer"];
    
    NSData *tempdata = [NSData dataWithBytes:otaBuffer length:length + 4];
    
    //写数据
    
    [[WZBlueToothManager shareInstance].currentDevice.peripheral writeValue:tempdata forCharacteristic:[WZBlueToothManager shareInstance].OTACharacteristic type:CBCharacteristicWriteWithoutResponse];
    
    
    otaPackIndex++;
}

/**
 CRC校验
 
 @param pD 整个数据包
 @param len 长度
 @return 校验码
 */
extern unsigned short crc16(unsigned char *pD, int len) {
    static unsigned short poly[2] = {0, 0xa001}; // 0x8005 <==> 0xa001
    unsigned short crc = 0xffff;
    int i, j;
    for (j = len; j > 0; j--) {
        unsigned char ds = *pD++;
        for (i = 0; i < 8; i++) {
            crc = (crc >> 1) ^ poly[(crc ^ ds) & 1];
            ds = ds >> 1;
        }
    }
    return crc;
}

@end
