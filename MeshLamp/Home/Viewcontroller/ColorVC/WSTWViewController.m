//
//  WSTWViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/25.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTWViewController.h"
#import "WSTWView.h"
#import "WSTEditColorViewController.h"
@interface WSTWViewController ()<ColorPickerDelegate,WZBlueToothDataSource>
@property (nonatomic,strong) WSTWView  *containerView;

@end

@implementation WSTWViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_containerView) {
        [self.containerView changeColor];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isColor = YES;
}

#pragma mark - delegate
- (void)colorPickerView:(ColorPickerView *)colorPickerView withHue:(float)hue Saturation:(float)saturation{
//        [[WZBlueToothDataManager shareInstance]setWarmWithAddress:(uint32_t)self.devAddr  isGroup:self.isRoom WithWarm:1 - colorPickerView.saturationValue Delay:0];
}

#pragma mark - WZBlueToothDataManagerDelegate
- (void)updateDeviceStatus{
    NSArray *devices = [[WZBlueToothDataManager shareInstance]getCurrentDevicesWithOnlie:YES];
    for (WZBLEDataModel *model in devices) {
        if (model.addressLong == self.devAddr) {
            [self.containerView.slider setValue:model.brightness/100.f animated:YES];
        }
    }
}
//设备灯珠的状态
- (void)responseOfDeviceStatus:(NSArray *)status{
    CGFloat hue, saturation, brightness, lum;
    if (status.count>6) {
        lum = [status[6] floatValue]/100.f;
        UIColor *color = [UIColor colorWithRed:[status[0] floatValue] / 255 green:[status[1] floatValue] / 255 blue:[status[2] floatValue] / 255 alpha:1];
        [color getHue:&hue saturation:&saturation brightness:&brightness alpha:NULL];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (lum<0.06) {
                [self.containerView.slider setValue:0.05 animated:YES];
            }else{
                [self.containerView.slider setValue:lum animated:YES];
            }
            
            [self.containerView.colorView.colorBlock setFrame:[self.containerView.colorView getColorPointInColorPickerHue:hue Saturation:saturation]];
        });
        
    }
    
}


- (void)masLayoutSubview{
    [super masLayoutSubview];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.leftContainerView);
    }];
}

- (WSTWView *)containerView{
    if (!_containerView) {
        _containerView = [[WSTWView alloc]init];
        _containerView.colorView.delegate = self;
        [_containerView.slider addTarget:self action:@selector(changeLum:) forControlEvents:UIControlEventValueChanged];
        __weak typeof (self)weakSelf = self;
        _containerView.pressButton = ^(CGFloat h, CGFloat s, CGFloat b, BOOL isColor) {
            weakSelf.isColor = isColor;
            if ((h==s)&& (h==b) && h==0) {return;}
                [[WZBlueToothDataManager shareInstance]setWarmWithAddress:(uint32_t)weakSelf.devAddr  isGroup:weakSelf.isRoom WithWarm:b Delay:0];
        };
        _containerView.longPress = ^(WSTColorModel *model,NSInteger index) {
            WSTEditColorViewController *vc = [WSTEditColorViewController new];
            vc.devAddr = weakSelf.devAddr;
            vc.isColor = NO;
            vc.isSingle = YES;
            vc.isWarm = YES;
            vc.isRoom = weakSelf.isRoom;
            vc.currentModel = model;
            vc.index = index;
            [weakSelf.rt_navigationController pushViewController:vc animated:YES complete:nil];
        };
        [self.leftContainerView addSubview:_containerView];
    }
    return _containerView;
}
@end


