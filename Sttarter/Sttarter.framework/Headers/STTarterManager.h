//
//  SttarterClass.h
//  SttarterClass
//
//  Created by Prajna Shetty on 21/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManager.h"
#import "GetOtpModel.h"
#import "OtpLoginModel.h"
#import "JSONModel.h"
#import "TopicsModel.h"
#import "AuthModel.h"
#import "SignUpModel.h"
#import "SignUpUserInfoModel.h"
#import "Referrals.h"
#import "DatabaseHandler.h"

//typedef NS_ENUM(NSUInteger, AuthType){
//    STTARTER_ACCOUNT_AUTH=0,//user name,pass
//    STTARTER_OTP_AUTH,//
//    STTARTER_CUSTOM_AUTH//external user id
//};

//#import "UIWebView+AFNetworking.h"
@protocol STTarterDelegate <NSObject>

@optional
-(void)signupwithReferralcodeSuccess;
-(void)sigupwithReferralcodeFailure:(NSString*)errorMessage;

-(void)changeReferralcodeFailure:(NSString*)errorMessage;
-(void)changeReferralcodeSuccess:(ChangeRefModel*)modelChangeReferral;

-(void)getReferralsSucces:(NSString*)referralCode;
-(void)getReferralsFailure:(NSString*)referralCode;;

-(void)referralAddtransactionSucces;
-(void)referralAddtransactionFailure:(NSString*)errorMessage;

-(void)trackReferralFailure:(NSString*)strErrorMessage;
-(void)trackReferralSuccess:(TrackUsageModel*)trackReferrals;

//callLoginApi/ Login
-(void)loginFailureDelegateMethod:(NSMutableDictionary*)dctAlertInfo;//LoginFailureNotification
-(void)loginSuccessDelegateMethod;//LoginSuccessNotification

//callSignUpApi  SignUp with Sttarter
-(void)signUpFailureDelegateMethod:(NSString*)strErrorMessage;//
-(void)signUpSuccessDelegateMethod;//SignUpSuccessNotification

//SttarterClassQuickLogin
//-(void)quickLoginDelegateMethod:(NSMutableDictionary*)dctAlertInfo;
-(void)signupWithOTPSuccessDelegateMethod:(NSMutableDictionary*)dctAlertInfo;
-(void)signupWithOTPFailureDelegateMethod:(NSString*)errorMessage;

//SttarterClassGetOTP
-(void)getOTPSuccess:(NSString*)msg;
-(void)getOTPFailure:(NSString*)msg;//LoginAlertNotification(***)

//SttarterClassVerifyOTP /confirmOTPWithServer
-(void)verifyOTPSuccess:(NSString*)msg;
-(void)verifyOTPFailure:(NSString*)msg;//AlertNotification

// loginwithCustomAuth
-(void)loginwithCustomAuthSuccess:(NSString*)message;
-(void)loginwithCustomAuthFailure:(NSString*)message;


@required
//callAuthApi
-(void)authFailureDelegateMethod:(NSMutableDictionary*)dctAlertInfo;//AuthFailureNotification
-(void)authSuccessDelegateMethod:(NSMutableDictionary*)dctAlertInfo;//AuthSuccessNotification

@end



@interface STTarterManager : NSObject
{

    id <STTarterDelegate> _delegate;
}

@property (nonatomic,strong) id <STTarterDelegate> delegate;
+(STTarterManager*)sharedSttarterClass;


//Init Functions
-(void)STTarterInit:(NSString *)strAppKey appSecret:(NSString *)strAppSecret; //Authenticate APP Only
-(void)STTarterInit:(NSString *)strAppKey appSecret:(NSString *)strAppSecret username:(NSString *)strUsername password:(NSString *)strPassword; // Authenticate App and User with STTarter Auth
-(void)STTarterInit:(NSString *)strAppKey appSecret:(NSString *)strAppSecret externalUserId:(NSString *)strExternalUserId;
//Authenticate App and Store External User ID
-(void)loginwithCustomAuth:(NSString*)externalUserId; // Assumes app is already authenticated


//Sign Up functions
-(void)signUp:(NSString *)strAppKey appSecret:(NSString *)strAppSecret userData:(SignUpUserInfoModel*)userModelToSignUp; //Authenticate app and then do a sign up
-(void)signUp:(SignUpUserInfoModel*)userModelToSignUp;// Sign Up with Sttarter Auth (assuming app is authenticated already)

//Log Out - clears all the data
-(void)logout;

// Push notification

-(void)RegisterForPush:(NSString*)deviceToken;



@end
