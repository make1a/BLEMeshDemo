//
//  MusicCell.m
//  doonne
//
//  Created by TrusBe Sil on 2017/4/28.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MusicCell.h"

@implementation MusicCell
@synthesize nameLable, artistLabel, artworkImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        artworkImageView = [[UIImageView alloc] initWithFrame: CGRectMake(Sp2Pt(16), Sp2Pt(4), Sp2Pt(48), Sp2Pt(48))];
        artworkImageView.layer.masksToBounds = YES;
        artworkImageView.layer.cornerRadius = Sp2Pt(6);
        artworkImageView.contentMode = UIViewContentModeScaleAspectFill;
        artworkImageView.clipsToBounds = YES;
        [self addSubview: artworkImageView];
        
        nameLable = [[UILabel alloc] initWithFrame:CGRectMake(Sp2Pt(70), Sp2Pt(8), SCREEN_WIDTH - Sp2Pt(75), Sp2Pt(20))];
        nameLable.backgroundColor = [UIColor clearColor];
        nameLable.textAlignment = NSTextAlignmentLeft;
        [nameLable setFont:[UIFont systemFontOfSize:15.0]];
        [nameLable setTextColor: [UIColor lightGrayColor]];
        [self addSubview:nameLable];
        
        artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(Sp2Pt(70), Sp2Pt(32), SCREEN_WIDTH - Sp2Pt(75), Sp2Pt(16))];
        artistLabel.backgroundColor = [UIColor clearColor];
        artistLabel.textAlignment = NSTextAlignmentLeft;
        [artistLabel setFont:[UIFont systemFontOfSize:12.0]];
        [artistLabel setTextColor: [UIColor grayColor]];
        [self addSubview:artistLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
