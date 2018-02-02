//
//  WSTWView.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/25.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPickerView.h"

@interface WSTWView : UIView
/**ColorPickerView*/
@property (nonatomic,strong) ColorPickerView *colorView;
/**slider*/
@property (nonatomic,strong) UISlider *slider;
/**button的点击 */
@property (nonatomic,copy) void(^pressButton)(CGFloat h, CGFloat s,CGFloat b,BOOL isColor);
@property (nonatomic,strong) void (^longPress)(WSTColorModel *model,NSInteger index);
- (void)changeColor;
@end
