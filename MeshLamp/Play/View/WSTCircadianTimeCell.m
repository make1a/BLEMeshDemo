//
//  WSTCircadianTimeCell.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/18.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTCircadianTimeCell.h"
@interface WSTCircadianTimeCell ()
@property (weak, nonatomic) IBOutlet UIView *topLine;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;

@end
@implementation WSTCircadianTimeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)cellRefreshWith:(NSIndexPath *)indexPath andZInfo:(AlarmInfo *)zinfo yInfo:(AlarmInfo *)yinfo{
    NSString *timeStr;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            if (zinfo.hour == -1) {
                timeStr = LCSTR("please_choose");
            }else{
                timeStr = [NSString stringWithFormat:@"%@:%@",[NSString padingZero:[NSString stringWithFormat:@"%d",zinfo.hour] length:2],[NSString padingZero:[NSString stringWithFormat:@"%d",zinfo.minute] length:2]];
            }
        }else if (indexPath.row == 2){
            if (zinfo.duration == -1) {
                timeStr = LCSTR("please_choose");
            }else{
                timeStr = [NSString stringWithFormat:@"%d%@",zinfo.duration,LCSTR("minute")];
            }
        }
        self.rightLabel.text = timeStr;
    }else if (indexPath.section == 1){
        if (indexPath.row == 1) {
            if (yinfo.hour == -1) {
                timeStr = LCSTR("please_choose");
            }else{
                timeStr = [NSString stringWithFormat:@"%@:%@",[NSString padingZero:[NSString stringWithFormat:@"%d",yinfo.hour] length:2],[NSString padingZero:[NSString stringWithFormat:@"%d",yinfo.minute] length:2]];
            }
        }else if (indexPath.row == 2){
            if (yinfo.duration == -1) {
                timeStr = LCSTR("please_choose");
            }else{
                timeStr = [NSString stringWithFormat:@"%d%@",yinfo.duration,LCSTR("minute")];
            }
        }
        self.rightLabel.text = timeStr;
    }
    
    if (indexPath.row == 1) {
        self.leftLabel.text = LCSTR("day_start_time");
        self.topLine.hidden = NO;
        self.bottomLine.hidden = NO;
    }else{
        self.leftLabel.text = LCSTR("day_durtime_time");
        self.topLine.hidden = YES;
        self.bottomLine.hidden = YES;
    }
    
    
    if (indexPath.row == 2) {
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH-20, 48);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame
                                                   byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(5, 5)];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = frame;
        maskLayer.path = path.CGPath;
        self.layer.mask = maskLayer;
    }
}
@end
