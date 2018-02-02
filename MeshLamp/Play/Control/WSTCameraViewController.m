//
//  WSTCameraViewController.m
//  MeshLamp
//
//  Created by 微智电子 on 2017/10/13.
//  Copyright © 2017年 make. All rights reserved.
//

#import "WSTCameraViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface WSTCameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession    *session;
    CALayer             *imageLayer;
    NSMutableArray      *points;
    int                 fraHight;
    NSString            *coloString;
}

@end

@implementation WSTCameraViewController
@synthesize isRoom, devAddr;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationStyle];
    // View
    [self loadMainView];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [session commitConfiguration];
    [session startRunning];
}
- (void)setNavigationStyle{
    [self setNavigationTitle:LCSTR("camera_color") titleColor:[UIColor whiteColor]];
     [self setLeftButtonImage:[UIImage imageNamed:@"nav_bar_icon_back"]];
}
#pragma mark - View
- (void)loadMainView {
    
    
    imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    imageLayer.contentsGravity = kCAGravityResizeAspectFill;
    [self.view.layer addSublayer:imageLayer];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake((Width(imageLayer)-Sp2Pt(116))/2, (Height(imageLayer)-Sp2Pt(116))/2, Sp2Pt(116), Sp2Pt(116));
    [imageView setImage:[UIImage imageNamed:@"CameraFocus"]];
    [self.view addSubview:imageView];
//    [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        center
//    }];
    
    [self performSelector:@selector(setupAVCapture) withObject:self afterDelay:1.0];
}

- (void)setupAVCapture {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device isTorchModeSupported:AVCaptureTorchModeOn]) {
        [device lockForConfiguration:nil];
        device.torchMode=AVCaptureTorchModeOff;
        [device setTorchMode:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
    // Create the AVCapture Session
    session = [AVCaptureSession new];
    [session beginConfiguration];
    // Create a AVCaptureDeviceInput with the camera device
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error %d", (int)[error code]]
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        //[self teardownAVCapture];
        return;
    }
    
    if ([session canAddInput:deviceInput])
        [session addInput:deviceInput];
    
    // AVCaptureVideoDataOutput
    AVCaptureVideoDataOutput *videoDataOutput = [AVCaptureVideoDataOutput new];
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                       [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [videoDataOutput setVideoSettings:rgbOutputSettings];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    dispatch_queue_t videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ([session canAddOutput:videoDataOutput])
        [session addOutput:videoDataOutput];
    
    AVCaptureDevice *avcap = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSArray * adfs = avcap.formats;
    double maxFps = 0;
    AVCaptureDeviceFormat * acCapDevFormat = nil;
    for (AVCaptureDeviceFormat * adf in adfs) {
        NSArray * rangs = adf.videoSupportedFrameRateRanges;
        for (AVFrameRateRange * arr in rangs) {
            if (arr.maxFrameRate > maxFps) {
                acCapDevFormat = adf;
                maxFps = arr.maxFrameRate;
            }
        }
    }
    
    // avcap.activeVideoMinFrameDuration = CMTimeMake(1, 20);
    if ([avcap lockForConfiguration:&error]) {
        avcap.activeFormat = acCapDevFormat;
        avcap.activeVideoMinFrameDuration = CMTimeMake(1, maxFps * 0.9);
        avcap.activeVideoMaxFrameDuration = CMTimeMake(1, maxFps);
        [avcap unlockForConfiguration];
    } else
        avcap.activeVideoMinFrameDuration = CMTimeMake(1, 20.0);
    
    AVCaptureConnection* connection = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    [session commitConfiguration];
    [session startRunning];
}

static int capTimes = 0;
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (++capTimes < 3) return;
    capTimes = 0;
    
    double start = [[NSDate date] timeIntervalSince1970];
    
    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    //    uint8_t *buf = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    id renderedImage = CFBridgingRelease(quartzImage);
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [CATransaction setDisableActions:YES];
        [CATransaction begin];
        imageLayer.contents = renderedImage;
        [CATransaction commit];
    });
    NSString *color = [self colorAtPixel:CGPointMake(imageLayer.frame.size.width/2, imageLayer.frame.size.height/2) ImageView:quartzImage];
    coloString = [NSString stringWithFormat:@"%@",color];
    NSArray *aaa = [color componentsSeparatedByString:@","];
    
    CGFloat h, s, b, a;
    UIColor * c = [UIColor colorWithRed:[aaa[0] floatValue] green:[aaa[1] floatValue] blue:[aaa[2] floatValue] alpha:1.0f];
    [c getHue:&h saturation:&s brightness:&b alpha:&a];
    c = [UIColor colorWithHue: h saturation: 0.3 + s brightness:b alpha:a];
    CGFloat R, G, B;
    [c getRed:&R green:&G blue:&B alpha:&a];
    
    [[WZBlueToothDataManager shareInstance]setRGBWCWithAddress:(uint32_t)devAddr isGroup:isRoom WithRed:R Green:G Blue:B Warm:0 Cold:0 Lum:1 Delay:0];
    
    double end = [[NSDate date] timeIntervalSince1970];
    NSLog(@"CAMERA processed: %f", (end - start) * 1000.0);
}

- (NSString *)colorAtPixel:(CGPoint)point ImageView:(CGImageRef)imageV {
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    
    CGImageRef cgImage = imageV;
    NSUInteger width = point.x*2;
    NSUInteger height = point.y*2;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 
                                                 1,
                                                 
                                                 1,
                                                 
                                                 bitsPerComponent,
                                                 
                                                 bytesPerRow,
                                                 
                                                 colorSpace,
                                                 
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    NSString *string = [NSString stringWithFormat:@"%f,%f,%f,%f",red,green,blue,alpha];
    
    return string;
}

void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v ) {
    float min, max, delta;
    min = MIN( r, MIN(g, b ));
    max = MAX( r, MAX(g, b ));
    *v = max;
    delta = max - min;
    if( max != 0 )
        *s = delta / max;
    else {
        *s = 0;
        *h = -1;
        return;
    }
    if( r == max )
        *h = ( g - b ) / delta;
    else if( g == max )
        *h = 2 + (b - r) / delta;
    else
        *h = 4 + (r - g) / delta;
    *h *= 60;
    if( *h < 0 )
        *h += 360;
}

#pragma mark - Action

- (void)addButtonClick:(id)sender {
    UIButton *butt = (UIButton*)sender;
    switch (butt.tag) {
        case 201:
        {
            [session commitConfiguration];
            [session startRunning];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 202:
        {
            float h,s,v;
            NSArray *ddd = [coloString componentsSeparatedByString:@","];
            RGBtoHSV([[ddd objectAtIndex:0] floatValue], [[ddd objectAtIndex:0] floatValue], [[ddd objectAtIndex:0] floatValue], &h, &s, &v);
            
            NSMutableArray *bbb =  [[NSUserDefaults standardUserDefaults] objectForKey:@"ownPaopaoColors"];
            NSMutableArray *tempARR = [NSMutableArray arrayWithArray:bbb];
            
            NSString *stringHes = [NSString stringWithFormat:@"%f",h];
            NSString *stringbri = [NSString stringWithFormat:@"%f",s];
            NSArray *aaa = [NSArray arrayWithObjects:stringHes,@"1",stringbri, nil];
            [tempARR addObject:aaa];
            
            if (tempARR.count > 0)
                [tempARR removeObjectAtIndex:0];
            [[NSUserDefaults standardUserDefaults] setObject:tempARR forKey:@"ownPaopaoColors"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
