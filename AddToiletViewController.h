//
//  AddToiletViewController.h
//  ToiGuruiOSApp
//
//  Created by João Martinez on 18/08/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLPlaceendpoint.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GTLToiletendpoint.h"

@interface AddToiletViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>

@property (strong, nonatomic) NSArray *categoryNames;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *workingHourField;
@property (strong, nonatomic) IBOutlet UISwitch *publicSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *paidSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *accessSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *kidsSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *babySwitch;
@property (retain, nonatomic) GTLPlaceendpointPlace *place;
@property (retain, nonatomic) GTLToiletendpointToilet *toilet;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (strong, nonatomic) GMSAddress *myAddress;
- (IBAction)onSavePress:(id)sender;
- (GTLServicePlaceendpoint *) placeService;
- (GTLServiceToiletendpoint *) toiletService;
-(void)hideKeyboard;
@end
