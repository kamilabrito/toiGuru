//
//  CheckInDetailViewController.m
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 8/29/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import "ToiletDetailViewController.h"

#import "ReviewViewController.h"

#import "GTLToiletendpoint.h"
#import "GTLPlaceendpoint.h"
#import "GTLCheckinendpoint.h"
#import "Util.h"


@interface ToiletDetailViewController ()

@end

@implementation ToiletDetailViewController{
    NSString *placeIdentifier;
    NSMutableArray *checkInInfos;
    NSTimer *t;
    NSMutableArray * infos_review;
    NSMutableArray *toiletReview;
    NSNumber * media, * localMedia;
}
@synthesize currentToilet, toiletName, totalCheckInLabel, userTotalCheckInLabel, toiletStoreLabel, detailIndicator, tableView;

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
    
    toiletName.text = currentToilet.name;
    
    detailIndicator.hidden = NO;
    [detailIndicator startAnimating];
    
    [self getPlaceInfo];
    [self getCheckIns];
    [self retrieveReviews];
    
    t = [NSTimer scheduledTimerWithTimeInterval:5
                                         target:self
                                       selector:@selector(setDetailsTexts)
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

- (void) getToilet:(GTLToiletendpointToilet *)toiletObject {

    currentToilet = toiletObject;
    
    NSLog(@"toilet name: %@", toiletObject.name);
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"reviewCustomCell";
    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSInteger row = [indexPath row];
    
    GTLReviewendpointReview *toiletAtIndex = [toiletReview objectAtIndex:row];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *scoreLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *commentLabel = (UILabel *)[cell viewWithTag:102];
    
    if (toiletAtIndex.title == NULL) {
        titleLabel.text = @"no title";
    } else {
        titleLabel.text = toiletAtIndex.title;
    }
    
    scoreLabel.text = [self calculateSingleReviewMedia:toiletAtIndex];
    
    if (toiletAtIndex.writenReview == NULL) {
        commentLabel.text = @"no comments";
    } else {
        commentLabel.text = toiletAtIndex.writenReview;
    }
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [toiletReview count];
}

- (GTLServicePlaceendpoint *) placeService {
    
    static GTLServicePlaceendpoint *service = nil;
    if (!service) {
        service = [[GTLServicePlaceendpoint alloc] init];
        service.retryEnabled = YES;
    }
    return service;
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


- (IBAction)confirmCheckInButton:(id)sender {
    
    if([Util hasUserLoggedIn]){
        [self registerCheckIn:[self createCheckInObject]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login first" message:@"You need to be loggeg in to use this feature" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (GTLCheckinendpointCheckIn *) createCheckInObject {
    
    GTLCheckinendpointCheckIn *checkin = [[GTLCheckinendpointCheckIn alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults objectForKey:@"user_id"];
    
    long long placeIdLong = [placeIdentifier longLongValue];
    long long userIdLong = [userId longLongValue];
    
    NSNumber * placeIdNum = [NSNumber numberWithUnsignedLongLong:placeIdLong];
    NSNumber  *userIdNum = [NSNumber numberWithUnsignedLongLong:userIdLong];
   
    [checkin setPlaceId:placeIdNum];
    [checkin setUserId:userIdNum];
    [checkin setCreationDate:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
    [checkin setToiletId:currentToilet.identifier];
    
    return checkin;
}

- (void) registerCheckIn : (GTLCheckinendpointCheckIn *) checkIn {
    
    GTLServiceCheckinendpoint *serviceCheckIn = [self checkInService];
    GTLQueryCheckinendpoint *queryCheckIn = [GTLQueryCheckinendpoint queryForInsertCheckInWithObject:checkIn];
    
    [serviceCheckIn executeQuery:queryCheckIn completionHandler:^(GTLServiceTicket *ticket, GTLObject *object, NSError *error) {
        NSLog(@"Log error: %@ ", [error localizedDescription]);
        NSLog(@"executeQuery Check in");
    }];
}

- (void) getCheckIns {
    
    long long long_id = [currentToilet.identifier longLongValue];
    
    GTLServiceCheckinendpoint *serviceCheckIn = [self checkInService];
    GTLQueryCheckinendpoint *queryCheckIn = [GTLQueryCheckinendpoint queryForListCheckInByToiletIdWithToiletId:long_id];

    checkInInfos = [[NSMutableArray alloc]init];
    
    NSMutableArray *totalCheckIns = [[NSMutableArray alloc] init];
    
    self.stp_toilet = NO;
    
    [serviceCheckIn executeQuery:queryCheckIn completionHandler:^(GTLServiceTicket *ticket, GTLToiletendpointToilet *object, NSError *error) {
        
        NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:object, nil];
        @try {
            //separetes info from server by block and and block to nsmutablearray
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [checkInInfos addObject:[obj valueForKey:@"items"]];
            }];
            
            [checkInInfos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                for (NSInteger i=0; i < [obj count]; i++) {
                    GTLCheckinendpointCheckIn *checkinAtIndex = [obj objectAtIndex:i];
                    if ([checkinAtIndex.toiletId isEqualToNumber:currentToilet.identifier]) {
                        [totalCheckIns addObject:checkinAtIndex];
                    }
                }
                
                if (stop) {
                    self.stp_toilet = YES;
                }
            }];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            NSString *text = [NSString stringWithFormat:@"%lu",(unsigned long)[totalCheckIns count]];
            
            totalCheckInLabel.text = text;
        }
        
    }];

}

- (void) setDetailsTexts {
    
    NSLog(@"setDetailsTexts: %hhd %hhd", self.stp_toilet, self.stp_review );
    
    if (self.stp_toilet && self.stp_review) {
        detailIndicator.hidden = YES;
        [detailIndicator stopAnimating];
        [self getUserToiletCheckIn];
        toiletStoreLabel.text = [self calculateToiletMediaFromReviews];
        tableView.dataSource = self;
        tableView.delegate = self;
        [tableView reloadData];
        [t invalidate];
    }

}

- (void) getUserToiletCheckIn {
    
    NSMutableArray *userCheckIns = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults objectForKey:@"user_id"];
    
    long long userIdLong = [userId longLongValue];
    NSNumber  *userIdNum = [NSNumber numberWithUnsignedLongLong:userIdLong];

    [checkInInfos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        for (NSInteger i=0; i < [obj count]; i++) {
            GTLCheckinendpointCheckIn *checkinAtIndex = [obj objectAtIndex:i];
            if ([checkinAtIndex.userId isEqualToNumber:userIdNum]) {
                [userCheckIns addObject:checkinAtIndex];
            }
        }
    }];
    
    NSString *text = [NSString stringWithFormat:@"%lu",(unsigned long)[userCheckIns count]];
    
    userTotalCheckInLabel.text = text;
}

