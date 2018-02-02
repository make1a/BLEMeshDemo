//
//  MLCountryCodeUtils.h
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLCountryCodeUtils : NSObject

+ (NSArray *)getDefaultPhoneCodeJson;
+ (NSString *)getCountryCode;

@end
