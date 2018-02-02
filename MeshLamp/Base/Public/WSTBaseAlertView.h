//
//  WSTBaseAlertView.h
//  MeshLamp
//
//  Created by make on 2017/10/8.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger,WSTAlertType){
    WSTAlertTypeInput = 0,
    WSTAlertTypeGroupIcon,
    WSTAlertTypeTelecontrol,
    WSTAlertTypeDatePicker,
    WSTAlertTypeTimePicker,
};




@interface WSTBaseAlertView : UIView

/** 取消 */
@property (nonatomic,strong) UIButton *leftButton;
/** 确定 */
@property (nonatomic,strong) UIButton *rightButton;
/** title */
@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong) UIView *centerView;

- (instancetype)initWithType:(WSTAlertType)type;

- (void)addWithSuperView:(UIView *)superView;
@end
