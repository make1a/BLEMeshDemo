//
//  SignInCell.m
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "SignInCell.h"

@implementation SignInCell
@synthesize backView, nameLabel, infoView;

#pragma mark - Init
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initCell];
    }
    return self;
}

#pragma mark - View
- (void)initCell {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.1];
    backView = [[UIView alloc] initWithFrame:CGRectMake(Sp2Pt(15), 0, SCREEN_WIDTH-Sp2Pt(30), Sp2Pt(50))];
    backView.backgroundColor = [UIColor clearColor];
    [self addSubview:backView];
    
    nameLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Width(backView)*0.25, Height(backView))];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:Sp2Pt(15)];
    [backView addSubview:nameLabel];
    
    infoView = [[UIView alloc] initWithFrame:CGRectMake(Width(nameLabel), 0, Width(backView)*0.75, Height(backView))];
    infoView.backgroundColor = [UIColor clearColor];
    [backView addSubview:infoView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
