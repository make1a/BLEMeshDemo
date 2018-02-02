//
//  WSTGroupHeadView.m
//  MeshLamp
//
//  Created by make on 2017/10/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTGroupHeadView.h"

@implementation WSTGroupHeadView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.headLabel.text = LCSTR("custom_group_icon_name");
}

@end
