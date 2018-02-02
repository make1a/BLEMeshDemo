//
//  WSTGoupEditDeviceVC.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/10.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTGoupEditDeviceVC.h"
#import "WSTGroupDeviceCell.h"
#import "WSTGroupHeadView.h"
#import "WSTGroupEditDeviceContainerView.h"

@interface WSTGoupEditDeviceVC ()<UICollectionViewDataSource,UICollectionViewDataSourcePrefetching,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,WZBlueToothDataSource>
/**containerView*/
@property (nonatomic,strong) WSTGroupEditDeviceContainerView *containerView;
/**数据源*/
@property (nonatomic,strong) NSMutableArray *dataSource;
/**未添加的数据源*/
@property (nonatomic,strong) NSMutableArray *noAdddataSource;
/**定时器*/
@property (nonatomic,strong) NSTimer *hidTimer;
@end

@implementation WSTGoupEditDeviceVC
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [WZBlueToothDataManager shareInstance].delegate = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    [self getCurrentDevices];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [WZBlueToothDataManager shareInstance].delegate = nil;
}

- (void)setNavigationStyle{
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    //    [self setRightButtonTitle:LCSTR("Done")];
    [self setNavigationTitle:LCSTR("group_manage") titleColor:[UIColor whiteColor]];
}

- (void)getCurrentDevices{
    NSArray *currenDevices =  [[WSTGroupDevice getCurrentGroupDevices] mutableCopy]; //当前群组的设备
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *allDevices = [[WZBlueToothDataManager shareInstance]getCurrentDevicesWithOnlie:YES];
        NSArray *noAddDevices = [WSTGroupDevice getCureentGroupNotAddDevices:currenDevices allDevices:allDevices];
        self.dataSource = [currenDevices mutableCopy];
        self.noAdddataSource = [noAddDevices mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.containerView.collectionView reloadData];
        });
    });
    
    
    
}
#pragma mark - wzbluetoothDelegate
- (void)deviceFirmWareData:(NSData *)data{
    
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.dataSource.count;
            break;
        case 1:
            return self.noAdddataSource.count;
            break;
        default:
            return 6;
            break;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WZBLEDataModel *model;
    if (indexPath.section == 0) {
        model = self.dataSource[indexPath.item];
    }else{
        model = self.noAdddataSource[indexPath.item];
    }
    
    WSTGroupDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSTGroupDeviceCell" forIndexPath:indexPath];
    
    [cell cellRefreshWithModel:model indexPath:indexPath];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hidTimer) {
        [self.hidTimer invalidate];
        self.hidTimer = nil;
    }
    
    WSTGroupDeviceCell *cell = (WSTGroupDeviceCell *)[collectionView cellForItemAtIndexPath:indexPath];
    WZBLEDataModel *model = indexPath.section==0?self.dataSource[indexPath.item]:self.noAdddataSource[indexPath.item];
    
    if (model.ismember == YES) { //第二次点击
        if (indexPath.section == 1) {//添加
            [[WZBlueToothDataManager shareInstance]addDevice:model.addressLong isGroup:NO ToDestinateGroupAddress:[AppDelegate instance].currentGroup.groupAddress];
            [WSTGroupDevice insertFromDB:model.address]; //插入数据库
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (WSTGroupKey *key in self.keyArray) {
                    [[WZBlueToothDataManager shareInstance]addDevice:(uint32_t)model.addressLong isGroup:NO ToDestinateGroupAddress:key.deviceAddress];
                }
            });
        }else{ //T出
            [[WZBlueToothDataManager shareInstance]deleteDevice:model.addressLong isGroup:NO ToDestinateGroupAddress:[AppDelegate instance].currentGroup.groupAddress];
            [WSTGroupDevice deleteFromDB:model.address]; //从数据库删除
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (WSTGroupKey *key in self.keyArray) {
                    [[WZBlueToothDataManager shareInstance] deleteDevice:(uint32_t)model.addressLong isGroup:NO ToDestinateGroupAddress:key.deviceAddress];
                }
            });
        }
        [self getCurrentDevices]; //刷新数据源和界面
    }else{ //第一次点击
        for (WZBLEDataModel *model in self.dataSource) {
            model.ismember = NO;
        }
        for (WZBLEDataModel *model in self.noAdddataSource) {
            model.ismember = NO;
        }
        model.ismember = YES;
        [collectionView reloadData];
        [[WZBlueToothDataManager shareInstance]locateTheDevice:model.addressLong]; //定位
    }
    
    if (!_hidTimer) {
        self.hidTimer = [NSTimer mk_scheduledTimerWithTimeInterval:2 repeats:NO block:^{
            cell.maskImageView.hidden = YES;
            model.ismember = NO;
            [collectionView reloadData];
            [_hidTimer invalidate];
            _hidTimer = nil;
        }];
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return px750Width(10);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return px750Width(10);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(px750Width(10),px750Width(10),px750Width(10),px750Width(10));
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(px750Width(174), px750Width(174));
} 

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WSTGroupHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTGroupHeadView" forIndexPath:indexPath];
        headView.headLabel.text = LCSTR("current_device");
        return headView;
    }else if (indexPath.section == 1){
        WSTGroupHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTGroupHeadView" forIndexPath:indexPath];
        headView.headLabel.text = LCSTR("not_added_device");
        return headView;
    }
    
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(SCREEN_WIDTH, px1334Hight(70));
    }else{
        return CGSizeMake(SCREEN_WIDTH, px1334Hight(170));
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
#pragma mark - 布局
- (void)masLayoutSubview{
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
}

#pragma mark - 懒加载
- (WSTGroupEditDeviceContainerView *)containerView{
    if (!_containerView) {
        _containerView = [[WSTGroupEditDeviceContainerView alloc]init];
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


@end
