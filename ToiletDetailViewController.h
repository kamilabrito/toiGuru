//
//  CheckInDetailViewController.h
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 8/29/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTLToiletendpoint.h"
#import "GTLPlaceendpoint.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTLCheckinendpoint.h"
#import "GTLReviewendpoint.h"

@interface ToiletDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UILabel *toiletName;
- (IBAction)confirmCheckInButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *totalCheckInLabel;
@property (strong, nonatomic) IBOutlet UILabel *userTotalCheckInLabel;
@property (strong, nonatomic) IBOutlet UILabel *toiletStoreLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *detailIndicator;
@property (nonatomic, strong) GTLToiletendpointToilet * currentToilet;
- (IBAction)reviewButton:(id)sender;
@property (nonatomic, assign) BOOL stp_toilet;
@property (nonatomic, assign) BOOL stp_review;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (void) getToilet : (GTLToiletendpointToilet *) toiletObject;
- (GTLServiceReviewendpoint *) reviewService;
- (GTLServicePlaceendpoint *) placeService;
- (GTLServiceCheckinendpoint *) checkInService;

@end
