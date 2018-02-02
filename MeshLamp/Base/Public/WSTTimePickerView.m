//
//  WSTTimePickerView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/18.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTTimePickerView.h"
@interface WSTTimePickerView ()
/**时间*/
@property (nonatomic,strong) NSMutableArray *timeArray;
@property (nonatomic,copy) id currentTime;
/**单位*/
@property (nonatomic,strong) UILabel *unitLabel;
@end
@implementation WSTTimePickerView

- (instancetype)init
{
    self = [super initWithType:WSTAlertTypeTimePicker];
    if (self) {
        
        [self masLayoutSubViews];
    }
    return self;
}

#pragma mark - 点击
- (void)addWithSuperView:(UIView *)superView{
    [super addWithSuperView:superView];
    [self.timePikerView selectRow:0 inComponent:0 animated:NO];
    self.currentTime = self.timeArray.firstObject;
}
#pragma mark - delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.timeArray.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.timeArray[row] stringValue];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component
{
    self.currentTime =  self.timeArray[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}
#pragma mark - 布局

- (void)masLayoutSubViews{
    
    [self.timePikerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.centerView);
    }];
    
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.centerView);
        make.centerX.equalTo(self.centerView).mas_offset(42);

    }];
}


- (UIPickerView *)timePikerView{
    if (!_timePikerView) {
        _timePikerView = [[UIPickerView alloc]init];
        _timePikerView.delegate = self;
        _timePikerView.dataSource = self;
        _timePikerView.showsSelectionIndicator = YES;
        [self.centerView addSubview:_timePikerView];
    }
    return _timePikerView;
}
- (UILabel *)unitLabel{
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc]init];
        _unitLabel.text = LCSTR("minute");
        [self addSubview:_unitLabel];
    }
    return _unitLabel;
}

- (NSMutableArray *)timeArray{
    if (!_timeArray) {
        _timeArray = [@[] mutableCopy];
        for (int i = 1; i<=30; i++) {
            [_timeArray addObject:@(i)];
        }
    }
    return _timeArray;
}

@end
