//
//  WSTOTAContainerView.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/20.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKECircleView.h"

@interface WSTOTAContainerView : UIView
/**button*/
@property (nonatomic,strong) UIButton *sender;
@property (nonatomic,strong) UILabel *notiLabel2;
@property (nonatomic,strong) MKECircleView *circleView;
- (void)setProgress:(CGFloat)value;
@end
