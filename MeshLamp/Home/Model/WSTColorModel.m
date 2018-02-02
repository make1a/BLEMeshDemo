//
//  WSTColorModel.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/11/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTColorModel.h"
#import "ColorNumber.h"
@implementation WSTColorModel
+(void)insertDefaultModelWithRGBWC{
    
    NSArray *colorNameArray = @[LCSTR("color_red"), LCSTR("color_orang"), LCSTR("color_yello"), LCSTR("color_green"), LCSTR("color_cyan"), LCSTR("color_blue"), LCSTR("color_purpl"), LCSTR("Warm-Cold")];
    NSArray *warmColdNameArray = @[LCSTR("3000k"), LCSTR("3500k"), LCSTR("4000k"), LCSTR("4500k"), LCSTR("5000k"), LCSTR("5500k"), LCSTR("6000k"), LCSTR("Color")];
    
    for (int i = 0; i<7; i++) {
        WSTColorModel *model = [[WSTColorModel alloc]init];
        model.modelName = @"RGBWC";
        model.name = colorNameArray[i];
        model.h = RGBConfig_All[i].h;
        model.s = RGBConfig_All[i].s;
        model.b = RGBConfig_All[i].b;
        [model insertObject];
    }
    
    for (int i = 0; i<7; i++) {
        WSTColorModel *model = [[WSTColorModel alloc]init];
        model.modelName = @"RGBWC";
        model.name = warmColdNameArray[i];
        model.h = WCColorConfig_All[i].h;
        model.s = WCColorConfig_All[i].s;
        model.b = WCColorConfig_All[i].b;
        model.warm = 1-WCColorConfig_All[i].t;
        model.cold = WCColorConfig_All[i].t;
        model.lum = WCColorConfig_All[i].tb;
        [model insertObject];
    }
}

