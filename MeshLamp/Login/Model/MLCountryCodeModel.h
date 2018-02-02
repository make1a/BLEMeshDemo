//
//  MLCountryCodeModel.h
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLCountryCodeModel : NSObject

@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, strong) NSString *countryCnName;
@property (nonatomic, strong) NSString *countryEnName;
@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, strong) NSString *countrySpell;
@property (nonatomic, strong) NSString *firstLetter;
@property (nonatomic, strong) NSString *countryAbb;//缩写

+ (MLCountryCodeModel *)getCountryCodeModel:(NSArray *)countryList phoneCode:(NSString *)phoneCode;
+ (MLCountryCodeModel *)getCountryCodeModel:(NSArray *)countryList countryCode:(NSString *)countryCode;
+ (instancetype)modelWithJSON:(NSDictionary *)json;

@end
