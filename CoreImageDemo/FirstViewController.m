//
//  FirstViewController.m
//  CoreImageDemo
//
//  Created by hehc on 2017/7/27.
//  Copyright © 2017年 hehc. All rights reserved.
//

#import "FirstViewController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
 

@interface FirstViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CIContext   *context;
    CIFilter    *filter;
    CIImage     *beginImage;
    
    UIImageOrientation orientation;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *amountSlider;

@end

@implementation FirstViewController

//创建基于GPU的CIContext对象
//和Core Graphics的CGContext类似但又与之不同，
//CIContext可以被重用，不必每次都新建一个，同时在输出CIImage的时候又必须有一个

- (void)createCIContext
{
    //第一种：创建基于CPU的CIContext对象
    CIContext *cpuContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}];
    
    //第二种：创建基于GPU的CIContext对象
    CIContext *gpuContext = [CIContext contextWithOptions:nil];
    
    //第三种：创建基于OpenGL优化的CIContext对象，需要导入OpenGL ES 框架
    EAGLContext *eaglContent = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    CIContext *glContext = [CIContext contextWithEAGLContext:eaglContent];
    
    /*
     一般采用基于GPU的，因为效率要比CPU高很多，但是要注意的是基于GPU的CIContext对象无法跨应用访问。
     
     默认是创建基于GPU的CIContext对象，不同之处在于GPU的CIContext对象处理起来会更快，而基于CPU的CIContext对象除了支持更大的图像以外，还能在后台处理。
     
     比如你打开UIImagePickerController要选张照片进行美化，如果你直接在UIImagePickerControllerDelegate的委托方法里调用CIContext对象进行处理，那么系统会自动将其降为基于CPU的，速度会变慢，所以正确的方法应该是在委托方法里先把照片保存下来，回到主类里再来处理。
     */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageView.clipsToBounds = YES;
    
    
    _imageView.image = [self imageBlackToTransparent:[self getQRCodeFromString:@"chemanman" size:100] withRed:100 andGreen:1 andBlue:234];
    return;
    // Do any additional setup after loading the view, typically from a nib.
    
    //1. 创建一个CIContext对象
    context = [CIContext contextWithOptions:nil];
    
    //2. 创建一个CIImage对象
    NSString *filePath =[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"];
    beginImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:filePath]];

    
    //3. 创建滤镜，并设置其输入参数
    filter = [CIFilter filterWithName:@"CISepiaTone"]; //创建一个棕榈色滤镜
    [filter setValue:beginImage forKey:kCIInputImageKey];
    [filter setValue:@(0.8) forKey:@"InputIntensity"];
    
    //4. 获得输出图像
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    //5. 渲染CIImage，得到CGImageRef，CGImageRef是可以直接展示或者保存到文件中的
    CGImageRef cgImage = [context createCGImage:result
                                       fromRect:result.extent];
    
    UIImage *outImage = [UIImage imageWithCGImage:cgImage];
    self.imageView.image = outImage;
    
    CGImageRelease(cgImage);
}

- (IBAction)loadPhoto:(id)sender
{
    UIImagePickerController *pickerC =
    [[UIImagePickerController alloc] init];
    pickerC.delegate = self;
    [self presentViewController:pickerC animated:YES completion:nil];
}

- (IBAction)amountSliderValueChanged:(UISlider *)slider
{
    
    NSLog(@"amountSliderValueChanged");
    float slideValue = slider.value;
    
    CIImage *outputImage = [self oldPhoto:beginImage withAmount:slideValue];
    
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *newImage = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:orientation];
    self.imageView.image = newImage;
    
    CGImageRelease(cgImage);
}

//滤镜链
-(CIImage *)oldPhoto:(CIImage *)img withAmount:(float)intensity
{
    //1 棕黑色调
    CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone"];
    [sepia setValue:img forKey:kCIInputImageKey];
    [sepia setValue:@(intensity) forKey:@"inputIntensity"];
    
    //2 生成随机噪点滤镜
    CIFilter *random = [CIFilter filterWithName:@"CIRandomGenerator"];
    
    //3
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:random.outputImage forKey:kCIInputImageKey];
    [lighten setValue:@(1 - intensity) forKey:@"inputBrightness"]; //明亮度,色泽度
    [lighten setValue:@0.0 forKey:@"inputSaturation"]; //饱和
    
    //4 裁剪输出的CIRandomGenerator过滤器，因为它是无限的
    CIImage *croppedImage = [lighten.outputImage imageByCroppingToRect:[beginImage extent]];
    
    //5 强光混合模式
    CIFilter *composite = [CIFilter filterWithName:@"CIHardLightBlendMode"];
    [composite setValue:sepia.outputImage forKey:kCIInputImageKey];
    [composite setValue:croppedImage forKey:kCIInputBackgroundImageKey];
    
    //6 印花
    CIFilter *vignette = [CIFilter filterWithName:@"CIVignette"];
    [vignette setValue:composite.outputImage forKey:kCIInputImageKey];
    [vignette setValue:@(intensity * 2) forKey:@"inputIntensity"];
    [vignette setValue:@(intensity * 30) forKey:@"inputRadius"];
    
    //7 输出
    return vignette.outputImage;
}


