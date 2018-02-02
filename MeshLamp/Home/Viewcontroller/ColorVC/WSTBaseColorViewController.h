//
//  WSTControlViewController.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/12.
//  Copyright © 2017年 make. All rights reserved.
//

#import "BaseViewController.h"

@interface WSTBaseColorViewController : BaseViewController<WZBlueToothDataSource>

/**leftview*/
@property (nonatomic,strong) UIView *leftContainerView;

/**是否是群组 */
@property (nonatomic,assign) BOOL isRoom;
@property (nonatomic) int     devAddr;
@property (nonatomic,assign) BOOL isColor;

- (void)changeLum:(UISlider *)slider;
@end

