//
//  BreathCell.m
//  doonne
//
//  Created by TrusBe Sil on 2017/4/21.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "BreathCell.h"


@implementation BreathCell
@synthesize icon, nameLabel;

#pragma mark - Init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCell];
    }
    return self;
}

#pragma mark - View
- (void)initCell {
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UIImageView *iconBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Width(self), Height(self))];
    iconBg.backgroundColor = [UIColor colorWithRed:33/255.0 green:47/255.0 blue:58/255.0 alpha:1.0];
    iconBg.clipsToBounds = YES;
    iconBg.userInteractionEnabled = YES;
    [self.contentView addSubview:iconBg];
    
    UIView *iconBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width(iconBg), Height(iconBg)*0.8)];
    iconBack.backgroundColor = [UIColor clearColor];
    [iconBg addSubview:iconBack];
    
    icon = [[UIImageView alloc] initWithFrame:CGRectMake((Width(iconBack) - Height(iconBack)*0.6)/2, Height(iconBack)*0.2, Height(iconBack)*0.6, Height(iconBack)*0.6)];
    icon.backgroundColor = [UIColor clearColor];
    [iconBg addSubview:icon];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Height(iconBack), Width(iconBg), Height(iconBg)*0.2)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor lightGrayColor];
    nameLabel.font = [UIFont systemFontOfSize:Sp2Pt(12)];
    [iconBg addSubview:nameLabel];
}
@end