#pragma mark -  UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"UIImagePickerController dismissViewControllerAnimated");
    UIImage *gotImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    beginImage = [CIImage imageWithCGImage:gotImage.CGImage];
    orientation = gotImage.imageOrientation;
    [filter setValue:beginImage forKey:kCIInputImageKey];
    [self amountSliderValueChanged:self.amountSlider];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 二维码
/**
 *  根据字符串生成二维码图片
 *
 *  @param code 二维码code
 *  @param size 生成图片大小
 *
 *  @return UIImage
 */
- (UIImage *)getQRCodeFromString:(NSString *)code size:(CGFloat)size
{
    //创建CIFilter 指定filter的名称为CIQRCodeGenerator
    filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //指定二维码的inputMessage,即你要生成二维码的字符串
    [filter setValue:[code dataUsingEncoding:NSUTF8StringEncoding] forKey:@"inputMessage"];
    //输出CIImage
    CIImage *ciImage = [filter outputImage];
    //对CIImage进行处理
    return [self createfNonInterpolatedImageFromCIImage:ciImage withSize:size];
    
}

/**
 *  对CIQRCodeGenerator 生成的CIImage对象进行不插值放大或缩小处理
 *
 *  @param image 原CIImage对象
 *  @param size  处理后的图片大小
 *
 *  @return UIImage
 */
- (UIImage *) createfNonInterpolatedImageFromCIImage:(CIImage *)image withSize:(CGFloat)size
{
    CGRect extent = image.extent;
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t with = scale * CGRectGetWidth(extent);
    size_t height = scale * CGRectGetHeight(extent);
    
    UIGraphicsBeginImageContext(CGSizeMake(with, height));
    CGContextRef bitmapContextRef = UIGraphicsGetCurrentContext();
    
    context = [CIContext contextWithOptions:nil];
    //通过CIContext 将CIImage生成CGImageRef
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    //在对二维码放大或缩小处理时,禁止插值
    CGContextSetInterpolationQuality(bitmapContextRef, kCGInterpolationNone);
    //对二维码进行缩放
    CGContextScaleCTM(bitmapContextRef, scale, scale);
    //将二维码绘制到图片上下文
    CGContextDrawImage(bitmapContextRef, extent, bitmapImage);
    //获得上下文中二维码
    UIImage *retVal =  UIGraphicsGetImageFromCurrentImageContext();
    //释放
    CGImageRelease(bitmapImage);
    CGContextRelease(bitmapContextRef);
    return retVal;
}

void ProviderReleaseData (void *info, const void *data, size_t size) {
    free((void*)data);
}

/**
 *  对图片逐像素进行颜色改变
 *
 *  @param image    原UIImage对象
 *  @param red      红色值
 *  @param green    绿色值
 *  @param blue     蓝色值
 *
 *  @return UIImage
 */

- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue
{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;//每一行的像素点占用的字节数，每个像素点的RGBA四个通道各占8bit空间
    uint32_t *rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight); //整张图片占用的字节数,分配足够容纳图片字节数的内存空间
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); //创建依赖设备的RGB通道
    
    /*
     data           指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
     width          bitmap的宽度,单位为像素
     height         bitmap的高度,单位为像素
     bitsPerComponent 内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
     bytesPerRow    bitmap的每一行在内存所占的比特数
     colorspace     bitmap上下文使用的颜色空间。
     bitmapInfo     指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
     */
    
    //创建CoreGraphic的图形上下文 该上下文描述了bitmaData指向的内存空间需要绘制的图像的一些绘制参数
    CGContextRef contextRef = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) == 0xFFFFFF00)    // 将白色变成透明
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
        else
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
    }
    
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

@end

