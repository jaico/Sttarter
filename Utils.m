//
//  Utils.m
//  Sttarter
//
//  Created by Prajna Shetty on 27/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "Utils.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>
#import "STTaterCommunicator.h"

@implementation Utils


static Utils* shared = nil;


+(Utils*)shared
{
    @synchronized([Utils class])
    {
        if (!shared)
        shared = [[self alloc] init];
        [shared checkInternetReachability];
        return shared;
    }
    return nil;
}

-(void)checkInternetReachability{
    
    BOOL isConnected;
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    
    if (internetStatus == NotReachable)
    {
        isConnected = FALSE;
    }
    else
    {
        isConnected = TRUE;
    }
    
    
    NSLog(@"!!!!!! Observer Added : kReachabilityChangedNotification!!!!!!");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    
    [reachability startNotifier];
}

-(BOOL)checkIfInternetConnectionExists{
    
    
    BOOL isConnected;
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    
    if (internetStatus == NotReachable)
    {
        isConnected = FALSE;
    }
    else
    {
        isConnected = TRUE;
    }

    static dispatch_once_t onceToken1;
    dispatch_once(&onceToken1, ^{
        
        NSLog(@"!!!!!! Observer Added : kReachabilityChangedNotification!!!!!!");

        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityDidChange:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];

    
    });
    
//    NSInteger oneTime = [[NSUserDefaults standardUserDefaults] integerForKey:@"ReachabilityDidChange"];
//    
//    if(oneTime ==  0){
//        
//        NSLog(@"!!!!!! Observer Added : kReachabilityChangedNotification!!!!!!");
//
//        oneTime = 1;
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(reachabilityDidChange:)
//                                                     name:kReachabilityChangedNotification
//                                                   object:nil];
//    }

    
    [reachability startNotifier];
    
    return isConnected;
}


- (void)reachabilityDidChange:(NSNotification *)notification {
   
    Reachability *reachability = (Reachability *)[notification object];
    
    
    if ([reachability isReachable]) { /// isReachableViaWiFi or ReachableViaWWAN
        
        NSLog(@"!!!!!! Connectivity Observer: Just Connected to Internet !!!!!!");
        
        /// observer for things to be done in communicator class..
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OnReconnectingToInternet" object:self userInfo:nil];
        
    } else {
        NSLog(@"!!!!!! Connectivity reachabilityDidChange: Just disconnected from Internet !!!!!!");
    }
}



//Creating timestamp
- (NSString*)GetCurrentEpochTime
{
    
    NSDate* localDate1 = [NSDate date];
    NSTimeInterval ti2 = [localDate1 timeIntervalSince1970];
    NSString *str= [NSString stringWithFormat:@"%f",ti2];
//    NSLog(@"After conversion :%f ",ti2);
    return str;
    
}


-(NSString*)getClientId
{
    // Cleint id = appkey-UDID-UserID
    NSLog(@"**** entered *** getClientId");

//    NSString* UDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];

    NSString *strUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"];

//    NSString *strClientId = [NSString stringWithFormat:@"%@-%@-%@",strAppKey,UDID,strUser];
    NSString *strClientId = [NSString stringWithFormat:@"%@-%@",strAppKey,strUser];

    
    [[NSUserDefaults standardUserDefaults] setObject:strClientId forKey:@"MQTT_CLIENT_ID"];//Your master

    [[NSUserDefaults standardUserDefaults] synchronize];

    
    return strClientId;
}


-(NSString *)getBaseURLString{
  
  NSString *baseURLString = @"";

  baseURLString = @"http://dev.sttarter.com:9000/";
  if(self.environmentTag == 0){ // Dev
    baseURLString = @"http://dev.sttarter.com:9000/";
  }else if(self.environmentTag == 1){ // Prod
    baseURLString = @"http://sttarter.com:9000/";
  }
  return baseURLString;
}

-(int)getMQTTPort{
  
  int host = 1884;
  if(self.environmentTag == 0){ // Dev
    host = 1884;
  }else if(self.environmentTag == 1){ // Prod
    host = 1884;
  }
  return host;
}

-(NSString *)getMQTTHostString{
  
  NSString *baseURLString = @"dev.sttarter.com";
  
  if(self.environmentTag == 0){ // Dev
    baseURLString = @"dev.sttarter.com";
  }else if(self.environmentTag == 1){ // Prod
    baseURLString = @"sttarter.com";
  }
  return baseURLString;
}


@end
