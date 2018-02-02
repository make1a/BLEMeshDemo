//
//  WSTAddDeviceVC.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/12.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTAddDeviceVC.h"

//views
#import "WSTGroupHeadView.h"
#import "WSTHomeDeviceCell.h"
#import "WSTAddDeviceContainerView.h"


@interface WSTAddDeviceVC ()<UICollectionViewDataSource,UICollectionViewDataSourcePrefetching,UICollectionViewDelegateFlowLayout>
/**WSTAddDeviceContainerView*/
@property (nonatomic,strong) WSTAddDeviceContainerView *containerView;
/**数据源*/
@property (nonatomic,strong) NSMutableArray *dataSource;
@end

@implementation WSTAddDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    [self setBleActions];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[WZBlueToothManager shareInstance]stopScanAndCancelAllPeripheralsConnection];
}

- (void)setNavigationStyle{

    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setNavigationTitle:LCSTR("add_device") titleColor:[UIColor whiteColor]];
    
}

#pragma mark - actions
- (void)updateConnectStatus:(NSNotification *)noti{
    NSString *statusStr = noti.object;
    if ([statusStr isEqualToString:kNotificationBeginScanStatus]) { //开始扫描
        self.containerView.notice = [NSString stringWithFormat:@"%@%@...",LCSTR("search"),LCSTR("device")];
    }else if ([statusStr isEqualToString:kNotificationStarConnectStatus]) { //开始连接设备
        self.containerView.notice = [NSString stringWithFormat:@"%@...",LCSTR("add_device")];
    }else if ([statusStr isEqualToString:kNotificationDisConnectDeviceStatus]) { //断开连接
//        self.containerView.notice = [NSString stringWithFormat:@"%@%@...",LCSTR("search"),LCSTR("device")];
    }else if ([statusStr isEqualToString:kNotificationNoDeviceStatus]){ //没发现设备了
        //弹框

    }
    
}
- (void)addButtonClickAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        NSString *currentName = [[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
        [[WZBlueToothDataManager shareInstance]setNewNetworkName:currentName andPwd:@"2846"];
        [[WZBlueToothManager shareInstance]startScanWithLocalName:kDeviceLoginUserName  andStatus:WZBlueToothScanAndConnectAll];
    }else{
         [[WZBlueToothManager shareInstance]stopScanAndCancelAllPeripheralsConnection];
    }
}
- (void)setBleActions{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateConnectStatus:) name:kNotificationAddDeviceStatus object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateView:) name:kNotificationAtNewDevice object:nil];
    
    [[WZBlueToothManager shareInstance]stopScanAndCancelAllPeripheralsConnection];
    
//    self.containerView.notice = [NSString stringWithFormat:@"%@%@...",LCSTR("search"),LCSTR("device")];
//
//    NSString *currentName = [[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
//    [[WZBlueToothDataManager shareInstance]setNewNetworkName:currentName andPwd:@"2846"];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[WZBlueToothManager shareInstance]startScanWithLocalName:kDeviceLoginUserName  andStatus:WZBlueToothScanAndConnectAll];
//    });
}
- (void)updateView:(NSNotification *)noti{
    
    WZScanDeviceModel *device =  noti.object;
    [self.dataSource addObject:device];
    [self.containerView.collectionView reloadData];
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            [self setRightButtonTitle:[NSString stringWithFormat:@"%ld",self.dataSource.count]];
            return self.dataSource.count;
        }
            break;
        default:
            return 6;
            break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSTHomeDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSTHomeDeviceCell" forIndexPath:indexPath];
   WZScanDeviceModel *dev = self.dataSource[indexPath.item];
    cell.deviceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_on", [WZBLEDataAnalysisTool NameWithModel:dev.devModel]]];
    cell.deviceNameLabel.text = [NSString stringWithFormat:@"%@-%d",dev.home,dev.address];
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
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
/*
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WSTGroupHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTGroupHeadView" forIndexPath:indexPath];
        headView.headLabel.text = [NSString stringWithFormat:@"%@-%ld",LCSTR("add_device"),self.dataSource.count];
        return headView;
    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0|| section ==1) {
        return CGSizeMake(SCREEN_WIDTH, px1334Hight(70));
    }else{
        return CGSizeZero;
    }
    
}
*/
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
- (WSTAddDeviceContainerView *)containerView{
    if (!_containerView) {
        _containerView = [[WSTAddDeviceContainerView alloc]init];
        _containerView.collectionView.delegate = self;
        _containerView.collectionView.dataSource = self;
        if (@available(iOS 10.0, *)) {
            _containerView.collectionView.prefetchDataSource = self;
        } else {
            
        }
        [_containerView.addButton addTarget:self action:@selector(addButtonClickAction:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_containerView];
    }
    return _containerView;
}
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [@[]mutableCopy];
    }
    return _dataSource;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
