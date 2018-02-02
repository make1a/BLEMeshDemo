//
//  AccountModel.m
//  doonne
//
//  Created by TrusBe Sil on 2017/5/9.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "AccountModel.h"

@implementation AccountModel
@synthesize model, account, password;

- (id)init {
    self = [super init];
    if (self) {
        model = [[MLCountryCodeModel alloc] init];
        account = [[NSString alloc] init];
        password = [[NSString alloc] init];
    }
    return self;
}

@end
