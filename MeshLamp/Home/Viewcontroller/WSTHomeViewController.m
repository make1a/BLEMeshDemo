//
//  HomeViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/29.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTHomeViewController.h"
#import "WSTGroupManageVC.h"
#import "WSTSettingViewController.h"
#import "WSTControlViewController.h"
#import "WSTRBGWViewController.h"
#import "WSTBaseColorViewController.h"
#import "WSTRGBCViewController.h"
#import "WSTRGBViewController.h"
#import "WSTWCViewController.h"
#import "WSTWViewController.h"
#import "WSTCViewController.h"
//views
#import "WSTHomeContainerView.h"
#import "WSTHomeGorupShowModel.h"
#import "WSTHomeGroupCell.h"
#import "WSTHomeGroupBtnCell.h"
#import "WSTHomeGroupHeadView.h"
#import "WSTHomeDeviceCell.h"
#import "WSTHomeDeviceHeadView.h"
#import "WSTInputView.h"

#import "WSTIFlyViewController.h"
@interface WSTHomeViewController ()<UICollectionViewDataSource,UICollectionViewDataSourcePrefetching,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,WZBlueToothDataSource>
{
    dispatch_queue_t globalQueue;
    dispatch_queue_t globalCustmoQueue;
}
/**containerView*/
@property (nonatomic,strong) WSTHomeContainerView *containerView;
/// collectionView群组数据源
@property (nonatomic, strong) NSMutableArray *groupDataSource;
/**device数据源*/
@property (nonatomic,strong) NSMutableArray *deviceDataSource;
/**主动获取设备类型的定时器*/
@property (nonatomic,strong) NSTimer *getDeviceModelTimer;
/**是否隐藏群组 */
@property (nonatomic,assign) BOOL isHide;
/**section */
@property (nonatomic,assign) NSInteger section;
/**WSTHomeGroupHeadView*/
@property (nonatomic,strong) WSTHomeGroupHeadView *headView;
@end

@implementation WSTHomeViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [WZBlueToothDataManager shareInstance].delegate = self;
    [self updateDeviceStatusNoDismiss];

    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self  setNavigationStyle];
    [self  addUpdateViewNoti];
    [self connectDeviceAction];
    [self setSection];
    [self configQuee];
    
    
}
- (void)onRightButtonClick:(id)sender{

}
- (void)configQuee{
    globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    globalCustmoQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [WZBlueToothDataManager shareInstance].delegate = nil;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [SVProgressHUD dismiss];
}

