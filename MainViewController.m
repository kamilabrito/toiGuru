//
//  MainViewController.m
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 8/7/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import "MainViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "MapInfoWindow.h"

#import "ToiletViewController.h"
#import "AddToiletViewController.h"
#import "Constants.h"
#import "Util.h"


@interface MainViewController ()

@end

@implementation MainViewController
{
    GMSMarker * globalMarker;
    NSString * textToiletQuant;
    NSString * textReviewQuant;
    NSMutableArray * infos_toilet;
    NSMutableArray * infos_review;
    NSMutableArray * totalReviews;
    UIView *contentView;
    NSNumber * clean, *features, *infra, *media, *localMedia;
    CLLocationManager *locationManager;
    BOOL loadedLocation;
    NSTimer *timerInfo;
    MapInfoWindow *infoWindow;
    NSNumber *placeid;
}

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
    
    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:3];
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor blueColor];
    
    [self.mainView addSubview:contentView];
    
    
    
	GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:38
                                                            longitude:-122
                                                            zoom:4];
    
    self.mapView = [GMSMapView mapWithFrame:self.mapContainer.bounds camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.zoomGestures = YES;
    self.mapView.delegate = self;
    [self.mapContainer addSubview:self.mapView];
    //[self retrieveToilets];
    //[self retrieveReviews];
    
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    locationManager.distanceFilter = 500; // meters
    loadedLocation = NO;
    [locationManager startUpdatingLocation];
}

- (void)loadMarkers:(GMSVisibleRegion) visibleRegion
{
    
    GTLServicePlaceendpoint *service = [self placeService];
    
    //os 4 cantos da tela sao esses abaixo
   // CLLocationCoordinate2D bottomLeft = visibleRegion.nearLeft;
    CLLocationCoordinate2D bottomRight = visibleRegion.nearRight;
    CLLocationCoordinate2D topLeft = visibleRegion.farLeft;
//    CLLocationCoordinate2D topRight = visibleRegion.farRight;
    NSString *bottomRightLat = [[NSString alloc] initWithFormat:@"%f", bottomRight.latitude];
    NSString *bottomRightLong = [[NSString alloc] initWithFormat:@"%f", bottomRight.longitude];
    NSString *topLeftLat = [[NSString alloc] initWithFormat:@"%f", topLeft.latitude];
    NSString *topLeftLong = [[NSString alloc] initWithFormat:@"%f", topLeft.longitude];
    
    NSNumberFormatter * fbrlat = [[NSNumberFormatter alloc] init];
    [fbrlat setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * brlat = [fbrlat numberFromString:bottomRightLat];
    
    NSNumberFormatter * fbrlong = [[NSNumberFormatter alloc] init];
    [fbrlong setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * brlong = [fbrlong numberFromString:bottomRightLong];

    NSNumberFormatter * ftllat = [[NSNumberFormatter alloc] init];
    [ftllat setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * tllat = [ftllat numberFromString:topLeftLat];
    
    NSNumberFormatter * ftllong = [[NSNumberFormatter alloc] init];
    [ftllong setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * tllong = [ftllong numberFromString:topLeftLong];
    
   GTLQueryPlaceendpoint *query = [GTLQueryPlaceendpoint queryForListPlace];
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLPlaceendpointCollectionResponsePlace *object, NSError *error) {
        NSLog(@"------ error --------  %@", error);
        NSArray *items = [object items];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            GTLPlaceendpointPlace *place = obj;
            CLLocationCoordinate2D position = CLLocationCoordinate2DMake(place.latitude.doubleValue, place.longitude.doubleValue);
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            marker.userData = place;
            marker.map = self.mapView;
            if ((place.latitude > brlat && place.latitude < tllat) &&
                (place.longitude > brlong && place.longitude< tllong)) {
                NSMutableArray *placesInRadius = [[NSMutableArray alloc] init];
                [placesInRadius addObject:place];
                NSLog(@"place in radius: %@ ", placesInRadius);
            }
         
        }];
    }];
    
}

- (void) hideSplash {
    contentView.hidden = YES;
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0 && !loadedLocation) {
        GMSCameraPosition *cam = [[GMSCameraPosition alloc] initWithTarget:location.coordinate zoom:5 bearing:0 viewingAngle:0];
        [self.mapView animateToCameraPosition:cam];
        loadedLocation = YES;
    }
}

