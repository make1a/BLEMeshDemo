//
//  WSTOTAViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/20.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTOTAViewController.h"
#import "WSTOTAContainerView.h"
@interface WSTOTAViewController ()

/**WSTOTAContainerView*/
@property (nonatomic,strong) WSTOTAContainerView *containerView;
// 当前发包数字
@property (nonatomic,assign)int currentNumber;
/**发包的总次数 */
@property (nonatomic,assign) int totalNumber;
/**数据包*/
@property (nonatomic,strong) NSData *firmwareData;
/**发包定时器*/
@property (nonatomic,strong) NSTimer *timer;
/**当前版本 */
@property (nonatomic,copy) NSString *currenVersion;
@property (nonatomic,copy) NSString *nextVersion;
@property (nonatomic,assign) NSInteger failNumber;
/**不重复观察 */
@property (nonatomic,assign) BOOL isOb;
/**进来看一下不重新连接 */
@property (nonatomic,assign) BOOL isConnect;
@end


@implementation WSTOTAViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self readVersion];
    [WZBlueToothDataManager shareInstance].delegate = self;
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    self.failNumber = 0;
    self.isOb = NO;
    self.isConnect = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [WZBlueToothDataManager shareInstance].delegate = nil;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
- (void)setNavigationStyle{
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setNavigationTitle:LCSTR("OTA") titleColor:[UIColor whiteColor]];
}

#pragma mark - actions
- (void)readVersion{
    [[WZBlueToothDataManager shareInstance]readDeviceFirmwareVersion:self.meshId]; //读取版本号
}
- (void)onLeftButtonClick:(id)sender{
    [super onLeftButtonClick:sender];
    if (self.isConnect == YES) {
        NSString *homeName = [[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName];
        [[WZBlueToothManager shareInstance]startScanWithLocalName:homeName andStatus:WZBlueToothScanAndConnectOne];

    }
}
- (void)bleAction:(UIButton *)sender{
    [SVProgressHUD setContainerView:nil];

    if (self.currenVersion.length == 0) {
        [SVProgressHUD showInfoWithStatus:LCSTR("last_version")];
        return;
    }
    
    self.nextVersion = @"1.40";
    if ([self.currenVersion floatValue]>=[self.nextVersion floatValue]) {
        [SVProgressHUD showInfoWithStatus:LCSTR("last_version")];
        return;
    }
    self.isConnect = YES;
    if ([sender.currentTitle isEqualToString:LCSTR("updating")]) {
        
    }else if([sender.currentTitle isEqualToString:LCSTR("success")]){ //成功之后
        [self.navigationController popToRootViewControllerAnimated:YES];
        NSString *homeName = [[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName];
        [[WZBlueToothManager shareInstance]startScanWithLocalName:homeName andStatus:WZBlueToothScanAndConnectOne];
    }else if ([sender.currentTitle isEqualToString:LCSTR("start_ota")]){ //固件升级
        [self updateWith:sender];
    }
    
}

- (void)updateWith:(UIButton *)sender{
    sender.userInteractionEnabled = NO;
    sender.backgroundColor = [UIColor grayColor];
    [sender setTitle:LCSTR("updating") forState:UIControlStateNormal];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.currentNumber = 0;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connectSuc:) name:kNotificationOTAConnectSuc object:nil];
    [SVProgressHUD setContainerView:nil];
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%@...",LCSTR("start_ota")]];
    [[WZBlueToothManager shareInstance]setWillConnectMeshId:self.meshId];
    [[WZBlueToothManager shareInstance]cancelAllPeripheralsConnection]; //断开所有设备连接
    NSString *homeName = [[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[WZBlueToothManager shareInstance]startScanWithLocalName:homeName andStatus:WZBlueToothScanAndConnectPer];
    });
}

#pragma mark - notiRecevice
- (void)connectSuc:(NSNotification *)noti{
    [SVProgressHUD dismiss];
    self.containerView.notiLabel2.text = LCSTR("updating");
    if (self.isOb == NO) {
        self.isOb = YES;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connectFail:) name:kNotificationOTAConnectFail object:nil];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self update];
    });
}

