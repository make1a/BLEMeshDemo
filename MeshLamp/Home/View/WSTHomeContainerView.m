//
//  HomeContainerView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/29.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTHomeContainerView.h"
#import "WSTHomeGorupShowModel.h"
#import "WSTHomeGroupCell.h"
#import "WSTHomeGroupBtnCell.h"
#import "WSTHomeDeviceCell.h"
#import "WSTHomeGroupHeadView.h"
@interface WSTHomeContainerView()
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;
@end
@implementation WSTHomeContainerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_addMasonry];
        
    }
    return self;
}


#pragma mark - # Private Methods
- (void)p_addMasonry
{
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self);
     }];
     
}



- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewFlowLayout];
        [_collectionView setBackgroundColor:[UIColor colorWithRed:21/255.0 green:37/255.0 blue:52/255.0 alpha:1.0]];

        [self addSubview:_collectionView];
        
        [_collectionView registerNib:[UINib nibWithNibName:@"WSTHomeGroupBtnCell" bundle:nil] forCellWithReuseIdentifier:@"WSTHomeGroupBtnCell"];

        [_collectionView registerNib:[UINib nibWithNibName:@"WSTHomeGroupCell" bundle:nil] forCellWithReuseIdentifier:@"WSTHomeGroupCell"];
        
        [_collectionView registerNib:[UINib nibWithNibName:@"WSTHomeGroupHeadView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTHomeGroupHeadView"];

        [_collectionView registerNib:[UINib nibWithNibName:@"WSTHomeDeviceCell" bundle:nil] forCellWithReuseIdentifier:@"WSTHomeDeviceCell"];

        [_collectionView registerNib:[UINib nibWithNibName:@"WSTHomeDeviceHeadView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTHomeDeviceHeadView"];
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
