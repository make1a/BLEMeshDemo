//
//  WSTControlViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/12.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTBaseColorViewController.h"
#import "WSTEditDeviceViewController.h"
#import "WSTBreatheViewController.h"
#import "WSTCameraViewController.h"
#import "MLMusicViewController.h"
#import "WSTShakeViewController.h"
#import "MLBabyLoveColorViewController.h"
#import "MLPinchBombViewController.h"
#import "WSTAlarmViewController.h"
#import "WSTCircadianViewController.h"
#import "WSTZhouYJLViewController.h"


#import "WSTControlColorView.h"
#import "WSTPlayColorView.h"
#import "BreathCell.h"




@interface WSTBaseColorViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>


/**WSTPlayColorView*/
@property (nonatomic,strong) WSTPlayColorView *playColorView;
/**UISegmentedControl*/
@property (nonatomic,strong) UISegmentedControl *segmentedControl;
/**scrollView*/
@property (nonatomic,strong) UIScrollView *scrollView;
/**当前UISegmentedControl下标 */
@property (nonatomic,assign) NSInteger currentIndex;
/**funcNameArray*/
@property (nonatomic,strong) NSArray *funcNameArray;
/**funcIconArray*/
@property (nonatomic,strong) NSArray *funcIconArray;

@end

@implementation WSTBaseColorViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNavigationStyle];
    [WZBlueToothDataManager shareInstance].delegate = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCurrentDeviceStatus];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [WZBlueToothDataManager shareInstance].delegate = nil;
    [self.segmentedControl removeFromSuperview];
    self.segmentedControl = nil;
}
- (void)setNavigationStyle{
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self segmentedControl];
    [self.segmentedControl setSelectedSegmentIndex:self.currentIndex];
    if (self.isRoom == NO) {
        [self setRightButtonImage:[UIImage imageNamed:@"edit_icon"]];
    }
}

#pragma mark - actions
- (void)onRightButtonClick:(id)sender{
    WSTEditDeviceViewController *vc = [WSTEditDeviceViewController new];
    vc.devAddr = _devAddr;
    [self.navigationController pushViewController:vc animated:YES];
}
//亮度
- (void)changeLum:(UISlider *)slider{
    [[WZBlueToothDataManager shareInstance]setBrightnessWithAddress:(uint32_t)_devAddr  isGroup:_isRoom Brightness:slider.value];
}
- (void)segmentedControlAction:(UISegmentedControl*)segment{
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            self.currentIndex = 0;
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
            break;
        default:
        {
            self.currentIndex = 1;
            [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
        }
            break;
    }
}
- (void)getCurrentDeviceStatus{
    if (_isRoom == NO) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[WZBlueToothDataManager shareInstance]getDeviceStatusWith:(uint32_t)_devAddr ];
        });
    }
}

