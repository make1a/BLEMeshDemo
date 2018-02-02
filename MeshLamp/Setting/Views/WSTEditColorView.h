//
//  WSTEditColorView.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/11/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPickerView.h"

@interface WSTEditColorView : UIView
@property (nonatomic,strong) ColorPickerView *colorView;
@property (nonatomic,strong) UIButton *sumbitButton;
@property (nonatomic,strong) UIButton *defaultButton;
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) UISlider *slider;
/**Description */
@property (nonatomic,assign) BOOL isColor;

- (instancetype)initWithSingleColor:(BOOL)isColor isSingle:(BOOL)isSingle;

@end
