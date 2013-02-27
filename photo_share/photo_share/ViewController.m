//  Created by Naohiro OHTA on 2/22/13.
//  Copyright (c) 2013 amaoto. All rights reserved.
#import "ViewController.h"
#import "R9HTTPRequest.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
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

/*
-(IBAction)takeButton:(id)sender {
    UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
}
*/

- (void)imagePickerController3:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%s",__func__);
    [picker dismissViewControllerAnimated:YES completion:^(){
        NSLog(@"%@",@"dismiss complete");
        UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData* imgData = [[NSData alloc]initWithData:UIImageJPEGRepresentation(img,0.0)];
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

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    [picker dismissViewControllerAnimated:YES completion:^(){
    
    if (assetURL) {
        ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset) {
            /*
            ALAssetRepresentation *representation;
            representation = [asset defaultRepresentation];
            // 元から付いているメタデータも残す
            NSMutableDictionary *metadata;
            metadata = [[NSMutableDictionary alloc]
                        initWithDictionary:[representation metadata]];
            
            // コメント、シャッター速度をExif情報として設定
            NSDictionary *exif = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"コメント",
                                  (NSString*)kCGImagePropertyExifUserComment,
                                  [NSNumber numberWithFloat:0.125f],
                                  (NSString*)kCGImagePropertyExifExposureTime,
                                  nil];
            [metadata setObject:exif
                         forKey:(NSString*)kCGImagePropertyExifDictionary];
            
            // カメラロールにメタデータを付けて書き込み
            ALAssetsLibrary* l = [[ALAssetsLibrary alloc] init];
            [l writeImageToSavedPhotosAlbum:[representation fullScreenImage]
                                   metadata:metadata
                            completionBlock:^(NSURL* url, NSError* e){
                                NSLog(@"Saved: %@<%@>", url, e);
                            }];
            */
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData* imgData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want

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
            
        };
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL
                 resultBlock:resultBlock
                failureBlock:^(NSError *error) {
                    NSLog(@"error:%@", error);
                }];
    } else { NSLog(@"error"); }

    }];
    
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end

