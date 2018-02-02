//
//  WSTColorModel.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/11/3.
//  Copyright © 2017年 make. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSTColorModel : FFDataBaseModel <NSCopying>
//RGB RBGWC  WC W C
@property (nonatomic,copy) NSString *modelName;
//e.g:红色
@property (nonatomic,copy) NSString *name;

@property (nonatomic,assign) CGFloat h;
@property (nonatomic,assign) CGFloat s;
@property (nonatomic,assign) CGFloat b;
@property (nonatomic,assign) CGFloat warm;
@property (nonatomic,assign) CGFloat cold;

//实际发送冷暖度的是用的这个值 !!!
@property (nonatomic,assign) CGFloat lum;

+ (void)insertDefaultModelWithRGBWC;
+ (void)insertDefaultModelWithRGBW;
+ (void)insertDefaultModelWithRGBC;
+ (void)insertDefaultModelWithRGB;
+ (void)insertDefaultModelWithWC;
+ (void)insertDefaultModelWithW;
+ (void)insertDefaultModelWithC;

- (void)setCurrentModel:(WSTColorModel *)model;

- (void)setdefaultColorWith:(NSInteger)index isColor:(BOOL)isColor;
//单色
- (void)setdefaultColorWith:(NSInteger)index isWarm:(BOOL)isWarm;
@end
