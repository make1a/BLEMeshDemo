//
//  WSTInputView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/9.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTInputView.h"
//#import "WSTAlertView.h"
@interface WSTInputView ()

@end
@implementation WSTInputView

- (instancetype)init
{
    self = [super initWithType:WSTAlertTypeInput];
    if (self) {
        [self masLayoutSubviews];
    }
    return self;
}

- (void)masLayoutSubviews{
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.centerView).mas_offset(px750Width(32));
        make.right.equalTo(self.centerView).mas_offset(px750Width(-32));
        make.top.equalTo(self.centerView).mas_offset(px1334Hight(30));
        make.height.mas_equalTo(px1334Hight(72));
    }];

}



- (UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc]init];
        _textField.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1.0];
        _textField.font = [UIFont systemFontOfSize:px750Width(36)];
//        _textField.delegate = self;
        [self.centerView addSubview:_textField];
    }
    return _textField;
}
@end
