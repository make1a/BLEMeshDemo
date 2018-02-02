
//
//  WSTGroupDeviceCell.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/11.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTGroupDeviceCell.h"

@implementation WSTGroupDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)cellRefreshWithModel:(WZBLEDataModel *)model indexPath:(NSIndexPath *)indexPath{
    self.nameLabel.font = [UIFont systemFontOfSize:px750Width(26)];
    NSString *devName = [WZBLEDataAnalysisTool NameWithModel:model.devModel];
    self.nameLabel.text = model.name;
    if (model.state == DeviceStatusOn) {
        self.deviceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_on",devName]];
    }else if (model.state == DeviceStatusOff){
        self.deviceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_off",devName]];
    }else{
        self.deviceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_offLine",devName]];
    }
    self.maskImageView.hidden = !model.ismember;
    if (indexPath.section == 0) {
        self.maskImageView.image = [UIImage imageNamed:@"delete_mask"];
    }else{
        self.maskImageView.image = [UIImage imageNamed:@"add_mask"];
    }
}
@end
