//
//  MLSignUpViewController.m
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLSignUpViewController.h"
#import "MLSelectCountryViewController.h"
#import "SignInCell.h"
#import "MLCountryCodeModel.h"
#import "MLCountryCodeUtils.h"
#import "MLVerificationViewController.h"

@interface MLSignUpViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MLSelectCountryDelegate> {
    UITableView                 *signInTableView;
    UILabel                     *detailLabel;
    UIImageView                 *icon;
    UITextField                 *accountTF;
    UIButton                    *doneButton;
    
    MLCountryCodeModel          *countryModel;
    NSString                    *accountStr;
}


@end

@implementation MLSignUpViewController
@synthesize isSignUp;
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Init
    [self initPropertys];
    [self setNavigationStyle];
    // View
    [self loadMainView];
}

- (void)setNavigationStyle{
    [self setNavigationTitle:isSignUp ? LCSTR("Register") : LCSTR("Retrieve Password") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
}

#pragma mark - Init
- (void)initPropertys {
    countryModel = [[MLCountryCodeModel alloc] init];
    accountStr = [[NSString alloc] init];
    [self getCurrentCountryCode];
}

#pragma mark - View
- (void)loadMainView {
    

    
    // table View
    signInTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_HEIGHT, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    signInTableView.backgroundColor = [UIColor clearColor];
    signInTableView.delegate = self;
    signInTableView.dataSource = self;
    [signInTableView setSeparatorColor:[UIColor colorWithRed:20.0/255.0 green:38.0/255.0 blue:51.0/255.0 alpha:1.0f]];
    [signInTableView registerClass:[SignInCell class] forCellReuseIdentifier:@"SignInCell"];
    [self.view addSubview:signInTableView];
    
    accountTF = [[UITextField alloc] init];
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
        return 2;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, Sp2Pt(200))];
        headerView.backgroundColor = BGColor;
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((Width(headerView)-Sp2Pt(100))/2, (Height(headerView)-Sp2Pt(32))/2, Sp2Pt(100), Sp2Pt(32))];
        [logoImageView setImage:[UIImage imageNamed:@"logo_word_icon"]];
        [headerView addSubview:logoImageView];
        return headerView;
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SignInCell";
    SignInCell *cell = (SignInCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SignInCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.nameLabel.frame = CGRectMake(0, 0, Width(cell.backView)*0.45, Height(cell.backView));
            cell.nameLabel.text =  countryModel ? [NSString stringWithFormat:@"%@", countryModel.countryName] : LCSTR("Country / Region");;
            
            detailLabel.frame = CGRectMake(0, 0, Width(cell.infoView)-Sp2Pt(16), Height(cell.infoView));
            detailLabel.textColor = [UIColor grayColor];
            detailLabel.textAlignment = NSTextAlignmentRight;
            detailLabel.font = [UIFont systemFontOfSize:Sp2Pt(12)];
            detailLabel.text = countryModel ? [NSString stringWithFormat:@"+%@", countryModel.countryCode] : @"";
            [cell.infoView addSubview:detailLabel];
            
            icon.frame = CGRectMake(Width(cell.infoView)-Sp2Pt(8), (Height(cell.infoView)-Sp2Pt(13))/2, Sp2Pt(8), Sp2Pt(13));
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
            doneButton.tag = 100;
            [doneButton setBackgroundColor:MLSelectColor];
            [doneButton setTitle:LCSTR("Next Step") forState:UIControlStateNormal];
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

#pragma mark - MLSelectCountryDelegate
- (void)didSelectCountry:(MLSelectCountryViewController *)controller model:(MLCountryCodeModel *)model {
    countryModel = model;
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self reloadTableView];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // 信息
    accountStr = textField.text;
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // 信息
    accountStr = textField.text;
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
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

- (void)buttonAction:(UIButton *)button {
    [accountTF resignFirstResponder];
    [signInTableView endEditing:YES];
    switch (button.tag) {
        case 100:
        {
            if (accountStr.length > 0) {
                NSLog(@"SignUpVC, buttonAction, model: %@, name: %@", countryModel, accountStr);
                MLVerificationViewController *verificationVC = [[MLVerificationViewController alloc] init];
                verificationVC.countryCode = countryModel.countryCode;
                verificationVC.accountStr = accountStr;
                verificationVC.isSignUp = isSignUp;
                if ([accountStr rangeOfString:@"@"].length > 0) {
                    // 邮箱
                    verificationVC.isEmail = YES;
                } else {
                    // 手机号
                    verificationVC.isEmail = NO;
                }
                [self.navigationController pushViewController:verificationVC animated:YES];
            } else {
                
                [SVProgressHUD showErrorWithStatus:LCSTR("Please enter your account")];
            }
        } break;
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
