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
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];

        NSData *dataOfImageFromGallery = UIImageJPEGRepresentation (image,0.5);
        NSLog(@"Image length:  %d", [dataOfImageFromGallery length]);
        
        
        CGImageSourceRef source;
        source = CGImageSourceCreateWithData((CFDataRef)CFBridgingRetain(dataOfImageFromGallery), NULL);
        
        NSDictionary *metadata = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
        
        NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
        
        NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
        NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
        
        
        if(!EXIFDictionary)
        {
            //if the image does not have an EXIF dictionary (not all images do), then create one for us to use
            EXIFDictionary = [NSMutableDictionary dictionary];
        }
        
        if(!GPSDictionary)
        {
            GPSDictionary = [NSMutableDictionary dictionary];
        }
        
        //Setup GPS dict -
        //I am appending my custom data just to test the logic……..
        
        [GPSDictionary setValue:[NSNumber numberWithFloat:1.1] forKey:(NSString*)kCGImagePropertyGPSLatitude];
        [GPSDictionary setValue:[NSNumber numberWithFloat:2.2] forKey:(NSString*)kCGImagePropertyGPSLongitude];
        [GPSDictionary setValue:@"lat_ref" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
        [GPSDictionary setValue:@"lon_ref" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
        [GPSDictionary setValue:[NSNumber numberWithFloat:3.3] forKey:(NSString*)kCGImagePropertyGPSAltitude];
        [GPSDictionary setValue:[NSNumber numberWithShort:4.4] forKey:(NSString*)kCGImagePropertyGPSAltitudeRef];
        [GPSDictionary setValue:[NSNumber numberWithFloat:5.5] forKey:(NSString*)kCGImagePropertyGPSImgDirection];
        [GPSDictionary setValue:@"_headingRef" forKey:(NSString*)kCGImagePropertyGPSImgDirectionRef];
        
        [EXIFDictionary setValue:@"xml_user_comment" forKey:(NSString *)kCGImagePropertyExifUserComment];
        [EXIFDictionary setValue:[[NSDate alloc]initWithTimeIntervalSinceNow:-60*60*24*2] forKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
        //add our modified EXIF data back into the image’s metadata
        [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
        [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
        
        CFStringRef UTI = CGImageSourceGetType(source);
        NSMutableData *dest_data = [NSMutableData data];
        
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef) CFBridgingRetain(dest_data), UTI, 1, NULL);
        
        if(!destination)
        {
            NSLog(@"--------- Could not create image destination---------");
        }
        
        
        CGImageDestinationAddImageFromSource(destination, source, 0, (CFDictionaryRef) CFBridgingRetain(metadataAsMutable));
        
        BOOL success = NO;
        success = CGImageDestinationFinalize(destination);
        
        if(!success)
        {
            NSLog(@"-------- could not create data from image destination----------");
        }
        
        UIImage * image1 = [[UIImage alloc] initWithData:dest_data];
        NSData* imgData = UIImageJPEGRepresentation(image1, 0.0);
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

