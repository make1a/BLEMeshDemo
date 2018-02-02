//
//  WSTControlColorView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/12.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTControlColorView.h"
#import "ColorNumber.h"

@interface WSTControlColorView()

/**bottomView*/
@property (nonatomic,strong) UIView *bottomView;
/**text*/
@property (nonatomic,strong) NSArray *colorNameArray;
@property (nonatomic,strong) NSArray *warmColdNameArray;
/**buttons*/
@property (nonatomic,strong) NSMutableArray<UIButton*> *buttons;
/**iscolor */
@property (nonatomic,assign) BOOL isColor;
/**颜色*/
@property (nonatomic,strong) NSArray *dataSource;
@end
@implementation WSTControlColorView

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
        self.isColor = !self.isColor;
        self.pressButton(0, 0, 0, self.isColor);
        [self refreshColor];
    }else{
        
        if (self.isColor) {
           WSTColorModel *model = self.dataSource[sender.tag-100];
            [_colorView.colorBlock setFrame:[_colorView getColorPointInColorPickerHue:model.h Saturation:model.s]];
            if (self.pressButton) {
                self.pressButton(model.h,model.s,model.b,self.isColor);
            }
            
        }else{
            WSTColorModel *model = self.dataSource[sender.tag-100+7];
              [_colorView.colorBlock setFrame:[_colorView getTempPointInTempPickerTemp:model.cold]];
            if (self.pressButton) {
                self.pressButton(model.warm,model.cold, model.lum, self.isColor);
            }
            
        }

    }
    

}
- (void)refreshColor{
    int i = 0;
    for (UIButton *button in self.buttons) {
        UILabel *label = [self viewWithTag:10+i];
        if (self.isColor) { //彩色
            if (button.tag!=107) {
                WSTColorModel *model = self.dataSource[i];
                label.text = model.name;
                button.backgroundColor = [UIColor colorWithHue:model.h saturation:model.s brightness:model.b alpha:1];
            }else{
                label.text =  self.colorNameArray.lastObject;
                [button setBackgroundImage:[UIImage imageNamed:@"wram_cold_icon"] forState:UIControlStateNormal];
                self.colorView.bgImageView.image = [UIImage imageNamed:@"hsb_circle"];
            }
        }else{ //冷暖
            if (button.tag!=107) {
                WSTColorModel *model = self.dataSource[i+7];
                button.backgroundColor = [UIColor colorWithHue:model.h saturation:model.s brightness:model.b alpha:1];
                label.text = model.name;
            }else{
                label.text =  self.warmColdNameArray.lastObject;
                [button setBackgroundImage:[UIImage imageNamed:@"color_icon"] forState:UIControlStateNormal];
                self.colorView.bgImageView.image = [UIImage imageNamed:@"warm_cold_circle"];
            }
        }
        
        [_colorView.colorBlock setFrame:[_colorView getColorPointInColorPickerHue:0 Saturation:0]];
        
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
        make.top.equalTo(self.slider.mas_bottom).mas_offset(px1334Hight(30));
    }];
    
    
    CGFloat space = px750Width(50);
    CGFloat hSpace = px1334Hight(80);
    CGFloat w = (SCREEN_WIDTH-(space*5))/4;
    NSInteger tag = 100;
    NSInteger tagg = 10;
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
            label.tag = tagg;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:13];
            if (tagg == 17) {
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
            tagg++;
            [self.buttons addObject:button];
            if (button.tag != 107) {
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
                [button addGestureRecognizer:longPress];
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
        _warmColdNameArray = @[LCSTR("3000k"), LCSTR("3500k"), LCSTR("4000k"), LCSTR("4500k"), LCSTR("5000k"), LCSTR("5500k"), LCSTR("6000k"), LCSTR("Color")];
        
    }
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
        _dataSource = [WSTColorModel selectFromClassPredicateWithFormat:@"where modelName = 'RGBWC'"];
        if (_dataSource.count == 0) {
            [WSTColorModel insertDefaultModelWithRGBWC];
            _dataSource = [WSTColorModel selectFromClassPredicateWithFormat:@"where modelName = 'RGBWC'"];
        }
    }
    return _dataSource;
}
@end
