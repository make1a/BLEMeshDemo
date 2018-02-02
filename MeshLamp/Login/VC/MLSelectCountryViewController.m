//
//  MLSelectCountryViewController.m
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLSelectCountryViewController.h"
#import "MLCountryCodeUtils.h"

@interface MLSelectCountryViewController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView               *countrytableView;
    NSDictionary              *dataSource;
    NSArray                   *letterList;
//    NSMutableArray            *searchResults;
    NSMutableArray            *allDataList;
}
@end

@implementation MLSelectCountryViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Init
    [self initPropertys];
    
    // View
    [self loadMainView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
}

#pragma mark - Init
- (void)initPropertys {
//    searchResults  = [NSMutableArray new];
    letterList     = [NSArray new];
    allDataList    = [NSMutableArray new];
    
    NSArray *countryList = [MLCountryCodeUtils getDefaultPhoneCodeJson];
    
    NSMutableDictionary *countryCodeDict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dict in countryList) {
        MLCountryCodeModel *model = [MLCountryCodeModel modelWithJSON:dict];
        NSString *letter = model.firstLetter;
        
        NSMutableArray *mutableList;
        if ([countryCodeDict objectForKey:letter]) {
            mutableList = [countryCodeDict objectForKey:letter];
            [mutableList addObject:model];
        } else {
            mutableList = [NSMutableArray arrayWithArray:@[model]];
        }
        [countryCodeDict setObject:mutableList forKey:letter];
    }
    
    dataSource = countryCodeDict;
    
    [self reloadData];
}

- (void)reloadData {
    NSArray *keys   = [dataSource allKeys];
    NSArray *sortKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSLiteralSearch];
    }];
    
    [[dataSource allValues] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [allDataList addObjectsFromArray:obj];
    }];
    
    letterList = sortKeys;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [countrytableView reloadData];
    });
}

#pragma mark - View
- (void)loadMainView {
    [self setNavigationTitle:LCSTR("Choose Country") titleColor:[UIColor whiteColor]];
    [self setRightButtonTitle:LCSTR("Cancel")];


    self.view.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:38.0/255.0 blue:51.0/255.0 alpha:1.0f];
    self.automaticallyAdjustsScrollViewInsets = NO;

    countrytableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-Sp2Pt(64)) style:UITableViewStylePlain];
    
    countrytableView.backgroundColor = [UIColor clearColor];
    countrytableView.showsVerticalScrollIndicator = NO;
    countrytableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    countrytableView.separatorColor = [UIColor colorWithRed:20.0/255.0 green:38.0/255.0 blue:51.0/255.0 alpha:1.0f];
    countrytableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    countrytableView.dataSource = self;
    countrytableView.delegate = self;
    countrytableView.sectionIndexColor = [UIColor whiteColor];
    countrytableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:countrytableView];

    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.equalTo(self.view.mas_safeAreaLayoutGuide);
        } else {
            make.edges.equalTo(self.view);
        }
    }];
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = [dataSource objectForKey:[letterList objectAtIndex:section]];
    return array.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return letterList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.1];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    MLCountryCodeModel *model = [[dataSource objectForKey:[letterList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    cell.textLabel.text = model.countryName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MLCountryCodeModel *model;
    model = [[dataSource objectForKey:[letterList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [self.delegate didSelectCountry:self model:model];
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return letterList.count > 1 ? letterList : nil;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    return [[letterList objectAtIndex:section] uppercaseString];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = BGColor;
    
    UIView *border1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Width(view), 0.5)];
    border1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    border1.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:38.0/255.0 blue:51.0/255.0 alpha:1.0f];
    [view addSubview:border1];
    
    
    UIView *border2 = [[UIView alloc] initWithFrame:CGRectMake(0, 25-0.5, Width(view), 0.5)];
    border2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    border2.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:38.0/255.0 blue:51.0/255.0 alpha:1.0f];
    [view addSubview:border2];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, Width(view), Height(view))];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = [UIFont boldSystemFontOfSize:12];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.text = [self titleForHeaderInSection:section];
//    textLabel.shadowColor = [UIColor whiteColor];
    textLabel.shadowOffset = CGSizeMake(0, 1);
    [view addSubview:textLabel];
    
    return view;
}

#pragma mark - Actions
- (void)onRightButtonClick:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
