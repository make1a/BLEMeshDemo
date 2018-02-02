//
//  WSTGroupDeviceCell.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/11.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSTGroupDeviceCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *maskImageView;

- (void)cellRefreshWithModel:(WZBLEDataModel *)model indexPath:(NSIndexPath *)indexPath;
@end
