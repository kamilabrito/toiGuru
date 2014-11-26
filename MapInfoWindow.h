//
//  MapInfoWindow.h
//  ToiGuruiOSApp
//
//  Created by João Martinez on 13/08/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapInfoWindow : UIView

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UILabel *toiletQuant;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mapInfoActivity;

@end
