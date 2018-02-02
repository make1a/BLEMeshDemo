//
//  WSTTelecontrolView.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/10.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTBaseAlertView.h"

@interface WSTTelecontrolView : WSTBaseAlertView
/**block */
@property (nonatomic,copy) void (^pressButton)(NSInteger index,BOOL select,UIButton *sender);
- (void)buttonSetSelectWith:(NSArray *)array;
@end