//called when camera updates its position
- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    GMSVisibleRegion region = [[self.mapView projection] visibleRegion];
    
    //clear markers
    [self.mapView clear];
    [self loadMarkers:region];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.mapView.padding = UIEdgeInsetsMake(0,0,100,0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOutButton:(UIBarButtonItem *)sender {
    
    if ([Util hasUserLoggedIn]) {
       [self performSegueWithIdentifier:@"SegueToUserProfile" sender:self];
    } else {
        [self performSegueWithIdentifier:@"SegueToLogIn" sender:self];
    }
}

- (IBAction)addToiletButton:(id)sender {
    if([Util hasUserLoggedIn]){
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:_mapView.myLocation.coordinate completionHandler:^ (GMSReverseGeocodeResponse* response, NSError* error) {
            if([[response results] count] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro" message:@"Aguarde o GPS obter sua localização" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                for(GMSAddress* addressObj in [response results])
                {
                    NSLog(@"locality=%@", addressObj.locality);
                    NSLog(@"administrativeArea=%@", addressObj.administrativeArea);
                    NSLog(@"country=%@", addressObj.country);
                    if(addressObj.locality && addressObj.country && addressObj.administrativeArea) {
                        [self performSegueWithIdentifier:@"AddToiletIdentifier" sender:addressObj];
                        break;
                    }
                }
            }
        }];
    } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login first" message:@"You need to be loggeg in to use this feature" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
    }
}

- (UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"MapInfoWindow" owner:self options:nil] objectAtIndex:0];
    
    infoWindow.mapInfoActivity.hidden = NO;
    [infoWindow.mapInfoActivity startAnimating];
    infoWindow.toiletQuant.hidden = YES;
    infoWindow.score.hidden = YES;
    
    GTLPlaceendpointPlace *place = marker.userData;
    infoWindow.name.text = place.name;
    
    [self retrieveToilets: placeid];
    
    placeid = place.identifier;
    
    NSLog(@"place id: %@", place.identifier);
    
    [self performSelector:@selector(callInfoMethod) withObject:nil];

    return infoWindow;
}

- (void) stopToiletActivity {
    
    NSLog(@"stopToiletActivity");
    [timerInfo invalidate];
    timerInfo = nil;
    
    infoWindow.mapInfoActivity.hidden = YES;
    [infoWindow.mapInfoActivity stopAnimating];
    infoWindow.toiletQuant.hidden = NO;
    infoWindow.score.hidden = NO;
    
    infoWindow.toiletQuant.text = textToiletQuant;
    infoWindow.score.text = [self calculateToiletsMediaFromReviews];
    
}

- (void) doToiletVerification {
    
    NSLog(@"doToiletVerification");
    
    NSLog(@"self.stp_reviews: %hhd", self.stp_reviews);
    NSLog(@"self.stp_toilets: %hhd", self.stp_toilets);
    
    if (self.stp_reviews && self.stp_toilets) {
        [self performSelectorOnMainThread:@selector(stopToiletActivity) withObject:nil waitUntilDone:NO];
    }
}


- (void) callInfoMethod {
    
    NSLog(@"callInfoMethod");
    
    timerInfo = [NSTimer scheduledTimerWithTimeInterval:3
                                         target:self
                                       selector:@selector(doToiletVerification)
                                       userInfo: nil
                                        repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer: timerInfo forMode: NSDefaultRunLoopMode];
    
}

- (void) mapView:(GMSMapView *) mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    globalMarker = [[GMSMarker alloc] init];
    globalMarker = marker;
    [self performSegueWithIdentifier:@"SegueToToiletsOfPlace" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"SegueToToiletsOfPlace"])
    {
        [[segue destinationViewController] getMarker:globalMarker];
    }
    
    if([segue.identifier isEqualToString:@"AddToiletIdentifier"]) {
        NSLog(@"prepareForSegueIn");
        AddToiletViewController *controller = segue.destinationViewController;
        controller.myAddress = sender;
    }
    
}

- (GTLServicePlaceendpoint *) placeService {
    
    static GTLServicePlaceendpoint *service = nil;
    if (!service) {
        service = [[GTLServicePlaceendpoint alloc] init];
        service.retryEnabled = YES;
    }
    return service;
}

