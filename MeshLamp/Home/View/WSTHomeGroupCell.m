//
//  HomeGroupCell.m
//  doonne
//
//  Created by new on 2017/9/5.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "WSTHomeGroupCell.h"
@implementation WSTHomeGroupCell


- (void)awakeFromNib {
        [super awakeFromNib];

    [self.onButton setTitle:LCSTR("on") forState:0];
    [self.offButton setTitle:LCSTR("off") forState:0];
}

- (IBAction)onbuttonClick:(UIButton *)sender {
    [sender zoomAnimationPop];
    if (self.pressOnButton) {
        self.pressOnButton();
    }
}

- (IBAction)offButtonClick:(UIButton *)sender {
    [sender zoomAnimationPop];
    if (self.pressOffButton) {
        self.pressOffButton();
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
   
}

- (void)cellRefreshWithArray:(NSArray<WSTHomeGorupShowModel*>*)dataSource indexPath:(NSIndexPath *)indexPath{

    WSTHomeGorupShowModel *model = dataSource[indexPath.section];
    if (indexPath.item == 0) { //第一个item
        self.groupNameLable.text = NSLocalizedString(model.name, nil);
        self.groupImage.image = [UIImage imageNamed:model.imageStr];
    }else{

    }

    

}
@end
