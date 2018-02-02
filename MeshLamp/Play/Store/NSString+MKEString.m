//
//  NSString+MKEString.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/17.
//  Copyright © 2017年 make. All rights reserved.
//

#import "NSString+MKEString.h"

@implementation NSString (MKEString)
//  二进制转十进制
+(NSString *)binaryTodecimal:(NSString *)binary
{
    int ll = 0 ;
    int  temp = 0 ;
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    
    return result;
}

// 十进制转二进制字节字符
+ (NSString *)decimalToBinary:(uint8_t)decimal {
    char bits[sizeof(decimal) * 8] = { 0, };
    for (int idx = 0; idx < sizeof(bits); ++idx)
        bits[sizeof(bits) - 1 - idx] = '0' + ( (decimal & (0x1L << idx)) != 0 );
    return [NSString stringWithFormat:@"%s", bits];
}

+(NSString *)padingZero:(NSString *)str length:(NSInteger)length{
    if (length<str.length) {
        return nil;
    }
    NSMutableString *string = [str mutableCopy];
    for (int i = 0; i<length-str.length; i++) {
        [string insertString:@"0" atIndex:0];
    }
    return string;
}

+(NSString*)getPreferredLanguage
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
    NSLog(@"当前语言:%@", preferredLang);
    return preferredLang;
}
-(NSUInteger)textLength{
    
    NSUInteger asciiLength = 0;
    
    for (NSUInteger i = 0; i < self.length; i++) {
        
        
        unichar uc = [self characterAtIndex: i];
        
        asciiLength += isascii(uc) ? 1 : 2;
    }
    
    NSUInteger unicodeLength = asciiLength;
    
    return unicodeLength;
    
}
+ (BOOL)isChinese {
    NSArray *arLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *lang = [arLanguages[0] lowercaseString];
    if ([lang hasPrefix:[@"zh-Hans" lowercaseString]] || [lang hasPrefix:[@"zh-Hant" lowercaseString]]) {
        return YES;
    }
    return NO;
}
@end
