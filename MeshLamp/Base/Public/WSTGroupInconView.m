//
//  WSTGroupInconView.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/10.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTGroupInconView.h"
//#import "UIButton+ActionBlock.h"

@interface WSTGroupInconView()
/**图片数组*/
@property (nonatomic,strong) NSArray *imageArray;
/**数组*/
@property (nonatomic,strong) NSMutableArray<UIButton*> *buttonArray;
@end
@implementation WSTGroupInconView
- (instancetype)init
{
    self = [super initWithType:WSTAlertTypeGroupIcon];
    if (self) {
        [self masLayoutSubViews];
    }
    return self;
}


- (void)masLayoutSubViews{
    CGFloat space = 2;
    CGFloat w = (px750Width(497)-3*space)/4;
    int tag = 100;
    for (int j = 0; j<2; j++) {
        for (int i = 0; i<4; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = tag;
            button.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1.0];
            if (tag==107){
                button.backgroundColor = [UIColor clearColor];
            }else{
                [button setImage:[UIImage imageNamed:self.imageArray[tag-100]] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
                button.frame = CGRectMake(i*(w+space), j*(w+space), w, w);
                [self.centerView addSubview:button];
                tag++;
                [self.buttonArray addObject:button];
            }
            
        }
    }
    
    UIView *lineView = ({
        lineView = [UIView new];
        lineView.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
        [self.centerView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.centerView);
            make.height.mas_equalTo(1);
        }];
        lineView;
    });
}

#pragma mark - action
- (void)clickAction:(UIButton *)sender{
    for (UIButton *button in self.buttonArray) {
        button.backgroundColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1.0];
    }
    sender.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    NSLog(@"点击了第%ld个",sender.tag - 100);
    if (self.pressBlock) {
        self.pressBlock(sender.tag-100);
    }
}

#pragma mark - 懒加载
- (NSArray *)imageArray{
    if (!_imageArray) {
        _imageArray = @[@"icon_group_all",@"icon_livingRoom",@"icon_bedRoom",@"icon_diningRoom",@"icon_kitchen",@"icon_bathroom",@"icon_study",@""];
    }
    return _imageArray;
}
- (NSMutableArray<UIButton *> *)buttonArray{
    if (!_buttonArray) {
        _buttonArray = [@[] mutableCopy];
    }
    return _buttonArray;
}
@end
