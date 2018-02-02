//
//  MLSelectCountryViewController.h
//  doonne
//
//  Created by TrusBe Sil on 2017/5/8.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "MLCountryCodeModel.h"

@class MLSelectCountryViewController;

@protocol MLSelectCountryDelegate <NSObject>

- (void)didSelectCountry:(MLSelectCountryViewController *)controller model:(MLCountryCodeModel *)model;

@end

@interface MLSelectCountryViewController : BaseViewController

@property (nonatomic,weak) id <MLSelectCountryDelegate> delegate;

@end
