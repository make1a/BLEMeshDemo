
#import <UIKit/UIKit.h>

@protocol ColorPickerDelegate;

@interface ColorPickerView : UIView

@property (nonatomic, strong) UIImageView       *bgImageView;           // 色盘图片
@property (nonatomic, strong) UIView            *colorBlock;            // 选中颜色指示块
@property (nonatomic, assign) float             hueValue;               // 当前值
@property (nonatomic, assign) float             saturationValue;        // 饱和度值
@property (nonatomic, assign) float             minValue;               // 最小值
@property (nonatomic, assign) float             maxValue;               // 最大值

@property (nonatomic,weak)id<ColorPickerDelegate>delegate;

- (CGRect)getColorPointInColorPickerHue:(double)hue Saturation:(double)saturation;

- (CGRect)getTempPointInTempPickerTemp:(double)temp;

@end


#pragma mark - ColorPickerDelegate
@protocol ColorPickerDelegate <NSObject>

@optional

- (void)colorPickerView:(ColorPickerView *)colorPickerView withHue:(float)hue Saturation:(float)saturation;

@end
