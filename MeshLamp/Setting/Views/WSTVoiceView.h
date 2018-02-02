//
//  WSTVoiceView.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/31.
//  Copyright © 2017年 make. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLCustomButton.h"

@class MLVoiceView,MLCustomButton;
@protocol MLVoiceViewDelegate <NSObject>
@optional
- (void)voiceView:(MLVoiceView *)voiceView didClickVoiceRecordBtn:(MLCustomButton *)btn;

@end

@interface WSTVoiceView : UIView
/**
 *  没有说话提示
 */
@property (weak, nonatomic) UILabel *noVoiceLabel;
/**
 *  提示文字
 */
@property (weak, nonatomic) UILabel *tipsLabel;
/**
 *  语音文字
 */
@property (weak, nonatomic) UILabel *voiceLabel;
/**
 *  聆听或者识别文字
 */
@property (weak, nonatomic) UILabel *listenAndRecognLabel;
/**
 *  解析后的文字
 */
@property (weak, nonatomic) UILabel *resultLabel;
/**
 *  录音按钮
 */
@property (weak, nonatomic) MLCustomButton *voiceRecordBtn;

@property (weak, nonatomic) id <MLVoiceViewDelegate> delegate;
@end
