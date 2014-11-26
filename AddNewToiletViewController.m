//
//  AddNewToiletViewController.m
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 9/16/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import "AddNewToiletViewController.h"

@interface AddNewToiletViewController ()

@end

@implementation AddNewToiletViewController
{
    NSArray *categoryNames;
    NSString *selectedCategory;
    GTLPlaceendpointPlace * localPlace;
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
    
    categoryNames = @[@"Masc", @"Fem", @"Unisex"];
    selectedCategory = [categoryNames objectAtIndex:0];
    
    self.toiletType = [[UIPickerView alloc] init];
    self.toiletType.dataSource = self;
    self.toiletType.delegate = self;
    
    self.changingTableSwitch.on = NO;
    self.paidSwitch.on = NO;
    self.accessibilitySwitch.on = NO;
    self.childSwitch.on = NO;
    self.publicSwitch.on = NO;
    
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return categoryNames.count;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedCategory = [categoryNames objectAtIndex:row];
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [categoryNames objectAtIndex:row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (GTLServiceToiletendpoint *) toiletService {
    
    static GTLServiceToiletendpoint *service = nil;
    if (!service) {
        service = [[GTLServiceToiletendpoint alloc] init];
        service.retryEnabled = YES;
    }
    return service;
}

- (IBAction)saveNewToilet:(id)sender {
    
    [self sentToiletToServer];
}

- (void) getPlace : (GTLPlaceendpointPlace *) place {
    
    localPlace = [[GTLPlaceendpointPlace alloc] init];
    localPlace = place;
    NSLog(@"place: %@ ", localPlace.name);
}


-(void)sentToiletToServer
{

    GTLToiletendpointToilet * toilet = [[GTLToiletendpointToilet alloc] init];
    
    [toilet setName:self.toiletName.text];
    [toilet setPlaceId:localPlace.identifier];
    [toilet setCreationDate:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
    [toilet setCategory:selectedCategory];
    [toilet setPaid:[NSNumber numberWithBool:self.paidSwitch.isOn]];
    [toilet setChangingTable:[NSNumber numberWithBool:self.changingTableSwitch.isOn]];
    [toilet setChildToilet:[NSNumber numberWithBool:self.childSwitch.isOn]];
    [toilet setAccessibility:[NSNumber numberWithBool:self.accessibilitySwitch.isOn]];
    [toilet setPublicProperty:[NSNumber numberWithBool:self.publicSwitch.isOn]];
    
    GTLServiceToiletendpoint *service = [self toiletService];
    GTLQueryToiletendpoint *query = [GTLQueryToiletendpoint queryForInsertToiletWithObject:toilet];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        NSLog(@"Log error: %@ ", [error localizedDescription]);
        NSLog(@"executeQuery:query ");
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.toiletName isFirstResponder] && [touch view] != self.toiletName) {
        [self.toiletName resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

@end
