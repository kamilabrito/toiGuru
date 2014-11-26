//
//  ReviewViewController.h
//  ToiGuruiOSApp
//
//  Created by Kamila Brito on 9/1/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMHTTPFetcherLogging.h"
#import "GTLReviewendpoint.h"

@interface ReviewViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *commentsTextBox;
@property (strong, nonatomic) IBOutlet UITextField *cleanlinessTextField;
@property (strong, nonatomic) IBOutlet UITextField *infrastructureTextField;
@property (strong, nonatomic) IBOutlet UITextField *featuresTextField;
- (IBAction)sendButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *reviewTitleTextField;

- (GTLServiceReviewendpoint *) reviewService;

- (void) registerReview : (GTLReviewendpointReview *) review;

- (void) getToiletId : (NSNumber *) toiletId;

@end
