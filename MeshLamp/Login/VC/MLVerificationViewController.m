//
//  MLVerificationViewController.m
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLVerificationViewController.h"
#import "SignInCell.h"
#import "WSTHomeViewController.h"

@interface MLVerificationViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    UITableView         *verifTableView;
    UIButton            *getVerifButton;
    UIButton            *doneButton;
    UITextField         *verifTF;
    UITextField         *passwordTF;
    NSString            *verifStr;
    NSString            *passwordStr;
    NSTimer            *identifyTimer;
    int                identifyTimes;
}

@end

@implementation MLVerificationViewController
@synthesize countryCode, accountStr, passwordStr, isSignUp, isEmail;
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Init
    [self initPropertys];
    
    // View
    [self loadMainView];
    
    // 发送验证码
    [self sendIdentCode];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.title = isSignUp?LCSTR("Register"):LCSTR("Reset Password");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [self disableTimer];
}

#pragma mark - Init
- (void)initPropertys {
    passwordStr = [[NSString alloc] init];
    verifStr = [[NSString alloc] init];
}

#pragma mark - View
- (void)loadMainView {
    
    // table View
    verifTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_WIDTH-64) style:UITableViewStyleGrouped];
    verifTableView.backgroundColor = [UIColor clearColor];
    verifTableView.delegate = self;
    verifTableView.dataSource = self;
    [verifTableView setSeparatorColor:[UIColor colorWithRed:20.0/255.0 green:38.0/255.0 blue:51.0/255.0 alpha:1.0f]];
    [verifTableView registerClass:[SignInCell class] forCellReuseIdentifier:@"SignInCell"];
    [self.view addSubview:verifTableView];
    
    getVerifButton = [[UIButton alloc] init];
    doneButton = [[UIButton alloc] init];
    verifTF = [[UITextField alloc] init];
    passwordTF = [[UITextField alloc] init];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (isSignUp) {
            return isEmail?1:2;
        } else {
            return 2;
        }
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Sp2Pt(50);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return Sp2Pt(100);
    } else {
        return Sp2Pt(40);
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    if (section == 0) {
        headerView.backgroundColor = BGColor;
        headerView.frame = CGRectMake(Sp2Pt(15), 0, SCREEN_WIDTH-Sp2Pt(30), Sp2Pt(40));
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Sp2Pt(20), Width(headerView), Sp2Pt(30))];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(12)];
        if (isSignUp) {
            titleLabel.text = isEmail ? LCSTR("Please enter your password") : LCSTR("Verification code is sent to your phone:");
        } else {
            titleLabel.text = LCSTR("The verification code is sent to your phone or email:");
        }
        [headerView addSubview:titleLabel];
        
        // 手机号, 邮箱
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Height(titleLabel)+Sp2Pt(20), Width(headerView), Sp2Pt(30))];
        infoLabel.textColor = [UIColor colorWithRed:245.0/255.0 green:206.0/255.0 blue:111.0/255.0 alpha:1.0f];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.font = [UIFont systemFontOfSize:Sp2Pt(12)];
        if (isSignUp) {
            infoLabel.text = isEmail ? [NSString stringWithFormat:@"%@", accountStr] : [NSString stringWithFormat:@"+%@ %@", countryCode, accountStr];
        } else {
            infoLabel.text = [NSString stringWithFormat:@"%@", accountStr];
        }
        [headerView addSubview:infoLabel];
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SignInCell";
    SignInCell *cell = (SignInCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SignInCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.nameLabel.hidden = YES;
        cell.infoView.hidden = YES;
    }
    
    if (indexPath.section == 0) {
        if (isSignUp) {
            if(isEmail) {
                if (indexPath.row == 0) {
                    passwordTF.frame = CGRectMake(0, 0, Width(cell.backView), Height(cell.backView));;
                    NSString *holderText = LCSTR("New Password");
                    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
                    [placeholder addAttribute:NSForegroundColorAttributeName
                                        value:[UIColor grayColor]
                                        range:NSMakeRange(0, holderText.length)];
                    [placeholder addAttribute:NSFontAttributeName
                                        value:[UIFont boldSystemFontOfSize:16]
                                        range:NSMakeRange(0, holderText.length)];
                    passwordTF.attributedPlaceholder = placeholder;
                    passwordTF.clearButtonMode = UITextFieldViewModeAlways;
                    passwordTF.font = [UIFont systemFontOfSize:Sp2Pt(15)];
                    passwordTF.textColor = [UIColor whiteColor];
                    passwordTF.delegate = self;
                    passwordTF.returnKeyType = UIReturnKeyDone;
                    [cell.backView addSubview:passwordTF];
                }
            } else {
                if (indexPath.row == 0) {
                    verifTF.frame = CGRectMake(0, 0, Width(cell.backView)*0.75, Height(cell.backView));
                    NSString *holderText = LCSTR("Input Verification Code");
                    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
                    [placeholder addAttribute:NSForegroundColorAttributeName
                                        value:[UIColor grayColor]
                                        range:NSMakeRange(0, holderText.length)];
                    [placeholder addAttribute:NSFontAttributeName
                                        value:[UIFont boldSystemFontOfSize:16]
                                        range:NSMakeRange(0, holderText.length)];
                    verifTF.attributedPlaceholder = placeholder;
                    verifTF.clearButtonMode = UITextFieldViewModeAlways;
                    verifTF.font = [UIFont systemFontOfSize:Sp2Pt(15)];
                    verifTF.textColor = [UIColor whiteColor];
                    verifTF.delegate = self;
                    verifTF.returnKeyType = UIReturnKeyDone;
                    [cell.backView addSubview:verifTF];
                    
                    getVerifButton.frame = CGRectMake(Width(verifTF), Sp2Pt(2), Width(cell.backView)*0.25, Height(cell.backView)-Sp2Pt(4));
                    getVerifButton.titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(12)];
                    getVerifButton.titleLabel.textColor = [UIColor whiteColor];
                    getVerifButton.layer.masksToBounds = YES;
                    getVerifButton.layer.cornerRadius = Sp2Pt(10);
                    getVerifButton.tag = 100;
                    [getVerifButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                    [getVerifButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
//                    [getVerifButton setBackgroundColor:MLSelectColor forState:UIControlStateNormal];
//                    [getVerifButton jk_setBackgroundColor:APGrey forState:UIControlStateSelected];
                    [getVerifButton setTitle:LCSTR("Get") forState:UIControlStateNormal];
                    [getVerifButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.backView addSubview:getVerifButton];
                    
                } else if (indexPath.row == 1) {
                    passwordTF.frame = CGRectMake(0, 0, Width(cell.backView), Height(cell.backView));;
                    NSString *holderText = LCSTR("New Password");
                    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
                    [placeholder addAttribute:NSForegroundColorAttributeName
                                        value:[UIColor grayColor]
                                        range:NSMakeRange(0, holderText.length)];
                    [placeholder addAttribute:NSFontAttributeName
                                        value:[UIFont boldSystemFontOfSize:16]
                                        range:NSMakeRange(0, holderText.length)];
                    passwordTF.attributedPlaceholder = placeholder;
                    passwordTF.clearButtonMode = UITextFieldViewModeAlways;
                    passwordTF.font = [UIFont systemFontOfSize:Sp2Pt(15)];
                    passwordTF.textColor = [UIColor whiteColor];
                    passwordTF.delegate = self;
                    passwordTF.returnKeyType = UIReturnKeyDone;
                    [cell.backView addSubview:passwordTF];
                }
            }
        } else {
            if (indexPath.row == 0) {
                verifTF.frame = CGRectMake(0, 0, Width(cell.backView)*0.75, Height(cell.backView));
                NSString *holderText = LCSTR("Input Verification Code");
                NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
                [placeholder addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor grayColor]
                                    range:NSMakeRange(0, holderText.length)];
                [placeholder addAttribute:NSFontAttributeName
                                    value:[UIFont boldSystemFontOfSize:16]
                                    range:NSMakeRange(0, holderText.length)];
                verifTF.attributedPlaceholder = placeholder;
                verifTF.clearButtonMode = UITextFieldViewModeAlways;
                verifTF.font = [UIFont systemFontOfSize:Sp2Pt(15)];
                verifTF.textColor = [UIColor whiteColor];
                verifTF.delegate = self;
                verifTF.returnKeyType = UIReturnKeyDone;
                [cell.backView addSubview:verifTF];
                
                getVerifButton.frame = CGRectMake(Width(verifTF), Sp2Pt(2), Width(cell.backView)*0.25, Height(cell.backView)-Sp2Pt(4));
                getVerifButton.titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(12)];
                getVerifButton.titleLabel.textColor = [UIColor whiteColor];
                getVerifButton.layer.masksToBounds = YES;
                getVerifButton.layer.cornerRadius = Sp2Pt(10);
                getVerifButton.tag = 100;
                [getVerifButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                [getVerifButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
//                [getVerifButton jk_setBackgroundColor:MLSelectColor forState:UIControlStateNormal];
//                [getVerifButton jk_setBackgroundColor:APGrey forState:UIControlStateSelected];
                [getVerifButton setTitle:LCSTR("Get") forState:UIControlStateNormal];
                [getVerifButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.backView addSubview:getVerifButton];
                
            } else if (indexPath.row == 1) {
                passwordTF.frame = CGRectMake(0, 0, Width(cell.backView), Height(cell.backView));;
                NSString *holderText = LCSTR("New Password");
                NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
                [placeholder addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor grayColor]
                                    range:NSMakeRange(0, holderText.length)];
                [placeholder addAttribute:NSFontAttributeName
                                    value:[UIFont boldSystemFontOfSize:16]
                                    range:NSMakeRange(0, holderText.length)];
                passwordTF.attributedPlaceholder = placeholder;
                passwordTF.clearButtonMode = UITextFieldViewModeAlways;
                passwordTF.font = [UIFont systemFontOfSize:Sp2Pt(15)];
                passwordTF.textColor = [UIColor whiteColor];
                passwordTF.delegate = self;
                passwordTF.returnKeyType = UIReturnKeyDone;
                [cell.backView addSubview:passwordTF];
            }
        }
    } else {
        cell.backgroundColor = [UIColor clearColor];
        cell.nameLabel.hidden = YES;
        cell.infoView.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            doneButton.frame = CGRectMake(0, 0, Width(cell.backView), Height(cell.backView));;
            doneButton.titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(17)];
            doneButton.titleLabel.textColor = [UIColor whiteColor];
            doneButton.layer.masksToBounds = YES;
            doneButton.layer.cornerRadius = Sp2Pt(10);
            doneButton.tag = 101;
            [doneButton setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:206.0/255.0 blue:111.0/255.0 alpha:1.0f]];
            [doneButton setTitle:isSignUp ? LCSTR("Register") : LCSTR("Save") forState:UIControlStateNormal];
            [doneButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.backView addSubview:doneButton];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // 信息
    if (textField == verifTF) {
        verifStr = textField.text;
    } else {
        passwordStr = textField.text;
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // 信息
    if (textField == verifTF) {
        verifStr = textField.text;
    } else {
        passwordStr = textField.text;
    }
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}


