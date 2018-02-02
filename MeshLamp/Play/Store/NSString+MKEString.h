//
//  NSString+MKEString.h
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/17.
//  Copyright © 2017年 make. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MKEString)

/**
 二进制转十进制

 @param binary 二进制
 @return 十进制的str
 */
+(NSString *)binaryTodecimal:(NSString *)binary;
/** 十进制转二进制*/
+ (NSString *)decimalToBinary:(uint8_t)decimal;

+(NSString *)padingZero:(NSString *)str length:(NSInteger)length;
+(NSString*)getPreferredLanguage;


/**
 获取字节长度 1个汉字2个字节

 @return changdu
 */
-(NSUInteger)textLength;
+ (BOOL)isChinese;
@end
