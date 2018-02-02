//
//  WSTHomeGroupBtnCell.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/30.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKEButton.h"

@interface WSTHomeGroupBtnCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet MKEButton *controlBtn;
@property (weak, nonatomic) IBOutlet MKEButton *mangageBtn;
@property (weak, nonatomic) IBOutlet MKEButton *deleteBtn;

/** block */
@property (nonatomic,copy) void(^pressControlBlock)(void);
@property (nonatomic,copy) void(^pressManageBlock)(void);
@property (nonatomic,copy) void(^pressDeleteBlock)(void);

- (void)cellRefreshWith:(NSIndexPath *)indexPath;
@end
