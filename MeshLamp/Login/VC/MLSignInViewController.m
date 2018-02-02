//
//  MLSignInViewController.m
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLSignInViewController.h"
#import "AccountModel.h"
#import "MLCountryCodeModel.h"
#import "MLCountryCodeUtils.h"
#import "WSTHomeViewController.h"
#import "MLSelectCountryViewController.h"
#import "MLSignUpViewController.h"
#import "SignInCell.h"

@interface MLSignInViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MLSelectCountryDelegate> {
    UITableView *signInTableView;
    UILabel *detailLabel;
    UIImageView *icon;
    UITextField *accountTF;
    UITextField *passwordTF;
    UIButton *doneButton;

    MLCountryCodeModel *countryModel;
    NSString *accountStr;
    NSString *passwordStr;
}

@end

@implementation MLSignInViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Init
    [self initPropertys];

    // View
    [self loadMainView];
}


#pragma mark - Init
- (void)initPropertys {
    countryModel = [[MLCountryCodeModel alloc] init];
    accountStr = [[NSString alloc] init];
    passwordStr = [[NSString alloc] init];
    [self getCurrentCountryCode];
}

#pragma mark - View
- (void)loadMainView {
    [self setNavigationTitle:LCSTR("Sign In") titleColor:[UIColor whiteColor]];
    [self setRightButtonTitle:LCSTR("Register")];
    if (self.isFirst == YES) {
        [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    }
    // table View
    signInTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    signInTableView.backgroundColor = [UIColor clearColor];
    signInTableView.delegate = self;
    signInTableView.dataSource = self;
    [signInTableView setSeparatorColor:[UIColor colorWithRed:20.0/255.0 green:38.0/255.0 blue:51.0/255.0 alpha:1.0f]];
    [signInTableView registerClass:[SignInCell class] forCellReuseIdentifier:@"SignInCell"];
    [self.view addSubview:signInTableView];

    [signInTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
    
    accountTF = [[UITextField alloc] init];
    passwordTF = [[UITextField alloc] init];
    doneButton = [[UIButton alloc] init];
    detailLabel = [[UILabel alloc] init];
    icon = [[UIImageView alloc] init];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Sp2Pt(50);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return Sp2Pt(200);
    } else {
        return Sp2Pt(20);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return Sp2Pt(20);
    } else {
        return Sp2Pt(40);
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, Sp2Pt(200))];
        headerView.backgroundColor = BGColor;
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((Width(headerView) - Sp2Pt(100)) / 2, (Height(headerView) - Sp2Pt(32)) / 2, Sp2Pt(100), Sp2Pt(32))];
        [logoImageView setImage:[UIImage imageNamed:@"logo_word_icon"]];
        [headerView addSubview:logoImageView];
        return headerView;
    } else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    if (section == 1) {
        footerView.frame = CGRectMake(Sp2Pt(15), 0, SCREEN_WIDTH - Sp2Pt(30), Sp2Pt(40));
        // 短信验证登陆
        UIButton *smsButton = [[UIButton alloc] initWithFrame:CGRectMake(Sp2Pt(15), 0, (Width(footerView) - Sp2Pt(15)) * 0.5, Height(footerView))];
        smsButton.backgroundColor = [UIColor clearColor];
        //        smsButton.titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(12)];
        //        smsButton.titleLabel.textColor = APGrey;
        //        smsButton.tag = 100;
        //        smsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //        [smsButton setTitle:LCSTR("SMS verification login") forState:UIControlStateNormal];
        //        [smsButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:smsButton];
        // 忘记密码
        UIButton *forgotButton = [[UIButton alloc] initWithFrame:CGRectMake(Width(smsButton) + Sp2Pt(30), 0, (Width(footerView) - Sp2Pt(15)) * 0.5, Height(footerView))];
        forgotButton.backgroundColor = [UIColor clearColor];
        forgotButton.titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(12)];
        forgotButton.titleLabel.textColor =  [UIColor colorWithRed:164.0/255.0 green:170.0/255.0 blue:179.0/255.0 alpha:1.0f];
        forgotButton.tag = 101;
        forgotButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [forgotButton setTitle:LCSTR("Forget Password") forState:UIControlStateNormal];
        [forgotButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:forgotButton];

        UIButton *skipLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(Sp2Pt(15), 0, (Width(footerView) - Sp2Pt(15)) * 0.5, Height(footerView))];
        skipLoginButton.backgroundColor = [UIColor clearColor];
        skipLoginButton.titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(12)];
        skipLoginButton.titleLabel.textColor =  [UIColor colorWithRed:164.0/255.0 green:170.0/255.0 blue:179.0/255.0 alpha:1.0f];
        skipLoginButton.tag = 101;
        skipLoginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [skipLoginButton setTitle:LCSTR("Skip Login") forState:UIControlStateNormal];
        [skipLoginButton addTarget:self action:@selector(skipAction:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:skipLoginButton];
    }
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SignInCell";
    SignInCell *cell = (SignInCell *) [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SignInCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.nameLabel.frame = CGRectMake(0, 0, Width(cell.backView) * 0.45, Height(cell.backView));
            cell.nameLabel.text = LCSTR("Country / Region");

            detailLabel.frame = CGRectMake(0, 0, Width(cell.infoView) - Sp2Pt(16), Height(cell.infoView));
            detailLabel.textColor = [UIColor grayColor];
            detailLabel.textAlignment = NSTextAlignmentRight;
            detailLabel.font = [UIFont systemFontOfSize:Sp2Pt(12)];
            detailLabel.text = countryModel ? [NSString stringWithFormat:@"%@ +%@", countryModel.countryName, countryModel.countryCode] : @"";
            [cell.infoView addSubview:detailLabel];

            icon.frame = CGRectMake(Width(cell.infoView) - Sp2Pt(8), (Height(cell.infoView) - Sp2Pt(13)) / 2, Sp2Pt(8), Sp2Pt(13));
            icon.image = [UIImage imageNamed:@"ez_arrow_small_icon"];
            [cell.infoView addSubview:icon];
        } else if (indexPath.row == 1) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.nameLabel.text = LCSTR("Account:");
            accountTF.frame = CGRectMake(0, 0, Width(cell.infoView), Height(cell.infoView));
            NSString *holderText = LCSTR("Phone / Email");
            NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
            [placeholder addAttribute:NSForegroundColorAttributeName
                                value:[UIColor grayColor]
                                range:NSMakeRange(0, holderText.length)];
            [placeholder addAttribute:NSFontAttributeName
                                value:[UIFont boldSystemFontOfSize:16]
                                range:NSMakeRange(0, holderText.length)];
            accountTF.attributedPlaceholder = placeholder;
            accountTF.clearButtonMode = UITextFieldViewModeAlways;
            accountTF.font = [UIFont systemFontOfSize:Sp2Pt(15)];
            accountTF.textColor = [UIColor whiteColor];
            accountTF.delegate = self;
            accountTF.returnKeyType = UIReturnKeyDone;
            [cell.infoView addSubview:accountTF];
        } else if (indexPath.row == 2) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.nameLabel.text = LCSTR("Password:");
            passwordTF.frame = CGRectMake(0, 0, Width(cell.infoView), Height(cell.infoView));
            ;
            NSString *holderText = LCSTR("Password");
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
            [cell.infoView addSubview:passwordTF];
        }
    } else {
        cell.backgroundColor = [UIColor clearColor];
        cell.nameLabel.hidden = YES;
        cell.infoView.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            doneButton.frame = CGRectMake(0, 0, Width(cell.backView), Height(cell.backView));
            ;
            doneButton.titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(17)];
            doneButton.titleLabel.textColor = [UIColor whiteColor];
            doneButton.layer.masksToBounds = YES;
            doneButton.layer.cornerRadius = Sp2Pt(10);
            doneButton.tag = 102;
            [doneButton setBackgroundColor:[UIColor colorWithRed:245.0/255.0 green:206.0/255.0 blue:111.0/255.0 alpha:1.0f]];
            [doneButton setTitle:LCSTR("Sign In") forState:UIControlStateNormal];
            [doneButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.backView addSubview:doneButton];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            MLSelectCountryViewController *selectCountryVC = [[MLSelectCountryViewController alloc] init];
            selectCountryVC.delegate = self;
            RTRootNavigationController *nav = [[RTRootNavigationController alloc] initWithRootViewController:selectCountryVC];
            [self presentViewController:nav animated:YES completion:nil];
        }
    } else {
        if (indexPath.row == 0) {
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // 信息
    if (textField == accountTF) {
        accountStr = textField.text;
    } else {
        passwordStr = textField.text;
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // 信息
    if (textField == accountTF) {
        accountStr = textField.text;
    } else {
        passwordStr = textField.text;
    }
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

#pragma mark - MLSelectCountryDelegate
- (void)didSelectCountry:(MLSelectCountryViewController *)controller model:(MLCountryCodeModel *)model {
    countryModel = model;
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self reloadTableView];
}

#pragma mark - Actions
- (void)getCurrentCountryCode {
    countryModel = [MLCountryCodeModel getCountryCodeModel:[MLCountryCodeUtils getDefaultPhoneCodeJson] countryCode:[MLCountryCodeUtils getCountryCode]];
}

- (void)reloadTableView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [signInTableView reloadData];
    });
}

