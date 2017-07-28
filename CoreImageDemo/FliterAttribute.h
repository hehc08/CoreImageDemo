
/* fliter.attributes
  
  "CIAttributeFilterAvailable_Mac" = "10.4";
  "CIAttributeFilterAvailable_iOS" = 5;
  CIAttributeFilterCategories =     ( //滤镜所示种类，通常一个滤镜可以属于几种
    CICategoryColorEffect,
    CICategoryVideo,
    CICategoryInterlaced,
    CICategoryNonSquarePixels,
    CICategoryStillImage,
    CICategoryBuiltIn,
    CICategoryXMPSerializable
  );
  
  CIAttributeFilterDisplayName = "Sepia Tone";  //滤镜的名称，通过该名称来调用滤镜
  CIAttributeFilterName = CISepiaTone;
  CIAttributeReferenceDocumentation = "http://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CISepiaTone";
  
  inputImage =     {   //滤镜使用需要输入的参数
    CIAttributeClass = CIImage; //参数类型为CIImage
    CIAttributeDescription = "The image to use as an input image. For filters that also use a background image, this is the foreground image.";
    CIAttributeDisplayName = Image;
    CIAttributeType = CIAttributeTypeImage;
  };
  
  inputIntensity =     { //输入强度,参数的名称
    CIAttributeClass = NSNumber;
    CIAttributeDefault = 1;
    CIAttributeDescription = "The intensity of the sepia effect. A value of 1.0 creates a monochrome sepia image. A     value of 0.0 has no effect on the image.";
    CIAttributeDisplayName = Intensity;
    CIAttributeIdentity = 0;
    CIAttributeMin = 0;
    CIAttributeSliderMax = 1;
    CIAttributeSliderMin = 0;
    CIAttributeType = CIAttributeTypeScalar;
  };

 
 
*/
