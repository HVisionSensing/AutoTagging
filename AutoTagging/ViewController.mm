//
//  ViewController.m
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-03-11.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import "ViewController.h"
#import "UIImageIPLImageConverter.h"
#import "SceneRecognitionTraining.h"
#import "UIImageCVMatConverter.h"
#import "FaceRecognition.h"
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end


@implementation ViewController

@synthesize imageView;
@synthesize loadButton, imgProcButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSString* filename = [[NSBundle mainBundle] pathForResource:@"Liboiron" ofType:@"jpg"];
    UIImage* tempImage = [UIImage imageWithContentsOfFile:filename];
    
    if (tempImage !=nil)
    {
        //IplImage* tempIPLImage = [UIImageIPLImageConverter CreateIplImageFromUIImage: tempImage];
        
        //tempImage = [UIImageIPLImageConverter UIImageFromIplImage: tempIPLImage];
        
        //imageView.image=tempImage;
        
        
        Mat tempCvMat = [UIImageCVMatConverter cvMatfromUIImage:tempImage];
        tempImage = [UIImageCVMatConverter UIImageFromcvMat:tempCvMat];
        imageView.image=tempImage;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    // dismissModelViewControllerAnimated is deprecated by ios 6, use the above instead 
    UIImage *temp = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    imageView.image = temp;}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil]; }


- (IBAction)loadButtonPressed:(id)sender {
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary])
        return;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
    
    for(UIView *subview in [imageView subviews]) {
        [subview removeFromSuperview];
    }
    
}

- (IBAction)procButtonPressed:(id)sender {
    IplImage* tempIPLImage = [UIImageIPLImageConverter CreateIplImageFromUIImage: imageView.image];
    
    IplImage* procIPLImage = cvCreateImage(cvGetSize(tempIPLImage), IPL_DEPTH_8U, 1);
    
    // Converting color image to gray image
    cvCvtColor(tempIPLImage,procIPLImage,CV_RGB2GRAY);
    // image smoothing
    cvSmooth(procIPLImage, procIPLImage, CV_GAUSSIAN);
    // edge detection
    cvCanny(procIPLImage, procIPLImage, 0, 50);
    
    
    imageView.image=[UIImageIPLImageConverter UIImageFromIplImage: procIPLImage];
    cvReleaseImage(&procIPLImage);
}

- (IBAction)recogButtonPressed:(id)sender {
    
    NSString* TrainingModePath=@"/Users/jiannanzheng/Desktop/Pantoscope/lib/AutoTagging/Scene_Categories/TrainingMode";
    SceneRecognitionTraining* SceneRecMode= [[SceneRecognitionTraining alloc] initWithParams:TrainingModePath];
    NSInteger num = 3;
    
    //UIImage* testImage=[UIImage imageWithCGImage:imageView.image.CGImage];
    
    
    BOOL BOWDictionaryLabel = [SceneRecMode BOWDictionaryExisting:TrainingModePath];
    BOOL ClassifiersLabel = [SceneRecMode TrainingModeExisting:TrainingModePath];
    	
    if (BOWDictionaryLabel==NO) {
        BOWDictionaryLabel=[SceneRecMode LoadTrainingData:TrainingModePath];
        NSLog(@"Load Training Data is done");
    }
    
    if (ClassifiersLabel==NO) {
        ClassifiersLabel=[SceneRecMode TrainingClassifier:TrainingModePath];
        NSLog(@"Training classifier is done");
    }
    
    if (BOWDictionaryLabel && ClassifiersLabel) {
        //NSString* SceneCategory=[SceneRecMode TestClassifier:imageView.image at:TrainingModePath];
        NSArray *SceneCategories=[SceneRecMode CreateTagsForImage:imageView.image numOfRequestedTags:num trainingPath:TrainingModePath];
        
        for (int i=0; i<num; i++) {
            NSLog(@"%@",[SceneCategories objectAtIndex:i]);
        }
        
        
        /*
        if (SceneCategory!=nil) {
            UIAlertView *SceneRecogResult = [[UIAlertView alloc] initWithTitle: @"Scene Recognition Category" message:SceneCategory delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [SceneRecogResult show];
        }
        else
        {
            UIAlertView *SceneRecogResult = [[UIAlertView alloc] initWithTitle: @"Scene Recognition Category" message:@"Detection Failed" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
            [SceneRecogResult show];
        }
         */

    }
    else
    {
        UIAlertView *SceneRecogResult = [[UIAlertView alloc] initWithTitle: @"Scene Recognition Category" message:@"Detection Failed" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        [SceneRecogResult show];
    }
    
    
}

- (IBAction)faceDetButtonPressed:(id)sender {
    
    NSArray* faceFeatures = [FaceRecognition faceDetection: imageView.image];
    
    
    
    if (faceFeatures.count>0) {
        NSLog(@"Face Exists");
    }
    else
    {
        NSLog(@"No Face Exists");
    }
    
    
    /*
    float widthRatio = imageView.bounds.size.width/imageView.image.size.width;
    float heightRatio = imageView.bounds.size.height/imageView.image.size.height;
    float disScale = MIN(widthRatio, heightRatio);
    */
   
 
    
    
    for (CIFaceFeature* mulFaceFeatures in faceFeatures) {
        
         
        CGRect modifiedBounds = mulFaceFeatures.bounds;
        
        if (imageView.image.size.width<imageView.image.size.height) {
            float disScale = imageView.bounds.size.height/imageView.image.size.height;
            
            modifiedBounds.origin.y = imageView.image.size.height-mulFaceFeatures.bounds.size.height-mulFaceFeatures.bounds.origin.y;
            modifiedBounds.size.width*=disScale;
            modifiedBounds.size.height*=disScale;
            modifiedBounds.origin.x*=disScale;
            modifiedBounds.origin.y*=disScale;
            modifiedBounds.origin.x+=0.5*(imageView.bounds.size.width-imageView.image.size.width*disScale);
        }
        else
        {
            float disScale = imageView.bounds.size.width/imageView.image.size.width;
            
            modifiedBounds.origin.y = imageView.image.size.height-mulFaceFeatures.bounds.size.height-mulFaceFeatures.bounds.origin.y;
            modifiedBounds.size.width*=disScale;
            modifiedBounds.size.height*=disScale;
            modifiedBounds.origin.x*=disScale;
            modifiedBounds.origin.y*=disScale;
            modifiedBounds.origin.y+=0.5*(imageView.bounds.size.height-imageView.image.size.height*disScale);
            
        }
        

        UIView* faceView = [[UIView alloc] initWithFrame: modifiedBounds];
        
        faceView.layer.borderWidth=1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];

        [imageView addSubview:faceView];
       
        
    }


    
    
    // face recognition demo

    NSString* TrainingDataPath=@"/Users/ptan/cypress/ios/lib/AutoTagging/Face_Recognition/Training Mode";
    FaceRecognition* FaceRecog=[[FaceRecognition alloc] initWithParams:TrainingDataPath];


    NSString* Face_Name = [FaceRecog faceRecognitionTest:imageView.image at:TrainingDataPath];

    NSLog(@"%@", Face_Name);

}


@end
