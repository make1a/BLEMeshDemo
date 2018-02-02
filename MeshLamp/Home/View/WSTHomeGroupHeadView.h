//
//  WSTHomeGroupHeadView.h
//  MeshLamp
//
//  Created by make on 2017/10/2.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSTHomeGroupHeadView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *headTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *HidButton;

- (void)viewRefresWith:(WSTHomeGorupShowModel*)model;
@end
