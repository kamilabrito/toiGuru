//
//  UserLogInViewController.m
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 8/10/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import "UserLogInViewController.h"
#import "GTLUserendpointUser.h"
#import "GTMHTTPFetcherLogging.h"
#import "Constants.h"

@interface UserLogInViewController ()

@end

@implementation UserLogInViewController
{
    NSTimer *t;
    NSMutableArray *infos;
}

@synthesize userNameArray, passwordArray, logInPassword_tf, logInUsername_tf;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (GTLServiceUserendpoint *) userService {
    
    static GTLServiceUserendpoint *service = nil;
    if (!service) {
        service = [[GTLServiceUserendpoint alloc] init];
        service.retryEnabled = YES;
    }
    return service;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    lonInIndicatorView.hidden = YES;
    [lonInIndicatorView stopAnimating];
    
    userNameArray = [[NSMutableArray alloc] init];
    passwordArray = [[NSMutableArray alloc] init];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) checkUsernameAndPassword {
    
    self.stp = NO;
    self.userExist = NO;
    
    GTLServiceUserendpoint *service = [self userService];
    
    GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForListUserByUsernameAndPasswordWithPassword:self.password username:self.username];
    
    infos = [[NSMutableArray alloc]init];
    
    NSLog(@"checkUser: %@  %@", self.username, self.password);
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLUserendpointUser *object, NSError *error) {
        NSLog(@"checkUser error: %@", error);
        
        NSLog(@"OBJ: %@", object);
        
        @try {
            NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:object, nil];
            //separetes info from server by block and and block to nsmutablearray
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [infos addObject:[obj valueForKey:@"items"]];
                NSLog(@"verificando usuario");
                if ([infos count] > 0) {
                    self.stp = YES;
                    self.userExist = YES;
                    NSLog(@"USUARIO: %@ ",infos);
                }
            }];
        }
        @catch (NSException *exception) {
            [self checkUsername];
        }
        @finally {
            
        }

    }];
    
}

- (void) checkUsername {
    
    GTLServiceUserendpoint *service = [self userService];
    
    GTLQueryUserendpoint *query = [GTLQueryUserendpoint queryForListUserByUsernameWithUsername:self.username];
    
    NSMutableArray *justinfos = [[NSMutableArray alloc]init];
    
    NSLog(@"checkUsername: %@", self.username);
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLUserendpointUser *object, NSError *error) {
        NSLog(@"checkUser error: %@", error);
        
        @try {
            NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:object, nil];
            //separetes info from server by block and and block to nsmutablearray
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [justinfos addObject:[obj valueForKey:@"items"]];
                NSLog(@"verificando usuario");
                if ([justinfos count] > 0) {
                    self.userExist = YES;
                    NSLog(@"USUARIO SO COM USERNAME: %@ ",justinfos);
                }
            }];
        }
        @catch (NSException *exception) {
            self.userExist = NO;
        }
        @finally {
            self.stp = YES;
        }
        
    }];

}

-(BOOL) saveCurrentUserInfos {
    
    NSMutableArray *infoToBeSaved = [[NSMutableArray alloc] init];
    
    [infos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        for (NSInteger i=0; i < [obj count]; i++) {
            GTLUserendpointUser *userAtIndex = [obj objectAtIndex:i];
            [infoToBeSaved addObject:userAtIndex];
        }
    }];
    
    for (NSInteger i=0; i < [infoToBeSaved count]; i++) {
        GTLUserendpointUser *userAtIndex = [infoToBeSaved objectAtIndex:i];
        if ([userAtIndex.username isEqualToString:self.username] || [userAtIndex.password isEqualToString:self.password])
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:userAtIndex.username forKey:defaults_key_username];
            [defaults setObject:userAtIndex.password forKey:defaults_key_password];
            [defaults setObject:userAtIndex.identifier forKey:defaults_key_user_id];
            [defaults setObject:userAtIndex.firstname forKey:defaults_key_firstname];
            [defaults setObject:userAtIndex.lastname forKey:defaults_key_lastname];
            [defaults setObject:userAtIndex.email forKey:defaults_key_email];
            [defaults synchronize];
            
            return YES;
        }
    }
    return NO;
}

- (IBAction)logInLogin_tf:(id)sender {

    self.username =  logInUsername_tf.text;
    self.password = logInPassword_tf.text;

    [lonInIndicatorView startAnimating];
    lonInIndicatorView.hidden = NO;
  
    [self performSelector:@selector(callMethod) withObject:nil];

}

- (void) loginOutcome : (BOOL) logInResult {
    
    self.isLogInSuccess = NO;
    
    if (logInResult) {
        self.isLogInSuccess = YES;
    }
}


- (void) callMethod {
    
    NSLog(@"callMethod");
    t = [NSTimer scheduledTimerWithTimeInterval:5
                                     target:self
                                   selector:@selector(myMethod)
                                   userInfo: nil
                                    repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer: t forMode: NSDefaultRunLoopMode];
    
}

- (void) myMethod {
    
    NSLog(@"Executando MY METHOD");
    
    if (!self.stp) {
        [self checkUsernameAndPassword];
    } else {
        [self performSelectorOnMainThread:@selector(stopActivity) withObject:nil waitUntilDone:NO];
    }
}

- (void) stopActivity {
    
    NSLog(@"stopActivity");
    
    [t invalidate];
    
    [lonInIndicatorView stopAnimating];
    
    [self loginOutcome:[self saveCurrentUserInfos]];
    
    lonInIndicatorView.hidden = YES;
    
    if (self.isLogInSuccess) {
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    } else {
        if (self.userExist) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Unable to perform Log In. Wrong username or password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Unable to perform Log In. User don't exist, please sing in." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([logInPassword_tf isFirstResponder] && [touch view] != logInPassword_tf) {
        [logInPassword_tf resignFirstResponder];
    } else if ([logInUsername_tf isFirstResponder] && [touch view] != logInUsername_tf) {
        [logInUsername_tf resignFirstResponder];
    }    
    [super touchesBegan:touches withEvent:event];
}


@end
