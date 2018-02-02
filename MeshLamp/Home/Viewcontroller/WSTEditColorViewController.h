//
//  WSTEditColorViewController.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/11/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import "BaseViewController.h"

@interface WSTEditColorViewController : BaseViewController
/**是否彩色 */
@property (nonatomic,assign) BOOL isColor;
/**单色？YES -是  NO-否  */
@property (nonatomic,assign) BOOL isSingle;
/**是否暖色 */
@property (nonatomic,assign) BOOL isWarm;
/**meshID */
@property (nonatomic,assign) int devAddr;
@property (nonatomic,assign) BOOL isRoom;
/**Description*/
@property (nonatomic,strong) WSTColorModel *currentModel;
/**Description */
@property (nonatomic,assign) NSInteger index;
@end
