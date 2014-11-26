//
//  AddNewToiletViewController.h
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 9/16/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLToiletendpoint.h"
#import "GTLPlaceendpoint.h"


@interface AddNewToiletViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *toiletType;
@property (strong, nonatomic) IBOutlet UITextField *toiletName;
@property (strong, nonatomic) IBOutlet UISwitch *publicSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *paidSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *accessibilitySwitch;
@property (strong, nonatomic) IBOutlet UISwitch *childSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *changingTableSwitch;
- (IBAction)saveNewToilet:(id)sender;

- (void) getPlace : (GTLPlaceendpointPlace *) place;
@end
