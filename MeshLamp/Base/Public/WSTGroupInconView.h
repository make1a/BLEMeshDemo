//
//  WSTGroupInconView.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/10.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTBaseAlertView.h"
//typedef void (^clickIconBlock)(UIButton *sender);
@interface WSTGroupInconView : WSTBaseAlertView
/**图片数组*/
@property (nonatomic,strong,readonly) NSArray *imageArray;

/**block*/
@property (nonatomic,copy) void(^pressBlock)(NSInteger index);
@end
