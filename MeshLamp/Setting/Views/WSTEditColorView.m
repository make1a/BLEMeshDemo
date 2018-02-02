//
//  WSTEditColorView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/11/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTEditColorView.h"
@interface WSTEditColorView ()
/**Description*/
@property (nonatomic,strong) UILabel *noticeLabel1;
@property (nonatomic,strong) UILabel *noticeLabel2;

@property (nonatomic,strong) UIImageView *rightImageView;
/**Description */
@property (nonatomic,assign) BOOL isSingle;
/**取色*/
@end

@implementation WSTEditColorView

- (instancetype)initWithSingleColor:(BOOL)isColor isSingle:(BOOL)isSingle
{
    self = [super init];
    if (self) {
        self.isColor = isColor;
        self.isSingle = isSingle;
        [self masLayoutsubviews];
    }
    return self;
}

- (void)masLayoutsubviews{
    
    [self.noticeLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).mas_offset(8);
        make.top.equalTo(self).mas_offset(8);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.noticeLabel1.mas_bottom).mas_offset(8);
        make.height.mas_equalTo(48);
    }];
    
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).mas_offset(-8);
        make.centerY.equalTo(self.textField);
        make.height.mas_equalTo(28);
        make.width.mas_equalTo(30);
    }];
    
    [self.noticeLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).mas_offset(8);
        make.top.equalTo(self.textField.mas_bottom).mas_offset(8);
    }];

    if(_isColor == NO && _isSingle == YES){
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.noticeLabel2.mas_bottom).mas_offset(px1334Hight(250));
            make.centerX.equalTo(self);
            make.width.mas_equalTo(px750Width(600));
        }];
    }else {
        [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.noticeLabel2.mas_bottom).mas_offset(20);
            make.width.height.mas_equalTo(px750Width(500));
        }];
    }

    [self.defaultButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).mas_offset(-px1334Hight(100));
        make.height.width.mas_equalTo(self.sumbitButton);
        make.centerX.equalTo(self);
    }];
    
    [self.sumbitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.defaultButton.mas_top).mas_offset(-px1334Hight(20));
        make.centerX.equalTo(self);
        make.width.mas_equalTo(px750Width(500));
        make.height.mas_equalTo(48);
    }];
    

}



#pragma mark - 懒加载
- (UILabel *)noticeLabel1{
    if (!_noticeLabel1) {
        _noticeLabel1 = [UILabel new];
        _noticeLabel1.font = [UIFont systemFontOfSize:13];
        _noticeLabel1.textColor = [UIColor whiteColor];
        _noticeLabel1.text = LCSTR("色块名称");
        [self addSubview:_noticeLabel1];
    }
    return _noticeLabel1;
}

- (UILabel *)noticeLabel2{
    if (!_noticeLabel2) {
        _noticeLabel2 = [UILabel new];
        _noticeLabel2.font = [UIFont systemFontOfSize:13];
        _noticeLabel2.textColor = [UIColor whiteColor];
        _noticeLabel2.text = LCSTR("参数设置");
        [self addSubview:_noticeLabel2];
    }
    return _noticeLabel2;
}
- (UITextField *)textField{
    if (!_textField) {
        _textField = [UITextField new];
        _textField.placeholder = LCSTR("请输入色块名称");
        _textField.textColor = [UIColor whiteColor];
        _textField.backgroundColor = [UIColor colorWithRed:33/255.0 green:46/255.0 blue:58/255.0 alpha:1.0];
        _textField.textAlignment = NSTextAlignmentCenter;
        [_textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self addSubview:_textField];
    }
    return _textField;
}
- (UIImageView *)rightImageView{
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc]init];
        _rightImageView.image = [UIImage imageNamed:@"rename_icon"];
        [self addSubview:_rightImageView];
    }
    return _rightImageView;
}

- (ColorPickerView *)colorView{
    if (!_colorView) {
        _colorView = [[ColorPickerView alloc]init];
        _colorView.bgImageView.image = _isColor?[UIImage imageNamed:@"hsb_circle"]:[UIImage imageNamed:@"warm_cold_circle"];
        [self addSubview:_colorView];
    }
    return _colorView;
}

- (void)setIsColor:(BOOL)isColor{
    _isColor = isColor;
        _colorView.bgImageView.image = isColor?[UIImage imageNamed:@"hsb_circle"]:[UIImage imageNamed:@"warm_cold_circle"];
}
 

- (UIButton *)sumbitButton{
    if (!_sumbitButton) {
        _sumbitButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_sumbitButton setBackgroundColor:[UIColor colorWithRed:254/255.0 green:208/255.0 blue:38/255.0 alpha:1.0]];
        [_sumbitButton setTitle:LCSTR("完成") forState:UIControlStateNormal];
        [_sumbitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sumbitButton.layer.masksToBounds = YES;
        _sumbitButton.layer.cornerRadius = 5;
        [self addSubview:_sumbitButton];
    }
    return _sumbitButton;
}

- (UIButton *)defaultButton{
    if (!_defaultButton) {
        _defaultButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_defaultButton setBackgroundColor:[UIColor clearColor]];
        [_defaultButton setTitle:LCSTR("默认色值") forState:UIControlStateNormal];
        [_defaultButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _defaultButton.layer.borderWidth = 1.f;
        _defaultButton.layer.borderColor =[UIColor colorWithRed:254/255.0 green:208/255.0 blue:38/255.0 alpha:1.0].CGColor;
        [self addSubview:_defaultButton];
        _defaultButton.layer.masksToBounds = YES;
        _defaultButton.layer.cornerRadius = 5;
    }
    return _defaultButton;
}

- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc]init];
        if (self.isSingle == YES && _isColor ==NO) {
            _slider.hidden = NO;
        }else{
            _slider.hidden = YES;
        }
        
        [_slider setMinimumTrackImage:[UIImage imageNamed:@"lum_slider"] forState:UIControlStateNormal];
        [_slider setMaximumTrackImage:[UIImage imageNamed:@"lum_slider"] forState:UIControlStateNormal];
        [self addSubview:_slider];
    }
    return _slider;
}

@end
