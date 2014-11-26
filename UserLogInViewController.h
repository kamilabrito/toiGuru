//
//  UserLogInViewController.h
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 8/10/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLUserendpoint.h"

@interface UserLogInViewController : UIViewController
{
    IBOutlet UIActivityIndicatorView *lonInIndicatorView;
}

@property (strong, nonatomic) IBOutlet UITextField *logInUsername_tf;
@property (strong, nonatomic) IBOutlet UITextField *logInPassword_tf;
@property (strong, nonatomic) NSMutableArray *userNameArray;
@property (strong, nonatomic) NSMutableArray *passwordArray;

@property (nonatomic, assign) BOOL stp;
@property (nonatomic, assign) BOOL isLogInSuccess;
@property (nonatomic, assign) BOOL userExist;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

- (IBAction)logInLogin_tf:(id)sender;

- (GTLServiceUserendpoint *) userService;

@end
