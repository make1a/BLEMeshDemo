//
//  HomeGroupCell.h
//  doonne
//
//  Created by new on 2017/9/5.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSTHomeGorupShowModel.h"

@interface WSTHomeGroupCell : UICollectionViewCell


@property (assign, nonatomic) int row;
@property (weak, nonatomic) IBOutlet UIImageView *groupImage;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLable;
@property (weak, nonatomic) IBOutlet UIButton *onButton;
@property (weak, nonatomic) IBOutlet UIButton *offButton;
/**block */
@property (nonatomic,copy) void(^pressOnButton)(void);
@property (nonatomic,copy) void(^pressOffButton)(void);

- (void)cellRefreshWithArray:(NSArray<WSTHomeGorupShowModel*>*)dataSource indexPath:(NSIndexPath *)indexPath;
@end
