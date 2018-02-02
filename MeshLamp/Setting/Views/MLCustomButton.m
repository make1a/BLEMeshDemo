//
//  MLCustomButton.m
//  doonne
//
//  Created by new on 2017/7/6.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//
#define radio 0.65

#import "MLCustomButton.h"
@implementation MLCustomButton
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        // 1.图片居中
        self.imageView.contentMode = UIViewContentModeCenter;
        
        // 2.文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

/**
 *  目的是去掉父类在高亮时所做的操作
 */
- (void)setHighlighted:(BOOL)highlighted {}

#pragma mark - 覆盖父类的2个方法
#pragma mark - 设置按钮图片的frame
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat imageH = contentRect.size.height * radio;
    CGFloat imageW = contentRect.size.width;
    return CGRectMake(0, 0, imageW,  imageH);
}

#pragma mark - 设置按钮文字的frame
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat titleY = contentRect.size.height * radio;
    CGFloat titleH = contentRect.size.height - titleY;
    CGFloat titleW = contentRect.size.width;
    return CGRectMake(0, titleY, titleW, titleH);
}

@end
