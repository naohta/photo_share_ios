//
//  ViewController.m
//  photo_share
//
//  Created by Naohiro OHTA on 2/22/13.
//  Copyright (c) 2013 amaoto. All rights reserved.
//

BOOL selected;
#import "ViewController.h"
#import "R9HTTPRequest.h"
@interface ViewController ()
@property(strong,nonatomic) NSMutableData* receivedOne;
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
    if(selected==YES){selected=NO;return;}
}
- (IBAction)photo_album:(UIButton *)sender {
    [self selectImg];
}

-(void)selectImg
{
    UIImagePickerController* picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^(){}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%s",__func__);
    selected = YES;
    [picker dismissViewControllerAnimated:YES completion:^(){
        NSLog(@"%@",@"dismiss complete");
        UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData* imgData = [[NSData alloc]initWithData:UIImageJPEGRepresentation(img,0.0)];
        NSLog(@"%@",@"imagData complete");
        
        NSURL *URL = [NSURL URLWithString:@"http://Naos-Air11-Mid-2012.local:4567/photo"];
        R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:URL];
        [request setHTTPMethod:@"POST"];
        [request addBody:@"test" forKey:@"TestKey"];
        [request setData:imgData withFileName:@"nao.jpg" andContentType:@"image/jpg" forKey:@"imgData"];
        [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
            NSLog(@"%@", responseString);
        }];
        // Progress
        [request setUploadProgressHandler:^(float newProgress){
            NSLog(@"%g", newProgress);
        }];
        [request startRequest];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

