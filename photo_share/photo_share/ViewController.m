//  Created by Naohiro OHTA on 2/22/13.
//  Copyright (c) 2013 amaoto. All rights reserved.
#import "ViewController.h"
#import "R9HTTPRequest.h"
#import "AppDelegate.h"
@interface ViewController ()
@property(strong,nonatomic) NSMutableData* receivedOne;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%s",__func__);
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
    [picker dismissViewControllerAnimated:YES completion:^(){
        NSLog(@"%@",@"dismiss complete");
        UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData* imgData = [[NSData alloc]initWithData:UIImageJPEGRepresentation(img,0.0)];
        NSLog(@"%@",@"imagData complete");
        
        //NSURL *URL = [NSURL URLWithString:@"http://Naos-Air11-Mid-2012.local:4567/photo"];
        //NSURL *URL = [NSURL URLWithString:@"http://photo.elasticbeanstalk.com/photo"];
        NSURL *URL = [NSURL URLWithString:_url_strings[_url_string_index]];
        R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:URL];
        [request setHTTPMethod:@"POST"];
        [request addBody:@"test" forKey:@"TestKey"];
        [request setData:imgData withFileName:@"nao.jpg" andContentType:@"image/jpg" forKey:@"imgData"];
        [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
            NSLog(@"%@", responseString);
            self.textView.text = responseString;
        }];
        // Progress
        [request setUploadProgressHandler:^(float newProgress){
            NSLog(@"%g", newProgress);
            self.textView.text = [NSString stringWithFormat:@"Progress.. %f, now.",newProgress*100];
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