#pragma mark - Actions
- (void)buttonAction:(UIButton *)button {
    [verifTF resignFirstResponder];
    [passwordTF resignFirstResponder];
    switch (button.tag) {
        case 100:
        {
            // 获取验证码
            [self sendIdentCode];
        } break;
        case 101:
        {
            // 完成注册
            // 检测密码
            [verifTableView endEditing:YES];
            if (passwordStr.length == 0) {
                [SVProgressHUD showErrorWithStatus:LCSTR("Please enter your password")];
                return;
            } else if ([passwordStr rangeOfString:@"^[A-Za-z\\d!@#$%*&_\\-.,:;+=\\[\\]{}~()^]{6,20}$" options:NSRegularExpressionSearch].location == NSNotFound) {
                [SVProgressHUD showErrorWithStatus:LCSTR("Please enter the correct password")];
                return;
            }
            // 检测验证码
            
            if (verifStr.length == 0 && isEmail == NO) {
                [SVProgressHUD showErrorWithStatus:LCSTR("Please enter verification code")];
                return;
            }
            [SVProgressHUD showInfoWithStatus:LCSTR("Loading...")];
            TYFailureError failureHandler = ^(NSError *error) {
                [SVProgressHUD dismiss];
                if(error.code == 1506)
                {
                    [SVProgressHUD showErrorWithStatus:LCSTR("用户名已存在")];

                }else{
                    [SVProgressHUD showErrorWithStatus:isSignUp? LCSTR("注册失败"):LCSTR("重置密码失败")];
                }
                
            };
            
            if (isSignUp) {
                // 注册
                TYSuccessHandler successSignUpHandler = ^{
                    [SVProgressHUD showSuccessWithStatus:LCSTR("Registration Success")];
                    // 成功之后跳转首页或上一页
                    [self toHomeVC];
                };
                if ([accountStr rangeOfString:@"@"].length > 0) {
                    [[TuyaSmartUser sharedInstance] registerByEmail:countryCode email:accountStr password:passwordStr success:successSignUpHandler failure:failureHandler];
                } else {
                    [[TuyaSmartUser sharedInstance] registerByPhone:countryCode phoneNumber:accountStr password:passwordStr code:verifStr success:successSignUpHandler failure:failureHandler];
                }
            } else {
                // 找回密码
                // 重置密码,登录页面进入的,成功后调登录接口登录
                TYSuccessHandler successResetHandler = ^{
                    [SVProgressHUD dismiss];
                    // 重新登陆
                    // 登录
                    TYSuccessHandler successLoginHandler = ^{
                        
                        [SVProgressHUD showSuccessWithStatus:LCSTR("Password reset complete")];
                        // 成功之后跳转首页或上一页
                        [self toHomeVC];
                    };
                    // 忘记密码之后登陆
                    if ([accountStr rangeOfString:@"@"].length > 0) {
                        [[TuyaSmartUser sharedInstance] loginByEmail:countryCode email:accountStr password:passwordStr success:successLoginHandler failure:failureHandler];
                    } else {
                        [[TuyaSmartUser sharedInstance] loginByPhone:countryCode phoneNumber:accountStr password:passwordStr success:successLoginHandler failure:failureHandler];
                    }
                };
                
                if ([accountStr rangeOfString:@"@"].length > 0) {
                    [[TuyaSmartUser sharedInstance] resetPasswordByEmail:countryCode email:accountStr newPassword:passwordStr code:verifStr success:successResetHandler failure:failureHandler];
                } else {
                    [[TuyaSmartUser sharedInstance] resetPasswordByPhone:countryCode phoneNumber:accountStr newPassword:passwordStr code:verifStr success:successResetHandler failure:failureHandler];
                }
            }
        } break;
        default:
            break;
    }
}

