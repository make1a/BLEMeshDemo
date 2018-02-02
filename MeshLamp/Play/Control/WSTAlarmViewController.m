//
//  WSTAlarmViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTAlarmViewController.h"
#import "WSTAlarmCell.h"
#import "WSTAddAlarmViewController.h"
@interface WSTAlarmViewController ()<UITableViewDelegate,UITableViewDataSource>
/**UITableView*/
@property (nonatomic,strong) UITableView *tableView;
/**数据源*/
@property (nonatomic,strong) NSMutableArray *dataSource;
/**群组名*/
@property (nonatomic,strong) NSMutableArray *nameArray;
@end

@implementation WSTAlarmViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getAlarmInfo];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
}
- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("alarm") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setRightButtonImage:[UIImage imageNamed:@"add_icon"]];
}
-(void)getAlarmInfo{
    NSString *str ;
    if (self.devAddr == 0xffff) {
        NSArray *groups = [WSTHomeGorupShowModel selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where homeName = '%@'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName]]];
        NSMutableArray *groupAlarm = [@[] mutableCopy];
        for (WSTHomeGorupShowModel *model in groups) {
            str = [NSString stringWithFormat:@"where homeName = '%@' and addrL = '%d' and sceneId != '15' and sceneId != '16'",[[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName],model.groupAddress];
            NSArray *alarmArray = [AlarmInfo selectFromClassPredicateWithFormat:str];
            [groupAlarm addObjectsFromArray:alarmArray];
            for (AlarmInfo *info in alarmArray) {
                [self.nameArray addObject:model.name];
            }
        }
        self.dataSource = groupAlarm;
    }else{
        str = [NSString stringWithFormat:@"where homeName = '%@' and addrL = '%d' and sceneId != '15' and sceneId != '16'",[[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName],self.devAddr];
        NSArray *array = [AlarmInfo selectFromClassPredicateWithFormat:str];
        self.dataSource = [array mutableCopy];
    }
    
    [self.tableView reloadData];
}

#pragma mark - actions
- (void)onRightButtonClick:(id)sender{
    WSTAddAlarmViewController *vc = [WSTAddAlarmViewController new];
    vc.isRoom = self.isRoom;
    vc.devAddr = self.devAddr;
    vc.isEdit = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)openAlarmWith:(BOOL)isOn andAlarm:(AlarmInfo*)info{
    
    if (info.actionAndModel<128 && isOn == YES) {
         info.actionAndModel += 128;
    }else{
        info.actionAndModel -= 128;
    }

    [[WZBlueToothDataManager shareInstance]modifyAlarmToDevice:self.devAddr isGroup:self.isRoom WithAlarmInfo:info];
    [info updateObject];
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return px1334Hight(135);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WSTAlarmCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WSTAlarmCell"];
    if (!cell) {
        cell = [[WSTAlarmCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WSTAlarmCell"];
    }
    AlarmInfo *info = self.dataSource[indexPath.row];
    if (self.devAddr == 0xffff) {
        [cell cellRefreshWith:info allDataSourece:self.nameArray indexPath:indexPath];
    }else{
        [cell cellRefreshWith:info allDataSourece:nil indexPath:nil];
    }
    cell.pressSwitch = ^(BOOL isOn) { //这里的isOn是使能
        [self openAlarmWith:isOn andAlarm:info];
        [self.tableView reloadData];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LCSTR("delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        AlarmInfo *info = self.dataSource[indexPath.row];
        [info deleteObject];
        [self.dataSource removeObject:info];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
        [[WZBlueToothDataManager shareInstance]deleteAlarmToDevice:self.devAddr isGroup:NO WithIndex:info.alarmId];
    }];
    //编辑
    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LCSTR("edit") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        WSTAddAlarmViewController *vc = [WSTAddAlarmViewController new];
        vc.isRoom = self.isRoom;
        vc.devAddr = self.devAddr;
        vc.isEdit = YES;
        vc.currentAlarm = self.dataSource[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    shareAction.backgroundColor = [UIColor colorWithRed:240/255.0 green:206/255.0 blue:125/255.0 alpha:1.0];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction,shareAction];
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
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
- (NSMutableArray *)nameArray{
    if (!_nameArray) {
        _nameArray = [@[] mutableCopy];
    }
    return _nameArray;
}
@end
