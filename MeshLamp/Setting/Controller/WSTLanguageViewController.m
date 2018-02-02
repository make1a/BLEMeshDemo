//
//  WSTLanguageViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/11.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTLanguageViewController.h"
#import "NSBundle+Language.h"
#import "WSTHomeViewController.h"

@interface WSTLanguageViewController ()<UITableViewDelegate,UITableViewDataSource>
/**tableView*/
@property (nonatomic,strong) UITableView *tableView;
/**current index */
@property (nonatomic,assign) NSInteger currentIndex;
@end

@implementation WSTLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPropertys];
    [self setNavigationStyle];
    [self getCurrentLanguege];
}

- (void)getCurrentLanguege{
    NSString *language = [[NSUserDefaults standardUserDefaults]valueForKey:@"myLanguage"];
        if (!language||language.length == 0) {
            language = [NSString getPreferredLanguage];
        }
    if ([language containsString:@"zh-Hans"]) {
        self.currentIndex = 0;
    }else if ([language containsString:@"zh-Hant"]) {
        self.currentIndex = 1;
    }else if ([language containsString:@"en"]) {
        self.currentIndex = 2;
    }else if ([language containsString:@"nl"]) {
        self.currentIndex = 3;
    }
    [self.tableView reloadData];
}
- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("language_mode") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    
}
- (void)initPropertys {
    
   self.currentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"LANGUAGEINDEX"];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return px1334Hight(100);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SettingCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:31/255.0 green:47/255.0 blue:57/255.0 alpha:1.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        UIImageView *imageVie = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_icon_normal"]];
        imageVie.tag = 100;
        [cell addSubview:imageVie];
        [imageVie mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cell);
            make.right.equalTo(cell.mas_right).mas_offset(-12);
            make.width.height.mas_equalTo(px1334Hight(50));
        }];
        
        UIView *line = ({
            line = [[UIView alloc]init];
            line.backgroundColor = BGColor;
            [cell addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(cell);
                make.height.mas_equalTo(2);
            }];
            line;
        });
    }
    if (indexPath.row == _currentIndex) {
       UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
        imageView.image = [UIImage imageNamed:@"check_icon_selected"];
    }else{
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
        imageView.image = [UIImage imageNamed:@"check_icon_normal"];
    }
    [cell layoutIfNeeded];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = LCSTR("Simplified Chinese");
    } else if (indexPath.row == 1) {
        cell.textLabel.text = LCSTR("Traditional Chinese");
    } else if (indexPath.row == 2) {
        cell.textLabel.text = LCSTR("English");
    } else {
        cell.textLabel.text = LCSTR("Nederlands");
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _currentIndex) {
        if (indexPath.row == 0) {
            [self changeLanguageTo:@"zh-Hans"];
        } else if (indexPath.row == 1) {
            [self changeLanguageTo:@"zh-Hant"];
        } else if (indexPath.row == 2) {
            [self changeLanguageTo:@"en"];
        } else {
            [self changeLanguageTo:@"nl"];
        }
    } else {
        
        if (indexPath.row == 0) {
            [self changeLanguageTo:@"zh-Hans"];
        } else if (indexPath.row == 1) {
            [self changeLanguageTo:@"zh-Hant"];
        } else if (indexPath.row == 2) {
            [self changeLanguageTo:@"en"];
        } else {
            [self changeLanguageTo:@"nl"];
        }
    }
    _currentIndex = indexPath.row;
    
    [[NSUserDefaults standardUserDefaults] setInteger:_currentIndex forKey:@"LANGUAGEINDEX"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}


#pragma mark - Actions
- (void)changeLanguageTo:(NSString *)language {
    // 设置语言
    [NSBundle setLanguage:language];
    
    // 然后将设置好的语言存储好，下次进来直接加载
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"myLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        WSTHomeViewController *vc = [[WSTHomeViewController alloc]init];
        RTRootNavigationController *nav = [[RTRootNavigationController alloc]initWithRootViewController:vc];
        [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    }];
}

#pragma mark - 布局
- (void)masLayoutSubview{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
#pragma mark - 懒加载
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = BGColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
@end
