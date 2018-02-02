//
//  WSTGroupManageCell.m
//  MeshLamp
//
//  Created by make on 2017/10/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTGroupManageCell.h"

@implementation WSTGroupManageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)cellRefreshWithIndexPath:(NSIndexPath *)indexPath roomArray:(NSArray *)array{
    switch (indexPath.section) {
        case 0:
        {
            self.leftLabel.text = LCSTR("group_name");
            self.rightLabel.text = [NSString stringWithFormat:@"%@",NSLocalizedString([AppDelegate instance].currentGroup.name, nil)];
        }
            break;
        case 1:
        {
            array = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                WSTGroupKey *device1 =  obj1;
                WSTGroupKey *device2 =  obj2;
                return  [@(device1.deviceAddress)compare:@(device2.deviceAddress)];
            }];
            self.leftLabel.text = LCSTR("bind_ctrl_key");
            if (array.count != 0) {
                NSMutableString *devStr = [@"" mutableCopy];
                for (WSTGroupKey *key in array) {
                    NSString *str;
                        str = [NSString stringWithFormat:@"k%d ",(key.deviceAddress - 0x8000)];
                    [devStr appendString:str];
                }
                self.rightLabel.text = devStr;
            }else{
                self.rightLabel.text = LCSTR("not_bind");
            }
        }
        default:
            break;
    }
}
@end
