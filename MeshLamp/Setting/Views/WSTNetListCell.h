//
//  WSTNetListCell.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/11.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSTHomeInfo.h"


@interface WSTNetListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

- (void)cellRefreshWithHomeList:(NSIndexPath *)indexPath homeInfo:(WSTHomeInfo *)info index:(NSInteger)index;
- (void)cellRefreshWithEditDevice:(NSIndexPath *)indexPath roomArray:(NSArray *)roomArray;
@end
