//
//  WSTHomeGroupHeadView.m
//  MeshLamp
//
//  Created by make on 2017/10/2.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTHomeGroupHeadView.h"

@implementation WSTHomeGroupHeadView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.describeLabel.text = LCSTR("add_group");
}
- (void)viewRefresWith:(WSTHomeGorupShowModel*)model{
    NSString *str = [NSString stringWithFormat:@"where homeName = '%@'",[[NSUserDefaults standardUserDefaults] valueForKey:currentHomeName]];
    NSArray *array = [WSTHomeGorupShowModel selectFromClassPredicateWithFormat:str];
    if (array.count-1 == 0) {
        self.headTitleLabel.text = NSLocalizedString(@"group", nil);
    }else{
        self.headTitleLabel.text = [NSString stringWithFormat:@"%@-%ld",NSLocalizedString(@"group", nil),array.count-1];
    }
    
}
@end
