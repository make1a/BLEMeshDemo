//
//  WSTGroupManageViewController.m
//  MeshLamp
//
//  Created by make on 2017/10/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTGroupManageVC.h"
#import "WSTGoupEditDeviceVC.h"

//views
#import "WSTGroupManageContainerView.h"
#import "WSTGroupIconCell.h"
#import "WSTGroupManageCell.h"
#import "WSTHomeDeviceCell.h"
#import "WSTGroupHeadView.h"
#import "WSTGroupDeviceHeadView.h"
#import "WSTInputView.h"
#import "WSTGroupInconView.h"
#import "WSTTelecontrolView.h"

//model
#import "WSTHomeGorupShowModel.h"


@interface WSTGroupManageVC ()<UICollectionViewDataSource,UICollectionViewDataSourcePrefetching,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
/** WSTGroupManageViewController */
@property (nonatomic,strong) WSTGroupManageContainerView *containerView;
/// collectionView群组数据源
@property (nonatomic, strong) NSMutableArray *data;
/**修改群组名称*/
@property (nonatomic,strong) WSTInputView *alertView;
/**修改群组图标*/
@property (nonatomic,strong) WSTGroupInconView *iconView;
/**绑定遥控器*/
@property (nonatomic,strong) WSTTelecontrolView *telecontrolView;

/**保存一张图片*/
@property (nonatomic,strong) NSString *imageStr;
/**遥控器地址*/
@property (nonatomic,strong) NSMutableArray *roomArray;
@end


@implementation WSTGroupManageVC
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [WZBlueToothDataManager shareInstance].delegate = self;
    [self getGroupDecvices];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    [self getGroupStatus];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [WZBlueToothDataManager shareInstance].delegate = nil;
}

- (void)setNavigationStyle{
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setNavigationTitle:LCSTR("group_manage") titleColor:[UIColor whiteColor]];
}
#pragma mark - 事件
- (void)getGroupDecvices{
   self.data = [[WSTGroupDevice getCurrentGroupDevices] mutableCopy]; //获取当前群组内的设备
    [self.containerView.collectionView reloadData];
}
- (void)getGroupStatus{
//    [[WZBlueToothDataManager shareInstance] getAllGroupAddressWithDevice:(uint32_t)[AppDelegate instance].currentGroup.groupAddress isGroup:YES];
    self.roomArray = [[WSTGroupKey getCurrentKeyDevices] mutableCopy];
    [self.containerView.collectionView reloadData];
}
#pragma mark - actions
- (void)pushEditAction:(UIButton *)sender{
    WSTGoupEditDeviceVC *vc = [[WSTGoupEditDeviceVC alloc]init];
    vc.keyArray = self.roomArray;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)alterNameAction:(id)sender{
    [SVProgressHUD setContainerView:nil];
    NSString *name = self.alertView.textField.text;
    if (name.length == 0) {
        [SVProgressHUD showErrorWithStatus:LCSTR("name_can_not_null")];
        return;
    }
    
    NSString *homeName = [[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
    NSString *str = [NSString stringWithFormat:@"where home = '%@' and name = '%@'",homeName,name];
    NSArray *deviceArray = [WZBLEDataModel selectFromClassPredicateWithFormat:str];
    
    NSString *str2 = [NSString stringWithFormat:@"where homeName = '%@' and name = '%@'",homeName,name];
    NSArray *groupArray = [WSTHomeGorupShowModel selectFromClassPredicateWithFormat:str2];
    
    
    if (![[AppDelegate instance].currentGroup.name isEqualToString:name]) {
        if (deviceArray.count != 0 || groupArray.count != 0) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@%@",LCSTR("group_name"),LCSTR("repeat")]];
            return;
        }
    }
    
    [AppDelegate instance].currentGroup.name = name;
    [AppDelegate instance].currentGroup.item = 1;
    [[AppDelegate instance].currentGroup updateObject];
    [self.containerView.collectionView reloadData];
    [self.alertView removeFromSuperview];
}

- (void)alertGroupIcon:(UIButton *)sender{
    if (self.imageStr.length == 0) {
        [self.iconView removeFromSuperview];
    }else{
        [AppDelegate instance].currentGroup.imageStr = self.imageStr;
        [[AppDelegate instance].currentGroup updateObject];
        [self.containerView.collectionView reloadData];
        [self.iconView removeFromSuperview];
    }
}
#pragma mark - WZBlueToothDataManagerDelegate
//- (void)responseOfDeviceHasGroupsArray:(GroupInfo *)info{
//    self.roomArray = [info.groupArray mutableCopy];
//    [self.containerView.collectionView reloadData];
//}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
        default:
            return self.data.count;
            break;
    }

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0 && indexPath.section<2) {
        WSTGroupManageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSTGroupManageCell" forIndexPath:indexPath];
        [cell cellRefreshWithIndexPath:indexPath roomArray:self.roomArray];
        return cell;
    }else if (indexPath.item == 1 && indexPath.section == 0){
        WSTGroupIconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSTGroupIconCell" forIndexPath:indexPath];
        cell.iconImageView.image = [UIImage imageNamed:[AppDelegate instance].currentGroup.imageStr];
        cell.leftLabel.text = LCSTR("group_icon");
        return cell;
    }else{
        WSTHomeDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSTHomeDeviceCell" forIndexPath:indexPath];
        WZBLEDataModel *model = self.data[indexPath.item];
        [cell refreshWithModel:model indexPath:indexPath];
        cell.deviceNameLabel.font = [UIFont systemFontOfSize:px750Width(26)];
        return cell;
    }

}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0 && indexPath.section == 0) {
        if (self.alertView) {
            self.alertView.textField.text = @"";
            self.alertView.textField.placeholder = [AppDelegate instance].currentGroup.name;
            [self.alertView addWithSuperView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.alertView.textField becomeFirstResponder];
            });
            
            [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }
    }else if (indexPath.item == 1 && indexPath.section == 0){
        if (self.iconView) {
            [self.iconView addWithSuperView:self.view];
            [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }
    }else if (indexPath.item == 0 && indexPath.section == 1){
        if (self.telecontrolView) {
            [self.telecontrolView addWithSuperView:self.view];
            [_telecontrolView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (section<2) {
        return CGFLOAT_MIN;
    }else{
        return px750Width(10);
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return px750Width(10);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section<2) {
        return UIEdgeInsetsMake(px1334Hight(5), 0, px1334Hight(5), 0);
    }else{
        return UIEdgeInsetsMake(px750Width(10),px750Width(10),0,px750Width(10));
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section < 2) {
        return CGSizeMake(SCREEN_WIDTH, px1334Hight(91));
    }else{
        return CGSizeMake(px750Width(174), px750Width(174));
    }


}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WSTGroupHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTGroupHeadView" forIndexPath:indexPath];
        return headView;
    }else if (indexPath.section == 2){
        WSTGroupDeviceHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTGroupDeviceHeadView" forIndexPath:indexPath];
        [headView.addButton addTarget:self action:@selector(pushEditAction:) forControlEvents:UIControlEventTouchDown];
        [headView.deleteButton addTarget:self action:@selector(pushEditAction:) forControlEvents:UIControlEventTouchDown];
        return headView;
    }

    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0|| section ==2) {
        return CGSizeMake(SCREEN_WIDTH, px1334Hight(100));
    }else{
        return CGSizeZero;
    }

}

