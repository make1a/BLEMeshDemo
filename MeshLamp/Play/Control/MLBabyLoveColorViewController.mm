//
//  MLBabyLoveColorViewController.m
//  doonne
//
//  Created by TrusBe Sil on 2017/4/28.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLBabyLoveColorViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MLBabyLoveColorViewController ()<AVAudioPlayerDelegate> {
    UIImageView      *_itemsImage;
    NSMutableArray   *_imageBackARR;
    NSMutableArray   *_buttBackARR;
    int               imageNumber;
    int               tureButt;
    int              isPlaynumber;
}

@property (nonatomic,strong)AVAudioPlayer *myPlay;

@end

@implementation MLBabyLoveColorViewController
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
}

#pragma mark - Init
- (void)initPropertys {
    isPlaynumber = NO;
    _imageBackARR = [[NSMutableArray alloc] initWithObjects:@"ty_image_01_1.png",@"ty_image_01_2.png",@"ty_image_01_3.png",@"ty_image_02_4.png",@"ty_image_02_5.png",@"ty_image_03_6.png",@"ty_image_03_7.png",@"ty_image_04_8.png",@"ty_image_04_9.png",@"ty_image_04_10.png",@"ty_image_05_11.png",@"ty_image_05_12.png",@"ty_image_06_13.png",@"ty_image_06_14.png",@"ty_image_07_15.png",@"ty_image_07_16.png",@"ty_image_08_18.png",@"ty_image_08_18.png",@"ty_image_08_19.png",@"ty_image_08_20.png", nil];

}

