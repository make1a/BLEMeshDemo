//
//  MLScanQRCodeViewController.m
//  doonne
//
//  Created by TrusBe Sil on 2017/4/13.
//  Copyright © 2017年 we-smart Co., Ltd. All rights reserved.
//

#import "MLScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WSTHomeInfo.h"
#import "WSTNetworkListViewController.h"
@interface MLScanQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImageView *scanLine;
    NSTimer     *scanTimer; // 扫描线定时器
    NSTimer     *imagePickerTimer;
    int         i;
}

@property (nonatomic, strong) AVCaptureSession              *mySession; // 二维码生成的会话
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *myPreviewLayer; // 二维码生成的图层

@end

@implementation MLScanQRCodeViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Init
    [self initPropertys];
    
    // View
    [self loadMainView];
    [self readQRCode];
    [self setNavigationStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if (![scanTimer isValid]) {
        scanTimer  = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(scanAnimation:) userInfo:nil repeats:YES];
        [scanTimer fire];
    }
    if (![imagePickerTimer isValid]) {
        imagePickerTimer  = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(scanAnimation:) userInfo:nil repeats:YES];
        [imagePickerTimer fire];
    }
}

- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("Scan QR Code") titleColor:[UIColor whiteColor]];
    [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
    [self setRightButtonTitle:LCSTR("Photos")];
}
- (void)onRightButtonClick:(id)sender{
    [self rightNavBarAction];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [scanTimer invalidate];
    [imagePickerTimer invalidate];
    scanTimer = imagePickerTimer = nil;
}

#pragma mark - Init
- (void)initPropertys {
    //    defaults = [WSDefaults instance];
    i = 0;
}

#pragma mark - View
- (void)loadMainView {
    // 设定扫描框四周黑边视图
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_HEIGHT-Sp2Pt(300))/2)];
    topView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    [self.view addSubview:topView];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, Height(topView), (SCREEN_WIDTH-Sp2Pt(300))/2, Sp2Pt(300))];
    leftView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    [self.view addSubview:leftView];
    UIView *bottonView = [[UIView alloc] initWithFrame:CGRectMake(0, Height(topView)+Height(leftView), SCREEN_WIDTH, (SCREEN_HEIGHT-Sp2Pt(300))/2)];
    bottonView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    [self.view addSubview:bottonView];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+Sp2Pt(150), Height(topView), (SCREEN_WIDTH-Sp2Pt(300))/2, Sp2Pt(300))];
    rightView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    [self.view addSubview:rightView];
    // 设定扫描框
    UIImageView *scanView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-Sp2Pt(305))/2, (SCREEN_HEIGHT-Sp2Pt(305))/2, Sp2Pt(305), Sp2Pt(305))];
    scanView.image = [UIImage imageNamed:@"scanBackground"];
    scanView.clipsToBounds = YES;
    [self.view addSubview:scanView];
    // 设定扫描线
    scanLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, -Sp2Pt(55), Width(scanView), Sp2Pt(55))];
    [scanLine setImage:[UIImage imageNamed:@"scanLine"]];
    [scanView addSubview:scanLine];
    // 扫描定时
    scanTimer  = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(scanAnimation:) userInfo:nil repeats:YES];
    [scanTimer fire];
    // 设定文字提醒框
    float lableHeight = [self heightOfString:@"请扫描微信周边提供的商户二维码" font:[UIFont systemFontOfSize:14] width:Sp2Pt(300)];
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake((Width(bottonView)-Sp2Pt(300))/2, (Height(bottonView)-lableHeight)/2, Sp2Pt(300), lableHeight*2)];
    tipsLabel.text = LCSTR("Scan QR Code, To Join The Network");
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 0;
    [bottonView addSubview:tipsLabel];
}

