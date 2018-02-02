//
//  MLCountryCodeModel.m
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLCountryCodeModel.h"

@implementation MLCountryCodeModel

+ (MLCountryCodeModel *)getCountryCodeModel:(NSArray *)countryList phoneCode:(NSString *)phoneCode {
    
    MLCountryCodeModel *model;
    
    for (NSDictionary *dict in countryList) {
        if ([[dict objectForKey:@"code"] isEqualToString:phoneCode]) {
            model = [MLCountryCodeModel modelWithJSON:dict];
        }
    }
    return model;
}

+ (MLCountryCodeModel *)getCountryCodeModel:(NSArray *)countryList countryCode:(NSString *)countryCode {
    
    MLCountryCodeModel *model;
    
    for (NSDictionary *dict in countryList) {
        if ([[dict objectForKey:@"abbr"] isEqualToString:countryCode]) {
            model = [MLCountryCodeModel modelWithJSON:dict];
        }
    }
    return model;
}

+ (instancetype)modelWithJSON:(NSDictionary *)json {
    MLCountryCodeModel *model = [[MLCountryCodeModel alloc] init];
    model.countryCode   = [json objectForKey:@"code"];
    model.countryCnName = [json objectForKey:@"chinese"];
    model.countryEnName = [json objectForKey:@"english"];
    model.countrySpell  = [json objectForKey:@"spell"];
    model.countryAbb    = [json objectForKey:@"abbr"];
    
    if ([NSString isChinese]) {
        model.countryName = model.countryCnName;
        model.firstLetter = [[model.countrySpell substringToIndex:1] uppercaseString];
    } else {
        model.countryName = model.countryEnName;
        model.firstLetter = [model.countryName substringToIndex:1];
    }
    
    return model;
}

- (id)modelWithJSON:(NSDictionary *)json {
    return nil;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"countryCode": @"code",
             @"countryCnName": @"chinese",
             @"countryEnName": @"english",
             @"countrySpell": @"spell",
             @"countryAbb": @"abbr",
             };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.countryCnName = @"";
        self.countrySpell = @"";
    }
    return self;
}

@end
