//
//  WSTWView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/25.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTWView.h"
#import "WSTControlColorView.h"
#import "ColorNumber.h"
@interface WSTWView()

/**bottomView*/
@property (nonatomic,strong) UIView *bottomView;
/**text*/
@property (nonatomic,strong) NSArray *colorNameArray;
@property (nonatomic,strong) NSArray *warmColdNameArray;
/**buttons*/
@property (nonatomic,strong) NSMutableArray<UIButton*> *buttons;
@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,strong) UIButton *lastButton;
@end

@implementation WSTWView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self masLayoutSubviews];
    }
    return self;
}
- (void)clickButton:(UIButton *)sender{
    [sender zoomAnimation];
    WSTColorModel *model = self.dataSource[sender.tag-100];
    [_colorView.colorBlock setFrame:[_colorView getTempPointInTempPickerTemp:model.warm]];
    if (self.pressButton) {
        self.pressButton(model.warm,model.cold, model.lum, NO);
        [self.slider setValue:WCConfig_All[sender.tag-100].tb animated:YES];
    }
}
- (void)changeColor{
    int i = 0;
    for (UIButton *button in self.buttons) {
        UILabel *label = [self viewWithTag:10+i];
        
        WSTColorModel *model = self.dataSource[i];
        button.backgroundColor = [UIColor colorWithHue:model.h saturation:model.s brightness:model.b alpha:1];
        label.text = model.name;
        i++;
    }
}
#pragma mark - 布局
- (void)masLayoutSubviews{
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).mas_offset(px1334Hight(30));
        make.height.width.mas_equalTo(px750Width(550));
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.colorView.mas_bottom).mas_offset(px1334Hight(30));
        make.centerX.equalTo(self);
        make.width.mas_equalTo(px750Width(600));
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self).mas_offset(-px1334Hight(20));
        make.top.equalTo(self.slider.mas_bottom).mas_offset(px1334Hight(80));
    }];
    
    
    CGFloat space = px750Width(50);
    CGFloat hSpace = px1334Hight(80);
    CGFloat w = (SCREEN_WIDTH-(space*5))/4;
    NSInteger tag = 100;
    NSInteger tagt = 10;
    for (int j = 0;j<1;j++) {
        for (int i = 0; i<4; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = tag;
            button.frame = CGRectMake(i*w+((i+1)*space), j*w+((j+1)*hSpace), w, w );
            button.layer.cornerRadius = w/2;
            button.layer.masksToBounds = YES;
            button.layer.borderWidth = 2.f;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
            button.backgroundColor = [UIColor colorWithHue:WCConfig_All[button.tag-100].h saturation:WCConfig_All[button.tag-100].s brightness:WCConfig_All[button.tag-100].b alpha:1];
            [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
            
            [self.bottomView addSubview:button];
            UILabel *label = [UILabel new];
            label.textColor = [UIColor whiteColor];
            label.tag = tagt;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:13];
            label.text = self.warmColdNameArray[tag-100];
            [self.bottomView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(button);
                make.top.equalTo(button.mas_bottom).mas_offset(px1334Hight(5));
            }];
            tag++;
            tagt++;
            [self.buttons addObject:button];
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
            [button addGestureRecognizer:longPress];
            
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [longPress.view zoomAnimationPop];
        if (self.longPress) {
            WSTColorModel *model;
            model = self.dataSource[longPress.view.tag - 100];
            self.longPress(model,longPress.view.tag-100);
        }
    }
}


#pragma mark - 懒加载
- (ColorPickerView *)colorView{
    if (!_colorView) {
        _colorView = [[ColorPickerView alloc]init];
        _colorView.backgroundColor = [UIColor clearColor];
        _colorView.bgImageView.image = [UIImage imageNamed:@"icon_ctrl_w_mode"];
        [self addSubview:_colorView];
    }
    return _colorView;
}
- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc]init];
        [_slider setMinimumTrackImage:[UIImage imageNamed:@"lum_slider"] forState:UIControlStateNormal];
        [_slider setMaximumTrackImage:[UIImage imageNamed:@"lum_slider"] forState:UIControlStateNormal];
        [self addSubview:_slider];
    }
    return _slider;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        [self addSubview:_bottomView];
    }
    return _bottomView;
}
- (NSArray *)colorNameArray{
    if (!_colorNameArray) {
        _colorNameArray = @[LCSTR("color_red"), LCSTR("color_orang"), LCSTR("color_yello"), LCSTR("color_green"), LCSTR("color_cyan"), LCSTR("color_blue"), LCSTR("color_purpl"), LCSTR("Warm-Cold")];    }
    return _colorNameArray;
}

- (NSArray *)warmColdNameArray{
    if (!_warmColdNameArray) {
        _warmColdNameArray = @[LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("25%"), LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("25%")];    }
    return _warmColdNameArray;
}
- (NSMutableArray<UIButton *> *)buttons{
    if (!_buttons) {
        _buttons = [@[] mutableCopy];
    }
    return _buttons;
}
- (NSArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [WSTColorModel selectFromClassPredicateWithFormat:@"where modelName = 'W'"];
        if (_dataSource.count == 0) {
            [WSTColorModel insertDefaultModelWithW];
            _dataSource = [WSTColorModel selectFromClassPredicateWithFormat:@"where modelName = 'W'"];
        }
    }
    return _dataSource;
}
@end

