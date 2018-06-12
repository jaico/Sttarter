//
//  STTarterReferrals.h
//  Sttarter
//
//  Created by Vijeesh on 17/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChangeRefModel.h"
#import "TrackUsageModel.h"

@protocol STTarterReferralsDelegate <NSObject>
@optional
-(void)customizeReferralCodeFailure:(NSString*)errorMessage;
-(void)customizeReferralCodeSuccess:(ChangeRefModel*)modelChangeReferral;

-(void)getReferralsSucces:(NSString*)referralCode;
-(void)getReferralsFailure:(NSString*)errorMessage;

-(void)trackReferralFailure:(NSString*)strErrorMessage;
-(void)trackReferralSuccess:(TrackUsageModel*)trackReferrals;

-(void)referralAddtransactionSucces;
-(void)referralAddtransactionFailure:(NSString*)errorMessage;
@required
-(void)signupwithReferralcodeSuccess;
-(void)sigupwithReferralcodeFailure:(NSString*)errorMessage;


//STTarterReferrals

@end

@interface STTarterReferrals : NSObject

@property (nonatomic,strong) id <STTarterReferralsDelegate> delegate;

-(void)customizeReferralCode:(NSString*)oldCode newCode:(NSString*)newCode;
-(void)trackUsage;
-(void)addTransaction:(NSString*)transactionID transactionAmount:(NSString*)transactionAmount;
-(void)getReferral;

-(void)registerNewUserThroughReferralCode:(NSString*)referer_code;

//+ (STTarterReferrals*)sttarterReferralClass;

+(STTarterReferrals*)sharedReferralsClass;


//+(STTarterReferrals*)sharedSttarterClass;


@end
