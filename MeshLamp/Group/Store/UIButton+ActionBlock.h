//
//  UIButton+ActionBlock.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/10.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^clickBlock)(void);

@interface UIButton (ActionBlock)
/**
 按钮点击事件
 
 @param block block
 */
- (void)clickButtonAction:(clickBlock)block;
@end
