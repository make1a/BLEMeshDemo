//
//  WSTRGBC.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/25.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTRGBCView.h"

#import "WSTControlColorView.h"
#import "ColorNumber.h"
@interface WSTRGBCView()

/**bottomView*/
@property (nonatomic,strong) UIView *bottomView;
/**text*/
@property (nonatomic,strong) NSArray *colorNameArray;
@property (nonatomic,strong) NSArray *warmColdNameArray;
/**buttons*/
@property (nonatomic,strong) NSMutableArray<UIButton*> *buttons;
/**iscolor */
@property (nonatomic,assign) BOOL isColor;
@property (nonatomic,strong) UIButton *lastButton;
@property (nonatomic,strong) NSArray *dataSource;

@end
@implementation WSTRGBCView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isColor = YES;
        [self masLayoutSubviews];
    }
    return self;
}
- (void)clickButton:(UIButton *)sender{
    [sender zoomAnimation];
    if (sender.tag == 107) { //切换
        self.isColor = NO;
        self.pressButton(0, 0, 0, self.isColor);
        [self changeColor];
        
    }else if (sender == self.lastButton){
        self.isColor = YES;
        self.pressButton(0, 0, 0, self.isColor);
        [self changeColor];
        
    }else{
        
        if (self.isColor) {
            WSTColorModel *model = self.dataSource[sender.tag-100];
            [_colorView.colorBlock setFrame:[_colorView getColorPointInColorPickerHue:model.h Saturation:model.s]];
            if (self.pressButton) {
                self.pressButton(model.h,model.s,model.b,self.isColor);
            }
            
        }else{
            WSTColorModel *model = self.dataSource[sender.tag-100+7];
            [_colorView.colorBlock setFrame:[_colorView getTempPointInTempPickerTemp:model.warm]];
            if (self.pressButton) {
                self.pressButton(model.warm,model.cold, model.lum, self.isColor);
                [self.slider setValue:WCConfig_All[sender.tag-100].tb animated:YES];
            }
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [longPress.view zoomAnimationPop];
        if (self.longPress) {
            WSTColorModel *model;
            if (self.isColor == YES) {
                model = self.dataSource[longPress.view.tag - 100];
            }else{
                model = self.dataSource[longPress.view.tag - 100+7];
            }
            self.longPress(model,longPress.view.tag-100);
        }
    }
}
- (void)changeColor{
    int i = 0;
    for (UIButton *button in self.buttons) {
        UILabel *label = [self viewWithTag:10+i];
        if (self.isColor) { //彩色
            button.hidden = NO;
            [self viewWithTag:button.tag-90].hidden = NO;
            if (button.tag!=107) {
                WSTColorModel *model = self.dataSource[i];
                label.text = model.name;
                button.backgroundColor = [UIColor colorWithHue:model.h saturation:model.s brightness:model.b alpha:1];
            }else{
                label.text =  self.colorNameArray.lastObject;
                [button setBackgroundImage:[UIImage imageNamed:@"color_c"] forState:UIControlStateNormal];
                self.colorView.bgImageView.image = [UIImage imageNamed:@"hsb_circle"];
            }
        }else{ //冷暖
            if (button.tag!=107) {
                if (self.dataSource.count>i+7) {
                    WSTColorModel *model = self.dataSource[i+7];
                    button.backgroundColor = [UIColor colorWithHue:model.h saturation:model.s brightness:model.b alpha:1];
                    label.text = model.name;
                }
                
            }else{
                label.text =  self.warmColdNameArray.lastObject;
                [button setBackgroundImage:[UIImage imageNamed:@"color_icon"] forState:UIControlStateNormal];
                self.colorView.bgImageView.image = [UIImage imageNamed:@"color_c"];
            }
            if (button.tag>=104) {
                button.hidden = YES;
                [self viewWithTag:button.tag-90].hidden = YES;
            }
        }
        
        [_colorView.colorBlock setFrame:[_colorView getColorPointInColorPickerHue:0 Saturation:0]];
        i++;
    }
    
    if (self.isColor == YES) {
        self.lastButton.hidden = YES;
        [self viewWithTag:1000].hidden = YES;
    }else{
        self.lastButton.hidden = NO;
        [self viewWithTag:1000].hidden = NO;
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
        make.top.equalTo(self.slider.mas_bottom).mas_offset(px1334Hight(30));
    }];
    
    
    CGFloat space = px750Width(50);
    CGFloat hSpace = px1334Hight(80);
    CGFloat w = (SCREEN_WIDTH-(space*5))/4;
    NSInteger tag = 100;
    
    NSInteger tagt = 10;
    for (int j = 0;j<2;j++) {
        for (int i = 0; i<4; i++) {
            WSTColorModel *model = self.dataSource[tag-100];

            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = tag;
            button.frame = CGRectMake(i*w+((i+1)*space), j*w+((j+1)*hSpace), w, w );
            button.layer.cornerRadius = w/2;
            button.layer.masksToBounds = YES;
            button.layer.borderWidth = 2.f;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
            if (tag!=107) {
                button.backgroundColor = [UIColor colorWithHue:model.h saturation:model.s brightness:model.b alpha:1];
            }else{
                [button setBackgroundImage:[UIImage imageNamed:@"wram_cold_icon"] forState:UIControlStateNormal];
            }
            [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
            
            [self.bottomView addSubview:button];
            UILabel *label = [UILabel new];
            label.textColor = [UIColor whiteColor];
            label.tag = tagt;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:13];
            if (tagt == 17) {
                label.text = self.colorNameArray.lastObject;
            }else{
                label.text = model.name;
            }
            [self.bottomView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(button);
                make.top.equalTo(button.mas_bottom).mas_offset(px1334Hight(5));
            }];
            tag++;
            tagt++;
            [self.buttons addObject:button];
            
            if (button.tag != 107) {
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
                [button addGestureRecognizer:longPress];
            }
        }
    }
}



