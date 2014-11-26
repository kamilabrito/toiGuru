//
//  CheckInViewController.m
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 8/26/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import "ToiletViewController.h"

#import "ToiletDetailViewController.h"
#import "GTLToiletendpoint.h"
#import "GTMHTTPFetcherLogging.h"
#import "AddNewToiletViewController.h"

#import <GoogleMaps/GoogleMaps.h>

@interface ToiletViewController ()

@end

@implementation ToiletViewController
{
    NSNumber * placeIdGlobal;
    GTLPlaceendpointPlace *place;
}

@synthesize toiletsArray, tableView, toiletListIndicator;

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
    
    toiletsArray = [[NSMutableArray alloc] init];
    
    [self getToiletInfo];
    
    toiletListIndicator.hidden = NO;
    [toiletListIndicator startAnimating];
    
    [self.tableView setHidden:YES];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSInteger row = [indexPath row];
    
    GTLToiletendpointToilet *toiletAtIndex = [toiletsArray objectAtIndex:row];
    
    if (toiletAtIndex.name == NULL) {
        cell.textLabel.text = @"no name";
    } else {
        cell.textLabel.text = toiletAtIndex.name;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [toiletsArray count];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ToiletDetailSegue"])
    {
        NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
        
        //get the object for the selecte row
        
        GTLToiletendpointToilet * object = [toiletsArray objectAtIndex:indexPath.row];
        
        [[segue destinationViewController] getToilet: object];
    }
    
    if ([[segue identifier] isEqualToString:@"addNewToiletSegue"])
    {
        [[segue destinationViewController] getPlace: place];
        NSLog(@"place list:%@ ", place);
    }
    
}

- (void) getMarker : (GMSMarker *) marker {
    
    place = [[GTLPlaceendpointPlace alloc] init];
    place = marker.userData;
    placeIdGlobal = place.identifier;
    
}

- (GTLServiceToiletendpoint *) toiletService {
    
    static GTLServiceToiletendpoint *service = nil;
    if (!service) {
        service = [[GTLServiceToiletendpoint alloc] init];
        service.retryEnabled = YES;
    }
    return service;
}


- (void) getToiletInfo {
    
    long long long_id = [placeIdGlobal longLongValue];
    
    GTLServiceToiletendpoint *serviceToilet = [self toiletService];
    GTLQueryToiletendpoint *queryToilet = [GTLQueryToiletendpoint queryForListToiletByPlaceIdWithPlaceId:long_id];
    
    NSMutableArray *infos = [[NSMutableArray alloc]init];
    
    //request toilet info from server
    [serviceToilet executeQuery:queryToilet completionHandler:^(GTLServiceTicket *ticket, GTLToiletendpointToilet *object, NSError *error) {
        
        NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:object, nil];
        
        @try {
            //separetes info from server by block and and block to nsmutablearray
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [infos addObject:[obj valueForKey:@"items"]];
            }];
            
            [infos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                for (NSInteger i=0; i < [obj count]; i++) {
                    GTLToiletendpointToilet *toiletAtIndex = [obj objectAtIndex:i];
                    [toiletsArray addObject:toiletAtIndex];
                    NSLog(@"toilets array: %@", toiletsArray);
                }
                if (stop) {
                    [self stopAnimation];
                }
            }];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
            
        }
    }];
    
}

- (void) stopAnimation {

    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView reloadData];
    [toiletListIndicator stopAnimating];
    toiletListIndicator.hidden = YES;
    [self.tableView setHidden:NO];
}

@end
