//
//  AccountModel.h
//  doonne
//
//  Created by TrusBe Sil on 2017/5/9.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLCountryCodeModel.h"

@interface AccountModel : NSObject

@property (nonatomic, strong) MLCountryCodeModel    *model;
@property (nonatomic, strong) NSString              *account;
@property (nonatomic, strong) NSString              *password;

@end
