//
//  MLBuildQRCodeViewController.m
//  doonne
//
//  Created by TrusBe Sil on 2017/4/13.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLBuildQRCodeViewController.h"



@interface MLBuildQRCodeViewController ()<UIActionSheetDelegate> {
    UIView      *qrBackView;
    UIImageView *qrCodeImageView;
}


@end

@implementation MLBuildQRCodeViewController
@synthesize homeName, homePassword;
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Init
    [self initPropertys];
    
    // View
    [self loadMainView];
    [self buildQRcode];
    [self setNavigationStyle];
}
- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("Share Home") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
}
#pragma mark - Init
- (void)initPropertys {

}

#pragma mark - View
- (void)loadMainView {

    // 大背景
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:backView];
    
    // 小背景
    qrBackView = [[UIView alloc] initWithFrame:CGRectMake(Width(backView)*0.1, (Height(backView)-Height(backView)*0.6)/3, Width(backView)*0.8, Height(backView)*0.6)];
    qrBackView.backgroundColor = [UIColor colorWithRed:234.0 / 255.0 green:234.0 / 255.0 blue:234.0 / 255.0 alpha:1.0f];
    qrBackView.layer.masksToBounds = YES;
    qrBackView.layer.cornerRadius = Sp2Pt(8);
    [backView addSubview:qrBackView];
    // 添加手势保存图片
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(savePhoto)];
    tapRecognizer.numberOfTapsRequired = 1;
    [qrBackView addGestureRecognizer:tapRecognizer];
    
    // 二维码图片
    qrCodeImageView = [[UIImageView alloc]initWithFrame:CGRectMake((Width(qrBackView)-Sp2Pt(240))/2, (Height(qrBackView)-Sp2Pt(240)-Sp2Pt(30))/2, Sp2Pt(240), Sp2Pt(240))];
    [qrBackView addSubview:qrCodeImageView];
    
    // 提醒 Label
    UILabel *remindLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,qrCodeImageView.frame.origin.y+Sp2Pt(240)+Sp2Pt(8), Width(qrBackView), Sp2Pt(30))];
    remindLabel.font = [UIFont systemFontOfSize:12];
    remindLabel.textColor = [UIColor colorWithRed:164.0 / 255.0 green:170.0 / 255.0 blue:179.0 / 255.0 alpha:1.0f];
    remindLabel.textAlignment = NSTextAlignmentCenter;
    remindLabel.text = LCSTR("Scan QR Code, Share Network");
    [qrBackView addSubview:remindLabel];
}

- (void)buildQRcode {
    NSString *meshNetPassword = [@"91" stringByAppendingString:homePassword];
    NSString *meshNetVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *infoDictionary = @{@"meshNetName": homeName, @"meshNetPassword": meshNetPassword, @"meshNetVersion": meshNetVersion, @"meshNetCommand": @"shareNetwork"};
    NSData *infoData = [self toJSONData:infoDictionary];
    
    // 生成二维码
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:infoData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    UIColor *onColor = [UIColor colorWithRed:21.0 / 255.0 green:37.0 / 255.0 blue:52.0 / 255.0 alpha:1.0f];
    UIColor *offColor = [UIColor colorWithRed:234.0 / 255.0 green:234.0 / 255.0 blue:234.0 / 255.0 alpha:1.0f];
    
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage", qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    CGSize size = CGSizeMake(Sp2Pt(1024), Sp2Pt(1024));
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    qrCodeImageView.image = codeImage;
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [SVProgressHUD showErrorWithStatus:LCSTR("Successfully Saved")];
    } else {
        [SVProgressHUD showErrorWithStatus:LCSTR("Successfully Saved")];
    }
}

#pragma mark - Actions
- (void)savePhoto {
    UIAlertController *action = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:LCSTR("Cancel") style:UIAlertActionStyleCancel handler:nil];
    [action addAction:cancel];
    UIAlertAction *scanAction = [UIAlertAction actionWithTitle:LCSTR("Save To Photos") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(qrCodeImageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }];
    [action addAction:scanAction];
    
    if (IS_iPad) {
        UIPopoverPresentationController *popoverPresentCtr = action.popoverPresentationController;
        popoverPresentCtr.sourceView = qrCodeImageView;
        popoverPresentCtr.sourceRect = qrCodeImageView.bounds;
        popoverPresentCtr.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    [self presentViewController: action animated: YES completion:nil];
}

- (NSData *)toJSONData: (id)theData {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil) {
        return jsonData;
    } else {
        return nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