- (void)onRightButtonClick:(id)sender{
    MLSignUpViewController *signUpVC = [[MLSignUpViewController alloc] init];
    signUpVC.isSignUp = YES;
    [self.navigationController pushViewController:signUpVC animated:YES];
}

- (void)buttonAction:(UIButton *)button {
    [accountTF resignFirstResponder];
    [passwordTF resignFirstResponder];
    [signInTableView endEditing:YES];
    switch (button.tag) {
    case 100: {

    } break;
    case 101: {
        MLSignUpViewController *signUpVC = [[MLSignUpViewController alloc] init];
        signUpVC.isSignUp = NO;
        [self.navigationController pushViewController:signUpVC animated:YES];
    } break;
    case 102: {
        NSLog(@"SignInVC, buttonAction, model: %@, name: %@, pwd: %@", countryModel, accountStr, passwordStr);
        [signInTableView endEditing:YES];
        if (countryModel == nil) {
            
            [SVProgressHUD showErrorWithStatus:LCSTR("Please select a country or region")];
            return;
        }
        if (accountStr.length == 0) {
            [SVProgressHUD showErrorWithStatus:LCSTR("Please enter your account")];
            return;
        }
        if (passwordStr.length == 0) {
            [SVProgressHUD showErrorWithStatus:LCSTR("Please enter your password")];
            return;
        }

        [SVProgressHUD showInfoWithStatus:LCSTR("Loading...")];

        // 登录
        if ([accountStr rangeOfString:@"@"].length > 0) {
            // 邮箱
            [[TuyaSmartUser sharedInstance] loginByEmail:countryModel.countryCode
                email:accountStr
                password:passwordStr
                success:^{
                    [SVProgressHUD showSuccessWithStatus:LCSTR("Login Success")];
                    // 保存信息
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        RTRootNavigationController *nav = [[RTRootNavigationController alloc] initWithRootViewController:[WSTHomeViewController new]];
                        [AppDelegate instance].window.rootViewController = nav;
                        [[AppDelegate instance].window makeKeyAndVisible];
                    });
                }
                failure:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:LCSTR("Login Failure")];
                }];
        } else {
            // 手机号
            [[TuyaSmartUser sharedInstance] loginByPhone:countryModel.countryCode
                phoneNumber:accountStr
                password:passwordStr
                success:^{
                    [SVProgressHUD showSuccessWithStatus:LCSTR("Login Success")];
                    // 保存信息
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        RTRootNavigationController *nav = [[RTRootNavigationController alloc] initWithRootViewController:[WSTHomeViewController new]];
                        [AppDelegate instance].window.rootViewController = nav;
                        [[AppDelegate instance].window makeKeyAndVisible];
                    });
                }
                failure:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:LCSTR("Login Failure")];
                }];
        }
    } break;
    default:
        break;
    }
}

- (void)saveAccountInfoWithCountryMode:(MLCountryCodeModel *)model account:(NSString *)account password:(NSString *)pwd {
    AccountModel *accountModel = [[AccountModel alloc] init];
    accountModel.model = model;
    accountModel.account = account;
    accountModel.password = pwd;
    [[NSUserDefaults standardUserDefaults] setObject:accountModel forKey:@"ACCOUNTMODEL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)skipAction:(id)sender {
    RTRootNavigationController *nav = [[RTRootNavigationController alloc] initWithRootViewController:[WSTHomeViewController new]];
    [AppDelegate instance].window.rootViewController = nav;
    [[AppDelegate instance].window makeKeyAndVisible];
    
}

@end