+ (void)insertDefaultModelWithRGBW{
    NSArray *colorNameArray = @[LCSTR("color_red"), LCSTR("color_orang"), LCSTR("color_yello"), LCSTR("color_green"), LCSTR("color_cyan"), LCSTR("color_blue"), LCSTR("color_purpl"), LCSTR("Warm-Cold")];
    NSArray * warmColdNameArray = @[LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("25%"), LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("Color")];

    
    for (int i = 0; i<7; i++) {
        WSTColorModel *model = [[WSTColorModel alloc]init];
        model.modelName = @"RGBW";
        model.name = colorNameArray[i];
        model.h = RGBConfig_All[i].h;
        model.s = RGBConfig_All[i].s;
        model.b = RGBConfig_All[i].b;
        [model insertObject];
    }
    
    for (int i = 0; i<4; i++) {
        WSTColorModel *model = [[WSTColorModel alloc]init];
        model.modelName = @"RGBW";
        model.name = warmColdNameArray[i];
        model.h = WCConfig_All[i].h;
        model.s = WCConfig_All[i].s;
        model.b = WCConfig_All[i].b;
        model.warm = 1-WCConfig_All[i].t;
        model.cold = WCConfig_All[i].t;
        model.lum = WCConfig_All[i].tb;
        [model insertObject];
    }
}
+ (void)insertDefaultModelWithRGBC{
    NSArray *colorNameArray = @[LCSTR("color_red"), LCSTR("color_orang"), LCSTR("color_yello"), LCSTR("color_green"), LCSTR("color_cyan"), LCSTR("color_blue"), LCSTR("color_purpl"), LCSTR("Warm-Cold")];
    NSArray *warmColdNameArray = @[LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("25%"), LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("Color")];
    
    for (int i = 0; i<7; i++) {
        WSTColorModel *model = [[WSTColorModel alloc]init];
        model.modelName = @"RGBC";
        model.name = colorNameArray[i];
        model.h = RGBConfig_All[i].h;
        model.s = RGBConfig_All[i].s;
        model.b = RGBConfig_All[i].b;
        [model insertObject];
    }
    
    for (int i = 0; i<4; i++) {
        WSTColorModel *model = [[WSTColorModel alloc]init];
        model.modelName = @"RGBC";
        model.name = warmColdNameArray[i];
        model.h = WCConfig_All[i+4].h;
        model.s = WCConfig_All[i+4].s;
        model.b = WCConfig_All[i+4].b;
        model.warm = 1-WCConfig_All[i+4].t;
        model.cold = WCConfig_All[i+4].t;
        model.lum = WCConfig_All[i+4].tb;
        [model insertObject];
    }
}
+ (void)insertDefaultModelWithRGB{
    NSArray *colorNameArray = @[LCSTR("color_red"), LCSTR("color_orang"), LCSTR("color_yello"), LCSTR("color_green"), LCSTR("color_cyan"), LCSTR("color_blue"), LCSTR("color_purpl"), LCSTR("color_pink")];
    
    for (int i = 0; i<8; i++) {
        WSTColorModel *model = [[WSTColorModel alloc]init];
        model.modelName = @"RGB";
        model.name = colorNameArray[i];
        model.h = RGBConfig_All[i].h;
        model.s = RGBConfig_All[i].s;
        model.b = RGBConfig_All[i].b;
        [model insertObject];
    }
    
}
+ (void)insertDefaultModelWithWC{
    NSArray *warmColdNameArray = @[LCSTR("3000k"), LCSTR("3500k"), LCSTR("4000k"), LCSTR("4500k"), LCSTR("4800k"), LCSTR("5000k"), LCSTR("5500k"), LCSTR("6000k")];
    
    for (int i = 0; i<8; i++) {
        WSTColorModel *model = [[WSTColorModel alloc]init];
        model.modelName = @"WC";
        model.name = warmColdNameArray[i];
        model.h = WCColorConfig_All[i].h;
        model.s = WCColorConfig_All[i].s;
        model.b = WCColorConfig_All[i].b;
        model.warm = 1-WCColorConfig_All[i].t;
        model.cold = WCColorConfig_All[i].t;
        model.lum = WCColorConfig_All[i].tb;
        [model insertObject];
    }
    
}
+ (void)insertDefaultModelWithW{
    NSArray *warmColdNameArray = @[LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("25%"), LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("Color")];
    for (int i = 0; i<4; i++) {
        WSTColorModel *model = [[WSTColorModel alloc]init];
        model.modelName = @"W";
        model.name = warmColdNameArray[i];
        model.h = WCConfig_All[i].h;
        model.s = WCConfig_All[i].s;
        model.b = WCConfig_All[i].b;
        model.warm = 1-WCConfig_All[i].t;
        model.cold = WCConfig_All[i].t;
        model.lum = WCConfig_All[i].tb;
        [model insertObject];
    }
}
+ (void)insertDefaultModelWithC{
    NSArray *warmColdNameArray = @[LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("25%"), LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("Color")];
    for (int i = 0; i<4; i++) {
        WSTColorModel *model = [[WSTColorModel alloc]init];
        model.modelName = @"C";
        model.name = warmColdNameArray[i];
        model.h = WCConfig_All[i+4].h;
        model.s = WCConfig_All[i+4].s;
        model.b = WCConfig_All[i+4].b;
        model.warm = 1-WCConfig_All[i+4].t;
        model.cold = WCConfig_All[i+4].t;
        model.lum = WCConfig_All[i+4].tb;
        [model insertObject];
    }
}
#pragma mark - 设置默认颜色
- (void)setdefaultColorWith:(NSInteger)index isColor:(BOOL)isColor{
    NSArray *colorNameArray = @[LCSTR("color_red"), LCSTR("color_orang"), LCSTR("color_yello"), LCSTR("color_green"), LCSTR("color_cyan"), LCSTR("color_blue"), LCSTR("color_purpl"), LCSTR("color_pink")];
    NSArray *warmColdNameArray = @[LCSTR("3000k"), LCSTR("3500k"), LCSTR("4000k"), LCSTR("4500k"), LCSTR("5000k"), LCSTR("5500k"), LCSTR("6000k"), LCSTR("Color")];
    
    if (isColor) {
        self.name = colorNameArray[index];
        self.h = RGBConfig_All[index].h;
        self.s = RGBConfig_All[index].s;
        self.b = RGBConfig_All[index].b;
        [self updateObject];
    }else{
        self.name = warmColdNameArray[index];
        self.h = WCColorConfig_All[index].h;
        self.s = WCColorConfig_All[index].s;
        self.b = WCColorConfig_All[index].b;
        self.warm = 1-WCColorConfig_All[index].t;
        self.cold = WCColorConfig_All[index].t;
        self.lum = WCColorConfig_All[index].tb;
        [self updateObject];
    }
}
- (void)setdefaultColorWith:(NSInteger)i isWarm:(BOOL)isWarm{
    NSArray *warmColdNameArray = @[LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("25%"), LCSTR("100%"), LCSTR("75%"), LCSTR("50%"), LCSTR("25%")];

    if (isWarm) {
        self.name = warmColdNameArray[i];
        self.h = WCConfig_All[i].h;
        self.s = WCConfig_All[i].s;
        self.b = WCConfig_All[i].b;
        self.warm = 1-WCConfig_All[i].t;
        self.cold = WCConfig_All[i].t;
        self.lum = WCConfig_All[i].tb;
        [self updateObject];
    }else{
        self.name = warmColdNameArray[i];
        self.h = WCConfig_All[i+4].h;
        self.s = WCConfig_All[i+4].s;
        self.b = WCConfig_All[i+4].b;
        self.warm = 1-WCConfig_All[i+4].t;
        self.cold = WCConfig_All[i+4].t;
        self.lum = WCConfig_All[i+4].tb;
        [self updateObject];
    }
}
- (void)setCurrentModel:(WSTColorModel *)model{
    model.modelName = self.modelName;
    self.name = model.name;
    self.h =model.h;
    self.s = model.s;
    self.b = model.b;
    self.lum = model.lum;
    self.warm = model.warm;
    self.cold= model.cold;
}

- (id)copyWithZone:(NSZone *)zone{
    WSTColorModel *model = [[WSTColorModel allocWithZone:zone]init];
    model.modelName = self.modelName;
    model.name= self.name;
    model.h= self.h;
    model.s= self.s;
    model.b= self.b;
    model.lum= self.lum;
    model.warm= self.warm;
    model.cold= self.cold;
    return model;
}
@end
