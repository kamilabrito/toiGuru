//
//  ToiGuruViewController.h
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 8/1/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLUserendpoint.h"

@interface AddUserViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *addUserIndicator;
@property (weak, nonatomic) IBOutlet UITextField *tf_username;
@property (weak, nonatomic) IBOutlet UITextField *tf_firstname;
@property (weak, nonatomic) IBOutlet UITextField *tf_lastname;
@property (weak, nonatomic) IBOutlet UITextField *tf_email;
@property (weak, nonatomic) IBOutlet UITextField *tf_password;

@property (nonatomic, assign) BOOL isAvailable;
@property (nonatomic, assign) BOOL stp;

- (IBAction)btn_send:(id)sender;

- (GTLServiceUserendpoint *)userService;

@end
