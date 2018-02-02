//
//  WSTVoiceView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/31.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTVoiceView.h"

@implementation WSTVoiceView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpSubViews];
    }
    return self;
}
#pragma mark - 初始化所有子控件并且进行一次性设置
- (void)setUpSubViews {
    UILabel *noVoiceLabel = [[UILabel alloc] init];
    noVoiceLabel.text = LCSTR("您好像没有说话");
    noVoiceLabel.font = [UIFont boldSystemFontOfSize:19.5f];
    noVoiceLabel.textColor = [UIColor whiteColor];
    noVoiceLabel.textAlignment = NSTextAlignmentCenter;
    noVoiceLabel.hidden = YES;
    [self addSubview:noVoiceLabel];
    self.noVoiceLabel = noVoiceLabel;
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.text = LCSTR("您可以这样问我:");
    tipsLabel.font = [UIFont boldSystemFontOfSize:19.5f];
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:tipsLabel];
    self.tipsLabel = tipsLabel;
    
    UILabel *voiceLabel = [[UILabel alloc] init];
    voiceLabel.text = LCSTR("“群组名”+“控制命令”\n\n如：把客厅的灯调成蓝色\n\n或：晚安、我要出门了");
    voiceLabel.font = [UIFont systemFontOfSize:16.5f];
    voiceLabel.textColor = [UIColor whiteColor];
    voiceLabel.textAlignment = NSTextAlignmentCenter;
    voiceLabel.numberOfLines = 0;
    [self addSubview:voiceLabel];
    self.voiceLabel = voiceLabel;
    
    UILabel *listenAndRecognLabel = [[UILabel alloc] init];
    listenAndRecognLabel.font = [UIFont systemFontOfSize:16.5f];
    listenAndRecognLabel.textColor = [UIColor whiteColor];
    listenAndRecognLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:listenAndRecognLabel];
    self.listenAndRecognLabel = listenAndRecognLabel;
    
    UILabel *resultLabel = [[UILabel alloc] init];
    resultLabel.font = [UIFont systemFontOfSize:16.5f];
    resultLabel.textColor = [UIColor whiteColor];
    resultLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:resultLabel];
    self.resultLabel = resultLabel;
    
    MLCustomButton *voiceRecordBtn = [[MLCustomButton alloc] init];
    voiceRecordBtn.titleLabel.font = [UIFont systemFontOfSize:15.5f];
    voiceRecordBtn.imageView.contentMode = UIViewContentModeScaleToFill;
    [voiceRecordBtn setImage:[UIImage imageNamed:@"setting_startRecordBtn"] forState:UIControlStateNormal];
    [voiceRecordBtn setTitle:LCSTR("开始") forState:UIControlStateNormal];
    [voiceRecordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [voiceRecordBtn setImage:[UIImage imageNamed:@"setting_completeRecordBtn"] forState:UIControlStateSelected];
    //    [voiceRecordBtn setTitle:LCSTR("完成") forState:UIControlStateSelected];
    //    [voiceRecordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [voiceRecordBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:voiceRecordBtn];
    self.voiceRecordBtn = voiceRecordBtn;
}

#pragma mark - method
- (void)buttonClick:(MLCustomButton *)voiceRecordBtn {
    // 0.按钮选择和默认状态自己改变
    voiceRecordBtn.selected = !voiceRecordBtn.selected;
    
    // 1.只要点击隐藏提示文字
    self.noVoiceLabel.hidden = YES;
    self.tipsLabel.hidden = YES;
    self.voiceLabel.hidden = YES;
    
    // 2.显示录音状态条
    self.listenAndRecognLabel.text = nil;
    
    // 3.通知代理
    if ([self.delegate respondsToSelector:@selector(voiceView:didClickVoiceRecordBtn:)]) {
        [self.delegate voiceView:self didClickVoiceRecordBtn:voiceRecordBtn];
    }
}

#pragma mark - 拿到真实的尺寸然后进行设置
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat noVoiceLabelX = 0;
    CGFloat noVoiceLabelY = 50;
    CGFloat noVoiceLabelW = self.frame.size.width;
    CGFloat noVoiceLabelH = 40;
    self.noVoiceLabel.frame = CGRectMake(noVoiceLabelX, noVoiceLabelY, noVoiceLabelW, noVoiceLabelH);
    
    CGFloat tipsLabelX = 0;
    CGFloat tipsLabelY = 95;
    CGFloat tipsLabelW = noVoiceLabelW;
    CGFloat tipsLabelH = noVoiceLabelH;
    self.tipsLabel.frame = CGRectMake(tipsLabelX, tipsLabelY, tipsLabelW, tipsLabelH);
    
    CGFloat voiceLabelX = 0;
    CGFloat voiceLabelY = CGRectGetMaxY(self.tipsLabel.frame) + 30;
    CGFloat voiceLabelW = noVoiceLabelW;
    CGFloat voiceLabelH = 105;
    self.voiceLabel.frame = CGRectMake(voiceLabelX, voiceLabelY, voiceLabelW, voiceLabelH);
    
    CGFloat listenAndRecognLabelX = 0;
    CGFloat listenAndRecognLabelY = 50;
    CGFloat listenAndRecognLabelW = self.frame.size.width;
    CGFloat listenAndRecognLabelH = 35;
    self.listenAndRecognLabel.frame = CGRectMake(listenAndRecognLabelX, listenAndRecognLabelY, listenAndRecognLabelW, listenAndRecognLabelH);
    
    CGFloat resultLabelX = self.frame.size.width * 0.1;
    CGFloat resultLabelY = voiceLabelY + voiceLabelH * 0.5 + 10;
    CGFloat resultLabelW = noVoiceLabelW - 2 * resultLabelX;
    CGFloat resultLabelH = 70;
    self.resultLabel.frame = CGRectMake(resultLabelX, resultLabelY, resultLabelW, resultLabelH);
    
    CGFloat voiceRecordBtnH = 91;
    CGFloat voiceRecordBtnX = self.frame.size.width * 0.5;
    CGFloat voiceRecordBtnY = self.frame.size.height - voiceRecordBtnH * 0.5 - 20;
    CGFloat voiceRecordBtnW = 60;
    self.voiceRecordBtn.center = CGPointMake(voiceRecordBtnX, voiceRecordBtnY);
    self.voiceRecordBtn.bounds = CGRectMake(0, 0, voiceRecordBtnW, voiceRecordBtnH);
}
@end

