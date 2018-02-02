//
//  WSTCircadianTimeCell.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/18.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSTCircadianInfo.h"

@interface WSTCircadianTimeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

- (void)cellRefreshWith:(NSIndexPath *)indexPath andZInfo:(AlarmInfo *)zinfo yInfo:(AlarmInfo *)yinfo;
@end
