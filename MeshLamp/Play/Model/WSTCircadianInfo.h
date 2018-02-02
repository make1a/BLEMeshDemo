//
//  WSTCircadianInfo.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/18.
//  Copyright © 2017年 make. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSTCircadianInfo : FFDataBaseModel
/**homeName */
@property (nonatomic,copy) NSString *homeName;
@property (nonatomic,assign) int devAddress;
/**昼节律时间 */
@property (nonatomic,assign) int zHour;
@property (nonatomic,assign) int zMinute;
@property (nonatomic,assign) BOOL zisOn;
//持续时间
@property (nonatomic,assign) int zTime;

/**夜节律时间 */
@property (nonatomic,assign) int yHour;
@property (nonatomic,assign) int yMinute;
@property (nonatomic,assign) int yTime;
@property (nonatomic,assign) BOOL yisOn;
@end
