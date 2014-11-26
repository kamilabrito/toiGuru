//
//  UserProfileViewController.m
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 9/3/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import "UserProfileViewController.h"
#import "Constants.h"
#import "Util.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController {
    NSMutableArray *infos_checkIn, *infos_review;
    NSTimer *t;
}
@synthesize userPhotoImageView, userNameLabel, userVisitsLabel, userReviewsLabel, profileIndicator;

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
   [profileIndicator startAnimating];
    profileIndicator.hidden = NO;
    
    [self addImageView];
    [self setUsername];
    [self getCheckIns];
    [self getReviews];
    
    t = [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self
                                       selector:@selector(stopIndicator)
                                       userInfo: nil
                                        repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer: t forMode: NSDefaultRunLoopMode];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addImageView{
    userPhotoImageView = [[UIImageView alloc]
                            initWithFrame:CGRectMake(0, 64, 320, 175)];
    [userPhotoImageView setImage:[UIImage imageNamed:@"default_avatar.png"]];
    [userPhotoImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 198, 300, 21)];
    
    [userPhotoImageView addSubview:userNameLabel];
    [userNameLabel setUserInteractionEnabled:YES];
    [userPhotoImageView setUserInteractionEnabled:YES];
    
    [self.view addSubview:userPhotoImageView];
    
}

- (IBAction)logOutButton:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:defaults_key_username];
    [defaults setObject:@"" forKey:defaults_key_password];
    [defaults setObject:@"" forKey:defaults_key_user_id];
    [defaults setObject:@"" forKey:defaults_key_firstname];
    [defaults setObject:@"" forKey:defaults_key_lastname];
    [defaults setObject:@"" forKey:defaults_key_email];
    
    [defaults synchronize];
    
    [sender setTitle:@""];
    
    [self.navigationController popToRootViewControllerAnimated:TRUE];
    
    [profileIndicator stopAnimating];
    profileIndicator.hidden = YES;
    [t invalidate];
    
}

- (GTLServiceCheckinendpoint *) checkInService {
    
    static GTLServiceCheckinendpoint *service = nil;
    if (!service) {
        service = [[GTLServiceCheckinendpoint alloc] init];
        service.retryEnabled = YES;
    }
    return service;
}

- (GTLServiceReviewendpoint *) reviewService {
    
    static GTLServiceReviewendpoint *service = nil;
    if (!service) {
        service = [[GTLServiceReviewendpoint alloc] init];
        service.retryEnabled = YES;
    }
    return service;
}

- (void) getCheckIns{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults objectForKey:defaults_key_user_id];
    long long long_id = [userId longLongValue];
    
    self.stp_checkin = NO;
    
    NSLog(@"getCheckIns");
    
    GTLServiceCheckinendpoint *service = [self checkInService];
    
    GTLQueryCheckinendpoint *query = [GTLQueryCheckinendpoint queryForListCheckInByUserIdWithUserId:long_id];
    
    infos_checkIn = [[NSMutableArray alloc]init];

    NSMutableArray * checkInsOfCurrentUser = [[NSMutableArray alloc] init];
    
    //request info from server
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLCheckinendpointCheckIn *object, NSError *error) {
        NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:object, nil];
        @try {
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [infos_checkIn addObject:[obj valueForKey:@"items"]];
            }];
            [infos_checkIn enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                for (NSInteger i=0; i < [obj count]; i++) {
                    GTLCheckinendpointCheckIn *checkInAtIndex = [obj objectAtIndex:i];
                    NSLog(@"user check in");
                    [checkInsOfCurrentUser addObject:checkInAtIndex];
                }
                if (stop) {
                    self.stp_checkin = YES;
                }
            }];
        
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [self checkUserCheckIns:checkInsOfCurrentUser];
        }
    }];
    
}

- (void) checkUserCheckIns : (NSMutableArray *) checkInsOfCurrentUser{
    
    NSString *text = [NSString stringWithFormat:@"%lu",(unsigned long)[checkInsOfCurrentUser count]];
    
    userVisitsLabel.text = text;
}

- (void) getReviews{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults objectForKey:defaults_key_user_id];
    long long long_id = [userId longLongValue];
    
    self.stp_review = NO;
    
    GTLServiceReviewendpoint *service = [self reviewService];
    
    GTLQueryReviewendpoint *query = [GTLQueryReviewendpoint queryForListReviewByUserIDWithUserId:long_id];
    
    infos_review = [[NSMutableArray alloc]init];
    
    NSMutableArray * reviewsOfCurrentUser = [[NSMutableArray alloc] init];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLReviewendpointReview *object, NSError *error) {
        NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:object, nil];
        @try {
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [infos_review addObject:[obj valueForKey:@"items"]];
            }];
            [infos_review enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                for (NSInteger i=0; i < [obj count]; i++) {
                    GTLReviewendpointReview *reviewAtIndex = [obj objectAtIndex:i];
                    NSLog(@"user review");
                    [reviewsOfCurrentUser addObject:reviewAtIndex];
                }
                if (stop) {
                    self.stp_review = YES;
                }
            }];
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            [self checkUserReviews:reviewsOfCurrentUser];
        }
    }];

}

- (void) checkUserReviews: (NSMutableArray *) reviewsOfCurrentUser {
    
    NSString *text = [NSString stringWithFormat:@"%lu",(unsigned long)[reviewsOfCurrentUser count]];
    
    userReviewsLabel.text = text;
}

- (void) stopIndicator {
    
    NSLog(@"stop indicator: %hhd %hhd ", self.stp_checkin, self.stp_review);
    if (self.stp_review && self.stp_checkin) {
        NSLog(@"parando indicator");
        [profileIndicator stopAnimating];
        profileIndicator.hidden = YES;
        [t invalidate];
    }
}



- (BOOL) hasUserLoggedIn{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userName = [defaults objectForKey:defaults_key_username];
    NSString *password = [defaults objectForKey:defaults_key_password];
    
    if ((([userName length] == 0) || ([password length] == 0)) || ((userName == nil) || (password  == nil))) {
        return NO;
    } else {
        return YES;
    }
}

- (void) setUsername {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString * name = [NSString stringWithFormat:@"%@ %@", [defaults objectForKey:defaults_key_firstname], [defaults objectForKey:defaults_key_lastname]];
    
    userNameLabel.text = name;
}

@end
