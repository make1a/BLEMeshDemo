//
//  WSTGroupDeviceHeadView.h
//  MeshLamp
//
//  Created by make on 2017/10/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSTGroupDeviceHeadView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *headLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@end
