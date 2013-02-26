//  Created by Naohiro OHTA on 2/25/13.
//  Copyright (c) 2013 amaoto. All rights reserved.
#import <UIKit/UIKit.h>
@interface Settings : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *urlPicker;
@end
