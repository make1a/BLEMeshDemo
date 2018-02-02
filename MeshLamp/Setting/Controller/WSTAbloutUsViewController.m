//
//  AbloutUsViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/11.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTAbloutUsViewController.h"

@interface WSTAbloutUsViewController ()
/**logo*/
@property (nonatomic,strong) UIImageView *logoImageView;
/**title*/
@property (nonatomic,strong) UILabel *titleLabel;
/**detail*/
@property (nonatomic,strong) UILabel *detaiLabel;
/**build*/
@property (nonatomic,strong) UILabel *buildLabel;
@end

@implementation WSTAbloutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
    self.titleLabel.text = appName;
    self.detaiLabel.text = [NSString stringWithFormat:@"V%@",appVersion];
    self.buildLabel.text = [NSString stringWithFormat:@"(build:%@)",appBuild];
}

- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("About_Us") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
}

#pragma mark - 布局
- (void)masLayoutSubview{
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).mas_offset(-px1334Hight(100));
        make.width.height.mas_equalTo(100);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.logoImageView.mas_bottom).mas_offset(5);
    }];
    
    [self.detaiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(5);
    }];
    
    [self.buildLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.centerX.equalTo(self.view);
        make.top.equalTo(self.detaiLabel.mas_bottom).mas_offset(5);
    }];
}

#pragma mark - 懒加载
- (UIImageView *)logoImageView{
    if (!_logoImageView) {
        _logoImageView = [UIImageView new];
        _logoImageView.layer.cornerRadius = 10;
        _logoImageView.layer.masksToBounds = YES;
        _logoImageView.image = [UIImage imageNamed:@"app_icon"];
        [self.view addSubview:_logoImageView];
    }
    return _logoImageView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        [self.view addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detaiLabel{
    if (!_detaiLabel) {
        _detaiLabel = [UILabel new];
        _detaiLabel.text = @"";
        _detaiLabel.textColor = [UIColor colorWithRed:154/255.0 green:161/255.0 blue:166/255.0 alpha:1.0];
        _detaiLabel.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:_detaiLabel];
    }
    return _detaiLabel;
}

- (UILabel *)buildLabel{
    if (!_buildLabel) {
        _buildLabel = [UILabel new];
        _buildLabel.text = @"";
        _buildLabel.textColor = [UIColor colorWithRed:154/255.0 green:161/255.0 blue:166/255.0 alpha:1.0];
        _buildLabel.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:_buildLabel];
    }
    return _buildLabel;
}
@end
