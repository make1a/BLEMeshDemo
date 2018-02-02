

#import "WSTEditColorViewController.h"
#import "WSTEditColorView.h"
@interface WSTEditColorViewController ()<ColorPickerDelegate>
/**Description*/
@property (nonatomic,strong) WSTEditColorView *containerView;
/**临时的数据*/
@property (nonatomic,strong) WSTColorModel *interimModel;
@end

@implementation WSTEditColorViewController
#pragma mark - viewdidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];

    self.interimModel = [self.currentModel copy];
}
- (void)setNavigationStyle{
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setNavigationTitle:LCSTR("编辑色块") titleColor:[UIColor whiteColor]];
}

#pragma mark - actions
- (void)sumbitAction:(UIButton *)sender{
    if (!self.currentModel) {
        return;
    }
    [SVProgressHUD setContainerView:nil];
   NSString *name = self.containerView.textField.text;
    if (name.length == 0) {
        [SVProgressHUD showErrorWithStatus:LCSTR("名字不能为空")];
        return;
    }

    NSArray *array = [WSTColorModel selectFromClassPredicateWithFormat:[NSString stringWithFormat:@"where name = '%@'",name]];
    if (![self.currentModel.name isEqualToString:[array.firstObject name]]) {
        if (array.count != 0) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@%@",LCSTR("色块名称"),LCSTR("repeat")]];
            return;
        }
    }

    
    [self.currentModel setCurrentModel:self.interimModel];
    self.currentModel.name = name;
    [self.currentModel updateObject];
    [self.rt_navigationController popViewControllerAnimated:YES complete:^(BOOL finished) {
        
    }];
}
- (void)defaultAction:(id)sender{
    if (self.isColor == YES && self.isSingle == NO) {
        [self.currentModel setdefaultColorWith:self.index isColor:self.isColor];
    }else if (self.isColor == NO && self.isSingle == NO){
        [self.currentModel setdefaultColorWith:self.index isColor:self.isColor];
    }else{
        [self.currentModel setdefaultColorWith:self.index isWarm:self.isWarm];
    }
    [self.rt_navigationController popViewControllerAnimated:YES complete:nil];
}
- (void)changeLum:(UISlider *)sender{
    self.interimModel.lum = sender.value;
    if (self.isWarm) {
        [[WZBlueToothDataManager shareInstance]setWarmWithAddress:_devAddr isGroup:_isRoom WithWarm:sender.value Delay:0];
        self.interimModel.warm = sender.value;
    }else{
        [[WZBlueToothDataManager shareInstance]setColdWithAddress:_devAddr isGroup:_isRoom WithCold:sender.value Delay:0];
        self.interimModel.cold = sender.value;
    }
    
}

#pragma mark - ColorPickerDelegate
- (void)colorPickerView:(ColorPickerView *)colorPickerView withHue:(float)hue Saturation:(float)saturation{
    if (_isColor == YES) {
        [[WZBlueToothDataManager shareInstance] setHSBWithAddress:(uint32_t)_devAddr isGroup:_isRoom WithHue:hue Saturation:saturation Brightness:1 Warm:0 Cold:0 Lum:0 Delay:1];
        self.interimModel.h = hue;
        self.interimModel.s =saturation;
        self.interimModel.b = 1.0;
    }else{
        [[WZBlueToothDataManager shareInstance] setHSBWithAddress:(uint32_t)_devAddr isGroup:_isRoom WithHue:0 Saturation:0 Brightness:0 Warm:colorPickerView.saturationValue <= 0.05 ? 0 : colorPickerView.saturationValue Cold: 1 - colorPickerView.saturationValue Lum:0 Delay:1];
        self.interimModel.warm = colorPickerView.saturationValue <= 0.05 ? 0 : colorPickerView.saturationValue;
        self.interimModel.cold = 1 - colorPickerView.saturationValue;
    }}
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
- (WSTEditColorView *)containerView{
    if (!_containerView) {
        _containerView = [[WSTEditColorView alloc]initWithSingleColor:self.isColor isSingle:self.isSingle];
        _containerView.colorView.delegate = self;
        if (self.currentModel) {
            _containerView.textField.text = self.currentModel.name;
            _containerView.slider.value = (CGFloat)self.currentModel.lum;
        }
        [_containerView.slider addTarget:self action:@selector(changeLum:) forControlEvents:UIControlEventValueChanged];
        [_containerView.sumbitButton addTarget:self action:@selector(sumbitAction:) forControlEvents:UIControlEventTouchDown];
        [_containerView.defaultButton addTarget:self action:@selector(defaultAction:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_containerView];
    }
    return _containerView;
}
@end
