//
//  SceneRecognitionFeatures.m
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-04-02.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import "SceneRecognitionFeatures.h"
#import "UIImageCVMatConverter.h"
#import "opencv2/nonfree/nonfree.hpp"
//#import "opencv2/legacy/compat.hpp"


@implementation SceneRecognitionFeatures

+(Mat) computeBOWFeatures: (UIImage*) CurrentImage
{
    Mat tempMatImage = [UIImageCVMatConverter cvMatfromUIImage: CurrentImage]; // UIImage->CvMat
  
    cv::initModule_nonfree();
    // building feature extractor
    
    Ptr<DescriptorExtractor> SRfeatureExtractor = DescriptorExtractor::create("SIFT");
    Ptr<FeatureDetector> SRfeatureDetector = FeatureDetector::create("SIFT");
    
    
    vector<KeyPoint> DetectedKeypoints;
    
    SRfeatureDetector->detect(tempMatImage, DetectedKeypoints);
    
    //int sizekey = DetectedKeypoints.size();
    
    Mat ExtractedFeature;
    
    SRfeatureExtractor->compute(tempMatImage, DetectedKeypoints, ExtractedFeature);
    
    /*
    NSString* TrainingModePath=@"/Users/lxdppss/Documents/Programming/HelloWorldOpenCV/Scene_Categories";
    NSString *TempPath = [TrainingModePath stringByAppendingPathComponent:@"BSingleFeatures.xml"];
    FileStorage tempFS([TempPath UTF8String], FileStorage::WRITE);
    tempFS<<"BSingleFeatures"<<ExtractedFeature;
     */
    

    
    return ExtractedFeature;
}

+(Mat) computeBOWDescriptors:(UIImage *)CurrentImage with: (Mat) BOWdictionary
{
    Mat tempIPLImage = [UIImageCVMatConverter cvMatfromUIImage: CurrentImage]; // UIImage->CvMat
   
    cv::initModule_nonfree();
    // building feature extractor
    Ptr<DescriptorExtractor> SRfeatureExtractor = DescriptorExtractor::create("SIFT");
    Ptr<FeatureDetector> SRfeatureDetector = FeatureDetector::create("SIFT");
    Ptr<DescriptorMatcher> SRfeatureMatcher = DescriptorMatcher::create("BruteForce");
    
    
    /*
    NSString* TrainingModePath=@"/Users/lxdppss/Documents/Programming/HelloWorldOpenCV/Scene_Categories";
    NSString *TempPath = [TrainingModePath stringByAppendingPathComponent:@"BTempFeatures.xml"];
    FileStorage tempFS([TempPath UTF8String], FileStorage::WRITE);
    tempFS<<"BTempFeatures"<<BOWdictionary;
     */
    
    BOWImgDescriptorExtractor SRBOWDescriptor(SRfeatureExtractor, SRfeatureMatcher);
    SRBOWDescriptor.setVocabulary(BOWdictionary);
    
    vector<KeyPoint> DetectedKeypoints;
    SRfeatureDetector->detect(tempIPLImage, DetectedKeypoints);
    
    Mat BOWdescriptor;
    
    SRBOWDescriptor.compute(tempIPLImage, DetectedKeypoints, BOWdescriptor);

    return BOWdescriptor;
    
}
@end
