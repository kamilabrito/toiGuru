//
//  Util.m
//  ToiGuruiOSApp
//
//  Created by João Martinez on 08/09/14.
//  Copyright (c) 2014 Kamila Brito. All rights reserved.
//

#import "Util.h"
#import "Reachability.h"
#import "Constants.h"

@implementation Util

int const NO_INTERNET_CONNECTION = 0;
int const WIFI_CONNECTION = 1;
int const DATA_CONNECTION = 2;

+ (int) checkInternetConnection
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == ReachableViaWiFi)
    {
        //WiFi
        return WIFI_CONNECTION;
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        return DATA_CONNECTION;
    }
    return NO_INTERNET_CONNECTION;
}

+ (BOOL) checkIfConnected
{
    if ([Util checkInternetConnection] == NO_INTERNET_CONNECTION) {
        return false;
    }
    return true;
}

+ (BOOL) hasUserLoggedIn{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userName = [defaults objectForKey:defaults_key_username];
    NSString *password = [defaults objectForKey:defaults_key_password];
    
    if ((([userName length] == 0) || ([password length] == 0)) || ((userName == nil) || (password  == nil))) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSNumber *) stringInToNSNumber : (NSString *) mystring {
    
    long long longValue = [mystring longLongValue];
    
    NSNumber  *numValue = [NSNumber numberWithUnsignedLongLong:longValue];
    
    return numValue;
}

@end
