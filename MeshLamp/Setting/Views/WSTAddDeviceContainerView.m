//
//  WSTAddDeviceContainerView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/12.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTAddDeviceContainerView.h"
@interface WSTAddDeviceContainerView()
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UILabel *notiLabel;
@property (nonatomic,strong) UILabel *numberLabel;
@end

@implementation WSTAddDeviceContainerView
- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = BGColor;
        [self masLayoutSubviews];
    }
    return self;
}


#pragma mark ------------ 布局 --------------
- (void)masLayoutSubviews{
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(px1334Hight(80));
    }];

    [self.notiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.centerY.equalTo(self.topView);
    }];

//    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.topView);
//        make.right.equalTo(self.topView.mas_right).mas_offset(-8);
//    }];
    
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).mas_offset(-10);
        make.left.equalTo(self).mas_offset(20);
        make.right.equalTo(self).mas_offset(-20);
        make.height.mas_equalTo(px1334Hight(90));
    }] ;
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.addButton.mas_top);
    }];
    
}


#pragma mark ------------ 懒加载 --------------
- (UIButton *)addButton{
    if(!_addButton){
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.backgroundColor = [UIColor clearColor];
        [_addButton setTitle:LCSTR("add_device") forState:UIControlStateNormal];
        [_addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addButton setTitle:LCSTR("停止添加") forState:UIControlStateSelected];
        [_addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_addButton setBackgroundColor:[UIColor colorWithRed:254/255.0 green:204/255.0 blue:55/255.0 alpha:1.0]];
        _addButton.layer.masksToBounds = YES;
        _addButton.layer.cornerRadius = px1334Hight(90)/2;
        [self addSubview:_addButton];
    }
    return _addButton;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewFlowLayout];
        _collectionView. backgroundColor = [UIColor clearColor];
        [self addSubview:_collectionView];
        
        [_collectionView registerNib:[UINib nibWithNibName:@"WSTHomeDeviceCell" bundle:nil] forCellWithReuseIdentifier:@"WSTHomeDeviceCell"];
        
        [_collectionView registerNib:[UINib nibWithNibName:@"WSTGroupHeadView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTGroupHeadView"];
    
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

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor colorWithRed:254/255.0 green:204/255.0 blue:55/255.0 alpha:1.0];
        [self addSubview:_topView];
    }
    return _topView;
}

- (UILabel *)notiLabel{
    if (!_notiLabel) {
        _notiLabel = [UILabel new];
        _notiLabel.text = @"";
        _notiLabel.font = [UIFont systemFontOfSize:px750Width(32)];
        _notiLabel.textColor = [UIColor blackColor];
        [self.topView addSubview:_notiLabel];
    }
    return _notiLabel;
}
- (UILabel *)numberLabel{
    if (!_numberLabel) {
        _numberLabel = [UILabel new];
        _numberLabel.text = @"0";
        _numberLabel.font = [UIFont systemFontOfSize:px750Width(32)];
        _numberLabel.textColor = [UIColor blackColor];
        [self.topView addSubview:_numberLabel];
    }
    return _numberLabel;
}


- (void)setNotice:(NSString *)notice{
    [UIView animateWithDuration:.1 animations:^{
        self.notiLabel.text = notice;
        self.notiLabel.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.notiLabel.alpha = 1.0;
        }
    }];
    
    
}

- (void)setNumber:(NSInteger)number{
    self.numberLabel.text = [NSString stringWithFormat:@"%ld",number];
}
@end


