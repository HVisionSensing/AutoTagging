//
//  SceneRecognitionFeatures.h
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-04-02.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import <Foundation/Foundation.h>
using namespace cv;

@interface SceneRecognitionFeatures : NSObject


+(Mat) computeBOWFeatures: (UIImage*) CurrentImage;

+(Mat) computeBOWDescriptors: (UIImage*) CurrentImage with: (Mat) BOWdictionary;
@end
