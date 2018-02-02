//
//  WSTCircadianSwitchCell.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/18.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTCircadianSwitchCell.h"

@implementation WSTCircadianSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH-20, 48);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame
                                               byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                     cornerRadii:CGSizeMake(5, 5)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = frame;
    maskLayer.path = path.CGPath;
    self.layer.mask = maskLayer;

}


- (IBAction)clickSwitch:(UISwitch *)sender {
    if (self.pressSwitch) {
        self.pressSwitch(sender.isOn);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellRefreshWith:(NSIndexPath*)indexPath andZinfo:(AlarmInfo *)zinfo yInfo:(AlarmInfo *)yinfo{
    

    
    if (indexPath.section == 0) {
        NSString *enableBinary = [NSString decimalToBinary:zinfo.actionAndModel];
        NSString *bit7 = [enableBinary substringWithRange:NSMakeRange(0, 1)]; //使能
        [self.sswitch setOn:[bit7 intValue] animated:YES];
        self.headImageView.image = [UIImage imageNamed:@"day_circadian_icon"];
        self.nameLabel.text = LCSTR("day");

    }else{
        self.headImageView.image = [UIImage imageNamed:@"night_circadian_icon"];
        self.nameLabel.text = LCSTR("night");
        NSString *enableBinary = [NSString decimalToBinary:yinfo.actionAndModel];
        NSString *bit7 = [enableBinary substringWithRange:NSMakeRange(0, 1)]; //使能
        [self.sswitch setOn:[bit7 intValue] animated:YES];
    }
    
}
@end
