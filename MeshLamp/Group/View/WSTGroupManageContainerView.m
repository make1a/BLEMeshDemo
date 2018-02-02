//
//  WSTGroupManageContainerView.m
//  MeshLamp
//
//  Created by make on 2017/10/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTGroupManageContainerView.h"
@interface WSTGroupManageContainerView()
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;


@end


@implementation WSTGroupManageContainerView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self masLayoutSubviews];
    }
    return self;
}


#pragma mark ------------ 布局 --------------
- (void)masLayoutSubviews{

    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self);
    }];
}

#pragma mark ------------ 懒加载 --------------


- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewFlowLayout];
        [_collectionView setBackgroundColor:[UIColor colorWithRed:21/255.0 green:37/255.0 blue:52/255.0 alpha:1.0]];

        [self addSubview:_collectionView];

        [_collectionView registerNib:[UINib nibWithNibName:@"WSTGroupManageCell" bundle:nil] forCellWithReuseIdentifier:@"WSTGroupManageCell"];

        [_collectionView registerNib:[UINib nibWithNibName:@"WSTGroupIconCell" bundle:nil] forCellWithReuseIdentifier:@"WSTGroupIconCell"];

        [_collectionView registerNib:[UINib nibWithNibName:@"WSTHomeDeviceCell" bundle:nil] forCellWithReuseIdentifier:@"WSTHomeDeviceCell"];


        [_collectionView registerNib:[UINib nibWithNibName:@"WSTGroupHeadView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTGroupHeadView"];

        [_collectionView registerNib:[UINib nibWithNibName:@"WSTGroupDeviceHeadView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTGroupDeviceHeadView"];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayout
{
    if (!_collectionViewFlowLayout)
    {
        _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _collectionViewFlowLayout;
}
@end