- (void)toHomeVC {
    WSTHomeViewController *homeVC = [[WSTHomeViewController alloc] init];
    RTRootNavigationController *nav = [[RTRootNavigationController alloc] initWithRootViewController:homeVC];
    [AppDelegate instance].window.rootViewController = nav;
    [[AppDelegate instance].window makeKeyAndVisible];
}

// 发送验证码
- (void)sendIdentCode {
    [SVProgressHUD showWithStatus:LCSTR("Loading...")];
    
    TYSuccessHandler successHandler = ^{
        [SVProgressHUD dismiss];
        [getVerifButton setSelected:YES];
        [getVerifButton setTitle:[NSString stringWithFormat:@"%@ (60)",LCSTR("Resend")] forState:UIControlStateSelected];
        identifyTimes = 60;
        identifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resendIdentifyCode:) userInfo:nil repeats:YES];
    };
    
    TYFailureError failureHandler = ^(NSError *error) {
        [SVProgressHUD dismiss];
    };
    
    if ([accountStr rangeOfString:@"@"].length > 0) {
        [[TuyaSmartUser sharedInstance] sendVerifyCodeByEmail:countryCode email:accountStr success:successHandler failure:failureHandler];
    } else {
        [[TuyaSmartUser sharedInstance] sendVerifyCode:countryCode phoneNumber:accountStr type:1 success:successHandler failure:failureHandler];
    }
}

// 重新发送验证码
- (void)resendIdentifyCode:(id)userInfo {
    identifyTimes--;
    [getVerifButton setSelected:YES];
    [getVerifButton setTitle:[NSString stringWithFormat:@"%@ (%d)",LCSTR("Resend"), identifyTimes] forState:UIControlStateSelected];
    
    if (identifyTimes == 0) {
        [getVerifButton setSelected:YES];
        [getVerifButton setTitle:LCSTR("Get") forState:UIControlStateSelected];
        [self disableTimer];
    }
}

- (void)disableTimer {
    if (identifyTimer) {
        [identifyTimer invalidate];
        identifyTimer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
