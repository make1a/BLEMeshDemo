//
//  WSTOTAContainerView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/20.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTOTAContainerView.h"


@interface WSTOTAContainerView ()
/**label*/
@property (nonatomic,strong) UILabel *notiLabel;
@end
@implementation WSTOTAContainerView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self masLayoutSubviews];
    }
    return self;
}
- (void)setProgress:(CGFloat)value{
    [_circleView setProgress:value];
    
}

#pragma mark - 布局
- (void)masLayoutSubviews{
   NSString *language = [[NSUserDefaults standardUserDefaults]valueForKey:@"myLanguage"];
    if (!language||language.length == 0) {
        language = [NSString getPreferredLanguage];
    }
    
    [self.notiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).mas_offset(px1334Hight(100));
        if (![language containsString:@"zh"]) {
            make.left.equalTo(self).mas_offset(12);
        }
        
    }];


    
    [self.circleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.notiLabel.mas_bottom).mas_offset(px1334Hight(50));
        make.width.height.mas_equalTo(SCREEN_WIDTH*0.7);
    }];
    
    [self.notiLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.circleView.mas_bottom).mas_offset(20);
    }];
    
    [self.sender mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).mas_offset(-50);
        make.left.equalTo(self).mas_offset(20);
        make.right.equalTo(self).mas_offset(-20);
        make.height.mas_equalTo(48);
    }];
}

#pragma mark - 懒加载
- (UILabel *)notiLabel{
    if(!_notiLabel)
    {
        _notiLabel = [[UILabel alloc]init];
        [self addSubview:_notiLabel];
        _notiLabel.textColor = [UIColor whiteColor];
        _notiLabel.font = [UIFont systemFontOfSize:13];
        _notiLabel.numberOfLines = 0;
        [_notiLabel sizeToFit];
        _notiLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",LCSTR("ota_reminder1"),LCSTR("ota_reminder2"),LCSTR("ota_reminder3"),LCSTR("ota_reminder4")];
    }
    return _notiLabel;
}
- (UILabel *)notiLabel2{
    if(!_notiLabel2)
    {
        _notiLabel2 = [[UILabel alloc]init];
        [self addSubview:_notiLabel2];
        _notiLabel2.textColor = [UIColor whiteColor];
        _notiLabel2.font = [UIFont systemFontOfSize:18];
        _notiLabel2.text = @"";
    }
    return _notiLabel2;
}

- (MKECircleView *)circleView{
    if (!_circleView) {
        _circleView = [[MKECircleView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*0.7, SCREEN_WIDTH*0.7)];
        [self addSubview:_circleView];
    }
    return _circleView;
}
- (UIButton *)sender{
    if (!_sender) {
        _sender = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sender setTitle:LCSTR("start_ota") forState:UIControlStateNormal];

        
        _sender.backgroundColor = [UIColor colorWithRed:250/255.0 green:212/255.0 blue:83/255.0 alpha:1.0];
        
        _sender.layer.cornerRadius = 5;
        _sender.layer.masksToBounds = YES;
        [self addSubview:_sender];
    }
    return _sender;
}
@end
