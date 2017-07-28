//
//  SecondViewController.m
//  CoreImageDemo
//
//  Created by hehc on 2017/7/27.
//  Copyright © 2017年 hehc. All rights reserved.
//

#import "SecondViewController.h"
#include "cubeMap.c"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *inputFilterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *outputImageView;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    _inputFilterImageView.image = [UIImage imageNamed:@"testPic1"];
    _backgroundImageView.image = [UIImage imageNamed:@"background1"];
}


- (IBAction)cube:(id)sender
{
    CubeMap myCube = createCubeMap(200,240); //CubeMap 参数(float minHueAngle, float maxHueAngle)
 
    
    NSData *myData = [[NSData alloc] initWithBytesNoCopy:myCube.data
                                                  length:myCube.length
                                            freeWhenDone:true];
   
    // CIColorCube滤镜需要一张cube映射表，这张表其实就是张颜色表（3D颜色查找表）
    CIFilter *colorCubeFilter = [CIFilter filterWithName:@"CIColorCube"];
    
    [colorCubeFilter setValue:[NSNumber numberWithFloat:myCube.dimension]
                       forKey:@"inputCubeDimension"];
    [colorCubeFilter setValue:myData
                       forKey:@"inputCubeData"];
    [colorCubeFilter setValue:[CIImage imageWithCGImage:_inputFilterImageView.image.CGImage]
                       forKey:kCIInputImageKey];
    
    CIImage *outputImage = colorCubeFilter.outputImage;
    
    //
    CIFilter *sourceOverCompositingFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [sourceOverCompositingFilter setValue:outputImage
                                   forKey:kCIInputImageKey];
    [sourceOverCompositingFilter setValue:[CIImage imageWithCGImage:_backgroundImageView.image.CGImage]
                                   forKey:kCIInputBackgroundImageKey];
    
    outputImage = sourceOverCompositingFilter.outputImage;
    
    CGImage *cgImage = [[CIContext contextWithOptions: nil] createCGImage:outputImage fromRect:outputImage.extent];
    
    _outputImageView.image = [UIImage imageWithCGImage:cgImage];
}


@end
