//
//  SceneRecognitionTraining.m
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-03-27.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import "SceneRecognitionTraining.h"
#import "SceneRecognitionFeatures.h"


#define DICTIONARY_SIZE 1000
#define TRAINING_SIZE 100


@implementation SceneRecognitionTraining
{
    NSArray * _sceneClassLabel;
    NSUInteger _trainingClassNumber;

}


-(id) initWithParams: (NSString*) TrainingFileDir
{
    self=[super init];
    if (self) {
        NSFileManager *TrainingDataFM=[NSFileManager defaultManager];
        
        // loading class labels
        NSString *labelDir = [NSString stringWithFormat:@"%@/%@", TrainingFileDir, @"Category_Names"];
        NSData *tempData= [TrainingDataFM contentsAtPath:labelDir];
        
        NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSASCIIStringEncoding];
        
        _sceneClassLabel = [tempStr componentsSeparatedByString:@"\n"];
        
        if (_sceneClassLabel) {
            _trainingClassNumber=[_sceneClassLabel count]-1;
        }        
    }
    return self;
}




-(BOOL) LoadTrainingData: (NSString*) TrainingFileDir
{
    if (!TrainingFileDir) {
        return NO;
    }
    
    NSFileManager *TrainingDataFM=[NSFileManager defaultManager];

    // loading class label
    NSString *labelDir = [NSString stringWithFormat:@"%@/%@/%@", TrainingFileDir, @"../TrainingMode",@"Category_Names"];
    NSData *tempData= [TrainingDataFM contentsAtPath:labelDir];
    
    NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSASCIIStringEncoding];
    
    _sceneClassLabel = [tempStr componentsSeparatedByString:@"\n"];
    
    if (_sceneClassLabel) {
        _trainingClassNumber=[_sceneClassLabel count]-1;
    }
    else{
        _trainingClassNumber=0;
        return NO;
    }
    
    //For Progress Check
    NSLog(@"loading class labels is done");
    
    // Constructing BOW
    TermCriteria tc(CV_TERMCRIT_ITER+CV_TERMCRIT_EPS, 20, 0.001);
    int retries=1;
    int flags=KMEANS_PP_CENTERS;
    
    BOWKMeansTrainer SRBOWTrainer(DICTIONARY_SIZE, tc, retries, flags);
    
    // loading image data, calculate features, building BOW and store

    for (int i=0; i<_trainingClassNumber; i++) {
        NSLog(@"%@",[_sceneClassLabel objectAtIndex:i]);
        for (int j=1; j<TRAINING_SIZE; j++) {
            NSString *imgDir = [NSString stringWithFormat:@"%@/%@/%@/%@%04d%@", TrainingFileDir, @"../ImageData",[_sceneClassLabel objectAtIndex:i], @"image_",j,@".jpg"];
            NSLog(@"%d",j);
            UIImage *tempImg=[UIImage imageWithContentsOfFile:imgDir];
            Mat imgFeatures =[SceneRecognitionFeatures computeBOWFeatures:tempImg];
        
            //imgFeatures.convertTo(imgFeatures, CV_32F);
            SRBOWTrainer.add(imgFeatures);
            
        }
    }
    
    Mat SRDictionary = SRBOWTrainer.cluster();
    
    //For Progress Check
    NSLog(@"BOW dictionary is done");
    
    // save word dictionary
    
       // using opencv filestorage method
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *docs = [paths objectAtIndex:0];
    //NSString *BOWVolPath = [docs stringByAppendingPathComponent:@"BOW_Vocabulary.yml"];
    //NSString *BOWVolPath = [TrainingFileDir stringByAppendingPathComponent:@"BOW_Vocabulary.xml"];
    NSString *BOWVolPath = [NSString stringWithFormat:@"%@/%@/%@", TrainingFileDir,@"../TrainingMode", @"BOW_Vocabulary.xml"];
    FileStorage tempFS([BOWVolPath UTF8String], FileStorage::WRITE);
    tempFS<<"BOW_Vocabulary"<<SRDictionary;
    //tempFS.release();
     
    //For Progress Check
    NSLog(@"saving BOW dictionary is done");
    
    return YES;
}

