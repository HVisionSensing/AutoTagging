//
//  FaceRecognition.h
//  AutoTagging
//
//  Created by XUDONG LU on 2013-05-03.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import <Foundation/Foundation.h>
using namespace cv;

@interface FaceRecognition : NSObject


-(id) initWithParams: (NSString*) TrainingDataPath;

+(NSArray*) faceDetection: (UIImage*) faceImage;

-(void) faceRecognitionTraining: (NSString*) TrainingDataPath;

-(NSString*) faceRecognitionTest: (UIImage*) faceImage at: (NSString*) ModePath;




@end
