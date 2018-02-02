//
//  WSTHomeDeviceCell.m
//  MeshLamp
//
//  Created by make on 2017/10/2.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTHomeDeviceCell.h"
@interface WSTHomeDeviceCell()<UIGestureRecognizerDelegate>
/**UILongPressGestureRecognizer*/
@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;
@end
@implementation WSTHomeDeviceCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:_longPress];
        
    }
    return self;
}



- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.longPressBlock) {
            self.longPressBlock();
        }
    }
}

- (void)refreshWithModel:(WZBLEDataModel*)model indexPath:(NSIndexPath*)indexPath{
    
    NSString *devName = [WZBLEDataAnalysisTool NameWithModel:model.devModel];
    self.deviceNameLabel.text = model.name;
    if (model.state == DeviceStatusOn) {
        self.deviceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_on",devName]];
    }else if (model.state == DeviceStatusOff){
        self.deviceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_off",devName]];
    }else{
        self.deviceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_offLine",devName]];
    }
    
    
}
@end
