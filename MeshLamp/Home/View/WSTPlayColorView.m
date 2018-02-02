//
//  WSTPlayColorView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/12.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTPlayColorView.h"
#import "BreathCell.h"

@interface WSTPlayColorView()
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;

@end
@implementation WSTPlayColorView
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
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_collectionView];
        
        [_collectionView registerClass:[BreathCell class] forCellWithReuseIdentifier:@"BreathCell"];

    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayout
{
    if (!_collectionViewFlowLayout)
    {
        _collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewFlowLayout.minimumInteritemSpacing = Sp2Pt(1);
        _collectionViewFlowLayout.minimumLineSpacing = Sp2Pt(1.5);
        _collectionViewFlowLayout.sectionHeadersPinToVisibleBounds = YES;
        _collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(Sp2Pt(1), 0, 0, 0);
    }
    return _collectionViewFlowLayout;
}
@end
