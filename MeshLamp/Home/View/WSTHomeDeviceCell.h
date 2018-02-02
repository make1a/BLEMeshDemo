//
//  WSTHomeDeviceCell.h
//  MeshLamp
//
//  Created by make on 2017/10/2.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZBLEDataModel.h"
@interface WSTHomeDeviceCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

/**blcol */
@property (nonatomic,copy) void(^longPressBlock)(void);
- (void)refreshWithModel:(WZBLEDataModel*)model indexPath:(NSIndexPath*)indexPath;
@end
