//
//  WSTGroupDeviceHeadView.m
//  MeshLamp
//
//  Created by make on 2017/10/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTGroupDeviceHeadView.h"

@implementation WSTGroupDeviceHeadView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headLabel.text = LCSTR("current_device");
}

@end