-(BOOL) TrainingClassifier: (NSString*) TrainingFileDir
{
    // load word dictionary
    
    // /*filestorage in opencv
    
    //NSString *BOWVolPath = [TrainingFileDir stringByAppendingPathComponent:@"BOW_Vocabulary.xml"];
    NSString *BOWVolPath = [NSString stringWithFormat:@"%@/%@/%@", TrainingFileDir,@"../TrainingMode", @"BOW_Vocabulary.xml"];
    FileStorage tempFS([BOWVolPath UTF8String], FileStorage::READ);
    
    if (!tempFS.isOpened()) {
        return NO;
    }
    
    Mat SRDictionary;
    tempFS["BOW_Vocabulary"]>>SRDictionary;
    
    //For Progress Check
    NSLog(@"loading BOW dictionary is done");
    
    
    // construct TrainingData and Labels;
    // 1-vs-all SVM tranining
    
    Mat TrainingData(0, SRDictionary.cols, SRDictionary.type());

    
    for (int i=0; i<_trainingClassNumber; i++) {
        for (int j=1; j<=TRAINING_SIZE; j++) {
            NSString *imgDir = [NSString stringWithFormat:@"%@/%@/%@/%@%04d%@", TrainingFileDir,@"../ImageData",[_sceneClassLabel objectAtIndex:i], @"image_",j,@".jpg"];
            
            UIImage *tempImg=[UIImage imageWithContentsOfFile:imgDir];
            Mat imgFeatures =[SceneRecognitionFeatures computeBOWDescriptors:tempImg with:SRDictionary];
            TrainingData.push_back(imgFeatures);
        }
    }
    
    
   // Training Data Normalization
   //Mat NormalizedTrainingData;
   //normalize(TrainingData, NormalizedTrainingData, -1, 1, NORM_L1, -1, Mat());
   //TrainingData=NormalizedTrainingData;

    
    
    //For Progress CheckimgFeatures.convertTo(imgFeatures, CV_32F);
    NSLog(@"Training data preparation is done");
     
    
    
    // Set up SVM's parameters
    /* // SVM classification
    CvSVMParams params;
    params.svm_type    = CvSVM::NU_SVC;
    params.kernel_type = CvSVM::RBF;
    params.gamma=1;
    params.nu=0.4;
    params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 5000, 0.00001);
    */
    
    // Option: SVM Regression
    CvSVMParams params;
    params.svm_type    = CvSVM::NU_SVC;
    params.kernel_type = CvSVM::RBF;
    params.C = 10000;
    //params.gamma=50;
    params.nu=0.05;
    params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 5000, 0.0001);
    
    // Train SVM model
    
    int TrainingCount=0;
    
    for (int i=0; i<_trainingClassNumber; i++)
    {
        Mat TrainingDataLabels(0, 1, CV_32FC1);
        for (int j=0; j<_trainingClassNumber; j++)
        {
            for (int k=0; k<TRAINING_SIZE; k++) {
                if (i==j) {
                    TrainingDataLabels.push_back(1);
                }
                else
                    TrainingDataLabels.push_back(0);
            }
        }
    
        CvSVM SRSVM;
        
        if(SRSVM.train(TrainingData, TrainingDataLabels, Mat(), Mat(), params))
        {
            NSString *SVMDir = [NSString stringWithFormat:@"%@/%@/%@%@", TrainingFileDir,@"../TrainingMode",[_sceneClassLabel objectAtIndex:i], @".xml"];
            SRSVM.save([SVMDir UTF8String]);
            TrainingCount++;
        }
    }
    
    //For Progress Check
    NSLog(@"SVM training is done");
    
    //NSString *BOWVolPath = [NSString stringWithFormat:@"%@/%@/%@", TrainingFileDir,@"TrainingMode", @"BOW_Vocabulary.xml"];
    //NSString *SVMClassifierPath = [TrainingFileDir stringByAppendingPathComponent:@"SVM_Classifiers.xml"];
    NSString *SVMClassifierPath =[NSString stringWithFormat:@"%@/%@/%@", TrainingFileDir, @"../TrainingMode", @"SVM_Classifiers.xml"];
    tempFS.open([SVMClassifierPath UTF8String], FileStorage::WRITE);
    BOOL SVMClassifiersExist=YES;
    tempFS<<"SVM_Classifiers"<<SVMClassifiersExist;
    NSLog(@"saving SVM model is done");
        
    return YES;
 
    
}

