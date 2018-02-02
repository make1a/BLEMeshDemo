//
//  MLPinchBombViewController.m
//  doonne
//
//  Created by TrusBe Sil on 2017/4/28.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLPinchBombViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MLPinchBombViewController (){
    NSDate          *beginTime;
    NSDate          *endedTime;
    
    CGPoint         beginPoint;
    CGPoint         endedPoint;
    UIImageView     *barrelImage;
    
    UILabel         *timeLable;
    UILabel         *timeTipLabel;
    UILabel         *shotLable;
    UILabel         *shotTipLabel;
    UIImageView     *animationImageView;
    NSTimer         *levelTimer;
    
    
    int              timeNumber;
    int              shotNumber;
    BOOL             ISBEGIN;
}

@property (nonatomic,strong)AVAudioPlayer *myPlay;
@property (nonatomic,strong)NSString *showMess;

@end

@implementation MLPinchBombViewController
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [levelTimer invalidate];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
}

#pragma mark - Init
- (void)initPropertys {
    
}

#pragma mark - View
- (void)loadMainView {
    self.view.backgroundColor = [UIColor colorWithRed:230/255.0 green:244/255.0 blue:246/255.0 alpha:1.0];
    if (IS_iPhone5) {
        UIImageView *image_bg = [[UIImageView alloc] initWithFrame:self.view.frame];
        image_bg.tag = 9988;
        [image_bg setImage:[UIImage imageNamed:@"lu_bg_iPhone5.png"]];
        [self.view addSubview:image_bg];
    } else {
        UIImageView *image_bg = [[UIImageView alloc] initWithFrame:self.view.frame];
        image_bg.tag = 9988;
        [image_bg setImage:[UIImage imageNamed:@"lu_bg.png"]];
        [self.view addSubview:image_bg];
    }
    
    UIImageView *image_monkey = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-Sp2Pt(153))/2, 0, Sp2Pt(153), Sp2Pt(130))];
    image_monkey.tag = 1000;
    image_monkey.animationImages =  [NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"lu_monkey_01.png"],
                                     [UIImage imageNamed:@"lu_monkey_02.png"],nil];
    //设置动画时间
    image_monkey.animationDuration = 0.5;
    image_monkey.animationRepeatCount = 1;
    
    [image_monkey setImage:[UIImage imageNamed:@"lu_monkey_02.png"]];
    [image_monkey setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:image_monkey];
    
    
    shotLable = [[UILabel  alloc] initWithFrame:CGRectMake(HGS(20), VGS(25), HGS(50), VGS(25))];
    [shotLable setText:@"0"];
    shotLable.textAlignment = NSTextAlignmentCenter;
    shotLable.shadowColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
    [shotLable setBackgroundColor:[UIColor clearColor]];
    [shotLable setFont:[UIFont fontWithName:@"Verdana-Bold" size:Sp2Pt(21)]];
    [shotLable setTextColor:[UIColor whiteColor]];
    [self.view addSubview:shotLable];
    
    shotTipLabel = [[UILabel  alloc] initWithFrame:CGRectMake(HGS(20), 0, HGS(50), VGS(25))];
    [shotTipLabel setText:LCSTR("Hits")];
    shotTipLabel.textAlignment = NSTextAlignmentCenter;
    shotTipLabel.shadowColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
    [shotTipLabel setBackgroundColor:[UIColor clearColor]];
    [shotTipLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:Sp2Pt(21)]];
    [shotTipLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:shotTipLabel];
    
    timeLable = [[UILabel  alloc] initWithFrame:CGRectMake(HGS(252), VGS(25), HGS(33), VGS(25))];
    [timeLable setText:@"30"];
    timeLable.textAlignment = NSTextAlignmentRight;
    timeLable.shadowColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
    [timeLable setBackgroundColor:[UIColor clearColor]];
    [timeLable setFont:[UIFont fontWithName:@"Verdana-Bold" size:Sp2Pt(21)]];
    [timeLable setTextColor:[UIColor whiteColor]];
    [self.view addSubview:timeLable];
    
    timeTipLabel = [[UILabel  alloc] initWithFrame:CGRectMake(HGS(246), 0, HGS(60), VGS(25))];
    [timeTipLabel setText:LCSTR("Time")];
    timeTipLabel.textAlignment = NSTextAlignmentCenter;
    timeTipLabel.shadowColor = [UIColor colorWithWhite:0.1f alpha:0.8f];
    [timeTipLabel setBackgroundColor:[UIColor clearColor]];
    [timeTipLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:Sp2Pt(21)]];
    [timeTipLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:timeTipLabel];
    
    UILabel *lable2 = [[UILabel  alloc] initWithFrame:CGRectMake(HGS(286), VGS(30), HGS(20), VGS(20))];
    [lable2 setText:@"s"];
    [lable2 setBackgroundColor:[UIColor clearColor]];
    [lable2 setFont:[UIFont fontWithName:@"Verdana-Bold" size:Sp2Pt(15)]];
    [lable2 setTextColor:[UIColor whiteColor]];
    [self.view addSubview:lable2];
    
    animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Sp2Pt(125), Sp2Pt(125))];
    animationImageView.animationImages =  [NSArray arrayWithObjects:
                                           [UIImage imageNamed:@"lu_bo_01_01.png"],
                                           [UIImage imageNamed:@"lu_bo_01_02.png"],
                                           [UIImage imageNamed:@"lu_bo_01_03.png"],
                                           [UIImage imageNamed:@"lu_bo_01_04.png"],
                                           [UIImage imageNamed:@"lu_bo_01_05.png"],
                                           [UIImage imageNamed:@"lu_bo_01_06.png"],
                                           [UIImage imageNamed:@"lu_bo_01_07.png"],
                                           [UIImage imageNamed:@"lu_bo_01_08.png"],
                                           [UIImage imageNamed:@"lu_bo_01_09.png"],
                                           [UIImage imageNamed:@"lu_bo_01_10.png"],nil];
    animationImageView.animationDuration = 0.15;//设置动画时间
    animationImageView.animationRepeatCount = 1;
    [self.view addSubview:animationImageView];
    
    NSArray *array = [NSArray arrayWithObjects:@"lu_light_01.png",@"lu_wei_01_01.png",@"lu_light_02.png",@"lu_wei_02_01.png",@"lu_light_03.png",@"lu_wei_03_01.png",@"lu_light_04.png",@"lu_wei_04_01.png",@"lu_light_05.png",@"lu_wei_05_01.png",@"lu_light_06.png",@"lu_wei_06_01.png",@"lu_light_01.png",@"lu_wei_01_01.png",@"lu_light_02.png",@"lu_wei_02_01.png",@"lu_light_03.png",@"lu_wei_03_01.png",@"lu_light_04.png",@"lu_wei_04_01.png",@"lu_light_05.png",@"lu_wei_05_01.png",@"lu_light_06.png",@"lu_wei_06_01.png",@"lu_light_01.png",@"lu_wei_01_01.png",@"lu_light_02.png",@"lu_wei_02_01.png",@"lu_light_03.png",@"lu_wei_03_01.png",@"lu_light_04.png",@"lu_wei_04_01.png",@"lu_light_05.png",@"lu_wei_05_01.png",@"lu_light_06.png",@"lu_wei_06_01.png",nil];
    for (int i = 0 ; i<6; i++) {
        UIView *vvv = [[UIView alloc] initWithFrame:[self bulbOrigPos]];
        vvv.tag = 100+i;
        [self.view addSubview:vvv];
        
        UIImageView* paodan = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, HGS(55), VGS(75))];
        paodan.tag = 1;
        [paodan setUserInteractionEnabled:YES];
        [paodan setContentMode:UIViewContentModeScaleAspectFit];
        [paodan setImage:[UIImage imageNamed:array[2*i]]];
        [vvv addSubview:paodan];
        
        UIImageView* weiImage = [[UIImageView alloc] initWithFrame:CGRectMake(HGS(15), VGS(50), HGS(25), VGS(131))];
        weiImage.tag = 2;
        [weiImage setUserInteractionEnabled:YES];
        [weiImage setImage:[UIImage imageNamed:array[2*i+1]]];
        [vvv addSubview:weiImage];
        weiImage.hidden = YES;
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [vvv addGestureRecognizer:panRecognizer];
        panRecognizer.maximumNumberOfTouches = 1;
    }
    
    if (isSJNR) {
        UIImageView * downPerson = [[UIImageView alloc] initWithFrame:CGRectMake(32 - 60, SCREEN_HEIGHT - 10 - 192 + 6, 192, 192)];
        [downPerson setImage:[UIImage imageNamed:@"sjnr_zx_01.png"]];
        [downPerson setContentMode:UIViewContentModeScaleAspectFit];
        [UIView animateWithDuration:0.8 delay: 0 options: UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            downPerson.transform = CGAffineTransformMakeTranslation(20, 0);
        }completion:^(BOOL finished){
            downPerson.transform = CGAffineTransformMakeTranslation(-20, 0);
        }];
        [self.view addSubview:downPerson];
    }
    
    //    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan1:)];
    //    [self.view addGestureRecognizer:panRecognizer];
    //    panRecognizer.maximumNumberOfTouches = 1;
    
    barrelImage = [[UIImageView alloc] initWithFrame:CGRectMake(HGS(144), (self.view.frame.size.height - VGS(60)), HGS(32), VGS(32))];
    [barrelImage setImage:[UIImage imageNamed:@"lu_fa_01.png"]];
    [self.view addSubview:barrelImage];
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-Sp2Pt(36), SCREEN_WIDTH, Sp2Pt(36))];
    [self.view addSubview:downView];
    
    UIImageView *down_bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, Sp2Pt(36))];
    [down_bg setImage:[UIImage imageNamed:@"lu_down_bg.png"]];
    [downView addSubview:down_bg];
    
    UIButton *nav_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [nav_back setImage:[UIImage imageNamed:@"nav_game_black.png"] forState:UIControlStateNormal];
    nav_back.frame = CGRectMake(Sp2Pt(20), Sp2Pt(3), Sp2Pt(32), Sp2Pt(33));
    nav_back.tag = 200;
    [nav_back addTarget:self action:@selector(buttonFunClick:) forControlEvents:1<<6];
    [downView addSubview:nav_back];
    
    UIButton *nav_geng = [UIButton buttonWithType:UIButtonTypeCustom];
    [nav_geng setBackgroundImage:[UIImage imageNamed:@"nav_game_geng.png"] forState:UIControlStateNormal];
    nav_geng.frame = CGRectMake(SCREEN_WIDTH-Sp2Pt(120), 0, Sp2Pt(96), Sp2Pt(35));
    nav_geng.tag = 201;
    [nav_geng addTarget:self action:@selector(buttonFunClick:) forControlEvents:1<<6];
    //    [downView addSubview:nav_geng];
    [nav_geng setTitle:LCSTR("With friends") forState:UIControlStateNormal];
    [nav_geng.titleLabel setFont:[UIFont systemFontOfSize:Sp2Pt(12)]];
    
    UILabel *withFriendLabel = [[UILabel alloc] initWithFrame:CGRectMake(225, 0, 70, 35)];
    [withFriendLabel setText:LCSTR("With friends")];
    [withFriendLabel setFont: [UIFont systemFontOfSize:12]];
    [withFriendLabel setTextColor:[UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.6]];
    [withFriendLabel setBackgroundColor:[UIColor clearColor]];
    [withFriendLabel setTextAlignment: NSTextAlignmentCenter];
    //    [downView addSubview:withFriendLabel];
    
    levelTimer = [NSTimer scheduledTimerWithTimeInterval: 1 target: self selector: @selector(levelTimerCallback) userInfo: nil repeats: YES];
    [levelTimer setFireDate:[NSDate distantFuture]];
    timeNumber = 30;
    ISBEGIN = NO;
    shotNumber = 0;
}

