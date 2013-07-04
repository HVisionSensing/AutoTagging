//
//  SceneRecognitionTraining.h
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-03-27.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import <Foundation/Foundation.h>
using namespace cv;


@interface SceneRecognitionTraining : NSObject




-(id) initWithParams: (NSString*) TrainingFileDir;
-(BOOL) LoadTrainingData: (NSString*) TrainingFileDir;
-(BOOL) TrainingClassifier: (NSString*) TrainingFileDir;
-(NSArray*) CreateTagsForImage: (UIImage*) TestImage numOfRequestedTags:(NSInteger)num trainingPath:(NSString*) TrainingFileDir;
-(BOOL) TrainingModeExisting: (NSString*) TrainingFileDir;
-(BOOL) BOWDictionaryExisting:(NSString *)TrainingFileDir;




@end
