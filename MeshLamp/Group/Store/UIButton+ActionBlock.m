//
//  UIButton+ActionBlock.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/10.
//  Copyright © 2017年 make. All rights reserved.
//

#import "UIButton+ActionBlock.h"
#import <objc/runtime.h>
@implementation UIButton (ActionBlock)
- (void)clickButtonAction:(clickBlock)block{
    if (block) {
        objc_setAssociatedObject(self, "WSTGroupInconViewButtonClick", block, OBJC_ASSOCIATION_COPY);

    }
    [self addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)clickAction:(UIButton *)sender{
    clickBlock block = objc_getAssociatedObject(self, "WSTGroupInconViewButtonClick");
    block();
}

@end
