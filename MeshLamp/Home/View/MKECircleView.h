//
//  MKECircleView.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/20.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKECircleView : UIView
/**label*/
@property (nonatomic,strong) UILabel *numberLabel;

- (void)setProgress:(CGFloat)value;
- (void)setCircleColor:(UIColor *)color;
@end
