//
//  WSTHomeGroupBtnCell.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/30.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTHomeGroupBtnCell.h"

@implementation WSTHomeGroupBtnCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.controlBtn setTitle:LCSTR("Control") forState:UIControlStateNormal];
    [self.mangageBtn setTitle:LCSTR("manage") forState:UIControlStateNormal];
    [self.deleteBtn setTitle:LCSTR("delete") forState:UIControlStateNormal];

    self.controlBtn.lzType = LZRelayoutButtonTypeBottom;
    self.mangageBtn.lzType = LZRelayoutButtonTypeBottom;
    self.deleteBtn.lzType = LZRelayoutButtonTypeBottom;
    self.controlBtn.imageSize = CGSizeMake(20, 20);
    self.mangageBtn.imageSize = CGSizeMake(20, 20);
    self.deleteBtn.imageSize = CGSizeMake(20, 20);
    self.controlBtn.titleLabel.adjustsFontSizeToFitWidth = true;
    self.mangageBtn.titleLabel.adjustsFontSizeToFitWidth = true;
    self.deleteBtn.titleLabel.adjustsFontSizeToFitWidth = true;

}

- (IBAction)controAction:(id)sender {
    if (self.pressControlBlock) {
        self.pressControlBlock();
    }
}
- (IBAction)manageAction:(id)sender {
    if (self.pressManageBlock) {
        self.pressManageBlock();
    }
}
- (IBAction)DeleteAction:(id)sender {
    if (self.pressDeleteBlock) {
        self.pressDeleteBlock();
    }
}
- (void)cellRefreshWith:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        self.mangageBtn.hidden = YES;
        self.deleteBtn.hidden = YES;
        [self.controlBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.contentView.mas_height);
            make.centerY.equalTo(self.contentView);
            make.centerX.equalTo(self.contentView);
        }];
    }else{
        self.mangageBtn.hidden = NO;
        self.deleteBtn.hidden = NO;
        [self.controlBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).mas_offset(30);
            make.height.mas_equalTo(self.contentView.mas_height);
        }];
    }
}
@end
