//
//  ViewController.h
//  HelloWorldOpenCV
//
//  Created by XUDONG LU on 2013-03-11.
//  Copyright (c) 2013 XUDONG LU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage* image;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loadButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *imgProcButton;



- (IBAction)loadButtonPressed:(id)sender;

- (IBAction)procButtonPressed:(id)sender;

- (IBAction)recogButtonPressed:(id)sender;


- (IBAction)faceDetButtonPressed:(id)sender;


@end
