//
//  FaceRecognition.m
//  AutoTagging
//
//  Created by XUDONG LU on 2013-05-03.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import "FaceRecognition.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImageCVMatConverter.h"
#import <opencv2/highgui/highgui.hpp>



#define TRAINING_SIZE 5  // size<=10

@implementation FaceRecognition

{
    NSArray * _faceClassName;
    NSUInteger _trainingDataNumber;
    
}

-(id) initWithParams:(NSString *)TrainingDataPath
{
    self=[super init];
    if (self) {
        NSFileManager *TrainingDataFM=[NSFileManager defaultManager];
        
        // loading class labels
        NSString *labelDir = [NSString stringWithFormat:@"%@/%@", TrainingDataPath, @"Face_List"];
        NSData *tempData= [TrainingDataFM contentsAtPath:labelDir];
        
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSASCIIStringEncoding];
        
        _faceClassName = [tempStr componentsSeparatedByString:@"\n"];
        
        if (_faceClassName) {
            _trainingDataNumber=[_faceClassName count]-1;
        }
    }
    return self;
}


+(NSArray*) faceDetection: (UIImage*) faceImage
{
    // draw a CI image with the previously loaded face detection picture
    CIImage* CIFaceImage = [CIImage imageWithCGImage:faceImage.CGImage];
    
    CIDetector* faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];

    
    NSArray* faceFeatures = [faceDetector featuresInImage:CIFaceImage];
    return faceFeatures;

        
}

-(void) faceRecognitionTraining: (NSString*) TrainingDataPath
{
    vector<Mat> trainingImages;    // load training images
    vector<int> trainingLabels;    // construct training labels
    
    for (int i=0; i<_trainingDataNumber; i++)
    {
        NSLog(@"%@",[_faceClassName objectAtIndex:i]);
        
        for (int j=1; j<TRAINING_SIZE; j++)
        {
            NSString *imgDir = [NSString stringWithFormat:@"%@/%@/%@/%d%@", TrainingDataPath, @"../Face Image Data",[_faceClassName objectAtIndex:i],j,@".pgm"];
            NSLog(@"%d",j);
    
            string *cStringImagePath = new std::string([imgDir UTF8String]);
            Mat faceMatImage = imread(*cStringImagePath, CV_LOAD_IMAGE_GRAYSCALE);
            
            trainingImages.push_back(faceMatImage);
            trainingLabels.push_back(i);
            
        }
    }
    
    
    Ptr<FaceRecognizer> faceRecognitionModel = createEigenFaceRecognizer();
    faceRecognitionModel->train(trainingImages, trainingLabels);
    
    NSString *faceRecognitionModePath = [NSString stringWithFormat:@"%@/%@%@", TrainingDataPath, @"FaceRecognitionMode" , @".xml"];
    
    NSLog(@"%@", faceRecognitionModePath);
    faceRecognitionModel->save([faceRecognitionModePath UTF8String]);
        
}


-(NSString*) faceRecognitionTest: (UIImage*) faceImage at: (NSString*) ModePath
{
    //Mat faceMatImage = [UIImageCVMatConverter cvMatfromUIImage: faceImage];
    

    NSString *faceRecognitionModePath = [NSString stringWithFormat:@"%@/%@", ModePath, @"FaceRecognitionMode.xml"];
    
    FileStorage FaceModeFS([faceRecognitionModePath UTF8String], FileStorage::READ);
        
    Ptr<FaceRecognizer> faceRecognitionModel = createEigenFaceRecognizer();
    
    
    if (FaceModeFS.isOpened()) {
        
        faceRecognitionModel->load(FaceModeFS);
    }
    
    else
    {
        [self faceRecognitionTraining:ModePath];
        faceRecognitionModel->load(FaceModeFS);
    }
     
   // faceRecognitionModel->set("threshold", 0.0);
    
    // test image
    int subIndex = 23;
    int imgIndex = 8;
    NSString *imgDir = [NSString stringWithFormat:@"%@/%@/%@/%d%@", ModePath, @"../Face Image Data",[_faceClassName objectAtIndex:subIndex], imgIndex,@".pgm"];
 
    
    string *cStringImagePath = new std::string([imgDir UTF8String]);
    Mat faceMatImage = imread(*cStringImagePath, CV_LOAD_IMAGE_GRAYSCALE);
    //
    
    
    
    int predictFaceLabel = faceRecognitionModel->predict(faceMatImage);
    NSString * predictFaceName;
    
    if (predictFaceLabel==-1) {
        predictFaceName=@"Unknown Person!";
    }
    
    else{
        predictFaceName=[_faceClassName objectAtIndex:predictFaceLabel-1];
    }
    return predictFaceName;
    
}





@end
