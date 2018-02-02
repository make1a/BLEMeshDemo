//
//  WSTBreatheViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTBreatheViewController.h"
#import "BreathCell.h"

@interface WSTBreatheViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    UICollectionView    *breathCollectionView;
    NSArray             *breathIconArray;
    NSArray             *breathNameArray;
}

@end


@implementation WSTBreatheViewController
@synthesize isRoom, devAddr;
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Init
    [self initPropertys];
    
    // View
    [self loadMainView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
}

#pragma mark - Init
- (void)initPropertys {
    // 初始化呼吸数据
    breathIconArray = @[@"rainbow_icon", @"heart_breath_icon", @"green_breath_icon", @"blue_breath_icon", @"alarm_icon", @"flash_icon", @"breathings_icon", @"feel_green_icon", @"setting_sun_icon"];
    breathNameArray = @[LCSTR("breath_rainbow"), LCSTR("breath_heartbeat"), LCSTR("breath_heartbeat_gs"), LCSTR("breath_heartbeat_bs"), LCSTR("breath_alarm"), LCSTR("breath_flash"), LCSTR("breath_flash_ls"), LCSTR("breath_green_feel"), LCSTR("breath_sunset")];
    
}

#pragma mark - View
- (void)loadMainView {

    [self setNavigationTitle:LCSTR("breath_mode") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    
    // 呼吸列表
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = Sp2Pt(1);
    layout.minimumLineSpacing = Sp2Pt(1.5);
    layout.sectionHeadersPinToVisibleBounds = YES;
    layout.sectionInset = UIEdgeInsetsMake(Sp2Pt(1), 0, 0, 0);
    breathCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, Width(self.view), Height(self.view)) collectionViewLayout:layout];
    breathCollectionView.backgroundColor = [UIColor clearColor];
    breathCollectionView.collectionViewLayout = layout;
    breathCollectionView.delegate = self;
    breathCollectionView.dataSource = self;
    breathCollectionView.scrollEnabled = YES;
    breathCollectionView.showsVerticalScrollIndicator = NO;
    [breathCollectionView registerClass:[BreathCell class] forCellWithReuseIdentifier:@"BreathCell"];
    [self.view addSubview:breathCollectionView];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return breathNameArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH-3*Sp2Pt(1))/3, (SCREEN_WIDTH-3*Sp2Pt(1))/3);
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BreathCell *cell = [breathCollectionView dequeueReusableCellWithReuseIdentifier:@"BreathCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.icon.image = [UIImage imageNamed:breathIconArray[indexPath.row]];
    cell.nameLabel.text = breathNameArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BreathCell *cell = (BreathCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell zoomAnimationPop];
    [[WZBlueToothDataManager shareInstance] setModeWithAddress:(uint32_t)devAddr isGroup:isRoom andMode:indexPath.item+1 Delay:1];
}

#pragma mark - Actions


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

