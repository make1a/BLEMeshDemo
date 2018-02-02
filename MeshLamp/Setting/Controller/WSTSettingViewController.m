//
//  WSTSettingViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/11.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTSettingViewController.h"
#import "WSTAbloutUsViewController.h"
#import "WSTLanguageViewController.h"
#import "WSTNetworkListViewController.h"
#import "WSTIFlyViewController.h"
#import "MLSignInViewController.h"
#import "MLAccountViewController.h"
@interface WSTSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
/**table*/
@property (nonatomic,strong) UITableView *tableView;
/**Description */
@property (nonatomic,copy) NSString *language;

@end

@implementation WSTSettingViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)setNavigationStyle{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:44/255.0 green:62/255.0 blue:75/255.0 alpha:1.0];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setNavigationTitle:LCSTR("Settings") titleColor:[UIColor whiteColor]];
}

#pragma mark - actions
- (void)onLeftButtonClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableView delegate&datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self.language containsString:@"zh"]) {
        if (section == 1) {
            return 2;
        }
        return 1;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingfCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"settingfCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:31/255.0 green:47/255.0 blue:57/255.0 alpha:1.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    UIView *lineView = ({
        lineView = [UIView new];
        lineView.backgroundColor = BGColor;
        [cell addSubview:lineView];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(cell);
            make.height.mas_equalTo(1);
        }];
        
        lineView;
    });
    
    switch (indexPath.section) {
        case 0:
        {
            cell.textLabel.text = LCSTR("current_network");
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName]isEqualToString:kDeviceLoginUserName]) {
                cell.detailTextLabel.text = LCSTR("defalut_home");
            }else{
                cell.detailTextLabel.text =[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName];
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                cell.textLabel.text = LCSTR("language_mode");
            }else{
                cell.textLabel.text = LCSTR("语音控制");
            }
            
        }
            break;
        case 2:
            cell.textLabel.text = LCSTR("About_Us");
            break;
        default:
//            cell.textLabel.text = LCSTR("Account");
            break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            WSTNetworkListViewController *vc = [WSTNetworkListViewController new];
            [self.rt_navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                WSTLanguageViewController *vc = [WSTLanguageViewController new];
                [self.rt_navigationController pushViewController:vc animated:YES];
            }else{
                WSTIFlyViewController *vc = [WSTIFlyViewController new];
                [self.rt_navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case 2:
        {
            WSTAbloutUsViewController *vc = [WSTAbloutUsViewController new];
            [self.rt_navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
        {
//            if ([TuyaSmartUser sharedInstance].isLogin) {
//                MLAccountViewController *vc = [MLAccountViewController new];
//                [self.rt_navigationController pushViewController:vc animated:YES complete:nil];
//            }else{
//                MLSignInViewController *vc = [MLSignInViewController new];
//                vc.isFirst = YES;
//                [self.rt_navigationController pushViewController:vc animated:YES complete:nil];
//            }
        }
            break;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return LCSTR("network_info");
            break;
        case 1:
            return LCSTR("advanced_Function");
            break;
        case 2:
            return LCSTR("About_Us");
            break;
        default:
            return LCSTR("Account_info");
            break;
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
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView setBackgroundColor:[UIColor colorWithRed:21/255.0 green:37/255.0 blue:52/255.0 alpha:1.0]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
- (NSString *)language{
    _language = [[NSUserDefaults standardUserDefaults]valueForKey:@"myLanguage"];
    if (!_language||_language.length == 0) {
        _language = [NSString getPreferredLanguage];
    }
    return _language;
}


@end
