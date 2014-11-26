//
//  CheckInViewController.h
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 8/26/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTLToiletendpoint.h"
#import "GTLPlaceendpoint.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ToiletViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *toiletsArray;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *toiletListIndicator;

@property (nonatomic, assign) BOOL stp;

- (GTLServiceToiletendpoint *) toiletService;
- (void) getMarker : (GMSMarker *) marker;

@end
