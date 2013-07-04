//
//  UIImageCVMatConverter.m
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-03-11.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import "UIImageCVMatConverter.h"

@implementation UIImageCVMatConverter

+ (cv::Mat) cvMatfromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    
    int num = CGColorSpaceGetNumberOfComponents(colorSpace);
    if (num<3) {
        cv::Mat cvMatrix(rows, cols, CV_8UC1);
        CGContextRef contextRef = CGBitmapContextCreate(cvMatrix.data,                 // Pointer to backing data
                                                        cols,                       // Width of bitmap
                                                        rows,                       // Height of bitmap
                                                        8,                          // Bits per component
                                                        cvMatrix.step[0],              // Bytes per row
                                                        colorSpace,                 // Colorspace
                                                        kCGImageAlphaNone |
                                                        kCGBitmapByteOrderDefault); // Bitmap info flags
        
        CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
        CGContextRelease(contextRef);
        
        
        return cvMatrix;

    }
    
    else
    {
     
        cv::Mat cvMatrix(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    
        CGContextRef contextRef = CGBitmapContextCreate(cvMatrix.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMatrix.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
        CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
        CGContextRelease(contextRef);
    
    

    
        return cvMatrix;
   }
    
    
}



+ (UIImage *)UIImageFromcvMat:(cv::Mat&) cvMatrix
{
    NSData *data = [NSData dataWithBytes:cvMatrix.data length:cvMatrix.elemSize() * cvMatrix.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMatrix.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMatrix.cols,                                     // Width
                                        cvMatrix.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMatrix.elemSize(),                           // Bits per pixel
                                        cvMatrix.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
    
}

@end
