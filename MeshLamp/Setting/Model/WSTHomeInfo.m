//
//  WSTHomeInfo.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTHomeInfo.h"

@implementation WSTHomeInfo
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

+ (void)insertDefualtHome{
    if ([WSTHomeInfo selectFromClassAllObject].count==0) { //添加默认
        WSTHomeInfo *info =  [[WSTHomeInfo alloc]init];
        info.homeName = @"defalut_home";
        [info insertObject];
    }
}

+ (BOOL)isExist:(NSString *)homeName{
   NSArray *ar = [WSTHomeInfo selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where homeName = '%@'",homeName]];
    return ar.count>0?YES:NO;
}

+ (void)deleteNetwork:(WSTHomeInfo *)info{
    
    [info deleteObject]; //删除本地网络
    [WSTHomeGorupShowModel deleteFromClassPredicateWithFormat:[NSString stringWithFormat:@"where homeName = '%@'",info.homeName]];    
}
@end