- (void)connectFail:(NSNotification *)noti{
    [self.timer invalidate];
    self.timer = nil;
    if (self.failNumber == 3) {
        self.failNumber = 0;
        [SVProgressHUD showErrorWithStatus:LCSTR("retry")];
        self.containerView.sender.userInteractionEnabled = YES;
        self.containerView.sender.selected = NO;
        [self.containerView.sender setTitle:LCSTR("start_ota") forState:UIControlStateNormal];
        self.containerView.sender.backgroundColor = [UIColor colorWithRed:250/255.0 green:212/255.0 blue:83/255.0 alpha:1.0];
        self.containerView.circleView.numberLabel.text = LCSTR("升级失败");
        self.containerView.notiLabel2.text = LCSTR("retry");
        [self.containerView.circleView setCircleColor:[UIColor colorWithRed:185/255.0 green:0/255.0 blue:25/255.0 alpha:1.0]];
        return;
    }else{
        [SVProgressHUD showErrorWithStatus:LCSTR("retry")];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateWith:self.containerView.sender];
        });
        self.failNumber ++;
    }
    
    
}

- (void)deviceFirmWareData:(NSData *)data{
    NSString *version = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    self.containerView.notiLabel2.text = [NSString stringWithFormat:@"%@:%@",LCSTR("device_firmware"),version];
    self.currenVersion = version;
}
- (void)update{
    
    NSData *data = [[NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle] pathForResource:@"light_8266_V1.40_20171026" ofType:@"bin"]] readDataToEndOfFile];
    self.firmwareData = data;
    //发包的总次数
    self.totalNumber = ((int)data.length % 16)== 0 ? (((int)data.length / 16)) : (((int)data.length / 16) +1);

    __weak typeof (self)weakSelf = self;
    CGFloat time = 0.0;
    if ([self.currenVersion floatValue]<1.35) {
        time = 0.05;
    }else{
        time = 0.015;
    }
    self.timer = [NSTimer mk_scheduledTimerWithTimeInterval:time repeats:YES block:^{
        if (weakSelf.currentNumber>weakSelf.totalNumber) {
            [weakSelf.timer invalidate];
            weakSelf.timer = nil;
        }
        [weakSelf sendPacaket];
    }];
    
}

//分包 发包
- (void)sendPacaket{
    NSUInteger packLoction;
    NSUInteger packLength;
    
    if (self.currentNumber>self.totalNumber) {
        [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
        [SVProgressHUD showSuccessWithStatus:LCSTR("success")];
        self.containerView.notiLabel2.text = LCSTR("success");
        self.containerView.sender.userInteractionEnabled = YES;
        self.containerView.sender.backgroundColor = [UIColor colorWithRed:250/255.0 green:212/255.0 blue:83/255.0 alpha:1.0];
        [self.containerView.sender setTitle:LCSTR("success") forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        return;
    }
    if (![WZBlueToothManager shareInstance].currentDevice) {
        [self.timer invalidate];
        self.timer = nil;
        return;
    }
    
    if (self.currentNumber == self.totalNumber) {
        packLength = 0;
    }else if (self.currentNumber == self.totalNumber -1){
        packLength = [self.firmwareData length] - self.currentNumber * 16;
    }else{
        packLength = 16;
    }
    
    packLoction = self.currentNumber *16;
    //截取
    NSData *sendDate = [self.firmwareData subdataWithRange:NSMakeRange(packLoction, packLength)];
    if (self.currentNumber == 0) {
        [[WZBlueToothDataManager shareInstance]sendOTAPack:sendDate isFirst:YES]; //发包
    }else{
        [[WZBlueToothDataManager shareInstance]sendOTAPack:sendDate isFirst:NO]; //发包
    }
    
    [self.containerView.circleView setProgress:self.currentNumber*1.f / self.totalNumber];
    self.currentNumber ++;
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
- (WSTOTAContainerView *)containerView{
    if (!_containerView) {
        _containerView = [[WSTOTAContainerView alloc]init];
        [_containerView.sender addTarget:self action:@selector(bleAction:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_containerView];
    }
    return _containerView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