- (void)readQRCode {
    //获取摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //设置输入
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error) {
        NSLog(@"没有摄像头:%@", error.localizedDescription);
        return;
    }
    
    //设置输出（metadata 元数据）
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // Y.X.H.W,原点在右上角
    [output setRectOfInterest:CGRectMake((SCREEN_HEIGHT/2-150)/SCREEN_HEIGHT, (SCREEN_WIDTH/2-150)/SCREEN_WIDTH,  300/SCREEN_HEIGHT, 300/SCREEN_WIDTH)];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //创建拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    //添加session的输入和输出
    [session addInput:input];
    [session addOutput:output];
    
    //设置输出的格式
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    [output setMetadataObjectTypes:@[
                                     AVMetadataObjectTypeUPCECode,
                                     AVMetadataObjectTypeCode39Code,
                                     AVMetadataObjectTypeCode39Mod43Code,
                                     AVMetadataObjectTypeEAN13Code,
                                     AVMetadataObjectTypeEAN8Code,
                                     AVMetadataObjectTypeCode93Code,
                                     AVMetadataObjectTypeCode128Code,
                                     AVMetadataObjectTypePDF417Code,
                                     AVMetadataObjectTypeQRCode,
                                     AVMetadataObjectTypeAztecCode,
                                     AVMetadataObjectTypeInterleaved2of5Code,
                                     AVMetadataObjectTypeITF14Code,
                                     AVMetadataObjectTypeDataMatrixCode
                                     ]];
    
    
    //设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    //设置preview图层的属性
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //设置preview图层的大小
    [preview setFrame:self.view.bounds];
    
    //将图层添加到视图的图层
    [self.view.layer insertSublayer:preview atIndex:0];
    
    //启动会话
    [session startRunning];
    
    self.myPreviewLayer = preview;
    self.mySession = session;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        NSString *netString = metadataObject.stringValue;
        NSData *netData = [netString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *netDictionary = [self toNSArrayOrNSDictionary:netData];
        NSLog(@"ScanQRCode: metadataObjects: %@, metadataObject: %@, netDictionary: %@", metadataObjects, metadataObject, netDictionary);
        
        if ([netDictionary objectForKey:@"meshNetName"] != nil && [netDictionary objectForKey:@"meshNetPassword"] != nil) {
            NSString *name = [netDictionary objectForKey:@"meshNetName"];
            NSString *password = [netDictionary objectForKey:@"meshNetPassword"];

            // 保存数据到数据库
            if (![WSTHomeInfo isExist:name]) {
                WSTHomeInfo *info = [[WSTHomeInfo alloc]init];
                info.homeName = name;
                info.isShare = YES;
                [info insertObject];
            }
            // 如果扫描完成，停止会话
            [self.mySession stopRunning];
          __block WSTNetworkListViewController *vc = self.navigationController.viewControllers[1];
            [self.rt_navigationController popViewControllerAnimated:YES complete:^(BOOL finished) {
                if (finished) {
                    [[NSUserDefaults standardUserDefaults]setObject:name forKey:currentHomeName];
                    [vc findCurrentRow];
                    [[WZBlueToothManager shareInstance]startScanWithLocalName:name andStatus:WZBlueToothScanAndConnectOne];
                }
            }];
            
        } else {
            [SVProgressHUD showErrorWithStatus:LCSTR("QRCode error, Scan the correct QRCode")];
            [self.mySession startRunning];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:LCSTR("QRCode error, Scan the correct QRCode")];
        [self.mySession startRunning];
    }
}

#pragma mark- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self readQRCode];
    imagePickerTimer  = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(scanAnimation:) userInfo:nil repeats:YES];
    [imagePickerTimer fire];
    [self scanAnimation:imagePickerTimer];
    if (info.count > 0) {
        UIImage *srcImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        CIContext *context = [CIContext contextWithOptions:nil];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
        NSArray *features = [detector featuresInImage:image];
        CIQRCodeFeature *feature = [features firstObject];
        NSString *netString = feature.messageString;
        NSData *netData = [netString dataUsingEncoding:NSUTF8StringEncoding];
        
        if (netData) {
            NSDictionary *netDictionary = [self toNSArrayOrNSDictionary:netData];
            NSLog(@"ScanQRCode: features: %@, netString: %@, netDictionary: %@", features, netString, netDictionary);
            
            if ([netDictionary objectForKey:@"meshNetName"] != nil && [netDictionary objectForKey:@"meshNetPassword"] != nil) {
                NSString *name = [netDictionary objectForKey:@"meshNetName"];
                NSString *password = [netDictionary objectForKey:@"meshNetPassword"];

                if (![WSTHomeInfo isExist:name]) {
                   WSTHomeInfo *info = [[WSTHomeInfo alloc]init];
                    info.homeName = name;
                    info.isShare = YES;
                    [info insertObject];
                }
                
                [self.mySession stopRunning];
                __block WSTNetworkListViewController *vc = self.navigationController.viewControllers[1];
                [self.rt_navigationController popViewControllerAnimated:YES complete:^(BOOL finished) {
                    if (finished) {
                        [[NSUserDefaults standardUserDefaults]setObject:name forKey:currentHomeName];
                        [vc findCurrentRow];
                        [[WZBlueToothManager shareInstance]startScanWithLocalName:name andStatus:WZBlueToothScanAndConnectOne];
                    }
                }];
            } else {
                [SVProgressHUD showErrorWithStatus:LCSTR("QRCode error, Scan the correct QRCode")];                [self.mySession startRunning];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:LCSTR("QRCode error, Scan the correct QRCode")];            [self.mySession startRunning];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:LCSTR("QRCode error, Scan the correct QRCode")];        [self.mySession startRunning];
    }
}

#pragma mark - Actions
- (void)rightNavBarAction {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoPicker.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

// 扫描定时
- (void)scanAnimation:(NSTimer *)temp {
    scanLine.frame = CGRectMake(Sp2Pt(3), i, Sp2Pt(300), Sp2Pt(55));
    i >= Sp2Pt(245) ? i = -Sp2Pt(55) : i++;
}

- (id)toNSArrayOrNSDictionary: (NSData *)jsonData {
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (jsonObject != nil && error == nil) {
        return jsonObject;
    } else {
        return nil;
    }
}

// 闪光灯相关
- (void)turnTorchOn: (bool) on {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(CGFloat)heightOfString:(NSString *)string font:(UIFont *)font width:(CGFloat)width {
    CGRect bounds;
    NSDictionary * parameterDict=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    bounds=[string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:parameterDict context:nil];
    return bounds.size.height;
}
@end