#pragma mark - delegate
- (void)colorPickerView:(ColorPickerView *)colorPickerView withHue:(float)hue Saturation:(float)saturation{
    if (_isColor == YES) {
        [[WZBlueToothDataManager shareInstance] setHSBWithAddress:(uint32_t)self.devAddr isGroup:self.isRoom WithHue:hue Saturation:saturation Brightness:1 Warm:0 Cold:0 Lum:0 Delay:1];
    }else{
        [[WZBlueToothDataManager shareInstance] setHSBWithAddress:(uint32_t)self.devAddr isGroup:self.isRoom WithHue:0 Saturation:0 Brightness:0 Warm:1 - colorPickerView.saturationValue Cold:colorPickerView.saturationValue <= 0.05 ? 0 : colorPickerView.saturationValue Lum:0 Delay:1];
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _isRoom ? self.funcNameArray.count - 1 : self.funcNameArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH - 3 * 1) / 3, (SCREEN_WIDTH - 3 * 1) / 3);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BreathCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BreathCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.icon.image = [UIImage imageNamed:self.funcIconArray[indexPath.row]];
    cell.nameLabel.text = self.funcNameArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    BreathCell *cell = (BreathCell *) [collectionView cellForItemAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        WSTBreatheViewController *breathVC = [[WSTBreatheViewController alloc] init];
        breathVC.isRoom = _isRoom;
        breathVC.devAddr = _devAddr;
        [self.navigationController pushViewController:breathVC animated:YES];
    }else if (indexPath.row == 1) {
        WSTCameraViewController *vc = [[WSTCameraViewController alloc] init];
        vc.isRoom = _isRoom;
        vc.devAddr = _devAddr;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2) {
        MLMusicViewController *musicVC = [[MLMusicViewController alloc] init];
        musicVC.isRoom = _isRoom;
        musicVC.devAddr = _devAddr;
        [self.navigationController pushViewController:musicVC animated:YES];
    }else if (indexPath.row == 3) {
        WSTShakeViewController *shakeVC = [[WSTShakeViewController alloc] init];
        shakeVC.isRoom = _isRoom;
        shakeVC.devAddr = _devAddr;
        [self.navigationController pushViewController:shakeVC animated:YES];
    }
    else if (indexPath.row == 4) {
        MLPinchBombViewController *pinchBombVC = [[MLPinchBombViewController alloc] init];
        pinchBombVC.isRoom = _isRoom;
        pinchBombVC.devAddr = _devAddr;
        [self.navigationController pushViewController:pinchBombVC animated:YES];
    } else if (indexPath.row == 5) {
        MLBabyLoveColorViewController *babyLoveColorVC = [[MLBabyLoveColorViewController alloc] init];
        babyLoveColorVC.isRoom = _isRoom;
        babyLoveColorVC.devAddr = _devAddr;
        [self.navigationController pushViewController:babyLoveColorVC animated:YES];
        
    } else if (indexPath.row == 6) {
        WSTAlarmViewController *timingVC = [[WSTAlarmViewController alloc] init];
        timingVC.isRoom = _isRoom;
        timingVC.devAddr = _devAddr;
        [self.navigationController pushViewController:timingVC animated:YES];
        
    }else if (indexPath.row == 7) {
        WSTZhouYJLViewController *vc = [[WSTZhouYJLViewController alloc]initWithNibName:@"WSTZhouYJLViewController" bundle:nil];
        vc.isRoom = _isRoom;
        vc.devAddr = _devAddr;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        
    }
    
}
#pragma mark - 布局
- (void)masLayoutSubview{
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
    [self.leftContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.scrollView);
        make.width.mas_equalTo(SCREEN_WIDTH);
        if (@available(iOS 11.0, *)) {
            make.height.equalTo(self.view.mas_safeAreaLayoutGuideHeight).mas_offset(1);
        } else {
            make.height.equalTo(self.view);
        }
    }];
    [self.playColorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.leftContainerView.mas_right);
        make.width.mas_equalTo(SCREEN_WIDTH);
        if (@available(iOS 11.0, *)) {
            make.height.equalTo(self.view.mas_safeAreaLayoutGuideHeight).mas_offset(1);
        } else {
            make.height.equalTo(self.view);
        }
    }];
}
#pragma mark - 懒加载
- (WSTPlayColorView *)playColorView{
    if (!_playColorView) {
        _playColorView = [[WSTPlayColorView alloc]init];
        _playColorView.collectionView.delegate = self;
        _playColorView.collectionView.dataSource = self;
        [self.scrollView addSubview:_playColorView];
    }
    return _playColorView;
}
- (UISegmentedControl *)segmentedControl{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc]initWithItems:@[LCSTR("palette"),LCSTR("interaction")]];
        [_segmentedControl setBackgroundColor:[UIColor clearColor]];
        _segmentedControl.layer.borderColor = [UIColor whiteColor].CGColor;
        _segmentedControl.layer.borderWidth = 1.f;
        _segmentedControl.tintColor = [UIColor whiteColor];
        _segmentedControl.layer.masksToBounds = YES;
        _segmentedControl.layer.cornerRadius = 5;
        [_segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
        _segmentedControl.frame = CGRectMake(0, 0, 200, [UIApplication sharedApplication].statusBarFrame.size.height);
        [self.navigationItem setTitleView:_segmentedControl];
        [_segmentedControl sizeToFit];
        
    }
    return _segmentedControl;
}
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.backgroundColor = BGColor;
        [self.view addSubview:_scrollView];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.scrollEnabled = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*2, 0);
    }
    return _scrollView;
}
- (NSArray *)funcNameArray{
    if (!_funcNameArray) {
        _funcNameArray = @[LCSTR("breath_mode"),LCSTR("camera_color"),LCSTR("music"),LCSTR("shake"),LCSTR("Pinch bomb"),LCSTR("child_color"),LCSTR("alarm"),LCSTR("dayAndNight")];
    }
    return _funcNameArray;
}

- (NSArray *)funcIconArray{
    if (!_funcIconArray) {
        _funcIconArray = @[@"breath_icon",@"camera_picker_icon",@"music_icon",@"shake_icon",@"pinch_bomb_icon",@"baby_love_color_icon",@"timing_icon",@"circadian_icon"];
    }
    return _funcIconArray;
}

- (UIView *)leftContainerView{
    if (!_leftContainerView) {
        _leftContainerView = [UIView new];
        [self.scrollView addSubview:_leftContainerView];
    }
    return _leftContainerView;
}
@end

