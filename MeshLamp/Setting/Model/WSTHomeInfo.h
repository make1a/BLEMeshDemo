//
//  WSTHomeInfo.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "FFDataBaseModel.h"

@interface WSTHomeInfo : FFDataBaseModel
/**名称 */
@property (nonatomic,copy) NSString *homeName;
/**是否是扫描的到的 */
@property (nonatomic,assign) BOOL isShare;

+ (void)insertDefualtHome;

+ (BOOL)isExist:(NSString *)homeName;

+ (void)deleteNetwork:(WSTHomeInfo *)info;
@end
