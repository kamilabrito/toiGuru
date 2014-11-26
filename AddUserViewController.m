//
//  ToiGuruViewController.m
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 8/1/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import "AddUserViewController.h"
#import "GTLUserendpointUser.h"
#import "GTMHTTPFetcherLogging.h"
#import "Constants.h"


@interface AddUserViewController ()

@end

@implementation AddUserViewController {
    NSString * username;
    NSString * firstname;
    NSString * lastname;
    NSString * email;
    NSString * password;
    
    NSTimer *t;
    
    NSMutableArray * userData;
}
@synthesize tf_username, tf_email, tf_firstname, tf_lastname, tf_password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.addUserIndicator.hidden = YES;
    [self.addUserIndicator stopAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (GTLServiceUserendpoint *) userService {
    
    static GTLServiceUserendpoint *service = nil;
    if (!service) {
        service = [[GTLServiceUserendpoint alloc] init];
        service.retryEnabled = YES;
    }
    return service;
}

- (void)sendUserToServer : (GTLUserendpointUser *) user{
    GTLServiceUserendpoint *service = [self userService];

    GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForInsertUserWithObject:user];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLObject *object, NSError *error) {
        
        NSLog(@"Log error: %@ ", [error localizedDescription]);
        NSLog(@"executeQuery:query ");
    }];
}

- (void) saveUserData {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
         NSLog(@"saving user data");
    
    [defaults setObject:username forKey:defaults_key_username];
    [defaults setObject:password forKey:defaults_key_password];
    [defaults setObject:email forKey:defaults_key_email];
    [defaults setObject:firstname forKey:defaults_key_firstname];
    [defaults setObject:lastname forKey:defaults_key_lastname];
    
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getUsersFromServer {
    
    GTLServiceUserendpoint *serviceUser = [self userService];
    GTLQueryUserendpoint *queryUser = [GTLQueryUserendpoint queryForListUser];
    
    NSMutableArray *infos = [[NSMutableArray alloc]init];

    [serviceUser executeQuery:queryUser completionHandler:^(GTLServiceTicket *ticket, GTLUserendpointUser *object, NSError *error) {
        NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:object, nil];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [infos addObject:[obj valueForKey:@"items"]];
            if (stop) {
                NSLog(@"retrieving info from server: %@", infos);
                [self verifyUsernameAveability : infos];
            }
        }];
    }];
    
}

- (void) verifyUsernameAveability : (NSMutableArray *) arrayOfUsers {
                NSLog(@"verifying aveability");
    
    self.isAvailable = YES;
    
    [arrayOfUsers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        for (NSInteger i=0; i < [obj count]; i++) {
            GTLUserendpointUser *userAtIndex = [obj objectAtIndex:i];
            if ([userAtIndex.username isEqual:username]) {
                NSLog(@"NOT avealiable: %@ ", username);
                self.isAvailable = NO;
            }
        }
        if (stop){
            NSLog(@"VERIFICATION FINISHED");
            self.stp = YES;
        } else {
            self.stp = NO;
        }
    }];
}


- (GTLUserendpointUser *)createUserObject  {
    
    GTLUserendpointUser *user;
    user = [[GTLUserendpointUser alloc] init];
    
   // NSString *currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    
     NSLog(@"creating user object");
    
    [user setUsername:username];
    [user setLastname:lastname];
    [user setFirstname:firstname];
    [user setEmail:email];
    [user setPassword:password];
    //[user setDeviceLanguage:currentLanguage];
    
    return user;
}


- (IBAction)btn_send:(id)sender {
    
    NSLog(@"SEND BUTTON PRESSED");
    
    username = tf_username.text;
    firstname = tf_firstname.text;
    lastname = tf_lastname.text;
    email = tf_email.text;
    password = tf_password.text;

    if ([username isEqual: @""] || [email isEqual:@""] || [firstname isEqual:@""] || [lastname isEqual:@""] || [password isEqual:@""]) {
        
            NSLog(@"there are blank fields");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create user"
                                                        message:@"You need to fill all the fields before continue."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self.addUserIndicator startAnimating];
        self.addUserIndicator.hidden = NO;
        [self getUsersFromServer];
        [self performSelector:@selector(callMethod) withObject:nil];
    }
}

- (void) callMethod {
    
    NSLog(@"callMethod");
    t = [NSTimer scheduledTimerWithTimeInterval:5
                                         target:self
                                       selector:@selector(doUserVerification)
                                       userInfo: nil
                                        repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer: t forMode: NSDefaultRunLoopMode];
    
}

- (void) doUserVerification {

    if (self.stp) {
        if (self.isAvailable) {
            [self sendUserToServer:[self createUserObject]];
            [self saveUserData];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create user"
                                                            message:@"The username you've choosed is taken already, please enter a new one."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [tf_username becomeFirstResponder];
        }
        
        [self performSelectorOnMainThread:@selector(stopActivity) withObject:nil waitUntilDone:NO];
    }
}

- (void) stopActivity {
    
    NSLog(@"stopActivity");
    
    [t invalidate];
    
    [self.addUserIndicator stopAnimating];
    
    self.addUserIndicator.hidden = YES;
    
    if ([self hasUserLoggedIn]) {
      [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
    
}

- (BOOL) hasUserLoggedIn{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *defaults_username = [defaults objectForKey:defaults_key_username];
    NSString *defaults_password = [defaults objectForKey:defaults_key_password];
    
    if ((([defaults_username length] == 0) || ([defaults_password length] == 0)) || ((defaults_username == nil) || (defaults_password  == nil))) {
        return NO;
    } else {
        return YES;
    }
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([tf_username isFirstResponder] && [touch view] != tf_username) {
        [tf_username resignFirstResponder];
    } else if ([tf_firstname isFirstResponder] && [touch view] != tf_firstname) {
        [tf_firstname resignFirstResponder];
    } else if ([tf_lastname isFirstResponder] && [touch view] != tf_lastname) {
        [tf_lastname resignFirstResponder];
    } else if ([tf_email isFirstResponder] && [touch view] != tf_email) {
        [tf_email resignFirstResponder];
    } else {
        [tf_password resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    //Assign new frame to your view
    [self.view setFrame:CGRectMake(0,-40,320,460)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
    
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view setFrame:CGRectMake(0,0,320,480)];
}
@end
