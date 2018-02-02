//
//  BaseViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/29.
//  Copyright © 2017年 make. All rights reserved.
//

#import "BaseViewController.h"
#define SystemVersionIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? YES : NO)


#ifdef SystemVersionIOS7
#define BASE_TEXTSIZE(text, font) ([text length] > 0 ? [text sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero)
#else
#define BASE_TEXTSIZE(text, font) ([text length] > 0 ? [text sizeWithFont:font] : CGSizeZero)
#endif
@interface BaseViewController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //顶部不留空
    self.automaticallyAdjustsScrollViewInsets = NO;
    //取消半透明
    self.navigationController.navigationBar.translucent = NO;
    
    [self masLayoutSubview];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = BGColor;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:44/255.0 green:62/255.0 blue:75/255.0 alpha:1.0];
}



- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];



}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
}


- (void)hideNavigationBottomLine{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.translucent = YES;
    
}






#pragma mark - --------------------------touch Event--------------------------
- (void)onLeftButtonClick:(id)sender{
    
    if ([self.navigationController.visibleViewController isMemberOfClass:[UITabBarController class]]) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)onRightButtonClick:(id)sender{
    
    
    
}

- (void)refreshEvent{
    
    
}


#pragma mark - 设置NavigationTitle
- (void)setNavigationTitle:(NSString *)title titleColor:(UIColor *)titleColor{
    
    self.title = title;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:titleColor};
    
}
#pragma mark - 左侧按钮设置
- (void)setLeftButtonTitle:(NSString *)title{
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    [self.leftButton setTitle:title forState:UIControlStateNormal];
    [self.leftButton setFrame:CGRectMake(0, 0, BASE_TEXTSIZE(title, self.leftButton.titleLabel.font).width, BASE_TEXTSIZE(title,self.leftButton.titleLabel.font).height)];
}
- (void)setLeftButtonImage:(UIImage *)image{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    [self.leftButton setImage:image forState:UIControlStateNormal];
    [self.leftButton setFrame:CGRectMake(0, 0, image.size.width,image.size.height)];
}
#pragma mark - 右侧按钮设置
- (void)setRightButtonTitle:(NSString *)title{
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    [self.rightButton setTitle:title forState:UIControlStateNormal];
    [self.rightButton setFrame:CGRectMake(0, 0, BASE_TEXTSIZE(title, self.rightButton.titleLabel.font).width, BASE_TEXTSIZE(title,self.rightButton.titleLabel.font).height)];
    
    
}
- (void)setRightButtonImage:(UIImage *)image{
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    [self.rightButton setImage:image forState:UIControlStateNormal];
    [self.rightButton setFrame:CGRectMake(0, 0, image.size.width,image.size.height)];
    
    
    
}

#pragma mark - --------------------------overwirte--------------------------
-(void)touchesEnded:(NSSet<UITouch*> *)touches withEvent:(UIEvent*)event{
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];//点击屏幕收起键盘
    
}

/**
 [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
 状态栏变白 要设置info.plist View controller-based status bar appearance  为NO
 */
-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleDefault;
    
}

#pragma mark - --------------------------lazy load--------------------------
- (UIButton *)leftButton{
    
    if (!_leftButton) {
        
        _leftButton = [[UIButton alloc]init];
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_leftButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_leftButton setExclusiveTouch:YES];
        [_leftButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [_leftButton addTarget:self action:@selector(onLeftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _leftButton;
    
}

- (UIButton *)rightButton{
    
    if (!_rightButton) {
        
        _rightButton = [[UIButton alloc]init];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_rightButton setExclusiveTouch:YES];
        [_rightButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [_rightButton addTarget:self action:@selector(onRightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _rightButton;
    
}


- (void)setNavigationStyle{
    
}

#pragma mark - --------------------------Masonry--------------------------
- (void)masLayoutSubview{
    
}


@end

