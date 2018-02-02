//
//  WSTIFlyViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/31.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTIFlyViewController.h"
#import <iflyMSC/iflyMSC.h>
#import "WSTVoiceView.h"
#import <AVFoundation/AVFoundation.h>
#import "WSTVoiceColorModel.h"
#import "Waver.h"

@interface WSTIFlyViewController () <IFlySpeechRecognizerDelegate,MLVoiceViewDelegate>
{
    IFlySpeechRecognizer *iFlySpeechRecognizer;
}
/**containerView*/
@property (nonatomic,strong) WSTVoiceView *containerView;
/**颜色数据源*/
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSArray *zhSource;
@property (nonatomic,strong) NSArray *numberSource;
@property (nonatomic, strong) AVAudioRecorder *recorder;

@property (nonatomic,strong) Waver * waver;
@end

@implementation WSTIFlyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    [self setUpiFlyRecognizer];
//    [self setupRecorder];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [iFlySpeechRecognizer cancel]; //取消识别
    [iFlySpeechRecognizer setDelegate:nil];
    [iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
}
- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("语音控制") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];

}
- (void)setUpWaver{


}
- (void)setUpiFlyRecognizer {
    // 1.实例化讯飞的识别器
    if (iFlySpeechRecognizer == nil) {
        // 单例模式，无UI的实例
        iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
        // 设置参数模式
        [iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        // 设置听写模式
        [iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        
        // asr_audio_path 是录音文件名，设置 value 为 nil 或者为空取消保存，默认保存目录在 Library/cache下。
        [iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [iFlySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant ASR_PTT]];
    }
    
    // 2.设置代理
    iFlySpeechRecognizer.delegate = self;
    
    // 3.如果已经实例化那么设置配置属性
    if (iFlySpeechRecognizer != nil) {
        // 网络等待时间
        [iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        [iFlySpeechRecognizer setParameter:@"28000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        [iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    }
}

#pragma mark - MLVoiceViewDelegate
- (void)voiceView:(MLVoiceView *)voiceView didClickVoiceRecordBtn:(MLCustomButton *)btn {
    if (btn.selected) {

        [iFlySpeechRecognizer startListening];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AudioServicesPlaySystemSound(1111);
        });
    } else { // 完成录音
        // 停止讯飞监听
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AudioServicesPlaySystemSound(1112);
        });
    }
}


#pragma mark - IFlySpeechRecognizerDelegate
- (void)onError:(IFlySpeechError *)errorCode {
    if (errorCode.errorCode != 0) {
        [SVProgressHUD setContainerView:nil];
        [SVProgressHUD showErrorWithStatus:errorCode.errorDesc];
    }
}

- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
    
    int groupAddress = -1;
    BOOL isGroup = NO;
    
    NSMutableString *result = [@"" mutableCopy];
    NSDictionary *dic = results.firstObject;
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    NSString *resultFromJson;
     resultFromJson = [self stringFromJson:result];
    self.containerView.voiceRecordBtn.selected = false;
    self.containerView.listenAndRecognLabel.text = LCSTR("正在识别...");
    self.containerView.listenAndRecognLabel.text = LCSTR("识别到以下信息");
    if (resultFromJson && resultFromJson.length > 0) {
        self.containerView.resultLabel.text = resultFromJson;
    }
    NSString *str = [NSString stringWithFormat:@"where homeName = '%@'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName]];
   NSArray *groups = [WSTHomeGorupShowModel selectFromClassPredicateWithFormat:str];
    for (WSTHomeGorupShowModel *group in groups) {
        if ([resultFromJson containsString:group.name]) {
            isGroup = YES;
            groupAddress = group.groupAddress;
            break;
        }
    }
   NSString *str2 = [NSString stringWithFormat:@"where home = '%@'",[[NSUserDefaults standardUserDefaults]valueForKey:currentHomeName]];
    NSArray *devices = [WZBLEDataModel selectFromClassPredicateWithFormat:str2];
    for (WZBLEDataModel *model in devices) {
        if ([resultFromJson containsString:model.name]) {
            isGroup = NO;
            groupAddress = model.addressLong;
            break;
        }
    }
    if ([resultFromJson containsString:@"所有"]||[resultFromJson containsString:@"全部"]) {
        groupAddress = 0xffff;
    }

    if ([resultFromJson containsString:@"亮度"]) {
        NSInteger location = [resultFromJson rangeOfString:@"亮度"].location + [resultFromJson rangeOfString:@"亮度"].length;
        NSMutableString *str = [[resultFromJson substringWithRange:NSMakeRange(location, resultFromJson.length - location)] mutableCopy];
        
        for (int i = 0; i<self.zhSource.count; i++) {
            if ([str containsString:self.zhSource[i]]) {
                
             str = [[str stringByReplacingOccurrencesOfString:self.zhSource[i] withString:[NSString stringWithFormat:@"%@",self.numberSource[i]]] mutableCopy];
             }
        }
         NSScanner *scanner = [NSScanner scannerWithString:str];
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
        int brightness = 0;
        [scanner scanInt:&brightness];
        if (groupAddress == -1) {
            return;
        }
        
        [[WZBlueToothDataManager shareInstance]setBrightnessWithAddress:groupAddress  isGroup:YES Brightness:(CGFloat)brightness/100.f];
    }
    
      if ([resultFromJson containsString:@"开"] || [resultFromJson containsString:@"回来"] || [resultFromJson containsString:@"早安"] || [resultFromJson containsString:@"早上"]) { //开
          if (groupAddress == -1) {
              return;
          }
          if (isGroup == YES) {
          [[WZBlueToothDataManager shareInstance]turnOnCertainGroupWithAddress:groupAddress];
          }else{
          [[WZBlueToothDataManager shareInstance]turnOnCertainLightWithAddress:groupAddress];
          }
          
          
    }else if ([resultFromJson containsString:@"关"]) { //关
        if (groupAddress == -1) {
            return;
        }
        if (isGroup == YES) {
            [[WZBlueToothDataManager shareInstance]turnOffCertainGroupWithAddress:groupAddress];
        }else{
            [[WZBlueToothDataManager shareInstance]turnOffCertainLightWithAddress:groupAddress];
        }
        
    }else if ([resultFromJson containsString:@"晚安"]|| [resultFromJson containsString:@"出去"] || [resultFromJson containsString:@"出门"]){
        [[WZBlueToothDataManager shareInstance]turnOffAllLight];
    }else{ //调色
        if (groupAddress == -1) {
            return;
        }
        for (WSTVoiceColorModel *model in self.dataSource) {
            if ([resultFromJson containsString:model.name]) {
                [[WZBlueToothDataManager shareInstance]setRGBWCWithAddress:groupAddress isGroup:isGroup       WithRed:[model.red integerValue] Green:[model.green integerValue] Blue:[model.blue integerValue] Warm:[model.warm integerValue] Cold:[model.cold integerValue] Lum:[model.lum integerValue] Delay:1];
                break;
            }
        }
    }
    
}
//音量
- (void)onVolumeChanged:(int)volume{
    _waver.waverLevelCallback = ^(Waver * waver) {
        CGFloat normalizedValue = (CGFloat)volume /80.f;
        waver.level = normalizedValue;
    };
}
//开始
- (void)onBeginOfSpeech{
    [self waver];
    [self setUpWaver];
    self.containerView.listenAndRecognLabel.text = LCSTR("正在聆听...");
    self.containerView.resultLabel.text = nil;
}
//结束
- (void)onEndOfSpeech {
    [_waver removeFromSuperview];
    _waver = nil;
    self.containerView.voiceRecordBtn.selected = false;
    self.containerView.listenAndRecognLabel.text = LCSTR("识别到以下信息");
}
//-(void)setupRecorder
//{
//    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
//
//    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
//                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
//                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
//                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
//
//    NSError *error;
//    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
//
//    if(error) {
//        NSLog(@"Ups, could not create recorder %@", error);
//        return;
//    }
//
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
//
//    if (error) {
//        NSLog(@"Error setting category: %@", [error description]);
//    }
//
//    [self.recorder prepareToRecord];
//    [self.recorder setMeteringEnabled:YES];
//    [self.recorder record];
//
//}
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
- (WSTVoiceView *)containerView{
    if (!_containerView) {
        _containerView = [[WSTVoiceView alloc]init];
        _containerView.delegate = self;
        [self.view addSubview:_containerView];
    }
    return _containerView;
}


- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [@[]mutableCopy];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"VoiceColor.plist" ofType:nil];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
        for (NSDictionary *dic in dictArray) {
            WSTVoiceColorModel *model = [WSTVoiceColorModel yy_modelWithDictionary:dic];
            [_dataSource addObject:model];
        }
    }
    return _dataSource;
}

- (NSArray *)zhSource{
    if (!_zhSource) {
        _zhSource = @[@"零",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"百",@"千"];
    }
    return _zhSource;
}
- (NSArray *)numberSource{
    if (!_numberSource) {
        _numberSource = @[@0,@1,@2,@3,@4,@5,@6,@7,@8,@9,@10,@100,@1000];
    }
    return _numberSource;
}
- (Waver *)waver{
    if (!_waver) {
        _waver = [[Waver alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds)/2.0 - 50.0, CGRectGetWidth(self.view.bounds), 100.0)];

        [self.view addSubview:_waver];
    }
    return _waver;
}
#pragma mark - tool
- (NSString *)stringFromJson:(NSString*)params
{
    if (params == NULL) {
        return nil;
    }
    
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:
                                [params dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    if (resultDic!= nil) {
        NSArray *wordArray = [resultDic objectForKey:@"ws"];
        
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                [tempStr appendString: str];
            }
        }
    }
    return tempStr;
}
@end