- (GTLServiceToiletendpoint *) toiletService {
    
    static GTLServiceToiletendpoint *service = nil;
    if (!service) {
        service = [[GTLServiceToiletendpoint alloc] init];
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


- (void) retrieveToilets : (NSNumber *) place_id{
   
    long long long_id = [place_id longLongValue];
    self.stp_toilets = NO;
    
    
    GTLServiceToiletendpoint *service = [self toiletService];
    GTLQueryToiletendpoint *query = [GTLQueryToiletendpoint queryForListToiletByPlaceIdWithPlaceId:long_id];

    infos_toilet = [[NSMutableArray alloc]init];

    NSMutableArray *totalToilets = [[NSMutableArray alloc] init];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLToiletendpointToilet *object, NSError *error) {
        @try {
            NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:object, nil];
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [infos_toilet addObject:[obj valueForKey:@"items"]];
            }];
            
            [infos_toilet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                for (NSInteger i=0; i < [obj count]; i++) {
                    GTLToiletendpointToilet *toiletAtIndex = [obj objectAtIndex:i];
                    [totalToilets addObject:toiletAtIndex];
                    if (stop) {
                        self.stp_toilets = YES;
                        [self retrieveReviews];
                    }

                }
            }];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            textToiletQuant = [NSString stringWithFormat:@"%lu",(unsigned long)[totalToilets count]];
        }
    }];
}

- (void) retrieveReviews {
    
    self.stp_reviews = NO;
    
    GTLServiceReviewendpoint *service = [self reviewService];
    infos_review = [[NSMutableArray alloc]init];
    totalReviews = [[NSMutableArray alloc] init];

    [infos_toilet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        for (NSInteger i=0; i < [obj count]; i++) {
            GTLToiletendpointToilet *toiletAtIndex = [obj objectAtIndex:i];
            long long long_id = [toiletAtIndex.identifier longLongValue];
            GTLQueryReviewendpoint *query = [GTLQueryReviewendpoint queryForListReviewByToiletIDWithToiletId:long_id];
            [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLReviewendpointReview *object, NSError *error) {
                @try {
                    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:object, nil];
                    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [infos_review addObject:[obj valueForKey:@"items"]];
                    }];
                    
                    [infos_review enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        for (NSInteger i=0; i < [obj count]; i++) {
                            GTLReviewendpointReview *reviewAtIndex = [obj objectAtIndex:i];
                            [totalReviews addObject:reviewAtIndex];
//                            NSLog(@"reviews: %@", totalReviews);
                        }
                        if (stop) {
                            self.stp_reviews = YES;
                        }
                    }];
                }
                @catch (NSException *exception) {
                
                }
                @finally {
                
                }
            
            }];
            
        }
    }];
    
}

- (NSString *) calculateToiletsMediaFromReviews {
    
    NSMutableArray * mediumScore = [[NSMutableArray alloc] init];
    
    if ([totalReviews count] >= 1) {
        
        [totalReviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            for (NSInteger z=0; z < [totalReviews count]; z++) {
                GTLReviewendpointReview *reviewAtIndex = [totalReviews objectAtIndex:z];
                clean = reviewAtIndex.cleanlinessScore;
                infra = reviewAtIndex.infrastructureScore;
                features = reviewAtIndex.featuresScore;
            
                NSNumber * mediascore = [NSNumber numberWithFloat:([clean floatValue] +
                                                               [infra floatValue] +
                                                               [features floatValue]) / 3];
            
                [mediumScore addObject:mediascore];
                
            }
        }];
        
    
        [mediumScore enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            for (NSInteger z=0; z < [mediumScore count]; z++) {
                NSNumber *mediaAtIndex = [mediumScore objectAtIndex:z];
                localMedia = 0;
                localMedia = [NSNumber numberWithFloat:([localMedia floatValue] + [mediaAtIndex floatValue])];
            }
        }];

        float size = (float) [totalReviews count];
    
        media = [NSNumber numberWithFloat:[localMedia floatValue] / size];
    
        return [NSString stringWithFormat:@"%@",media];
        
    } else {
        return @"0";
    }
   
}


@end
