//
//  ViewController.h
//  photo_share
//
//  Created by Naohiro OHTA on 2/22/13.
//  Copyright (c) 2013 amaoto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
