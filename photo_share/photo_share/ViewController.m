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
        NSLog(@"%@",@"did out data");
        NSMutableURLRequest *request;
        //NSString* url = @"http://photo.elasticbeanstalk.com/photo";
        NSString* url = @"http://localhost:4567/photo";
        request = [ NSMutableURLRequest requestWithURL : [ NSURL URLWithString : url ] ];
        [ request setHTTPMethod : @"POST" ];
        
        /*
        NSMutableData* body = [NSMutableData data];
        [body appendData:[@"imgDate=" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imgData];
        [request setHTTPBody:body];;
        //[request setHTTPBody:imgData];
        */
        
        NSMutableData* body = [NSMutableData data];

        //NSString* s = @"imgDate=Something";
        //NSString* s = @"command={\"method\":{\"name\":\"getPerson\"}}";
        //NSData* body = [s dataUsingEncoding:NSUTF8StringEncoding];

        NSString* s;
        s = @"Content-Disposition:form-data;name=\"imgDate\"";
        [body appendData:[s dataUsingEncoding:NSUTF8StringEncoding]];
        s = @"--AaB03x";
        [body appendData:[s dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imgData];
        s = @"--AaB03x--";
        [body appendData:[s dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        
        
        // MUST Content-Type
        //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        //[request setValue:@"image" forHTTPHeaderField:@"Content-Type"];
        //[request setValue:@"multipart" forHTTPHeaderField:@"Content-Type"];
        //[request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
        //[request setValue:@"multipart,boundary=AaB03x" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"multipart,boundary=AaB03x" forHTTPHeaderField:@"Content-Type"];
        //content-disposition: form-data; name="field1"
        
        //[request setValue:[NSString stringWithFormat:@"%d", [imgData length]] forHTTPHeaderField:@"Content-Length"];
        NSURLConnection* cnct = [ NSURLConnection connectionWithRequest : request delegate : self ];
        if(cnct){
            NSLog(@"Start sending");
            self.receivedOne = [NSMutableData data];
        }
    }];
}




- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error");
    NSString* s = @"yeah";
    s = [error description];
    [self.textView setText:s];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"-didReceiveResponse");
    [self.receivedOne setLength:0];
    NSLog(@"%@",response.MIMEType);
    NSLog(@"%@",response.textEncodingName);
    NSLog(@"%@",response.URL.resourceSpecifier);
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
    NSLog(@"-didReceivedData");
    [self.receivedOne appendData:data];
    NSLog(@"receivedOne's length is %dbytes",[self.receivedOne length]);
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSLog(@"-connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedOne length]);
    int len = [self.receivedOne length];
    NSLog(@"length is, %d",len);
    unsigned char aBuffer[len];
    [self.receivedOne getBytes:aBuffer length:len];
    NSString* resultString = [[NSString alloc]initWithBytesNoCopy:aBuffer length:len encoding:NSUTF8StringEncoding freeWhenDone:NO];
    [self.textView setText:resultString];
    //NSLog(@"%@",self.receivedOne);
    NSLog(@"%@",resultString);
}








- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

