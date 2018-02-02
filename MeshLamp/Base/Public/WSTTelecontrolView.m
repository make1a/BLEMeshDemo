//
//  WSTTelecontrolView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/10.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTTelecontrolView.h"
@interface WSTTelecontrolView()

/**遥控器1*/
@property (nonatomic,strong) UIButton *telecontrol1;
@property (nonatomic,strong) UIButton *telecontrol2;
@property (nonatomic,strong) UIButton *telecontrol3;
@property (nonatomic,strong) UIButton *telecontrol4;
/**buttons*/
@property (nonatomic,strong) NSArray *buttons;
@end
@implementation WSTTelecontrolView

- (instancetype)init
{
    self = [super initWithType:WSTAlertTypeTelecontrol];
    if (self) {
        [self masLayoutSubViews];
        [self.rightButton addTarget:self action:@selector(clickRightButton) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}
- (void)buttonSetSelectWith:(NSArray *)array{
    for (WSTGroupKey *key in array) {
        int addr = key.deviceAddress-0x8000;
        for (UIButton *button in self.buttons) {
            if (addr == button.tag-100) {
                [button setSelected:YES];
            }
        }
    }
}
- (void)masLayoutSubViews{
    
    [self.telecontrol1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.centerView).mas_offset(px750Width(46));
        make.centerY.equalTo(self.centerView);
        make.width.mas_equalTo(px750Width(63));
        make.height.mas_equalTo(px1334Hight(159));
    }];
    
    [self.telecontrol2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.telecontrol1);
        make.left.equalTo(self.telecontrol1.mas_right).mas_offset(px750Width(51));
        make.width.equalTo(self.telecontrol1);
        make.height.equalTo(self.telecontrol1);
    }];
    
    [self.telecontrol3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.telecontrol1);
        make.left.equalTo(self.telecontrol2.mas_right).mas_offset(px750Width(51));
        make.width.equalTo(self.telecontrol1);
        make.height.equalTo(self.telecontrol1);
    }];
    
    [self.telecontrol4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.telecontrol1);
        make.left.equalTo(self.telecontrol3.mas_right).mas_offset(px750Width(51));
        make.width.equalTo(self.telecontrol1);
        make.height.equalTo(self.telecontrol1);
    }];
    
    UIView *lineView = ({
        lineView = [UIView new];
        lineView.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
        [self.centerView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.centerView);
            make.height.mas_equalTo(1);
        }];
        lineView;
    });
    self.buttons = @[_telecontrol1,_telecontrol2,_telecontrol3,_telecontrol4];
}

#pragma mark - actions
- (void)clickAction:(UIButton *)sender{
    if (self.pressButton) {
        self.pressButton(sender.tag - 100, sender.selected,sender);
    }
    
}
- (void)clickRightButton{
    [self removeFromSuperview];
}
#pragma mark - 懒加载
- (UIButton *)telecontrol1{
    if (!_telecontrol1) {
        _telecontrol1 = [UIButton buttonWithType:UIButtonTypeCustom];
        _telecontrol1.tag = 101;
        [_telecontrol1 setImage:[UIImage imageNamed:@"key-1_icon_nor"] forState:UIControlStateNormal];
        [_telecontrol1 setImage:[UIImage imageNamed:@"key-1_icon_sel"] forState:UIControlStateSelected];
        [_telecontrol1 addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchDown];
        [self.centerView addSubview:_telecontrol1];
    }
    return _telecontrol1;
}
- (UIButton *)telecontrol2{
    if (!_telecontrol2) {
        _telecontrol2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _telecontrol2.tag = 102;
        [_telecontrol2 setImage:[UIImage imageNamed:@"key-2_icon_nor"] forState:UIControlStateNormal];
        [_telecontrol2 setImage:[UIImage imageNamed:@"key-2_icon_sel"] forState:UIControlStateSelected];
        [_telecontrol2 addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchDown];
        [self.centerView addSubview:_telecontrol2];
    }
    return _telecontrol2;
}
- (UIButton *)telecontrol3{
    if (!_telecontrol3) {
        _telecontrol3 = [UIButton buttonWithType:UIButtonTypeCustom];
        _telecontrol3.tag = 103;
        [_telecontrol3 setImage:[UIImage imageNamed:@"key-3_icon_nor"] forState:UIControlStateNormal];
        [_telecontrol3 setImage:[UIImage imageNamed:@"key-3_icon_sel"] forState:UIControlStateSelected];
        [_telecontrol3 addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchDown];
        [self.centerView addSubview:_telecontrol3];
    }
    return _telecontrol3;
}
- (UIButton *)telecontrol4{
    if (!_telecontrol4) {
        _telecontrol4 = [UIButton buttonWithType:UIButtonTypeCustom];
        _telecontrol4.tag = 104;
        [_telecontrol4 setImage:[UIImage imageNamed:@"key-4_icon_nor"] forState:UIControlStateNormal];
        [_telecontrol4 setImage:[UIImage imageNamed:@"key-4_icon_sel"] forState:UIControlStateSelected];
        [_telecontrol4 addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchDown];
        [self.centerView addSubview:_telecontrol4];
    }
    return _telecontrol4;
}
@end
