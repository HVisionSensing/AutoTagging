//
//  UIImageIPLImageConverter.m
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-03-11.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import "UIImageIPLImageConverter.h"

@implementation UIImageIPLImageConverter

+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image
{
    // Getting CGImage from UIImage
    CGImageRef imageRef = image.CGImage;
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temporal IplImage for drawing
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4);
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData, iplimage->width, iplimage->height,
                                                    iplimage->depth, iplimage->widthStep,
                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
                                                    );
    // Drawing CGImage to CGContext
    CGContextDrawImage(
                       contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef
                       );
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2RGB);
    cvReleaseImage(&iplimage);
    
    return ret;
}


// NOTE You should convert color mode as RGB before passing to this function
+ (UIImage *)UIImageFromIplImage:(IplImage *)image
{
    
    CGColorSpaceRef colorSpace;
    if (image->nChannels!=1) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    else
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }
    // Allocating the buffer for CGImage
    NSData *data =[NSData dataWithBytes:image->imageData length:image->imageSize];
    //CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImage* imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}


@end
