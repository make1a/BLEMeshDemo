//
//  MLMusicViewController.m
//  doonne
//
//  Created by TrusBe Sil on 2017/4/28.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLMusicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MusicCell.h"

@interface MLMusicViewController ()<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate> {
    dispatch_queue_t loadDealersQueut;
    
    UITableView     *musicTableView;
    NSMutableArray  *musicArray;
    UIProgressView  *musicProgress;
    AVAudioPlayer   *audioPlayer;
    NSURL           *playURL;
    int             playNumb;
    
    NSTimer         *levelTimer;
    NSTimer         *levelTimer2;
    
    UIView          *downView;
    
    UIView          *playButt, *nextButt, *preButt;
    UIScrollView    *spsScrollView;
    UIView          *musicView;
    UIImageView     *musicIcon;
    UIView          *maikeView;
    
    UILabel         *songLable;
    UILabel         *starLable;
    
    AVAudioRecorder *recorder;
    float           lowPassResults;

}

@end

@implementation MLMusicViewController
@synthesize isRoom, devAddr;

#pragma mark - LifeCycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMainView];
    [self setNavigationStyle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [levelTimer invalidate];
    [levelTimer2 invalidate];
    
    [audioPlayer stop];
    audioPlayer = nil;
    
    [recorder stop];
    recorder = nil;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    }
}
- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("music") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
}
#pragma mark - View
- (void)loadMainView {


    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&err];
    if(err){
        return;
    }
    [audioSession setActive:YES error:&err];
    
    
    levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(listenForBlow:) userInfo: nil repeats: YES];
    [levelTimer setFireDate:[NSDate distantFuture]];
    if (loadDealersQueut == nil) {
        loadDealersQueut = dispatch_queue_create("com.geelycar.loadactivity.loadDealersQueute", DISPATCH_QUEUE_CONCURRENT);
    }
    
    // MusicView
    musicView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    musicView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:musicView];

    
    musicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Width(musicView), Height(musicView)) style:UITableViewStylePlain];
    musicTableView.delegate = self;
    musicTableView.dataSource = self;
    musicTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    musicTableView.separatorColor = [UIColor darkGrayColor];
    musicTableView.backgroundColor = [UIColor clearColor];
    [musicView addSubview:musicTableView];
    
    // 控制界面
    downView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    downView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:downView];
    
    [downView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(64);
        make.bottom.equalTo(self.view);
    }];
    [musicView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(downView.mas_top);
    }];
    [musicTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(musicView);
    }];
    
    musicProgress = [[UIProgressView alloc] init];
    musicProgress.tintColor = [UIColor colorWithRed:68.0 / 255.0 green:219.0 / 255.0 blue:94.0 / 255.0 alpha:1.0f];
    musicProgress.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    [downView addSubview:musicProgress];
    
    NSArray *playImage = [[NSArray alloc] initWithObjects:@"PlayIcon",@"NextIcon", nil];
    for (int i = 0; i<2; i++) {
        UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
        (i == 0) ? (self->playButt = button) : (self->nextButt = button);
        [button setFrame:CGRectMake(8+52*i, (Height(downView)-44)/2, 44, 44)];
        button.tag = 100+i;
        [button setImage:[UIImage imageNamed:[playImage objectAtIndex:i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [downView addSubview:button];
    }
    preButt = [UIButton buttonWithType:UIButtonTypeCustom];
    preButt.tag = 102;
    preButt.hidden = true;
    
    NSArray *playImage2 = [[NSArray alloc] initWithObjects:@"MusicIcon_n",@"MusicIcon_s",@"MicIcon_n",@"MicIcon_s", nil];
    for (int i = 0; i<2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setFrame:CGRectMake(Width(downView)-104+52*i, (Height(downView)-30)/2, 35, 35)];
        button.tag = 200+i;
        [button setImage:[UIImage imageNamed:[playImage2 objectAtIndex:2*i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[playImage2 objectAtIndex:2*i+1]] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [downView addSubview:button];
    }
    [self setModerView:0];
    
    [SVProgressHUD showInfoWithStatus:LCSTR("music_not_ready")];
    dispatch_async(loadDealersQueut, ^{
        // 读取条件
        MPMediaQuery *everything = [[MPMediaQuery alloc] init];
        MPMediaPropertyPredicate *albumNamePredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeMusic ] forProperty: MPMediaItemPropertyMediaType];
        [everything addFilterPredicate:albumNamePredicate];
        musicArray = [NSMutableArray arrayWithArray:[everything items]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (musicArray.count == 0) {
                UIAlertView *alview = [[UIAlertView alloc] initWithTitle: LCSTR("Notice") message:LCSTR("cannot_search_any_music") delegate:nil cancelButtonTitle: LCSTR("OK") otherButtonTitles:nil, nil];
                [alview show];
//                UIButton *recordButt = (UIButton*)[downView viewWithTag:201];
//                [self playButtonClick:recordButt];
            }
            [musicTableView reloadData];
            [SVProgressHUD dismiss];
        });
    });
    
    // 录音界面
    maikeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    maikeView.backgroundColor = [UIColor  clearColor];
    [self.view addSubview:maikeView];
    maikeView.hidden = YES;
    [maikeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    UIImageView *maike_bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MicLogo"]];
    maike_bg.frame = CGRectMake((SCREEN_WIDTH-128)/2, (Height(maikeView)-128)/2, 128, 128);
    [maikeView addSubview:maike_bg];
    
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    levelTimer2 = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    [levelTimer2 setFireDate:[NSDate distantFuture]];
    
    self.view.clipsToBounds = true;
    [self.view bringSubviewToFront:downView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return musicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellWithIdentifier = @"Cell";
    MusicCell *cell = (MusicCell*)[tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    if (cell == nil) {
        cell = [[MusicCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellWithIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
    }
    MPMediaItem *song = [musicArray objectAtIndex:indexPath.row];
    NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    NSString *songArtist = [song valueForProperty:MPMediaItemPropertyArtist];
    NSString *albumTitle = [song valueForProperty: MPMediaItemPropertyAlbumTitle];
    //MPMediaItemPropertyArtist
    [cell.nameLable setText: songTitle ? songTitle : @"-"];
    [cell.artistLabel setText: [NSString stringWithFormat: @"%@ - %@", songArtist ? songArtist : @"-", albumTitle ? albumTitle : @"-"]];
    UIImage *artwork = [[song valueForProperty: MPMediaItemPropertyArtwork] imageWithSize: cell.artworkImageView.frame.size];
    [cell.artworkImageView setImage: artwork ? artwork : [UIImage imageNamed:@"NoArtwork_n"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    playNumb = (int)indexPath.row;
    MPMediaItem *song = [musicArray objectAtIndex:indexPath.row];
    NSURL *musicURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
    
    NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
    NSString *albumTitle = [song valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString *star = [song valueForProperty: MPMediaItemPropertyArtist];
    NSObject *artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    
    // Update view music info.
    [songLable  setText: songTitle ? songTitle : @"-"];
    [starLable  setText: star ? star : @"-"];
    
    // Update remote.
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (songTitle) [dict setObject:songTitle forKey:MPMediaItemPropertyTitle];
    if (star) [dict setObject:star forKey:MPMediaItemPropertyArtist];
    if (albumTitle) [dict setObject:albumTitle forKey:MPMediaItemPropertyAlbumTitle];
    if (artwork) [dict setObject: artwork forKey:MPMediaItemPropertyArtwork];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    
    // Update player
    UIImage * artImg = [[song valueForProperty:MPMediaItemPropertyArtwork] imageWithSize: musicIcon.frame.size];
    [musicIcon setImage: artImg ? artImg : [UIImage imageNamed:@"NoArtwork_n"]];
    if (playURL == nil) {
        playURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
        if ( !playURL ) {
            [SVProgressHUD showWithStatus:LCSTR("This copyrighted music, temporarily can not be played")];
            return;
        }
        AVAudioPlayer *avau = [[AVAudioPlayer alloc] initWithContentsOfURL:playURL error:nil];
        audioPlayer = avau;
        audioPlayer.delegate = self;
        [audioPlayer play];
    } else {
        if (![playURL isEqual:musicURL]) {
            playURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
            if (!playURL) {
                [SVProgressHUD showWithStatus:LCSTR("This copyrighted music, temporarily can not be played")];
                return;
            }
            AVAudioPlayer *avau = [[AVAudioPlayer alloc] initWithContentsOfURL:playURL error:nil];
            audioPlayer = avau;
            audioPlayer.delegate = self;
            [audioPlayer play];
        } else {
            if (audioPlayer.isPlaying) {
                [audioPlayer pause];
            } else {
                [audioPlayer play];
            }
        }
    }
    [self detectingSound];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

#pragma mark -
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag{
    //播放结束时执行的动作
    [self playButtonClick: nextButt];
    NSLog(@"播放结束时执行的动作");
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error{
    //解码错误执行的动作
    NSLog(@"解码错误执行的动作");
}
- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player{
    //处理中断的代码
    NSLog(@"处理中断的代码");
}
- (void)audioPlayerEndInteruption:(AVAudioPlayer*)player{
    //处理中断结束的代码
    NSLog(@"处理中断结束的代码");
}

#pragma mark -
- (void)detectingSound{
    
    if (audioPlayer.isPlaying) {
        UIButton *butt = (UIButton*)[downView viewWithTag:100];
        [butt setImage:[UIImage imageNamed:@"PauseIcon"] forState:UIControlStateNormal];
        audioPlayer.meteringEnabled = YES;
        [levelTimer setFireDate:[NSDate date]];
    }else{
        UIButton *butt = (UIButton*)[downView viewWithTag:100];
        [butt setImage:[UIImage imageNamed:@"PlayIcon"] forState:UIControlStateNormal];
        audioPlayer.meteringEnabled = NO;
        [levelTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)setModerView:(int)moder{
    UIButton *button1 = (UIButton*)[downView viewWithTag:200];
    UIButton *button2 = (UIButton*)[downView viewWithTag:201];
    
    UIButton *button3 = (UIButton*)[downView viewWithTag:100];
    UIButton *button4 = (UIButton*)[downView viewWithTag:101];
    if (moder == 0) {
        [button1 setImage:[UIImage imageNamed:@"MusicIcon_s"] forState:UIControlStateNormal];
        [button1 setImage:[UIImage imageNamed:@"MusicIcon_s"] forState:UIControlStateHighlighted];
        
        [button2 setImage:[UIImage imageNamed:@"MicIcon_n"] forState:UIControlStateNormal];
        [button2 setImage:[UIImage imageNamed:@"MicIcon_s"] forState:UIControlStateHighlighted];
        
        [UIView animateWithDuration:0.3 animations:^{
            musicView.hidden = NO;
            maikeView.hidden = YES;
        } completion:^(BOOL finshed){
            
        }];
        button3.hidden = NO;
        button4.hidden = NO;
        
        // Change to Playback. So audio will auto switch to bluetooth speaker and so on.
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions: AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        
        if (recorder) {
            [recorder stop];
        }
        
        [levelTimer2 setFireDate:[NSDate distantFuture]];
        
    }else{
        [button1 setImage:[UIImage imageNamed:@"MusicIcon_n"] forState:UIControlStateNormal];
        [button1 setImage:[UIImage imageNamed:@"MusicIcon_s"] forState:UIControlStateHighlighted];
        
        [button2 setImage:[UIImage imageNamed:@"MicIcon_s"] forState:UIControlStateNormal];
        [button2 setImage:[UIImage imageNamed:@"MicIcon_s"] forState:UIControlStateHighlighted];
        
        [UIView animateWithDuration:0.3 animations:^{
            musicView.hidden = YES;
            maikeView.hidden = NO;
        } completion:^(BOOL finshed){
            
        }];
        button3.hidden = YES;
        button4.hidden = YES;
        if (audioPlayer.isPlaying) {
            [audioPlayer pause];
        }
        [self detectingSound];
        
        if (recorder) {
            // So microphone will work.
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions: AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionMixWithOthers error:nil];
            
            [recorder prepareToRecord];
            recorder.meteringEnabled = YES;
            [recorder recordForDuration: 1000000000000000.0];
        }
        [levelTimer2 setFireDate:[NSDate date]];
    }
}

//响应远程音乐播放控制消息
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            case UIEventSubtypeRemoteControlPause:
            case UIEventSubtypeRemoteControlStop:
            case UIEventSubtypeRemoteControlPlay:
                [self playButtonClick: self->playButt];
                NSLog(@"RemoteControlEvents: pause");
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self playButtonClick: self->nextButt];
                NSLog(@"RemoteControlEvents: playModeNext");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playButtonClick: self->preButt];
                NSLog(@"RemoteControlEvents: playPrev");
                break;
            default:
                break;
        }
    }
}

#pragma mark - Action
- (void)navBarButtonAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    float www = ([recorder averagePowerForChannel:0]+100)/100.0f;
    
    double hue, sat, brt;
    CalcHSBByDB(www, &hue, &sat, &brt);
    UIColor *cl = [UIColor colorWithHue:hue saturation:sat brightness:brt alpha:1];
    const CGFloat *components = CGColorGetComponents(cl.CGColor);
    // 获取RGB颜色
    CGFloat red = components[0]*255;
    CGFloat green = components[1]*255;
    CGFloat blue =components[2]*255;
    [[WZBlueToothDataManager shareInstance] setRGBWCWithAddress:(uint32_t)devAddr isGroup:isRoom WithRed:red Green:green Blue:blue Warm:0 Cold:0 Lum:1 Delay:0];
}

- (void)listenForBlow:(NSTimer *)timer{
    
    [audioPlayer updateMeters];
    musicProgress.progress =audioPlayer.currentTime/audioPlayer.duration;
    double averagePowerForChannel = [audioPlayer averagePowerForChannel:0];
    
    double hue, sat, brt;
    CalcHSBByDB(averagePowerForChannel, &hue, &sat, &brt);
    UIColor *clo = [UIColor colorWithHue:hue saturation:sat brightness:brt alpha:1];
    const CGFloat *components = CGColorGetComponents(clo.CGColor);
    // 获取RGB颜色
    CGFloat red = components[0]*255;
    CGFloat green = components[1]*255;
    CGFloat blue =components[2]*255;
    [[WZBlueToothDataManager shareInstance] setRGBWCWithAddress:(uint32_t)devAddr isGroup:isRoom WithRed:red Green:green Blue:blue Warm:0 Cold:0 Lum:1 Delay:0];
}

- (void)playButtonClick:(id)sender{
    UIButton *button = (UIButton*)sender;
    switch (button.tag) {
        case 100:
        {
            if (playURL != nil) {
                if (audioPlayer.isPlaying) {
                    [audioPlayer pause];
                }else{
                    [audioPlayer play];
                }
                [self detectingSound];
            }
            
        }
            break;
        case 102:
        case 101:
        {
            if (musicArray.count>0) {
                playNumb = playNumb+ (button.tag == 101 ? 1 : -1);
                if (playNumb > musicArray.count-1)  playNumb = 0;
                if (playNumb < 0)  playNumb = (int) (musicArray.count - 1);
                
                [self tableView:self->musicTableView didSelectRowAtIndexPath: [NSIndexPath indexPathForRow:playNumb inSection:0]];
            }
        }
            break;
        case 200:
        {
            [self setModerView:0];
        }
            break;
        case 201:
        {
            [self setModerView:1];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
struct DBParseInfo {
    bool            isInited;
    double          hisDB[20];
    int             currIdx, lastTopIdx, lastLowIdx;
    double          lastTop, lastAvrg, section, base;
    double          delta, avrgDelta, powerDelta, deltaSection, deltaDelta, deltaRatio, standrad_deviation, variance;
    bool            isLow, isHigh;
    
    static const double baseHueLine;
    
private:
    void ProcessDB(double db)
    {
        int hisDBLen = sizeof( hisDB)/sizeof(*(hisDB));
        currIdx = (currIdx + 1)%hisDBLen;
        hisDB[currIdx] = db;
        
        double sum = 0;
        for (int idx = 0; idx < hisDBLen; ++idx)
        {
            if (hisDB[idx] > hisDB[lastTopIdx])
                lastTopIdx = idx;
            if (hisDB[idx] < hisDB[lastLowIdx])
                lastLowIdx = idx;
            
            sum += hisDB[idx];
        }
        
        isHigh = ( lastTopIdx == (currIdx + hisDBLen - 3)%hisDBLen );
        isLow = ( lastLowIdx == (currIdx + hisDBLen - 3)%hisDBLen );
        
        lastTop = hisDB[lastTopIdx];
        lastAvrg = sum / hisDBLen;
        // update section & base
        section = 2*(lastTop - lastAvrg);
        base = lastTop - section;
        // if (base < 0) base = 0;
        // update this delta
        standrad_deviation = lastAvrg / (section/2), variance = (1.0/standrad_deviation/standrad_deviation);
        delta = (db - lastAvrg)/section /* /standrad_deviation */;
        powerDelta = delta*delta*delta;
    }
    
public:
    void ParseDB(double db)
    {
        ProcessDB(db);
        
        static DBParseInfo deltaDP = { 0, };
        deltaDP.ProcessDB(delta);
        avrgDelta = deltaDP.lastAvrg;
        deltaDelta = deltaDP.delta;
        deltaSection = deltaDP.deltaSection;
        deltaRatio = (delta - avrgDelta);
    }
    
    void ParseDBOld(double db)
    {
        const int sampleCnt = 20, currWeight = 1;
        // update average
        (lastAvrg == 0) ? (lastAvrg = db) : (lastAvrg = (db*currWeight + lastAvrg * (sampleCnt - currWeight))/sampleCnt);
        // update top
        if (lastTop == 0) lastTop = db;
        const double attenuation = 0.05;
        // (lastTop < db) ? (lastTop = db) : (lastTop -= attenuation * lastTop);       // Cause trimble.
        (lastTop < db) ? (lastTop = db) : (lastTop -= attenuation * lastTop);
        // update section & base
        section = 2*(lastTop - lastAvrg);
        base = lastTop - section;
        if (base < 0) base = 0;
        // update this delta
        standrad_deviation = lastAvrg / (section/2), variance = (1.0/standrad_deviation/standrad_deviation);
        delta = (db - lastAvrg)/section /* /standrad_deviation */;
        powerDelta = delta*delta*delta;
    }
};
const double DBParseInfo::baseHueLine = 0.5;

void CalcHSBByDB(double db, double *hue, double *sat, double *brt)
{
    static DBParseInfo dp = { 0, };
    dp.ParseDB(db);
#define POWER2(x)  ( ((x) > 0 ) ? (x)*(x) : -(x)*(x) )
    
    const double centerHue = 0.5;
    const static int STYPE_STABLE = 0, STYPE_STABLE_FLEX = 1, STYPE_FLEX = 2;
    const int stype = STYPE_STABLE;
    switch (stype) {
        case STYPE_STABLE: {
            // stable
            // double newHue = centerHue - 0.15 + 0.15*(rand()%1000)/1000 + dp.deltaRatio;
            double newHue = centerHue + dp.deltaRatio;
            // *hue = dp.lastAvrg/dp.lastTop - 0.5 + dp.deltaRatio*0.8;
            // *hue = 0.3 + 0.2*(rand()%1000)/1000 + dp.deltaRatio;
            
            while (newHue > 1.0)
                newHue -= 1.0;
            while (newHue < 0)
                newHue += 1.0;
            
            *hue = newHue;
            *sat = 1.0;
            // *brt = 0.45 + dp.deltaRatio;  // 0.2 + *hue*delta
            *brt = 0.45 + dp.deltaRatio * 1.2;  // 0.2 + *hue*delta
        }   break;
        case STYPE_STABLE_FLEX:
        default:
            // stable + flex
            *hue = (dp.lastAvrg - dp.lastTop/2)/dp.lastTop + dp.delta/dp.standrad_deviation;
            *sat = 1.0;
            *brt = 0.2 + *hue*dp.delta;
            break;
            
        case STYPE_FLEX:
            // flex
            *hue = dp.baseHueLine + dp.section/dp.lastAvrg + dp.delta/dp.standrad_deviation*2;
            *sat = 1.0;
            *brt = 0.2 + dp.delta;
            break;
    }
#undef POWER2
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
