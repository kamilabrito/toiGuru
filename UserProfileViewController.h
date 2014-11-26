//
//  UserProfileViewController.h
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 9/3/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTLCheckinendpoint.h"
#import "GTLReviewendpoint.h"

@interface UserProfileViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *userPhotoImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *userVisitsLabel;
@property (strong, nonatomic) IBOutlet UILabel *userReviewsLabel;
- (IBAction)logOutButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *profileIndicator;

@property (nonatomic, assign) BOOL stp_review;
@property (nonatomic, assign) BOOL stp_checkin;

- (GTLServiceCheckinendpoint *) checkInService;
- (GTLServiceReviewendpoint *) reviewService;

@end