/*

-(NSString*) TestClassifier:(UIImage *)TestImage at:(NSString *)TrainingFileDir
{
    
    // load word dictionary
    
    /// opencv filestorage
    NSString *BOWVolPath = [TrainingFileDir stringByAppendingPathComponent:@"BOW_Vocabulary.xml"];
    
    FileStorage VolFS([BOWVolPath UTF8String], FileStorage::READ);
    
    if (!VolFS.isOpened()) {
        return NO;
    }
    
    Mat SRDictionary;
    VolFS["BOW_Vocabulary"]>>SRDictionary;
    
    
    Mat imgFeatures =[SceneRecognitionFeatures computeBOWDescriptors:TestImage with:SRDictionary];
    
    
   // Mat TempTestData=Mat::zeros(imgFeatures.size(),imgFeatures.type());
   // scaleAdd(imgFeatures, 10000, TempTestData, imgFeatures);
   
 
   //  NSString *TempPath = [TrainingFileDir stringByAppendingPathComponent:@"TestFeatures.xml"];
   //  FileStorage tempFS([TempPath UTF8String], FileStorage::WRITE);
   //  tempFS<<"TestFeatures"<<imgFeatures;
     
 
 

    
    double maxClassifierResponse=0;
    NSString *SceneCategory;
    for (int i=0; i<_trainingClassNumber; i++)
    {
        CvSVM SRSVM;
        NSString *SVMDir = [NSString stringWithFormat:@"%@/%@%@", TrainingFileDir,[_sceneClassLabel objectAtIndex:i], @".xml"];
        SRSVM.load([SVMDir UTF8String]);
        
        double classifierResponse = SRSVM.predict(imgFeatures);
        if (classifierResponse>maxClassifierResponse) {
            maxClassifierResponse=classifierResponse;
            SceneCategory=[_sceneClassLabel objectAtIndex:i];
        
        }
        
    }
    

return SceneCategory;
    
}
*/


-(NSArray*) CreateTagsForImage: (UIImage*) TestImage numOfRequestedTags:(NSInteger)num trainingPath:(NSString*) TrainingFileDir
{
    // load word dictionary
    
    // opencv filestorage
    //NSString *BOWVolPath = [TrainingFileDir stringByAppendingPathComponent:@"BOW_Vocabulary.xml"];
    
    NSString *BOWVolPath = [NSString stringWithFormat:@"%@/%@", TrainingFileDir, @"BOW_Vocabulary.xml"];
    
    FileStorage VolFS([BOWVolPath UTF8String], FileStorage::READ);
    
    if (!VolFS.isOpened()) {
        return NO;
    }
    
    Mat SRDictionary;
    VolFS["BOW_Vocabulary"]>>SRDictionary;
    VolFS.release();

        
    
    Mat imgFeatures =[SceneRecognitionFeatures computeBOWDescriptors:TestImage with:SRDictionary];
    
 
    Mat CategoryResponse(0, 1, CV_32FC1);
    
   
    for (int i=0; i<_trainingClassNumber; i++)
    {
        CvSVM SRSVM;
        NSString *SVMDir = [NSString stringWithFormat:@"%@/%@%@", TrainingFileDir, [_sceneClassLabel objectAtIndex:i], @".xml"];
        SRSVM.load([SVMDir UTF8String]);
        
        double classifierResponse=0;
        classifierResponse=SRSVM.predict(imgFeatures, TRUE);
        CategoryResponse.push_back(classifierResponse);        
    }
    
    Mat SortedCategoryResponse;
    sortIdx(CategoryResponse, SortedCategoryResponse, CV_SORT_EVERY_COLUMN + CV_SORT_ASCENDING);

    NSMutableArray *ScenesCategoryDetected=[[NSMutableArray alloc] init];
    for (int i=0; i<num; i++) {
        [ScenesCategoryDetected addObject:[_sceneClassLabel objectAtIndex:SortedCategoryResponse.at<int>(i)]];
    }

    
    NSArray *FinalScenesDetection = [NSArray arrayWithArray:ScenesCategoryDetected];
    
    /*
    CvSize hh= CategoryResponse.size();
    for (int i=0; i<hh.height; i++) {
        NSLog(@"%f", CategoryResponse.at<double>(i));
    }
    */

    
    return FinalScenesDetection;
    
    
}




-(BOOL) BOWDictionaryExisting:(NSString *)TrainingFileDir
{
    NSFileManager *tempFM = [NSFileManager defaultManager];
    //NSString *BOWDictionaryPath = [TrainingFileDir stringByAppendingPathComponent:@"BOW_Vocabulary.xml"];
    NSString *BOWDictionaryPath = [NSString stringWithFormat:@"%@/%@/%@", TrainingFileDir,@"../TrainingMode", @"BOW_Vocabulary.xml"];
    BOOL BOWDictExist = [tempFM fileExistsAtPath:BOWDictionaryPath];
    return BOWDictExist;
    
}


-(BOOL) TrainingModeExisting:(NSString *)TrainingFileDir
{
    NSFileManager *tempFM = [NSFileManager defaultManager];
    //NSString *SVMClassifiersPath = [TrainingFileDir stringByAppendingPathComponent:@"SVM_Classifiers.xml"];
    NSString *SVMClassifiersPath =[NSString stringWithFormat:@"%@/%@/%@", TrainingFileDir, @"../TrainingMode", @"SVM_Classifiers.xml"];
    BOOL SVMClassifiersExist = [tempFM fileExistsAtPath:SVMClassifiersPath];
    return SVMClassifiersExist;
}


@end
