//
//  ViewController.m
//  photo_share
//
//  Created by Naohiro OHTA on 2/22/13.
//  Copyright (c) 2013 amaoto. All rights reserved.
//

BOOL selected;
#import "ViewController.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    selected = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%s",__func__);
    if(selected==YES) return;
    selected = YES;
    UIImagePickerController* picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^(){}];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%s",__func__);
    UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^(){}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