#pragma mark - View
- (void)loadMainView {
    UIImageView *image_bg = [[UIImageView alloc] initWithFrame:self.view.frame];
    [image_bg setImage:[UIImage imageNamed:@"ty_bg_iphone5.png"]];
    [self.view addSubview:image_bg];
    
    NSArray *titARR = [NSArray arrayWithObjects:@"ty_butt_up.png",@"ty_butt_down.png", nil];
    for (int i = 1; i<2; i++) {
        UIButton *upButt = [UIButton buttonWithType:UIButtonTypeCustom];
        upButt.frame = CGRectMake(SCREEN_WIDTH/2 - Sp2Pt(111)/2, VGS(275), Sp2Pt(111), Sp2Pt(38));
        [upButt setTitle:LCSTR("Next") forState:UIControlStateNormal];
        [upButt setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        upButt.titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(20)];
        [upButt.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [upButt setBackgroundImage:[UIImage imageNamed:[titARR objectAtIndex:i]] forState:UIControlStateNormal];
        upButt.tag = 100+i;
        [upButt addTarget:self action:@selector(butonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:upButt];
    }
    
    _itemsImage = [[UIImageView alloc] initWithFrame:CGRectMake(HGS(32), VGS(70), HGS(256), VGS(178))];
    _itemsImage.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_itemsImage];
    [self netPhoto];
    
    UIImageView *items_bg =[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-HGS(281))/2, 0, HGS(281), VGS(256))];
    [items_bg setImage:[UIImage imageNamed:@"ty_image_bg.png"]];
    [self.view addSubview:items_bg];
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-Sp2Pt(36), SCREEN_WIDTH, Sp2Pt(36))];
    [self.view addSubview:downView];
    
    UIImageView *down_bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, Sp2Pt(36))];
    [down_bg setImage:[UIImage imageNamed:@"lu_down_bg.png"]];
    [downView addSubview:down_bg];
    
    UIButton *nav_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [nav_back setImage:[UIImage imageNamed:@"nav_game_black.png"] forState:UIControlStateNormal];
    nav_back.frame = CGRectMake(Sp2Pt(20), Sp2Pt(3), Sp2Pt(32), Sp2Pt(33));
    nav_back.tag = 200;
    [nav_back addTarget:self action:@selector(buttonFunClick:) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:nav_back];
    
    UIButton *nav_geng = [UIButton buttonWithType:UIButtonTypeCustom];
    [nav_geng setBackgroundImage:[UIImage imageNamed:@"nav_game_geng.png"] forState:UIControlStateNormal];
    nav_geng.frame = CGRectMake(SCREEN_WIDTH-Sp2Pt(120), 0, Sp2Pt(96), Sp2Pt(35));
    nav_geng.tag = 201;
    [nav_geng addTarget:self action:@selector(buttonFunClick:) forControlEvents:UIControlEventTouchUpInside];
    [nav_geng setTitle:LCSTR("With friends") forState:UIControlStateNormal];
    [nav_geng.titleLabel setFont:[UIFont systemFontOfSize:Sp2Pt(12)]];
    //    [downView addSubview:nav_geng];
    
    int jusntHight1 ,jusntHight2;
    
    jusntHight1 = VGS(360);
    jusntHight2 = VGS(30);
    
    for (int i = 0; i<8; i++) {
        CGRect frame2;
        frame2.size.width = HGS(52);
        frame2.size.height = HGS(52);
        frame2.origin.x = floor(i%4)*(HGS(52)+(SCREEN_WIDTH-4*HGS(52))/5)+(SCREEN_WIDTH-4*HGS(52))/5;
        frame2.origin.y = floor(i/4)*(HGS(52)+jusntHight2)+jusntHight1;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 300+i;
        [button setFrame:frame2];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"ty_butt_0%d.png",i+1]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(colourButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

#pragma mark -
template<int SLOT_SIZE>
struct FairRandStat {
    bool            slots[SLOT_SIZE];
    int             gended;
    
#define slotSize()  ( sizeof(slots) / sizeof(*slots) )
    
    int getRandPos()
    {
        if (gended == slotSize()) {
            gended = 0;
            memset(slots, 0, slotSize());
        }
#define slotRand() ((int)random()%slotSize())
        int pos = slotRand();
        while (slots[pos] == true)
            pos = slotRand();
        slots[pos] = true;
        ++gended;
#undef slotRand
#undef slotSize
        
        NSLog(@"gened: %d/%d", gended, pos);
        return pos;
    }
    
    int slotsCnt()
    {
        return sizeof(slots) / sizeof(*slots);
    }
};

static FairRandStat<19> imgRand = { 0, };

#pragma mark -
- (void)upViewColor {
    NSLog(@"%@,%d",_imageBackARR,imageNumber);
    NSString *str = [NSString stringWithFormat:@"%@",[_imageBackARR objectAtIndex:imageNumber]];
    [_itemsImage setImage:[UIImage imageNamed:str]];
    
    NSArray *aaa = [str componentsSeparatedByString:@"_"];
    
    [self playColor:[[aaa objectAtIndex:2] intValue]];
    
    tureButt = 300+[[aaa objectAtIndex:2] intValue]-1;
    
    NSArray *colorH = [NSArray arrayWithObjects:@"0.0",@"0.04",@"0.166667",@"0.33333",@"0.472222",@"0.66667",@"0.75",@"0.975", nil];
    UIColor *col2 = nil;
    float Hue = [[colorH objectAtIndex:(tureButt-300)] floatValue];
    col2 = [UIColor colorWithHue:Hue saturation:1 brightness:1 alpha:1];
    
    const CGFloat *components = CGColorGetComponents(col2.CGColor);
    // 获取RGB颜色
    CGFloat  red = components[0];
    CGFloat  green = components[1];
    CGFloat  blue = components[2];
    [[WZBlueToothDataManager shareInstance] setRGBWCWithAddress:(uint32_t)devAddr isGroup:isRoom WithRed:red Green:green Blue:blue Warm:0 Cold:0 Lum:1 Delay:0];
}



- (void)upPhoto {
    imageNumber = imgRand.getRandPos();
    [self upViewColor];
}

- (void)netPhoto {
    imageNumber = imgRand.getRandPos();
    [self upViewColor];
}


- (BOOL)prefersStatusBarHidden {
    // 隐藏为YES，显示为NO
    return YES;
}

// 回答正确
- (void)answerCorrect {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSString *messagePath = [[NSBundle mainBundle] pathForResource:LCSTR("tyts_color_right") ofType:@"mp3"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:messagePath];
    AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    self.myPlay = thePlayer;
    self.myPlay.delegate = self;
    [self.myPlay play];
    isPlaynumber = YES;
}

// 回答错误
- (void)answerError {
    isPlaynumber = NO;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSString *messagePath = [[NSBundle mainBundle] pathForResource:LCSTR("tyts_color_wrong") ofType:@"mp3"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:messagePath];
    AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    self.myPlay = thePlayer;
    self.myPlay.delegate = self;
    [self.myPlay play];
}

- (void)playColor:(int)color {
    isPlaynumber = NO ;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSString *tit = [NSString stringWithFormat:LCSTR("tyts_color_audio_name_num"),color];
    
    NSString *messagePath = [[NSBundle mainBundle] pathForResource:tit ofType:@"mp3"];
    NSLog(@"messagePath = %@",messagePath);
    if (messagePath != nil) {
        NSURL *url=[[NSURL alloc] initFileURLWithPath:messagePath];
        AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        self.myPlay = thePlayer;
        self.myPlay.delegate = self;
        [self.myPlay play];
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player {
    NSLog(@"处理终端");
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag {
    NSLog(@"播放完毕");
    if (isPlaynumber == YES) {
        [self netPhoto];
    }
}

#pragma mark - Action
- (void)butonClick:(id)sender {
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 100://上一个
        {
            [self upPhoto];
        }
            break;
        case 101://下一个
        {
            [self netPhoto];
        }
            break;
        default:
            break;
    }
}

- (void)buttonFunClick:(id)sender {
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 200:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 201://大家一起玩
        {
        }
            break;
        default:
            break;
    }
}

- (void)colourButtonClick:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSLog(@"点击按钮得颜：%ld",(long)button.tag);
    if (tureButt == button.tag) {
        [self answerCorrect];
        NSLog(@"要发送颜色");
    } else {
        [self answerError];
    }
}

@end
