//
//  WSTShakeViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTShakeViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>
@interface WSTShakeViewController ()
{
    // View
    UIImageView         *shakeDanceImageView;
    UILabel             *tipsLabel;
    UISegmentedControl  *segmentedControl;
    
    // Motion
    CMMotionManager     *cmManager;
    NSTimer             *levelTimer;
}
@end

@implementation WSTShakeViewController
@synthesize isRoom, devAddr;

- (void)viewDidLoad {
    [super viewDidLoad];
   [self loadMainView];
    [self setNavigationStyle];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [levelTimer invalidate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}
- (void)setNavigationStyle{
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setNavigationTitle:LCSTR("shake_dance") titleColor:[UIColor whiteColor]];
}
- (void)loadMainView {

    
    shakeDanceImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-105)/2, (SCREEN_HEIGHT-200)/2, 105, 105)];
    shakeDanceImageView.image = [UIImage imageNamed:@"ShakeLogo"];
    [self.view addSubview:shakeDanceImageView];

    
    tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, shakeDanceImageView.frame.origin.y+105+8, SCREEN_WIDTH, 44)];
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.textColor = [UIColor grayColor];
    tipsLabel.font = [UIFont systemFontOfSize:Sp2Pt(15)];
    tipsLabel.text = LCSTR("Jiggle the phone changes color"); // 轻摇手机变换颜色
    [self.view addSubview:tipsLabel];
    [shakeDanceImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).mas_offset(-30);
    }];
    [tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shakeDanceImageView.mas_bottom).mas_offset(px1334Hight(20));
        make.centerX.equalTo(self.view);
    }];
    
    
    NSArray *array = @[LCSTR("shake"), LCSTR("Dance")];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:array];
    segmentedControl.frame = CGRectMake((SCREEN_WIDTH-200)/2, SCREEN_HEIGHT-80, 200, 40);
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.tintColor = [UIColor whiteColor];
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    [segmentedControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(200);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-px1334Hight(20));
        } else {
            make.bottom.equalTo(self.view).mas_offset(-px1334Hight(20));
        }
    }];
    
    cmManager = [[CMMotionManager alloc]init];
    if (!cmManager.accelerometerAvailable) {
        NSLog(@"CMMotionManager unavailable");
    }
    cmManager.accelerometerUpdateInterval = 0.08f;
    [cmManager startAccelerometerUpdates];
    
    levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.08f target:self selector:@selector(updateAcceleration:)userInfo:nil repeats:YES];
    [levelTimer setFireDate:[NSDate distantFuture]];
}

#pragma mark - Action
- (void)navBarButtonAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)segmentAction:(UISegmentedControl *)segment {
    NSInteger index = segment.selectedSegmentIndex;
    switch (index) {
        case 0:
            shakeDanceImageView.image = [UIImage imageNamed:@"ShakeLogo"];
            tipsLabel.text = LCSTR("Jiggle the phone changes color");// 轻摇手机变换颜色
            [levelTimer setFireDate:[NSDate distantFuture]];
            break;
        case 1:
            shakeDanceImageView.image = [UIImage imageNamed:@"DanceLogo"];
            tipsLabel.text = LCSTR("Color transform as you dance");// 颜色随您的舞姿变换
            [levelTimer setFireDate:[NSDate date]];
            break;
        default:
            break;
    }
}

#pragma mark -
-(void)updateAcceleration:(id)userInfo {
    CMAccelerometerData *accelData =cmManager.accelerometerData;
    double x = accelData.acceleration.x;
    double y = accelData.acceleration.y;
    double z = accelData.acceleration.z;  // + G
    CGFloat r = fabs(x);
    CGFloat g = fabs(y);
    CGFloat b = fabs(z);
    
    NSLog(@"%f, %f, %f", r, g, b);
    
    CGFloat H, S, B, A;
    UIColor * c = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
    [c getHue:&H saturation:&S brightness:&B alpha:&A];
    c = [UIColor colorWithHue: H saturation: 0.3 + S brightness:S*S*S alpha:A];
    [c getRed:&r green:&g blue:&b alpha:&A];
    
    if (r!=0 || g!=0 || b!=0) {
        [[WZBlueToothDataManager shareInstance] setRGBWCWithAddress:(uint32_t)devAddr isGroup:isRoom WithRed:r Green:g Blue:b Warm:0 Cold:0 Lum:1 Delay:0];
    }
}

// 图片晃动
-(void)shakeView:(UIView *)viewToShake {
    CGFloat t = 6.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}

#pragma mark - Motion
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (segmentedControl.selectedSegmentIndex == 0) {
        if (event.subtype == UIEventSubtypeMotionShake) {
            int ww =   arc4random()%(int)360;
            UIColor *col = [UIColor colorWithHue:ww/360.0f saturation:1 brightness:1 alpha:1];
            const CGFloat *components = CGColorGetComponents(col.CGColor);
            // 获取RGB颜色
            CGFloat  red = components[0]*255;
            CGFloat  green = components[1]*255;
            CGFloat  blue = components[2]*255;
            [[WZBlueToothDataManager shareInstance] setRGBWCWithAddress:(uint32_t)devAddr isGroup:isRoom WithRed:red Green:green Blue:blue Warm:0 Cold:0 Lum:1 Delay:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                [self shakeView:shakeDanceImageView];
            });
        }
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

