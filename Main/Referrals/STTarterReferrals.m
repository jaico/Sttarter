//
//  STTarterReferrals.m
//  Sttarter
//
//  Created by Vijeesh on 17/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "STTarterReferrals.h"
#import "DownloadManager.h"
@implementation STTarterReferrals

static STTarterReferrals* sttarterReferralClass = nil;

+ (STTarterReferrals*)sharedReferralsClass{
    @synchronized([STTarterReferrals class]) {
        if (!sttarterReferralClass){
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSData *myEncodedObject = [prefs objectForKey:@"AUTH_MODEL" ];
            if(myEncodedObject == nil || myEncodedObject == (NSData*)[NSNull null]){
                
                return nil;
                
            }
            AuthModel *modelAuth = (AuthModel *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
            
            for (int i=0; i < modelAuth.permitted_modules.count; i++) {
                
                PermittedModulesModel *modelperModules = [modelAuth.permitted_modules objectAtIndex:i];
                
                if ([[modelperModules.module_name uppercaseString]isEqualToString:@"REFERRALS"] ) {
                    sttarterReferralClass = [[self alloc] init];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"is_ReferralsPermitted"];
                    NSLog(@"!!!!!! REFERRALS is permitted and Initialized !!!!!!");
                    
                    return sttarterReferralClass;
                }

            }
            return nil;
        }
        return sttarterReferralClass;
    }
}


-(void)getReferral
{
    
    
    [[DownloadManager shared]GetReferralCode:^(NSError *error, GetRefCodeModel *modelGetRef, NSString *errTitle, NSString *errMsg){
        if (error)
        {
            NSLog(@"***** getReferrals failed %@",errMsg);
            [self.delegate getReferralsFailure:errMsg];
            
        }
        else
        {
            NSLog(@"***** getReferrals Success %@",errMsg);
            NSLog(@"***** Ref_code %@",modelGetRef.code);
            
            [self.delegate getReferralsSucces:modelGetRef.code];
        }
    }];
    
//    [[DownloadManager shared]GetReferralCode:userName name:name email:email phone:mobile appXToken:strAppXToken completionBlock:^(NSError *error, GetRefCodeModel *modelGetRef, NSString *errTitle, NSString *errMsg)
//     {
//         if (error)
//         {
//             NSLog(@"***** getReferrals failed %@",errMsg);
//             [self.delegate getReferralsFailure:errMsg];
//             
//         }
//         else
//         {
//             NSLog(@"***** getReferrals Success %@",errMsg);
//             NSLog(@"***** Ref_code %@",modelGetRef.code);
//             
//             [self.delegate getReferralsSucces:modelGetRef.code];
//         }
//     }];
    
}

-(void)customizeReferralCode:(NSString*)oldCode newCode:(NSString*)newCode
{
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    [[DownloadManager shared]ChangeReferralCode:oldCode customcode:newCode strAppxToken:strAppXToken completionBlock:^(NSError *error, ChangeRefModel *modelChangeRef, NSString *errTitle, NSString *errMsg)
     {
         if (error)
         {
             NSLog(@"***** changeReferral failed %@",errMsg);
             [self.delegate customizeReferralCodeFailure:errMsg];
             
         }
         else
         {
             NSLog(@"***** changeReferral Success");
             [self.delegate customizeReferralCodeSuccess:modelChangeRef];
             
         }
         
     }];
}


-(void)trackUsage
{
    [[DownloadManager shared]TrackUsages:^(NSError *error, TrackUsageModel *modelTrackUsage, NSString *errTitle, NSString *errMsg) {
        if (error)
        {
            NSLog(@"***** Track Usage failed %@",errMsg);
            [self.delegate trackReferralFailure:errTitle];
        }
        else
        {
            [self.delegate trackReferralSuccess:modelTrackUsage];
        }
    }];
}



-(void)registerNewUserWithReferralCode:(NSString*)referer_code {
 
    
    [[DownloadManager shared]registerNewUserThroughRefCode:referer_code completionBlock:^(NSError *error, NSString *errTitle, NSString *errMsg){
        
//    [[DownloadManager shared]STT_signupUsingReferrelCode:externalUserId name:name email:email phone:phone referer_code:referer_code refmodel:refmodel completionBlock:^(NSError *error, id modelRefSignUp, NSString *errTitle, NSString *errMsg) {
        
         if (error)
         {
             NSLog(@"***** signupUsingReferralCode failed %@",errMsg);
             [self.delegate signupwithReferralcodeSuccess];
             
         }
         else
         {
             [self.delegate signupwithReferralcodeSuccess];
             
         }
         
     }];
}


-(void)addTransaction:(NSString*)transactionID transactionAmount:(NSString*)transactionAmount
{
    
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    NSDictionary *dctLogindata = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"STT_LOGIN_INFO"];
    
    
    [[DownloadManager shared]referralAddTransacrion:[dctLogindata valueForKey:@"username"] transaction_id:transactionID transaction_amount:transactionAmount appXToken:strAppXToken completionBlock:^(NSError *error, NSString *status, NSString *title, NSString *msg)
     {
         if (error)
         {
             NSLog(@"referral Add transaction failed%@",msg);
             [self.delegate referralAddtransactionFailure:msg];
         }
         else
         {
             NSLog(@"referral Add transaction Success%@",msg);
             [self.delegate referralAddtransactionSucces];
             
         }
     }];
}


@end
