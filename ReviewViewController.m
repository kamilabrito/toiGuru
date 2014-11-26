//
//  ReviewViewController.m
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 9/1/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import "ReviewViewController.h"
#import "Util.h"

@interface ReviewViewController ()

@end

@implementation ReviewViewController {
    NSNumber * toiletIdGlobal;
    NSNumber * checkInIdGlobal;
}

@synthesize commentsTextBox, cleanlinessTextField, infrastructureTextField, featuresTextField, reviewTitleTextField;

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (GTLServiceReviewendpoint *) reviewService {
    
    static GTLServiceReviewendpoint *service = nil;
    if (!service) {
        service = [[GTLServiceReviewendpoint alloc] init];
        service.retryEnabled = YES;
    }
    return service;
}

-(void)hideKeyboard
{
    [commentsTextBox resignFirstResponder];
    [featuresTextField resignFirstResponder];
    [cleanlinessTextField resignFirstResponder];
    [infrastructureTextField resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([commentsTextBox isFirstResponder] && [touch view] != commentsTextBox) {
        [commentsTextBox resignFirstResponder];
    } else if ([featuresTextField isFirstResponder] && [touch view] != featuresTextField) {
        [featuresTextField resignFirstResponder];
    } else if ([cleanlinessTextField isFirstResponder] && [touch view] != cleanlinessTextField) {
        [cleanlinessTextField resignFirstResponder];
    } else if ([infrastructureTextField isFirstResponder] && [touch view] != infrastructureTextField) {
       [infrastructureTextField resignFirstResponder];
    } else if ([reviewTitleTextField isFirstResponder] && [touch view] != reviewTitleTextField) {
        [reviewTitleTextField resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    //Assign new frame to your view
    if ([commentsTextBox isFirstResponder]) {
        [self.view setFrame:CGRectMake(0,-120,320,450)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
    } else if ([featuresTextField isFirstResponder]) {
        [self.view setFrame:CGRectMake(0,-40,320,450)];
    }
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view setFrame:CGRectMake(0,0,320,480)];
}

- (void) registerReview : (GTLReviewendpointReview *) review {
    
    GTLServiceReviewendpoint *serviceReview = [self reviewService];
    GTLQueryReviewendpoint *queryReview = [GTLQueryReviewendpoint queryForInsertReviewWithObject:review];
    
    [serviceReview executeQuery:queryReview completionHandler:^(GTLServiceTicket *ticket, GTLObject *object, NSError *error) {
        NSLog(@"Log error: %@ ", [error localizedDescription]);
        NSLog(@"executeQuery review");
    }];
}

- (IBAction)sendButton:(id)sender {
    
    NSString * cleanlinessScore = cleanlinessTextField.text;
    NSString * featuresScore = featuresTextField.text;
    NSString * infrastructureScore = infrastructureTextField.text;
    NSString * comments = commentsTextBox.text;
    NSString * reviewTitle = reviewTitleTextField.text;
    
    [self registerReview:[self createReviewObject:[Util stringInToNSNumber:cleanlinessScore]:[Util stringInToNSNumber:featuresScore]:[Util stringInToNSNumber:infrastructureScore]:reviewTitle:comments]];
}

- (GTLReviewendpointReview *) createReviewObject : (NSNumber *) cleanlinessScore : (NSNumber *) featuresScore : (NSNumber *) infrastructureScore : (NSString *) title : (NSString *) comment{
    
    GTLReviewendpointReview *review = [[GTLReviewendpointReview alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults objectForKey:@"user_id"];
    
    
    NSLog(@"toilet user id: %@ ", [Util stringInToNSNumber:userId]);

    
    [review setUserId:[Util stringInToNSNumber:userId]];
    [review setToiletId:toiletIdGlobal];
    [review setCreationDate:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
    [review setCleanlinessScore:cleanlinessScore];
    [review setFeaturesScore:featuresScore];
    [review setInfrastructureScore:infrastructureScore];
    [review setTitle:title];
    [review setWritenReview:comment];

    return review;
}

- (void) getToiletId : (NSNumber *) toiletId  {
    toiletIdGlobal = toiletId;
    NSLog(@"toilet id passed: %@ ", toiletId);
    
    NSLog(@"toilet id global: %@ ", toiletIdGlobal);
}

@end
