//
//  UIImageCVMatConverter.h
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-03-11.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImageCVMatConverter : NSObject


+ (cv::Mat) cvMatfromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromcvMat:(cv::Mat&)image;

@end
