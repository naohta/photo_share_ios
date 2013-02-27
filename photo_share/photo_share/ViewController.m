//  Created by Naohiro OHTA on 2/22/13.
//  Copyright (c) 2013 amaoto. All rights reserved.
#import "ViewController.h"
#import "R9HTTPRequest.h"
#import "AppDelegate.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>

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
        NSData* imgDataPre = [[NSData alloc]initWithData:UIImageJPEGRepresentation(img,0.0)];
        NSData* imgData = [self dataFromUIImage:[[UIImage alloc]initWithData:imgDataPre] info:info];
        NSLog(@"%@",@"imagData complete");
        
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

- (NSData *)dataFromUIImage:(UIImage *)image info:(NSDictionary*)info{
    NSMutableData *imageData = [[NSMutableData alloc] init];
    //http://blog.mudaimemo.com/2010/12/iosexif.html
    
    // メタデータ
    NSMutableDictionary *metadata = [info mutableCopy];
    
    // メタデータ: 画像の高さと幅
    /*
    [metadata setObject:[NSNumber numberWithInt:1000]
                 forKey:(NSString *)kCGImagePropertyPixelHeight];
    [metadata setObject:[NSNumber numberWithInt:1000]
                 forKey:(NSString *)kCGImagePropertyPixelWidth];
    */
    
    // メタデータ: Exif
    NSMutableDictionary *exif = [NSMutableDictionary dictionary];
    //exif = [metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    [exif setObject:@"ユーザーコメント" forKey:(NSString *)kCGImagePropertyExifUserComment];
    [metadata setObject:exif forKey:(NSString *)kCGImagePropertyExifDictionary];
    
    
    // CGImageDestination を利用して画像とメタデータをひ関連付ける
    CGImageDestinationRef dest;
    dest = CGImageDestinationCreateWithData((CFMutableDataRef)CFBridgingRetain(imageData), kUTTypeJPEG, 1, nil);
    
    CGImageDestinationAddImage(dest, image.CGImage, (CFDictionaryRef)CFBridgingRetain(metadata));
    CGImageDestinationFinalize(dest);
    CFRelease(dest);
    
    return imageData;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

