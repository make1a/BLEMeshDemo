//
//  WSTCircadianSwitchCell.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/18.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSTCircadianInfo.h"


@interface WSTCircadianSwitchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sswitch;
/**Description */
@property (nonatomic,copy) void (^pressSwitch)(BOOL isOn);
- (void)cellRefreshWith:(NSIndexPath*)indexPath andZinfo:(AlarmInfo *)zinfo yInfo:(AlarmInfo *)yinfo;
@end
