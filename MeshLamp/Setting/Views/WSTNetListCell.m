//
//  WSTNetListCell.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/11.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTNetListCell.h"

@implementation WSTNetListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)cellRefreshWithEditDevice:(NSIndexPath *)indexPath roomArray:(NSArray *)roomArray{
    if (indexPath.section == 1) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@%ld",LCSTR("bind_ctrl_key"),indexPath.row+1];
        int roomAddr = (int)indexPath.row+1;
        if ([roomArray containsObject:[NSNumber numberWithLong:roomAddr]]) {
            [self.checkImageView setImage:[UIImage imageNamed:@"check_icon_selected"]];
        } else {
            [self.checkImageView setImage:[UIImage imageNamed:@"check_icon_normal"]];
        }
    }
}

- (void)cellRefreshWithHomeList:(NSIndexPath *)indexPath homeInfo:(WSTHomeInfo *)info index:(NSInteger)index{
    
    self.nameLabel.text = NSLocalizedString(info.homeName, nil);
    
    if (indexPath.row == index) {
        self.checkImageView.image = [UIImage imageNamed:@"check_icon_selected"];
    }else{
        self.checkImageView.image = [UIImage imageNamed:@"check_icon_normal"];
    }
}
@end
