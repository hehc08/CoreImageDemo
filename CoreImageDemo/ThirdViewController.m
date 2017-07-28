//
//  ThirdViewController.m
//  CoreImageDemo
//
//  Created by hehc on 2017/7/27.
//  Copyright © 2017年 hehc. All rights reserved.
//

#import "ThirdViewController.h"

#define MainFrame [UIScreen mainScreen].bounds

@interface ThirdViewController ()
{
    UIImage     *inputImg_;
}

@property (nonatomic, weak) IBOutlet UIImageView *inputImgView;
@property (nonatomic, weak) IBOutlet UILabel *recognitionFacesNumLabel;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _inputImgView.clipsToBounds = YES;
    _inputImgView.tag = 100;
    inputImg_ = [UIImage imageNamed:@"faces1.jpg"];
    [self setImageView];
}

- (void)setImageView
{
    [_inputImgView setFrame:CGRectMake(40, 60, inputImg_.size.width,inputImg_.size.height)];
    [_inputImgView setImage:inputImg_];
}

- (IBAction)stepAction:(UIStepper *)sender
{
    inputImg_ = [UIImage imageNamed:[NSString stringWithFormat:@"faces%d.jpg",(int)sender.value]];
    [self setImageView];
    
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 99) {
            [obj removeFromSuperview];
        }
        
        if ([obj isKindOfClass:[UIImageView class]] && obj.tag != 100) {
            [obj removeFromSuperview];
        }
    }];
}

//------------------------------------------------------------------------------------------
/**
 *  人脸识别综合示例代码（包括人脸图片提取、人脸个数、人脸定位）
 */
-(IBAction)recognitionFaces:(id)sender
{
    // 创建图形上下文
    CIContext * context = [CIContext contextWithOptions:nil];
    
    // 创建自定义参数字典,设置识别精度CIDetectorAccuracy
    // 除了精度的设置，还有CIDetectorTracking，指定使用特种跟踪，这个功能就像相机中的人脸跟踪功能
    NSDictionary * param = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh
                                                       forKey:CIDetectorAccuracy];
    // 创建识别器对象
    /*
     CIDetectorTypeFace         NS_AVAILABLE(10_7, 5_0);    // 人脸识别探测器类型
     CIDetectorTypeRectangle    NS_AVAILABLE(10_10, 8_0);   // 矩形检测探测器类型
     CIDetectorTypeQRCode       NS_AVAILABLE(10_10, 8_0);   // 条码检测探测器类型
     CIDetectorTypeText         NS_AVAILABLE(10_11, 9_0)    // 文本检测探测器类型
     */
    CIDetector * faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                   context:context
                                                   options:param];
    
    
    CIImage * inputCIImage = [CIImage imageWithCGImage:[_inputImgView image].CGImage];
    NSArray * detectResult = [faceDetector featuresInImage:inputCIImage];
    
    
    UIView * resultView = [[UIView alloc] initWithFrame:_inputImgView.frame];
    [resultView setTag:99];
    [self.view addSubview:resultView];
    
    // 标出脸部,眼睛和嘴
    for (CIFaceFeature * faceFeature in detectResult) {
        UIView *faceView = [[UIView alloc] initWithFrame:faceFeature.bounds];
        faceView.layer.borderColor = [UIColor redColor].CGColor;
        faceView.layer.borderWidth = 1;
        [resultView addSubview:faceView];
        
        // 标出左眼
        if (faceFeature.hasLeftEyePosition) {
            UIView * leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
            [leftEyeView setCenter:faceFeature.leftEyePosition];
            leftEyeView.layer.borderWidth = 1;
            leftEyeView.layer.borderColor = [UIColor redColor].CGColor;
            [resultView addSubview:leftEyeView];
        }
        
        // 标出右眼
        if (faceFeature.hasRightEyePosition) {
            UIView * rightEyeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
            [rightEyeView setCenter:faceFeature.rightEyePosition];
            rightEyeView.layer.borderWidth = 1;
            rightEyeView.layer.borderColor = [UIColor redColor].CGColor;
            [resultView addSubview:rightEyeView];
        }
        
        // 标出嘴部
        if (faceFeature.hasMouthPosition) {
            UIView * mouthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 5)];
            [mouthView setCenter:faceFeature.mouthPosition];
            mouthView.layer.borderWidth = 1;
            mouthView.layer.borderColor = [UIColor redColor].CGColor;
            [resultView addSubview:mouthView];
        }
    }
    
    [resultView setTransform:CGAffineTransformMakeScale(1, -1)];
    
    for (int i = 0; i< detectResult.count; i++) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5+105*i, 350, 100, 100)];
        CIImage * faceImage = [inputCIImage imageByCroppingToRect:[[detectResult objectAtIndex:i] bounds]];
        [imageView setImage:[UIImage imageWithCIImage:faceImage]];
        [self.view addSubview:imageView];
    }
    
    if ([detectResult count] > 0) {
        _recognitionFacesNumLabel.text = [NSString stringWithFormat:@"人脸数：%lu",(unsigned long)detectResult.count];
    }
    
}

@end
