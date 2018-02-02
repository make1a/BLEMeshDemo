//
//  WSTEditDeviceViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTEditDeviceViewController.h"
#import "WSTTextFieldCell.h"
#import "WSTNetListCell.h"
#import "WSTImageCell.h"
#import "WSTButtonTableViewCell.h"
#import "WSTOTAViewController.h"
#import "WSTHomeGorupShowModel.h"
#import "WSTInputView.h"




@interface WSTEditDeviceViewController ()<UITableViewDelegate,UITableViewDataSource,WZBlueToothDataSource>
/**UITableView*/
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *roomArray;
/**currentModel*/
@property (nonatomic,strong) WZBLEDataModel *currentDevice;
@property (nonatomic,strong) WSTInputView *alertView;

/**版本号 */
@property (nonatomic,copy) NSString *version;
@end

@implementation WSTEditDeviceViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self readVersion];
    [WZBlueToothDataManager shareInstance].delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    [self getDeviceStatus];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [WZBlueToothDataManager shareInstance].delegate = nil;
}

- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("change_device_info") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
}
- (void)readVersion{
    [[WZBlueToothDataManager shareInstance]readDeviceFirmwareVersion:self.devAddr]; //读取版本号
}
#pragma mark - actions
- (void)deviceFirmWareData:(NSData *)data{
    self.version = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [self.tableView reloadData];
}
- (void)getDeviceStatus{
    NSString *homeName = [[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
    NSString *str = [NSString stringWithFormat:@"where home = '%@' And address = '%d'",homeName,(int)_devAddr>>8];
    WZBLEDataModel *model = [WZBLEDataModel selectFromClassPredicateWithFormat:str].firstObject;
    self.currentDevice = model;
    [self.tableView reloadData];
    [[WZBlueToothDataManager shareInstance] getAllGroupAddressWithDevice:(uint32_t)model.addressLong isGroup:NO];
}
-(void)alterNameAction:(id)sender{
    [SVProgressHUD setContainerView:nil];
    NSString *name = self.alertView.textField.text;
    NSString *homeName = [[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
    NSString *str = [NSString stringWithFormat:@"where home = '%@' and name = '%@'",homeName,name];
    NSArray *deviceArray = [WZBLEDataModel selectFromClassPredicateWithFormat:str];
    
    NSString *str2 = [NSString stringWithFormat:@"where homeName = '%@' and name = '%@'",homeName,name];
    NSArray *groupArray = [WSTHomeGorupShowModel selectFromClassPredicateWithFormat:str2];
    
    WZBLEDataModel *model = [WZBLEDataModel selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where address = '%d'",_devAddr>>8]].firstObject;
    if (![model.name isEqualToString:name]) {
        if (deviceArray.count != 0 || groupArray.count != 0) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@%@",LCSTR("device_name"),LCSTR("repeat")]];
            return;
        }
    }
    if (name.length == 0) {
        [SVProgressHUD showErrorWithStatus:LCSTR("name_can_not_null")];
        return;
    }
    self.currentDevice.name = name;
    if ([self.currentDevice updateObject]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - WZBlueToothDataManagerDelegate
- (void)responseOfDeviceHasGroupsArray:(GroupInfo *)info{
    self.roomArray = [info.groupArray mutableCopy];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark - tableview datasource&delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 4;
            break;
        default:
            return 1;
            break;
    }
}
- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {
            WSTTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSTTextFieldCell" forIndexPath:indexPath];
            cell.nameLabel.text = self.currentDevice.name;
            return cell;
        }
            break;
        case 1:
        {
            WSTNetListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSTNetListCell" forIndexPath:indexPath];
            [cell cellRefreshWithEditDevice:indexPath roomArray:self.roomArray];
            return cell;
        }
            break;
        case 2:
        {
            WSTImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSTImageCell" forIndexPath:indexPath];
            cell.headLabel.text = LCSTR("device_firmware");
            cell.rightLabel.text = self.version;
            return cell;
        }
        default:
        {
            WSTButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSTButtonTableViewCell" forIndexPath:indexPath];
            cell.nameLabel.text = LCSTR("delete_device");
            return cell;
        }
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        WSTNetListCell *cell = (WSTNetListCell *)[tableView cellForRowAtIndexPath:indexPath];
        int roomAddr = (int)indexPath.row + 1;
        if ([self.roomArray containsObject:[NSNumber numberWithLong:roomAddr]]) {
            cell.checkImageView.image = [UIImage imageNamed:@"check_icon_normal"];
            [[WZBlueToothDataManager shareInstance] deleteDevice:(uint32_t)_devAddr isGroup:NO ToDestinateGroupAddress:roomAddr + 0x8000];
        }else{
            cell.checkImageView.image = [UIImage imageNamed:@"check_icon_selected"];
            [[WZBlueToothDataManager shareInstance]addDevice:(uint32_t)_devAddr isGroup:NO ToDestinateGroupAddress:roomAddr+0x8000];
        }
        
    }else if (indexPath.section == 3){
        [[WZBlueToothDataManager shareInstance]kickoutLightFromMeshWithDestinateAddress:self.devAddr];
        [SVProgressHUD setContainerView:nil];
        [SVProgressHUD show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
        
    }else if (indexPath.section == 2){
        WSTOTAViewController *vc = [WSTOTAViewController new];
        vc.meshId = self.devAddr;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.section == 0){
        if (self.alertView) {
            self.alertView.textField.text = @"";
            self.alertView.textField.placeholder = self.currentDevice.name;
            [self.alertView addWithSuperView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.alertView.textField becomeFirstResponder];
            });
            
            [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return px1334Hight(100);
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return LCSTR("device_name");
            break;
        case 1:
            return LCSTR("bind_ctrl_key");
            break;
        default:
            //            return [NSString stringWithFormat:@"%@: %f", LCSTR("Current version"), devVersion];
            return @"";
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return px1334Hight(50);
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return px1334Hight(50);
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:@"WSTTextFieldCell"bundle:nil] forCellReuseIdentifier:@"WSTTextFieldCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"WSTNetListCell" bundle:nil] forCellReuseIdentifier:@"WSTNetListCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"WSTImageCell" bundle:nil] forCellReuseIdentifier:@"WSTImageCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"WSTButtonTableViewCell" bundle:nil] forCellReuseIdentifier:@"WSTButtonTableViewCell"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
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


@end
