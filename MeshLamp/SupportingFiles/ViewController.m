//
//  ViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/9/29.
//  Copyright © 2017年 make. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setRightButtonTitle:@"相册"];
}

- (void)onRightButtonClick:(id)sender{
    
    [self  createActionSheetWithImagePath:^(NSString *imagePath) {
        NSLog(@"%@",imagePath);
    }];
}




@end
