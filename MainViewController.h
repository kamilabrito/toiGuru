//
//  MainViewController.h
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 8/7/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GTLPlaceendpoint.h"
#import "GTLToiletendpoint.h"
#import "GTLReviewendpoint.h"

@interface MainViewController : UIViewController <GMSMapViewDelegate,CLLocationManagerDelegate>

- (IBAction)logOutButton:(UIBarButtonItem *)sender;
- (IBAction)addToiletButton:(id)sender;
- (GTLServicePlaceendpoint *) placeService;
- (GTLServiceToiletendpoint *) toiletService;
- (GTLServiceReviewendpoint *) reviewService;
@property (nonatomic, assign) BOOL stp_toilets;
@property (nonatomic, assign) BOOL stp_reviews;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) GMSMapView *mapView;

@property (weak, nonatomic) IBOutlet UIView *mapContainer;


@end
