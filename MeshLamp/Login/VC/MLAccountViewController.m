//
//  MLAccountViewController.m
//  doonne
//
//  Created by TrusBe Sil on 2017/5/18.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLAccountViewController.h"
#import "MLVerificationViewController.h"
#import "MLSignInViewController.h"
#import "SignInCell.h"

@interface MLAccountViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    UITableView         *accountTableView;
    UIButton            *doneButton;
}

@end

@implementation MLAccountViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMainView];
    [self setNavigationStyle];
}

- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("Account Info") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
}

#pragma mark - View
- (void)loadMainView {
    // table View
    accountTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 0, 0-64) style:UITableViewStyleGrouped];
    accountTableView.backgroundColor = [UIColor clearColor];
    accountTableView.delegate = self;
    accountTableView.dataSource = self;
    [accountTableView setSeparatorColor:[UIColor colorWithRed:20.0/255.0 green:38.0/255.0 blue:51.0/255.0 alpha:1.0f]];
    [self.view addSubview:accountTableView];
    doneButton = [[UIButton alloc] init];

    [accountTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
            make.edges.equalTo(self.view);
        }

    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    SignInCell *cell = (SignInCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SignInCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backView.hidden = YES;
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = LCSTR("Account");
            cell.detailTextLabel.text = [TuyaSmartUser sharedInstance].userName;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = LCSTR("Nike Name");
            cell.detailTextLabel.text = [TuyaSmartUser sharedInstance].nickname;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = LCSTR("Reset Password");
        }
    } else {
        if (indexPath.row == 0) {
            cell.backView.hidden = NO;
            cell.backgroundColor = [UIColor clearColor];
            doneButton.frame = CGRectMake(0, 0, Width(cell.backView), Height(cell.backView));;
            doneButton.titleLabel.font = [UIFont systemFontOfSize:Sp2Pt(17)];
            doneButton.titleLabel.textColor = [UIColor whiteColor];
            doneButton.layer.masksToBounds = YES;
            doneButton.layer.cornerRadius = Sp2Pt(10);
            [doneButton setBackgroundColor:[UIColor colorWithRed:254.0/255.0 green:56.0/255.0 blue:36.0/255.0 alpha:1.0f]];
            [doneButton setTitle:LCSTR("Sign Out") forState:UIControlStateNormal];
            [doneButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.backView addSubview:doneButton];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [self addNewHomeAction];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            MLVerificationViewController *verificationVC = [[MLVerificationViewController alloc] init];
            verificationVC.countryCode = [TuyaSmartUser sharedInstance].countryCode;
            if ([[TuyaSmartUser sharedInstance].userName rangeOfString:@"@"].length > 0) {
                verificationVC.accountStr = [TuyaSmartUser sharedInstance].email;
            } else {
                NSLog(@"account: %@ - phone:%@",[TuyaSmartUser sharedInstance].userName,  [TuyaSmartUser sharedInstance].phoneNumber);
                NSArray *temArray = [[TuyaSmartUser sharedInstance].phoneNumber componentsSeparatedByString:@"-"];
                verificationVC.accountStr = [temArray lastObject];
            }
            verificationVC.isSignUp = NO;
            [self.navigationController pushViewController:verificationVC animated:YES];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length > 0 && textField.text.length <= 13) {
        [self modifyNickname:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

#pragma mark - Actions
- (void)modifyNickname:(NSString *)nickname {
    [[TuyaSmartUser sharedInstance] updateNickname:nickname success:^{
        [SVProgressHUD showInfoWithStatus:LCSTR("Update Success")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [accountTableView reloadData];
        });
    } failure:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:LCSTR("Update Failure")];
    }];
}

/**
 *  弹出文本输入框更改昵称
 */
- (void)addNewHomeAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LCSTR("Change Nike Name") message:LCSTR("Please enter a new nike name") preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        textField.placeholder = LCSTR("New Nike Name");
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:LCSTR("Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated: YES completion: nil];
    }];
    [alert addAction:confirmAction];
    [self presentViewController: alert animated: YES completion:nil];
}

- (void)buttonAction:(UIButton *)button {
    [[TuyaSmartUser sharedInstance] loginOut:^{
        [SVProgressHUD showSuccessWithStatus:LCSTR("LogOut Success")];
        MLSignInViewController *signInVC = [[MLSignInViewController alloc] init];
        RTRootNavigationController *nav = [[RTRootNavigationController alloc] initWithRootViewController:signInVC];
        [self presentViewController:nav animated:YES completion:nil];
    } failure:^(NSError *error) {
        [SVProgressHUD showSuccessWithStatus:LCSTR("LogOut Failure")];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