- (void)setNavigationStyle{
    
    [self setLeftButtonImage:[UIImage imageNamed:@"setting_icon"]];
    [self setNavigationTitle:@"Mesh Lamp" titleColor:[UIColor whiteColor]];
}
- (void)setSection{
    
}
#pragma mark ------------ action --------------
- (void)addUpdateViewNoti{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connectDeviceAction) name:kNotificationBeginConnectDevice object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateDeviceStatusNoDismiss) name:kNotificationUpdateDeviceStatus object:nil];
}
//连接
- (void)connectDeviceAction{
    //配置homeName
    NSString *homeName = [[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName];
    if (homeName.length == 0) {
        [[NSUserDefaults standardUserDefaults]setObject:kDeviceLoginUserName forKey:currentHomeName];
        homeName = kDeviceLoginUserName;
    }
    //提示
    [SVProgressHUD setContainerView:self.view];
    [SVProgressHUD showWithStatus:LCSTR("Connect the device")];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![WZBlueToothManager shareInstance].currentDevice) {
            [SVProgressHUD showErrorWithStatus:LCSTR("find_not_device")];
        }
    });
    
    //配置数据源
    [self.deviceDataSource removeAllObjects];
    self.groupDataSource = [[WSTHomeGorupShowModel selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where homeName = '%@'",[[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName]]] mutableCopy];
    
    
    if (self.groupDataSource.count == 0) {
        [self.groupDataSource addObject:[WSTHomeGorupShowModel insertDefaultGroup]];
    }
    
    //发起扫描连接
    [[WZBlueToothManager shareInstance]startScanWithLocalName:homeName andStatus:WZBlueToothScanAndConnectOne];
    //刷新
    [self.containerView.collectionView reloadData];
    
    //开个定时器去主动获取设备状态，
    __weak typeof (self)weakSelf = self;
    if (!_getDeviceModelTimer) {
        _getDeviceModelTimer = [NSTimer mk_scheduledTimerWithTimeInterval:2.f repeats:YES block:^{
            if ([WZBlueToothManager shareInstance].currentDevice) { //有直连设备
                [weakSelf.getDeviceModelTimer invalidate];
                weakSelf.getDeviceModelTimer = nil;
                [[WZBlueToothDataManager shareInstance]getModelWithDataBaseOrDevice];
                
            }
        }];
    }
}

- (void)onLeftButtonClick:(id)sender{
    WSTSettingViewController *vc = [WSTSettingViewController new];
    RTRootNavigationController *nav = [[RTRootNavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)addGroupAction:(UIButton *)sender{
    if ([WSTHomeGorupShowModel selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where homeName = '%@'",[[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName]]].count<=200) {
        [WSTHomeGorupShowModel addGroupAndInsertDB];
    }else{
        [SVProgressHUD showErrorWithStatus:@"已超过最大群组数"];
        return;
    }
    
    self.groupDataSource = [[WSTHomeGorupShowModel selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where homeName = '%@'",[[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName]]] mutableCopy];
    if (self.isHide == YES) {
        [self hideGroupAction:self.headView.HidButton];
    }
    [self.containerView.collectionView reloadData];
}
- (void)hideGroupAction:(UIButton*)sender{
    sender.selected = !sender.selected;
    self.isHide = sender.selected;
    [self.containerView.collectionView reloadData];
}

#pragma mark - WZBLEDtaSource
//灯的状态---开关 亮度
//更新设备状态
- (void)updateDeviceStatus{
    
    dispatch_async(globalQueue, ^{
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            self.deviceDataSource = [[[WZBlueToothDataManager shareInstance]getCurrentDevicesWithOnlie:YES] mutableCopy];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.containerView.collectionView reloadData];
        });
    });
    
}
- (void)updateDeviceStatusNoDismiss{
    if ([WZBlueToothManager shareInstance].currentDevice) {
        dispatch_async(globalQueue, ^{
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                self.deviceDataSource = [[[WZBlueToothDataManager shareInstance]getCurrentDevicesWithOnlie:YES] mutableCopy];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.containerView.collectionView reloadData];
            });
        });
    }else{
        self.deviceDataSource = [@[] mutableCopy];
        [self.containerView.collectionView reloadData];
    }

}
//获取设备的信息
- (void)responseOfUserCustomData{
    dispatch_async(globalCustmoQueue, ^{
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            self.deviceDataSource = [[[WZBlueToothDataManager shareInstance]getCurrentDevicesWithOnlie:YES] mutableCopy];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.containerView.collectionView reloadData];
        });
    });
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.section+1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section<self.section) {
        WSTHomeGorupShowModel *model = self.groupDataSource[section];
        return (NSInteger)model.item;
    }else{
        return self.deviceDataSource.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section < self.section) { //群组
        __block WSTHomeGorupShowModel *model = self.groupDataSource[indexPath.section];
        if (indexPath.item%2 == 0) {
            WSTHomeGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSTHomeGroupCell" forIndexPath:indexPath];
            cell.pressOnButton = ^{
                [[WZBlueToothDataManager shareInstance]turnOnCertainGroupWithAddress:model.groupAddress];
            };
            cell.pressOffButton = ^{
                [[WZBlueToothDataManager shareInstance]turnOffCertainGroupWithAddress:model.groupAddress];
            };
            [cell cellRefreshWithArray:self.groupDataSource indexPath:indexPath];
            return cell;
        }else{
            
            __weak typeof (self)weakSelf = self;
            WSTHomeGroupBtnCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSTHomeGroupBtnCell" forIndexPath:indexPath];
            [cell cellRefreshWith:indexPath];
            
            cell.pressManageBlock = ^{
                [AppDelegate instance].currentGroup = model;
                WSTGroupManageVC *vc = [WSTGroupManageVC new];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            };
            
            cell.pressDeleteBlock = ^{
                [collectionView performBatchUpdates:^{
                    [WSTHomeGorupShowModel deleteGroup:model]; //删除群组以及里面的device 并发送指令
                    [weakSelf.groupDataSource removeObject:model];
                    [collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
                } completion:^(BOOL finished) {
                    [weakSelf.containerView.collectionView reloadData];
                }];
            };
            cell.pressControlBlock = ^{
                WSTControlViewController *vc = [WSTControlViewController new];
                vc.isRoom = YES;
                vc.devAddr = model.groupAddress;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            };
            return cell;
        }
    }else{ //设备
        WSTHomeDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WSTHomeDeviceCell" forIndexPath:indexPath];
        NSInteger row = indexPath.item;
        //多线程和数据库的事务会导致这里偶尔会出现 self.deviceDataSource.count = row
        if (self.deviceDataSource.count<=indexPath.item) {
            row = self.deviceDataSource.count -1;
        }
        WZBLEDataModel *model = self.deviceDataSource[row];
        [cell refreshWithModel:model indexPath:indexPath];
        cell.longPressBlock = ^{
            if ([model.devModel hasPrefix:DEV_TYPE_LIGHT_RGBWC]) {
                WSTControlViewController *vc = [WSTControlViewController new];
                vc.devAddr = model.addressLong;
                vc.isRoom = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([model.devModel hasPrefix:DEV_TYPE_LIGHT_RGBW]){
                WSTRBGWViewController *vc = [WSTRBGWViewController new];
                vc.devAddr = model.addressLong;
                vc.isRoom = NO;
                [self.navigationController pushViewController:vc animated:YES];
            } else if ([model.devModel hasPrefix:DEV_TYPE_LIGHT_RGBC]){
                WSTRGBCViewController *vc = [WSTRGBCViewController new];
                vc.devAddr = model.addressLong;
                vc.isRoom = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([model.devModel hasPrefix:DEV_TYPE_LIGHT_RGB]){
                WSTRGBViewController *vc = [WSTRGBViewController new];
                vc.devAddr = model.addressLong;
                vc.isRoom = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([model.devModel hasPrefix:DEV_TYPE_LIGHT_WC]){
                WSTWCViewController *vc = [WSTWCViewController new];
                vc.devAddr = model.addressLong;
                vc.isRoom = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([model.devModel hasPrefix:DEV_TYPE_LIGHT_W]){
                WSTWViewController *vc = [WSTWViewController new];
                vc.devAddr = model.addressLong;
                vc.isRoom = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([model.devModel hasPrefix:DEV_TYPE_LIGHT_C]){
                WSTCViewController *vc = [WSTCViewController new];
                vc.devAddr = model.addressLong;
                vc.isRoom = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        };
        return cell;
    }
    
    return nil;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.section < self.section) {
        if (indexPath.item%2 == 0) {
            WSTHomeGorupShowModel *model = self.groupDataSource[indexPath.section];
            model.item = model.item == 1?2:1;
            if (model.item == 2) {
                for (WSTHomeGorupShowModel *m in self.groupDataSource) {
                    m.item = 1;
                }
                model.item = 2;
            }
            [self.containerView.collectionView reloadData];
        }
    }else{
        WSTHomeDeviceCell *cell = (WSTHomeDeviceCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell zoomAnimationPop];
        if ([WZBlueToothManager shareInstance].currentDevice) {
            WZBLEDataModel *model = self.deviceDataSource[indexPath.item];
            if ([model.devModel isEqualToString:kDeviceDefaultMode]) {
                [[WZBlueToothDataManager shareInstance]getUserCustomDataWith:model.addressLong];
            }else{
                if (model.state == DeviceStatusOn) {
                    [[WZBlueToothDataManager shareInstance]turnOffCertainLightWithAddress:model.addressLong];
                }else if (model.state == DeviceStatusOff){
                    [[WZBlueToothDataManager shareInstance]turnOnCertainLightWithAddress:model.addressLong];
                }
            }
        }else{
            [self updateDeviceStatusNoDismiss]; //更新一下设备状态
        }
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (section<self.section) {
        return CGFLOAT_MIN;
    }else{
        return px750Width(10);
    }
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return px750Width(10);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section<self.section) {
        return UIEdgeInsetsMake(px1334Hight(5), 0, px1334Hight(5), 0);
    }else{
        return UIEdgeInsetsMake(px750Width(10),px750Width(10),0,px750Width(10));
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section < self.section) {
        return CGSizeMake(px750Width(730), px1334Hight(91));
    }else{
        return CGSizeMake(px750Width(235), px750Width(235));
    }
    
    
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        WSTHomeGroupHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTHomeGroupHeadView" forIndexPath:indexPath];
        [headView.addButton addTarget:self action:@selector(addGroupAction:) forControlEvents:UIControlEventTouchUpInside];
        [headView.HidButton addTarget:self action:@selector(hideGroupAction:) forControlEvents:UIControlEventTouchUpInside];
        [headView viewRefresWith:nil];
        self.headView = headView;
        return headView;
        
    }else if (indexPath.section == self.section){
        WSTHomeDeviceHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WSTHomeDeviceHeadView" forIndexPath:indexPath];
        headView.headLabel.font = [UIFont systemFontOfSize:px750Width(26)];
        headView.headLabel.text = [NSString stringWithFormat:@"%@%@-%ld",LCSTR("device"),LCSTR("device_reminder"),(unsigned long)self.deviceDataSource.count];
        return headView;
    }
    return nil;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0|| section == self.section) {
        return CGSizeMake(px750Width(730), px1334Hight(100));
    }else{
        return CGSizeZero;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.section == self.section && indexPath.item<self.deviceDataSource.count) {
            WZBLEDataModel *model = self.deviceDataSource[indexPath.item];
            WSTHomeDeviceCell *cell = (WSTHomeDeviceCell *)[collectionView cellForItemAtIndexPath:indexPath];
            [cell refreshWithModel:model indexPath:indexPath];
        }
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.section == self.section && indexPath.item<self.deviceDataSource.count) {
            if (self.deviceDataSource[indexPath.item]) {
                WZBLEDataModel *model = self.deviceDataSource[indexPath.item];
                model = nil;
            }
        }
    }
    
}
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
- (WSTHomeContainerView *)containerView{
    if (!_containerView) {
        _containerView = [[WSTHomeContainerView alloc]init];
        _containerView.collectionView.delegate = self;
        _containerView.collectionView.dataSource = self;
        if (@available(iOS 10.0, *)) {
            _containerView.collectionView.prefetchDataSource = self;
        } else {
            // Fallback on earlier versions
        }
        [self.view addSubview:_containerView];
    }
    return _containerView;
}
- (NSMutableArray *)groupDataSource
{
    if (!_groupDataSource)
    {
        _groupDataSource = [@[] mutableCopy];
    }
    
    return _groupDataSource;
}

- (NSMutableArray *)deviceDataSource{
    if (!_deviceDataSource) {
        _deviceDataSource = [@[] mutableCopy];
    }
    return _deviceDataSource;
}

- (NSInteger)section{
    
    return self.isHide?1:self.groupDataSource.count;
}
#pragma mark - delloc
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
