//
//  WSTGroupManageCell.h
//  MeshLamp
//
//  Created by make on 2017/10/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSTGroupManageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;


- (void)cellRefreshWithIndexPath:(NSIndexPath *)indexPath roomArray:(NSArray *)array;
@end
