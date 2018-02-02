//
//  MKEButton.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/30.
//  Copyright © 2017年 make. All rights reserved.
//

#import "MKEButton.h"

@implementation MKEButton

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //适合大按钮使用，小按钮使用这种方法很难点击到image
    /*
    // image center
    CGPoint center;
    center.x = self.frame.size.width/2;
    center.y = self.imageView.frame.size.height/2;
    self.imageView.center = center;
    
    //text
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.imageView.frame.size.height + 5;
    newFrame.size.width = self.frame.size.width;
    
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    */
    
}


- (void)setLzType:(LZRelayoutButtonType)lzType {
    _lzType = lzType;
    
    if (lzType != LZRelayoutButtonTypeNomal) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    self.offset = 5;
}

//重写父类方法,改变标题和image的坐标
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    
    if (self.lzType == LZRelayoutButtonTypeLeft) {
        
        CGFloat x = contentRect.size.width - self.offset - self.imageSize.width ;
        CGFloat y =  contentRect.size.height -  self.imageSize.height;
        y = y/2;
        
        
        CGRect rect = CGRectMake(x,y,self.imageSize.width,self.imageSize.height);
        
        return rect;
    } else if (self.lzType == LZRelayoutButtonTypeBottom) {
        
        CGFloat x =  contentRect.size.width -  self.imageSize.width;
        
        CGFloat  y=   self.offset   ;
        
        x = x / 2;
        
        CGRect rect = CGRectMake(x,y,self.imageSize.width,self.imageSize.height);
        
        return rect;
        
    } else {
        return [super imageRectForContentRect:contentRect];
    }
    
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    
    if (self.lzType == LZRelayoutButtonTypeLeft) {
        
        return CGRectMake(-_offset , 0, contentRect.size.width - self.offset - self.imageSize.width , contentRect.size.height);
        
        
    } else if (self.lzType == LZRelayoutButtonTypeBottom) {
        
        return CGRectMake(0,   self.offset + self.imageSize.height , contentRect.size.width , contentRect.size.height - self.offset - self.imageSize.height );
        
    } else {
        return [super titleRectForContentRect:contentRect];
    }
}
@end