/*
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    for (NSIndexPath *indexPath in indexPaths) {
    }
}

- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    for (NSIndexPath *indexPath in indexPaths) {
    }

}
 */
#pragma mark ------------ 布局 --------------
- (void)masLayoutSubview{
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
}
#pragma mark ------------ 懒加载 --------------
- (WSTGroupManageContainerView *)containerView{
    if (!_containerView) {
        _containerView = [[WSTGroupManageContainerView alloc]init];
        _containerView.collectionView.delegate = self;
        _containerView.collectionView.dataSource = self;
        if (@available(iOS 10.0, *)) {
            _containerView.collectionView.prefetchDataSource = self;
        } else {

        }
        [self.view addSubview:_containerView];
    }
    return _containerView;
}

- (NSMutableArray *)data
{
    if (!_data)
    {
        _data = [@[]mutableCopy];
    }
    return _data;
}

- (WSTInputView *)alertView{
    if (!_alertView) {
        _alertView = [[WSTInputView alloc]init];
        _alertView.title = LCSTR("input_group_name");
        [_alertView.rightButton addTarget:self action:@selector(alterNameAction:) forControlEvents:UIControlEventTouchDown];
        [ _alertView addWithSuperView:self.view];
        [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _alertView;
}
- (WSTGroupInconView *)iconView{
    if (!_iconView) {
        _iconView = [[WSTGroupInconView alloc]init];
        _iconView.title = LCSTR("pls_choose_icon");
        [_iconView addWithSuperView:self.view];
        [_iconView.rightButton addTarget:self action:@selector(alertGroupIcon:) forControlEvents:UIControlEventTouchDown];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        __weak typeof (self)weakSelf = self;
        _iconView.pressBlock = ^(NSInteger index) {
            weakSelf.imageStr = weakSelf.iconView.imageArray[index];
        };
    }
    return _iconView;
}
- (WSTTelecontrolView *)telecontrolView{
    if (!_telecontrolView) {
        _telecontrolView = [[WSTTelecontrolView alloc]init];
        _telecontrolView.title = LCSTR("bind_ctrl_key");
        [_telecontrolView addWithSuperView:self.view];
        [_telecontrolView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [_telecontrolView buttonSetSelectWith:self.roomArray];
        __weak typeof (self)weakSelf = self;
        _telecontrolView.pressButton = ^(NSInteger index, BOOL select,UIButton *sender) {
            sender.selected = !sender.selected;
            if (select == NO) {
                [[WZBlueToothDataManager shareInstance]addDevice:(uint32_t)[AppDelegate instance].currentGroup.groupAddress isGroup:YES ToDestinateGroupAddress:(uint32_t)(0x8000+index)];
                [WSTGroupKey insertFromDB:(uint32_t)(0x8000+index)];
            }else{
                [[WZBlueToothDataManager shareInstance]deleteDevice:(uint32_t)[AppDelegate instance].currentGroup.groupAddress isGroup:YES ToDestinateGroupAddress:(uint32_t)(0x8000+index)];

                [WSTGroupKey deleteFromDB:(uint32_t)(0x8000+index)];

            }
            weakSelf.roomArray = [[WSTGroupKey getCurrentKeyDevices] mutableCopy];
            [weakSelf.containerView.collectionView reloadData];
        };
    }
    return _telecontrolView;
}
@end
