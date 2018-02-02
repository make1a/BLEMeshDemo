//
//  WSTBaseAlertView.m
//  MeshLamp
//
//  Created by make on 2017/10/8.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTBaseAlertView.h"
#import "WSTInputView.h"




@interface WSTBaseAlertView ()
/** containerView */
@property (nonatomic,strong) UIView *containerView;
/** topView */
@property (nonatomic,strong) UIView *topView;

/** bottomView */
@property (nonatomic,strong) UIView *bottomView;
/** titleLabel */
@property (nonatomic,strong) UILabel *titleLabel;
@end
@implementation WSTBaseAlertView



- (instancetype)initWithType:(WSTAlertType)type
{
    self = [super init];
    if (self) {
        [self masLayoutSubViewsWithType:type];
    }
    return self;
}

- (void)addWithSuperView:(UIView *)view{
    [view addSubview:self];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).mas_offset(px1334Hight(700));
    }];
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:.5 animations:^{
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).mas_offset(-px1334Hight(100));
        }];
        [self layoutIfNeeded];
    }];
}
#pragma mark - actions
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    point = [self.containerView.layer convertPoint:point fromLayer:self.layer];
    if (![self.containerView.layer containsPoint:point]) {
        [self removeFromSuperview];
        
    }
}
- (void)leftButtonClick:(UIButton *)sender{
    [self removeFromSuperview];
}
#pragma mark - 布局
- (void)masLayoutSubViewsWithType:(WSTAlertType)type{
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).mas_offset(px1334Hight(700));
        make.width.mas_equalTo(px750Width(497));
        switch (type) {
            case WSTAlertTypeInput:
                make.height.mas_equalTo(px1334Hight(310));
                break;
            case WSTAlertTypeGroupIcon:
                make.height.mas_equalTo(px1334Hight(430));
                break;
            case WSTAlertTypeTelecontrol:
                make.height.mas_equalTo(px1334Hight(391));
                break;
            default:
                make.height.mas_equalTo(px1334Hight(500));
                break;
        }
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.containerView);
        make.height.mas_equalTo(px1334Hight(83));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.topView);
    }];
    
    [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.containerView);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.containerView);
        make.height.mas_equalTo(px1334Hight(100));
    }];
    
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).mas_offset(px750Width(32));
        make.bottom.equalTo(self.bottomView).mas_offset(-px1334Hight(24));
        make.height.mas_equalTo(px1334Hight(60));
        make.width.mas_equalTo(px750Width(189));
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).mas_offset(-px750Width(32));
        make.bottom.equalTo(self.bottomView).mas_offset(-px1334Hight(24));
        make.height.mas_equalTo(self.leftButton.mas_height);
        make.width.mas_equalTo(px750Width(189));
    }];
}

- (void)setContainerLayout{
    
}


#pragma mark ------------ 懒加载 --------------
- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_containerView];
        _containerView.layer.masksToBounds = YES;
        _containerView.layer.cornerRadius = 10;
    }
    return _containerView;
}

- (UIView *)topView{
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = [UIColor whiteColor];
        [self.containerView addSubview:_topView];
        UIView *lineView = ({
            lineView = [UIView new];
            lineView.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
            [_topView addSubview:lineView];
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.equalTo(self.topView);
                make.height.mas_equalTo(1);
            }];
            lineView;
        });
        
    }
    return _topView;
}

- (UIView *)centerView{
    if (!_centerView) {
        _centerView = [UIView new];
        _centerView.backgroundColor = [UIColor whiteColor];
        [self.containerView addSubview:_centerView];
    }
    return _centerView;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = [UIColor whiteColor];
        [self.containerView addSubview:_bottomView];
        UIView *lineView = ({
            lineView = [UIView new];
            lineView.backgroundColor = [UIColor grayColor];
            [_topView addSubview:lineView];
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(self.bottomView);
                make.height.mas_equalTo(1);
            }];
            lineView;
        });
    }
    return _bottomView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        [self.topView addSubview:_titleLabel];
        _titleLabel.text = @"名称";
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)leftButton{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomView addSubview:_leftButton];
        [_leftButton setBackgroundImage:[UIImage imageNamed:@"left_button"] forState:UIControlStateNormal];
        [_leftButton setTitle:LCSTR("Cancel") forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchDown];
    }
    return _leftButton;
}

- (UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomView addSubview:_rightButton];
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"right_button"] forState:UIControlStateNormal];
        [_rightButton setTitle:LCSTR("confirm") forState:UIControlStateNormal];
        _rightButton.backgroundColor = [UIColor colorWithRed:246/255.0 green:206/255.0 blue:97/255.0 alpha:1.0];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
    return _rightButton;
}
- (void)setTitle:(NSString *)title{
    _titleLabel.text = title;
}


@end