#pragma mark - 懒加载
- (ColorPickerView *)colorView{
    if (!_colorView) {
        _colorView = [[ColorPickerView alloc]init];
        _colorView.backgroundColor = [UIColor clearColor];
        _colorView.bgImageView.image = [UIImage imageNamed:@"hsb_circle"];
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
        _colorNameArray = @[LCSTR("color_red"), LCSTR("color_orang"), LCSTR("color_yello"), LCSTR("color_green"), LCSTR("color_cyan"), LCSTR("color_blue"), LCSTR("color_purpl"), LCSTR("Warm-Cold")];

    }
    return _colorNameArray;
}

- (NSArray *)warmColdNameArray{
    if (!_warmColdNameArray) {
        _warmColdNameArray = @[LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("25%"), LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("Color")];
        
    }
    return _warmColdNameArray;
}
- (NSMutableArray<UIButton *> *)buttons{
    if (!_buttons) {
        _buttons = [@[] mutableCopy];
    }
    return _buttons;
}

- (UIButton *)lastButton{
    if (!_lastButton) {
        _lastButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_lastButton];
        _lastButton.layer.borderColor = [UIColor whiteColor].CGColor;
        UIButton *b =self.buttons.firstObject;
        _lastButton.layer.masksToBounds = YES;
        _lastButton.layer.cornerRadius = b.frame.size.height/2;
        _lastButton.layer.borderWidth = 2.f;
        [_lastButton setBackgroundImage:[UIImage imageNamed:@"color_icon"] forState:UIControlStateNormal];
        
        [_lastButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchDown];
        
        [_lastButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(self.buttons.firstObject);
            make.centerX.equalTo(self);
            make.top.equalTo(self.buttons.lastObject);
        }];
        [self layoutIfNeeded];
        
        
        UILabel *label = [UILabel new];
        label.tag = 1000;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:13];
        label.text = self.warmColdNameArray.lastObject;
        [self.bottomView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_lastButton);
            make.top.equalTo(_lastButton.mas_bottom).mas_offset(px1334Hight(5));
        }];
    }
    return _lastButton;
}
- (NSArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [WSTColorModel selectFromClassPredicateWithFormat:@"where modelName = 'RGBC'"];
        if (_dataSource.count == 0) {
            [WSTColorModel insertDefaultModelWithRGBC];
            _dataSource = [WSTColorModel selectFromClassPredicateWithFormat:@"where modelName = 'RGBC'"];
        }
    }
    return _dataSource;
}
@end


