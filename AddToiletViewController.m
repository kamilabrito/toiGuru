//
//  AddToiletViewController.m
//  ToiGuruiOSApp
//
//  Created by João Martinez on 18/08/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import "AddToiletViewController.h"
#import "GTMHTTPFetcherLogging.h"


@interface AddToiletViewController ()

@end

@implementation AddToiletViewController {
    NSString *selectedCategory;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.scrollView setScrollEnabled:YES];
    self.categoryNames = @[@"Masc", @"Fem", @"Unisex"];
    selectedCategory = [self.categoryNames objectAtIndex:0];
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.loading.hidden = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapGesture];
}

-(void) viewDidLayoutSubviews
{
    [self.scrollView setContentSize:CGSizeMake(320, 800)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (void)sendPlaceToServer{
    NSLog(@"salvando");
    self.loading.hidden = NO;
    self.saveButton.enabled = NO;
    
    GTLServicePlaceendpoint *service = [self placeService];
    
    GTLQueryPlaceendpoint *query = [GTLQueryPlaceendpoint queryForInsertPlaceWithObject:_place];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLObject *object, NSError *error) {
        
        //get identifier generated in server
        [_place setIdentifier:[[object JSON] valueForKey:@"id"]];
        NSLog(@"Log error: %@ ", [error localizedDescription]);
        NSLog(@"executeQuery:query ");
        [self sentToiletToServer];
    }];
}

-(void)sentToiletToServer
{
    if(!_toilet) {
        _toilet = [[GTLToiletendpointToilet alloc] init];
    }
    
    [_toilet setName:_nameField.text];
    [_toilet setPlaceId:_place.identifier];
    [_toilet setCreationDate:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
    [_toilet setCategory:selectedCategory];
    [_toilet setPaid:[NSNumber numberWithBool:_paidSwitch.isOn]];
    [_toilet setChangingTable:[NSNumber numberWithBool:_babySwitch.isOn]];
    [_toilet setChildToilet:[NSNumber numberWithBool:_kidsSwitch.isOn]];
    [_toilet setAccessibility:[NSNumber numberWithBool:_accessSwitch.isOn]];

    
    GTLServiceToiletendpoint *service = [self toiletService];
    GTLQueryToiletendpoint *query = [GTLQueryToiletendpoint queryForInsertToiletWithObject:_toilet];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        NSLog(@"Log error: %@ ", [error localizedDescription]);
        NSLog(@"executeQuery:query ");
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.categoryNames.count;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedCategory = [self.categoryNames objectAtIndex:row];
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.categoryNames objectAtIndex:row];
}

- (IBAction)onSavePress:(id)sender
{
    if([_nameField.text length] == 0 || [_workingHourField.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro" message:@"Preencha todos os dados para salvar" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        if(!_place) {
            _place = [[GTLPlaceendpointPlace alloc] init];
        }
        
        NSString *latitude = [[NSString alloc] initWithFormat:@"%f", _myAddress.coordinate.latitude];
        
        NSNumberFormatter * flong = [[NSNumberFormatter alloc] init];
        [flong setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * lat = [flong numberFromString:latitude];
        
        NSString *longitude = [[NSString alloc] initWithFormat:@"%f", _myAddress.coordinate.longitude];
        
        NSNumberFormatter * flat = [[NSNumberFormatter alloc] init];
        [flat setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * longi = [flat numberFromString:longitude];
        
        
        [_place setName:_nameField.text];
        [_place setOnTheStreet:[NSNumber numberWithBool:_publicSwitch.isOn]];
        [_place setCreationDate:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
        [_place setProvince:_myAddress.administrativeArea];
        [_place setCountry:_myAddress.country];
        [_place setCity:_myAddress.locality];
        [_place setLatitude:lat];
        [_place setLongitude:longi];
        
        NSLog(@"longitude: %@", lat);
        NSLog(@"latitude: %@", longi);
        
    
        [self sendPlaceToServer];
    }
}

-(void)hideKeyboard
{
    [_nameField resignFirstResponder];
    [_workingHourField resignFirstResponder];
}


@end
