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
        if ([WSTHomeInfo selectFromClassAllObject].count==0) { //添加默认
           WSTHomeInfo *info =  [[WSTHomeInfo alloc]init];
            info.homeName = @"default home";
            [info insertObject];
        }
    }
    return self;
}
@end
