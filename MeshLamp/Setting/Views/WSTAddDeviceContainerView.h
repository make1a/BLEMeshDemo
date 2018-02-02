//
//  WSTAddDeviceContainerView.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/12.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSTAddDeviceContainerView : UIView
/**add button*/
@property (nonatomic,strong) UIButton *addButton;
/**collectionView*/
@property (nonatomic,strong) UICollectionView *collectionView;

/**notice */
@property (nonatomic,copy) NSString *notice;
/**数量 */
@property (nonatomic,assign) NSInteger number;
@end
