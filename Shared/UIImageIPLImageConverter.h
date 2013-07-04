//
//  UIImageIPLImageConverter.h
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-03-11.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface UIImageIPLImageConverter : NSObject

+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromIplImage:(IplImage *)image;


@end