#pragma mark -
static const char * (nameStrs[]) = {
    "菊花手", "撸王之王", "九阳白骨爪", "互撸娃", "一阳指",
};

- (void)levelTimerCallback {
    timeNumber = timeNumber-1;
    if (timeNumber<0) {
        timeNumber = 0;
        [levelTimer setFireDate:[NSDate distantFuture]];

        UIAlertView *alview = [[UIAlertView alloc] initWithTitle:LCSTR("Notice") message:LCSTR("pinch_bomb_share_msg_sjnr") delegate:self cancelButtonTitle:LCSTR("Cancel") otherButtonTitles:LCSTR("OK"), nil];
        [alview show];
    }
    [timeLable setText:[NSString stringWithFormat:@"%d",timeNumber]];
    NSLog(@"dingshiqi");
}

- (void)handlePan:(UIPanGestureRecognizer *)rec {
    CGPoint point = [rec translationInView:self.view];
    rec.view.center = CGPointMake(rec.view.center.x + point.x, rec.view.center.y+point.y);
    [rec setTranslation:CGPointMake(0, 0) inView:self.view];
    if (rec.state == UIGestureRecognizerStateBegan) {
        
        beginTime = [NSDate date];
        beginPoint.x = rec.view.center.x;
        beginPoint.y = rec.view.center.y;
    }
    if (rec.state == UIGestureRecognizerStateEnded) {
        if (ISBEGIN == NO) {
            ISBEGIN = YES;
            [levelTimer setFireDate:[NSDate date]];
        }
        UIImageView *bg_view = (UIImageView*)[self.view viewWithTag:1000];
        
        endedTime = [NSDate date];
        endedPoint.x = rec.view.center.x;
        endedPoint.y = rec.view.center.y;
        NSTimeInterval inrrr = [endedTime timeIntervalSinceDate:beginTime];
        
        float a1 = (endedPoint.x-beginPoint.x)/inrrr;
        float a2 = (endedPoint.y-beginPoint.y)/inrrr;
        
        float www1,t1,t2, rotateTime = 0;
        BOOL isPeng = NO;
        UIImageView *paodanView = (UIImageView*) [rec.view viewWithTag:1];
        UIImageView *imageView = (UIImageView*)[rec.view viewWithTag:2];
        if (!isSJNR) imageView.hidden = NO;
        UIImageView *mokeImagView = (UIImageView*)[self.view viewWithTag:1000];
        
        if ((endedPoint.x- beginPoint.x) == 0&&(endedPoint.y-beginPoint.y)!=0) {
            isPeng = YES;
            shotNumber = shotNumber+1;
            
            a2 = -a2;
            if (a2<300) {
                a2 = 300;
            }
            
            t2 = (endedPoint.y - 130)/a2;
            [UIView animateWithDuration:t2 animations:^{
                animationImageView.center = CGPointMake(endedPoint.x+(endedPoint.x-beginPoint.x)/inrrr*t2, endedPoint.y-a2*t2);
                rec.view.center = CGPointMake(endedPoint.x, endedPoint.y-a2*t2);
            } completion:^(BOOL finshed){
                if (isPeng == YES) {
                    [animationImageView startAnimating];
                    
                    [mokeImagView startAnimating];
                    float xxx = 0.833333 * (rec.view.tag - 100) / 5;
                    UIColor *col2 = [UIColor colorWithHue:xxx saturation:1 brightness:1 alpha:1];
                    
                    const CGFloat *components = CGColorGetComponents(col2.CGColor);
                    // 获取RGB颜色
                    CGFloat  red = components[0];
                    CGFloat  green = components[1];
                    CGFloat  blue = components[2];
                    [[WZBlueToothDataManager shareInstance] setRGBWCWithAddress:(uint32_t)devAddr isGroup:isRoom WithRed:red Green:green Blue:blue Warm:0 Cold:0 Lum:1 Delay:0];
                    @try {
                        [self monkeyShriek:getRandImgIdx()];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"Monkey shriek with: %@", exception);
                    }
                }
                [shotLable setText:[NSString stringWithFormat:@"%d",shotNumber]];
                imageView.hidden = YES;
                
                rec.view.frame =  [self bulbOrigPos];
                [self.view insertSubview:rec.view aboveSubview:bg_view];
            }];
            
            rotateTime = t2;
            
        } else if ((endedPoint.x- beginPoint.x) != 0&&(endedPoint.y-beginPoint.y)==0) {
            //            NSLog(@"失败了");
            if (a1<0) {
                a1 = -a1;
                www1 = endedPoint.x;
            }else{
                www1 = 320 - endedPoint.x;
            }
            t1 = www1/a1;
            
            //            NSLog(@"t1 ==== %f",t1);
            [UIView animateWithDuration:t1 animations:^{
                
                rec.view.center = CGPointMake(endedPoint.x+(endedPoint.x-beginPoint.x)/inrrr*t1, endedPoint.y);
            } completion:^(BOOL finshed){
                
                rec.view.frame = [self bulbOrigPos];
                [self.view insertSubview:rec.view aboveSubview:bg_view];
            }];
            
            rotateTime = t1;
        } else if((endedPoint.x- beginPoint.x) != 0&&(endedPoint.y-beginPoint.y)!=0) {
            if (a1<0) {
                a1 = -a1;
                www1 = endedPoint.x;
            } else {
                www1 = 320 - endedPoint.x;
            }
            a2 = -a2;
            if (a2<300) {
                a2 = 300;
            }
            t1 = www1/a1;
            t2 = (endedPoint.y - 130)/a2;
            if (t1>=t2) {
                shotNumber = shotNumber + 1;
                isPeng = YES;
                
            } else {
                isPeng = NO;
            }
            if (!isSJNR) imageView.hidden = NO;
            [UIView animateWithDuration:t2 animations:^{
                rec.view.center = CGPointMake(endedPoint.x+(endedPoint.x-beginPoint.x)/inrrr*t2, endedPoint.y-a2*t2);
                
                animationImageView.center = CGPointMake(endedPoint.x+(endedPoint.x-beginPoint.x)/inrrr*t2, endedPoint.y-a2*t2);
            } completion:^(BOOL finshed){
                imageView.hidden = YES;
                if (isPeng == YES) {
                    [mokeImagView startAnimating];
                    [animationImageView startAnimating];
                    float xxx = 0.833333 * (rec.view.tag - 100) / 5;
                    UIColor *col2 = [UIColor colorWithHue:xxx saturation:1 brightness:1 alpha:1];
                    
                    const CGFloat *components = CGColorGetComponents(col2.CGColor);
                    // 获取RGB颜色
                    CGFloat  red = components[0];
                    CGFloat  green = components[1];
                    CGFloat  blue = components[2];
                    [[WZBlueToothDataManager shareInstance] setRGBWCWithAddress:(uint32_t)devAddr isGroup:isRoom WithRed:red Green:green Blue:blue Warm:0 Cold:0 Lum:1 Delay:0];
                    [self monkeyShriek:getRandImgIdx()];
                }
                [shotLable setText:[NSString stringWithFormat:@"%d",shotNumber]];
                rec.view.frame =  [self bulbOrigPos];
                [self.view insertSubview:rec.view aboveSubview:bg_view];
            }];
            
            rotateTime = t2;
        }else if((endedPoint.x- beginPoint.x) == 0&&(endedPoint.y-beginPoint.y)==0){
            if (!isSJNR) imageView.hidden = NO;
            rec.view.frame =  [self bulbOrigPos];
            [self.view insertSubview:rec.view aboveSubview:bg_view];
        }
        
        if (isSJNR) {
            [UIView animateWithDuration:rotateTime animations:^{
                paodanView.transform = CGAffineTransformMakeRotation(180.0 / 180.0 * M_PI);
            }completion:^(BOOL finished){
                paodanView.transform = CGAffineTransformMakeRotation(0);
            }];
        }
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES; // 隐藏为YES，显示为NO
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"buttonIndex = %ld",(long)buttonIndex);
    switch (buttonIndex) {
        case 1:
        {
        }
            break;
        default:
            break;
    }
    timeNumber = 30;ISBEGIN = NO;shotNumber = 0;
    [timeLable setText:@"30"];
    [shotLable setText:@"0"];
}

- (void)monkeyShriek:(int)mo {
    NSString *strPath = [NSString stringWithFormat:@"Monkey_%d",mo];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    NSString *messagePath = [[NSBundle mainBundle] pathForResource:strPath ofType:@"mp3"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:messagePath];
    AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    self.myPlay = thePlayer;
    [self.myPlay play];
}

#pragma mark - Action
- (void)buttonFunClick:(id)sender {
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 200:
        {
            [levelTimer invalidate];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 201:
        {
        }
            break;
        case 202:
        {
        }
            break;
        default:
            break;
    }
}

#pragma mark - 
- (CGRect) bulbOrigPos {
    return CGRectMake((SCREEN_WIDTH-HGS(55))/2, SCREEN_HEIGHT-VGS(110), HGS(55), VGS(206));
}

static const bool isSJNR = false;

int getRandImgIdx() {
    int r = (int)random() % 9;
    if (isSJNR)
        return 0;
    return (r < 1) ? 0:( ( r < 3) ? 1 : 0);
}


@end
