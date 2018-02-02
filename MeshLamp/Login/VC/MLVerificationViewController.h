//
//  MLVerificationViewController.h
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "MLCountryCodeModel.h"

@interface MLVerificationViewController : BaseViewController

@property (nonatomic, strong) NSString              *countryCode;;
@property (nonatomic, strong) NSString              *accountStr;
@property (nonatomic, strong) NSString              *passwordStr;
@property (nonatomic) BOOL                          isSignUp;
@property (nonatomic) BOOL                          isEmail;

@end
