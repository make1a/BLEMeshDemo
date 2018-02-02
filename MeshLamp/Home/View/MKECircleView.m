//
//  MKECircleView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/20.
//  Copyright © 2017年 make. All rights reserved.
//

#import "MKECircleView.h"

CGFloat lineWidth = 10.f;

@interface MKECircleView()
{
    UIBezierPath *bottomPath;
    UIBezierPath *path;
    CAShapeLayer *layer;
}

@end

@implementation MKECircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self masLayoutSubview];
    }
    return self;
}

- (void)masLayoutSubview{
    
    bottomPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0) radius:self.frame.size.width/2.0 - 10 startAngle:- M_PI_2 endAngle:-M_PI_2 + M_PI * 2 clockwise:YES];

    CAShapeLayer *bottomLayer = [CAShapeLayer layer];
    bottomLayer.frame = self.bounds;
    bottomLayer.path = bottomPath.CGPath;
    bottomLayer.lineWidth = lineWidth;
    bottomLayer.strokeColor = [UIColor grayColor].CGColor;
    bottomLayer.fillColor = nil;
    [self.layer addSublayer:bottomLayer];

    
    layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.lineWidth = lineWidth;
    layer.fillColor = nil;
    layer.lineCap = kCALineCapRound;
    self.layer.contentsScale = [[UIScreen mainScreen]scale];
    [self.layer addSublayer:layer];
    
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
    }];
    
}

- (void)setProgress:(CGFloat)value{
    
    path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)  radius:self.frame.size.width/2.0 - 10
                                                    startAngle:3*M_PI_2 endAngle:3*M_PI_2+(2*M_PI*value) clockwise:YES];

    layer.path = path.CGPath;
    
    if (value == 1) {
        layer.strokeColor = [UIColor greenColor].CGColor;
    }else{
        layer.strokeColor = [UIColor colorWithRed:250/255.0 green:212/255.0 blue:83/255.0 alpha:1.0].CGColor;
    }

    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    animation.fromValue = @(0.0);
//    animation.toValue = @(1.0);
//    animation.duration = 1.f;
//    [layer addAnimation:animation forKey:nil];
    
    if (value == 1) {
        self.numberLabel.textColor = [UIColor greenColor];
    }
    NSString *str = [NSString stringWithFormat:@"%.0f%%",value*100];
    self.numberLabel.text = str;
}
- (void)setCircleColor:(UIColor *)color{
    layer.strokeColor = color.CGColor;
}

#pragma mark - 懒加载
- (UILabel *)numberLabel{
    if (!_numberLabel) {
        _numberLabel = [UILabel new];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.font = [UIFont systemFontOfSize:18];
        _numberLabel.text = @"0%";
        [self addSubview:_numberLabel];
    }
    return _numberLabel;
}
@end