- (void) getPlaceInfo {

    GTLServicePlaceendpoint *servicePlace = [self placeService];
    GTLQueryPlaceendpoint *queryPlace = [[GTLQueryPlaceendpoint alloc] init];
    
    long long long_id = [currentToilet.placeId longLongValue];
    queryPlace = [GTLQueryPlaceendpoint queryForGetPlaceWithIdentifier:long_id];
    
    [servicePlace executeQuery:queryPlace completionHandler:^(GTLServiceTicket *ticket, GTLPlaceendpointPlace *object, NSError *error) {
        placeIdentifier = [object valueForKey:@"identifier"];
    }];
}

- (void) retrieveReviews {
    
    long long long_id = [currentToilet.identifier longLongValue];
    
    GTLServiceReviewendpoint *service = [self reviewService];
    GTLQueryReviewendpoint *query = [GTLQueryReviewendpoint queryForListReviewByToiletIDWithToiletId:long_id];
    
    infos_review = [[NSMutableArray alloc]init];
    toiletReview = [[NSMutableArray alloc] init];
    
    self.stp_review = NO;
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLReviewendpointReview *object, NSError *error) {
        NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:object, nil];
        @try {
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [infos_review addObject:[obj valueForKey:@"items"]];
            }];
            
            [infos_review enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                for (NSInteger z=0; z < [infos_review count]; z++) {
                    GTLReviewendpointReview *reviewAtIndex = [obj objectAtIndex:z];
                    [toiletReview addObject:reviewAtIndex];
                }
                
                NSLog(@"toilet review: %@", toiletReview);
                
                if (stop)
                {
                    self.stp_review = YES;
                    
                }
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"error review toilet: %@ ", exception);
        }
        @finally {
            
        }
        
    }];
}

- (NSString *) calculateToiletMediaFromReviews {
    
    NSMutableArray * mediumScore = [[NSMutableArray alloc] init];
    
    if ([toiletReview count] >= 1) {
        
        [toiletReview enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            for (NSInteger z=0; z < [toiletReview count]; z++) {
                GTLReviewendpointReview *reviewAtIndex = [toiletReview objectAtIndex:z];
                NSNumber * clean = reviewAtIndex.cleanlinessScore;
                NSNumber * infra = reviewAtIndex.infrastructureScore;
                NSNumber * features = reviewAtIndex.featuresScore;
                
                NSNumber * mediascore = [NSNumber numberWithFloat:([clean floatValue] +
                                                                   [infra floatValue] +
                                                                   [features floatValue]) / 3];
                
                [mediumScore addObject:mediascore];
                
            }
        }];
        
        [mediumScore enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            for (NSInteger z=0; z < [mediumScore count]; z++) {
                NSNumber * mediaAtIndex = [mediumScore objectAtIndex:z];
                localMedia = 0;
                localMedia = [NSNumber numberWithFloat:([localMedia floatValue] + [mediaAtIndex floatValue])];
                
                NSLog(@"local media: %@ ", localMedia);
                
            }
        }];
        
        float size = (float) [toiletReview count];
        
        media = [NSNumber numberWithFloat:[localMedia floatValue] / size];
        
        return [NSString stringWithFormat:@"%@",media];
        
    } else {
        return @"0";
    }

}

- (NSString *) calculateSingleReviewMedia : (GTLReviewendpointReview *) review {
    
    NSNumber * clean = review.cleanlinessScore;
    NSNumber * infra = review.infrastructureScore;
    NSNumber * features = review.featuresScore;
                
    NSNumber * mediascore = [NSNumber numberWithFloat:([clean floatValue] +
                                                                   [infra floatValue] +
                                                                   [features floatValue]) / 3];
    return [NSString stringWithFormat:@"%@",mediascore];
        
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([Util hasUserLoggedIn] && [[segue identifier] isEqualToString:@"segueToReview"]){
        
        [[segue destinationViewController] getToiletId:currentToilet.identifier];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login first" message:@"You need to be loggeg in to use this feature" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    
}


- (IBAction)reviewButton:(id)sender {
    
    
}
@end
