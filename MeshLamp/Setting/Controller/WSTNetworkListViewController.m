//
//  WSTNetworkListViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/11.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTNetworkListViewController.h"
#import "MLScanQRCodeViewController.h"
#import "MLBuildQRCodeViewController.h"
#import "WSTAddDeviceVC.h"

#import "WSTInputView.h"
#import "WSTNetListCell.h"

#import "WSTHomeInfo.h"

@interface WSTNetworkListViewController ()<UITableViewDelegate,UITableViewDataSource>
/**tableview*/
@property (nonatomic,strong) UITableView *tableView;
/**当前房间 */
@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,strong) WSTInputView *alertView;
/**数据源*/
@property (nonatomic,strong) NSMutableArray *dataSource;
/**是否更新主界面 防止频繁连接断开 */
@property (nonatomic,assign) BOOL isNotify;
@end

@implementation WSTNetworkListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [WSTHomeInfo insertDefualtHome];
    _dataSource = [[WSTHomeInfo selectFromClassAllObject] mutableCopy];
    [self.tableView reloadData];
    [self findCurrentRow];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)dealloc{
    NSLog(@"delloc");
    if (self.isNotify == YES) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationBeginConnectDevice object:nil];
    }
}

- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("network_list") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setRightButtonImage:[UIImage imageNamed:@"add_icon"]];
}

- (void)findCurrentRow{
    NSString *homeName = [[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
    if ([homeName isEqualToString:kDeviceLoginUserName]) {
        homeName = @"defalut_home";
    }
    self.currentIndex = 0;
    for (WSTHomeInfo *info in self.dataSource) {
        if ([info.homeName isEqualToString:homeName]) {
            [self.tableView reloadData];
            break;
        }else{
            self.currentIndex++;
        }
    }
}
#pragma mark - actions
- (void)onRightButtonClick:(id)sender{
    if (IS_iPad) {
        NSLog(@"is_pad");
        return;
    }
    

    UIAlertController *action = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof (self)weakSelf = self;

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:LCSTR("cancel") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:LCSTR("add_network")
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          [weakSelf addAlertViewAction];

                                                      }];
    
    UIAlertAction *scanAction = [UIAlertAction actionWithTitle:LCSTR("scan_qr_code")
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                           MLScanQRCodeViewController *vc = [MLScanQRCodeViewController new];
                                                           
                                                           [self.rt_navigationController pushViewController:vc animated:YES];
                                                       }];
    [action addAction:addAction];
    [action addAction:cancel];
    [action addAction:scanAction];
    [self presentViewController:action animated:YES completion:nil];

}
- (void)addAlertViewAction{
    if (self.alertView) {
        [self.alertView addWithSuperView:self.view];
        [self.alertView.textField becomeFirstResponder];
        [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}
- (void)addDeviceAction:(UIButton *)sender{
   NSString * homeName = self.alertView.textField.text;
    if (homeName.length == 0) {
        [SVProgressHUD showErrorWithStatus:LCSTR("name_can_not_null")];
        return;
    }
    if (homeName.textLength >10) {
        [SVProgressHUD showErrorWithStatus:LCSTR("name_too_long")];
        return;
    }
    
    [self.alertView removeFromSuperview];
    
   WSTHomeInfo *homeInfo = [WSTHomeInfo selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where homeName = '%@'",homeName]].firstObject;
    if (homeInfo) {
        [homeInfo updateObject];
    }else{
        WSTHomeInfo * info = [[WSTHomeInfo alloc]init];
        info.homeName = homeName;
        [info insertObject];
    }
    [[NSUserDefaults standardUserDefaults]setObject:homeName forKey:currentHomeName];
    [self pushToAddDeviceAction];
}
- (void)pushToAddDeviceAction{
    WSTAddDeviceVC *vc = [[WSTAddDeviceVC alloc]init];
    [self.rt_navigationController pushViewController:vc animated:YES];
    self.isNotify = YES;
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return px1334Hight(130);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSTNetListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSTNetListCell" forIndexPath:indexPath];
    WSTHomeInfo *info = self.dataSource[indexPath.row];
    [cell cellRefreshWithHomeList:indexPath homeInfo:info index:self.currentIndex];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.isNotify = YES;
    self.currentIndex = indexPath.row;
    WSTHomeInfo *info = self.dataSource[indexPath.row];
    if (indexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults]setObject:kDeviceLoginUserName forKey:currentHomeName];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:info.homeName forKey:currentHomeName];
    }
    
    [self.tableView reloadData];
    
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{

    //share
    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LCSTR("share") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        MLBuildQRCodeViewController *vc = [MLBuildQRCodeViewController new];
        WSTHomeInfo *info = self.dataSource[indexPath.row];
        vc.homeName = info.homeName;
        vc.homePassword = kDeviceLoginUserPassword;
        [self.rt_navigationController pushViewController:vc animated:YES];
        [self.tableView reloadData];
    }];
    
    //delete
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LCSTR("delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        WSTHomeInfo *info = self.dataSource[indexPath.row];
        [WSTHomeInfo deleteNetwork:info]; //删除网络
        [self.dataSource removeObject:info];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self findCurrentRow];
    }];
    
    //add
    UITableViewRowAction *addAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LCSTR("add") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        WSTHomeInfo *info = self.dataSource[indexPath.row];
        [[NSUserDefaults standardUserDefaults]setObject:info.homeName forKey:currentHomeName];
        [self pushToAddDeviceAction];
    }];
    
    shareAction.backgroundColor = [UIColor colorWithRed:240/255.0 green:206/255.0 blue:125/255.0 alpha:1.0];
    deleteAction.backgroundColor = [UIColor redColor];
    addAction.backgroundColor = [UIColor colorWithRed:68.0 / 255.0 green:219.0 / 255.0 blue:94.0 / 255.0 alpha:1.0f];
    
    if (indexPath.row == 0) {
        return @[shareAction];
    }else if (self.currentIndex == indexPath.row){
        return @[addAction,shareAction];
    }else{
        return @[deleteAction,shareAction];
    }
    
}



#pragma mark - 布局
- (void)masLayoutSubview{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
}
#pragma mark - 懒加载
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = BGColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:@"WSTNetListCell" bundle:nil] forCellReuseIdentifier:@"WSTNetListCell"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
- (WSTInputView *)alertView{
    if (!_alertView) {
        _alertView = [[WSTInputView alloc]init];
        _alertView.title = LCSTR("add_network");
        _alertView.textField.placeholder = LCSTR("new_home_name");
        [ _alertView addWithSuperView:self.view];
        [_alertView.rightButton addTarget:self action:@selector(addDeviceAction:) forControlEvents:UIControlEventTouchDown];
        [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _alertView;
}
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[WSTHomeInfo selectFromClassAllObject] mutableCopy];
    }
    return _dataSource;
}
@end
