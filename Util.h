//
//  Util.h
//  ToiGuruiOSApp
//
//  Created by João Martinez on 08/09/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

extern int const NO_INTERNET_CONNECTION;
extern int const WIFI_CONNECTION;
extern int const DATA_CONNECTION;

+ (int) checkInternetConnection;
+ (BOOL) checkIfConnected;
+ (BOOL) hasUserLoggedIn;
+ (NSNumber *) stringInToNSNumber : (NSString *) mystring;

@end
