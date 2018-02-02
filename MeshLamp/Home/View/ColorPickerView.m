

#import "ColorPickerView.h"

@interface ColorPickerView() {
    CGPoint pointBegan, pointMoved, pointEnded;
    double tempTime;
}

@end

@implementation ColorPickerView
@synthesize bgImageView, colorBlock, hueValue, saturationValue, minValue, maxValue;

#pragma mark - Init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        minValue = 0.0;
        maxValue = 1.0;
        hueValue = 0.0;
        saturationValue = 0.0;
        
        tempTime = [[NSDate date] timeIntervalSince1970];
        
        [self loadMainView];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        minValue = 0.0;
        maxValue = 1.0;
        hueValue = 0.0;
        saturationValue = 0.0;
        
        tempTime = [[NSDate date] timeIntervalSince1970];
        
        [self loadMainView];
    }
    return self;
}

- (void)setMinValue:(float)value {
    minValue = value;
    hueValue = value;
}

#pragma mark - View
- (void)loadMainView {
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = Height(self)/2;
    
    // 背景图片
    bgImageView = [[UIImageView alloc] init];
    [self addSubview:bgImageView];
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    
    // 滑钮
//    colorBlock = [[UIView alloc] initWithFrame:CGRectMake((Width(bgImageView)-Sp2Pt(20))/2, (Height(bgImageView)-Sp2Pt(20))/2, Sp2Pt(20), Sp2Pt(20))];
    colorBlock = [[UIView alloc]init];
    colorBlock.backgroundColor = [UIColor clearColor];
    colorBlock.layer.masksToBounds = YES;
    colorBlock.layer.cornerRadius = px750Width(40)/2;
    colorBlock.layer.borderWidth = Sp2Pt(3);
    colorBlock.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1] CGColor];
    [self addSubview:colorBlock];
    
    [colorBlock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.height.width.mas_equalTo(px750Width(40));
    }];
    
//    [self addObserver:self forKeyPath:@"hueValue" options:NSKeyValueObservingOptionNew context:nil];
}


#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    pointMoved = [touch locationInView:self];
    
    // 计算当前点的色相值和饱和度值
    double vx = bgImageView.center.x-pointMoved.x, vy = bgImageView.center.y-pointMoved.y;
    // 计算饱和度值
    double saturation = sqrt(pow(fabs(vx), 2) + pow(fabs(vy), 2));
    double radius = bgImageView.frame.size.height/2 - Sp2Pt(10);
    if (saturation > radius) saturation = radius;
    saturationValue = (float)saturation/radius;
    // 计算色相值
    double startAngel = 90.0;
    double currAngel = AngelFromVector(vx, vy);
    currAngel -= startAngel;
    if (currAngel < 0) {
        currAngel += 360;
    }
    // 滑钮位置
    CGRect frame = colorBlock.frame;
    frame.origin.x = bgImageView.center.x + saturation * sin(currAngel * M_PI / 180.0) - frame.size.width / 2;
    frame.origin.y = bgImageView.center.y - saturation * cos(currAngel * M_PI / 180.0) - frame.size.height / 2;
    colorBlock.frame = frame;
    
    hueValue = currAngel/360*(maxValue-minValue)+minValue;
    
    if ([[NSDate date] timeIntervalSince1970] - tempTime > 0.03) {
        if (_delegate && [_delegate respondsToSelector:@selector(colorPickerView:withHue:Saturation:)]) {
            [_delegate colorPickerView:self withHue:hueValue Saturation:saturationValue];
        }
        tempTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (CGRect)getColorPointInColorPickerHue:(double)hue Saturation:(double)saturation {
    CGRect frame = colorBlock.frame;
    double  radius;
    radius = (Width(bgImageView)-Sp2Pt(20))/2;
    frame.origin.x = radius + saturation * radius * sin(hue * 2 * M_PI);
    frame.origin.y = radius + saturation * radius * cos((hue - 0.5) * 2 * M_PI);
    colorBlock.frame = frame;
    return frame;
}

- (CGRect)getTempPointInTempPickerTemp:(double)temp {
    CGRect frame = colorBlock.frame;
    double  radius, hue, saturation;
    radius = (Width(bgImageView)-Sp2Pt(20))/2;
    if (temp == 0) {
        hue = 0.13;
        saturation = 0;
        frame.origin.x = radius + saturation * radius * sin(hue * 2 * M_PI);
        frame.origin.y = radius + saturation * radius * cos((hue - 0.5) * 2 * M_PI);
    } else {
        hue = 0;
        saturation = 1;
        frame.origin.x = radius + temp * radius;
        frame.origin.y = radius;
    }
    colorBlock.frame = frame;
    return frame;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
////    colorBlock.backgroundColor = [UIColor colorWithHue:hueValue saturation:saturationValue brightness:1.0 alpha:1];
//}

//- (void)dealloc {
//    [self removeObserver:self forKeyPath:@"hueValue" context:nil];
//}

#pragma mark - Calculate
// 向量角度
static double AngelFromVector(double vec_x, double vec_y) {
    return RadianFromVector(vec_x, vec_y) * 180.0 / M_PI;
}

// 弧度
static double RadianFromVector(double vec_x, double vec_y) {
    if (vec_x == 0) {
        if ( vec_y == 0)
            return 0;
        else if (vec_y > 0)
            return M_PI / 2;
        else
            return M_PI / -2;
    }
    else if (vec_x > 0)
        return atan(vec_y / vec_x);
    else if (vec_x < 0) {
        if (vec_y >= 0)
            return M_PI + atan(vec_y / vec_x);
        else
            return atan(vec_y / vec_x) - M_PI;
    }
    return 0;
}

@end
