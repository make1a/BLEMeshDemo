//
//  MLCountryCodeUtils.m
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLCountryCodeUtils.h"

@implementation MLCountryCodeUtils

+ (NSArray *)getDefaultPhoneCodeJson {
//    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"TPViews" ofType:@"bundle"]];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"PhoneCodeList" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    return [dict objectForKey:@"PhoneCodeList"];
}

+ (NSString *)getCountryCode {
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}

@end
