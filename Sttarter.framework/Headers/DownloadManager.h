//
//  DownloadManager.h
//  Sttarter
//
//  Created by Prajna Shetty on 21/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManagerAdditions.h"
#import "DownloadManagerConstants.h"
//#import <AFNetworking/AFNetworking.h>
#import "GetOtpModel.h"
#import "OtpLoginModel.h"
#import "AFNetworking.h"
#import "BuzzMessagesModel.h"
#import "GetRefCodeModel.h"

@interface DownloadManager : NSObject


+ (DownloadManager *)shared;


-(void)ApiGetOtp:(NSString*)strPhoneNumber completionBlock:(apiGetOtpBlock)completionBlock;

-(void)ApiOtpLogin:(NSString*)PhoneNumber OTP:(NSString*)strOtp completionBlock:(apiOtpLoginBlock)completionBlock;

-(void)ApiQuickLogin:(NSString*)strName mobileNo:(NSString*)strMobileNo email:(NSString*)strEmail orgId:(NSString*)strOtp completionBlock:(apiQuickLoginBlock)completionBlock;

-(void)ApiMyTopics:(NSString*)HeaderUserToken appToken:(NSString*)HeaderAppToken  completionBlock:(apiMyTopicsBlock)completionBlock;

-(void)ApiBuzzMessages:(NSString*)HeaderUserToken appToken:(NSString*)HeaderAppToken strTopicId:(NSString*)TopicId completionBlock:(apiBuzzMessagesBlock)completionBlock;

-(void)ApiAuth:(NSString*)app_key app_secret:(NSString*)strApp_secret completionBlock:(apiAuthBlock)completionBlock;

-(void)STT_ApiLogin:(NSString*)strUserName password:(NSString*)strPassword app_XToken:(NSString*)strAppXToken completionBlock:(apiLoginBlock)completionBlock;

-(void)STT_SignUp:( SignUpUserInfoModel*)userModelToSignUp appXToken:(NSString*)strAppXToken completionBlock:(apiSignUpBlock)completionBlock;


-(void)registerNewUserThroughRefCode:(NSString*)referer_code completionBlock:(ReferellSignup)completionBlock;


//-(void)STT_signupUsingReferrelCode:(NSString*)externalUserId name:(NSString*)name email:(NSString*)email phone:(NSString*)phone referer_code:(NSString*)referer_code refmodel:(id)refmodel completionBlock:(ReferellSignup)completionBlock;

//-(void)STT_signupUsingReferrelCode:(NSString*)externalUserId name:(NSString*)name email:(NSString*)email phone:(NSString*)phone referer_code:(NSString*)referer_code completionBlock:(ReferellSignup)completionBlock;

//-(void)GetReferralCode:(NSString*)externalUserId name:(NSString*)name email:(NSString*)email phone:(NSString*)phone appXToken:(NSString*)strAppXToken completionBlock:(GetRefCode)completionBlock;

-(void)GetReferralCode:(GetRefCode)completionBlock;


-(void)ChangeReferralCode:(NSString*)code customcode:(NSString*)customcode strAppxToken:(NSString*)strAppxToken completionBlock:(ChangeRefCode)completionBlock;


-(void)TrackUsages:(TrackUsage)completionBlock;

-(void)referralAddTransacrion:(NSString*)userexternaluserId transaction_id:(NSString*)transaction_id transaction_amount:(NSString*)transaction_amount appXToken:(NSString*)strAppXToken completionBlock:(ReferralAddTransaction)completionBlock;

//Redeem Coupon

-(void)STT_ContentSystem_App_XToken:(NSString*)strAppXToken AppKey:(NSString*)strAppKey Tag:(NSString*)strTag contentModel:(id)contentModel completionBlock:(apiContentSystemBlock)completionBlock;

-(void)redeemCoupon:(NSString*)username order_value:(NSString*)order_value coupon_code:(NSString*)coupon_code completionBlock:(CouponRedeem)completionBlock;



//Wallets
-(void)testWallet:(NSString*)HeaderUserToken appToken:(NSString*)HeaderAppToken completionBlock:(testWallet)completionBlock;

-(void)createWallet:(NSString*)wallet_name externalUserId:(NSString*)externalUserId completionBlock:(CreateWallet)completionBlock;

-(void)addMember:(NSString*)wallet_id member_externalId:(NSString*)member_externalId  completionBlock:(AddMember)completionBlock;


-(void)getWalletList:(NSString*)externalUserId completionBlock:(getWalletList)completionBlock;
//;


-(void)getWalletDetails:(NSString*)wallet_id completionBlock:(Getwalletdetails)completionBlock;


-(void)walletDeposit:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description tags:(NSString*)tags completionBlock:(Deposit)completionBlock;//

-(void)withDrawFunds:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description tags:(NSString*)tags completionBlock:(WithDrawFund)completionBlock;//


-(void)transferFunds:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description receiver_externalId:(NSString*)receiver_externalId completionBlock:(TransferFund)completionBlock;//


-(void)removeMember:(NSString*)wallet_id member_externalUserId:(NSString*)member_externalUserId completionBlock:(removeMember)completionBlock;

-(void)subwallet:(NSString*)wallet_name display_name:(NSString*)display_name users_list:(NSArray*)users_list completionBlock:(Subwallet)completionBlock;

-(void)getWalletTransactions:(NSString*)walletId completionBlock:(getTransactionsList)completionBlock;


///communicator

-(void)getAllMessagesForTopic:(NSString*)topicId completionBlock:(getMessageBlock)completionBlock;

-(void)registerForPushNotificationApi:(NSString*)deviceToken completionBlock:(registerForPushBlock)completionBlock;

-(void)unRegisterForPushNotificationApi_completionBlock:(registerForPushBlock)completionBlock;

-(void)messageRead_Api_forTopic:(NSString*)strTopic messageHash:(NSMutableArray*)arrMessageHash completionBlock:(messageReadBlock)completionBlock;

/// groups API

-(void)createNewGroupApi:(NSString*)strGroupName withMeta:(NSString*)strMeta completionBlock:(createNewGroupBlock)completionBlock;

-(void)addManyMembersToGroup:(NSMutableArray*)arrMemebers forGroupTopic:(NSString*)strTopic completionBlock:(addManyMembersBlock)completionBlock;

-(void)addAMemberToGroup:(NSString*)strMemeberId forGroupTopic:(NSString*)strGroupTopic completionBlock:(addAMemberBlock)completionBlock;

-(void)ApiGetTopicForName:(NSString*)strGroupName completionBlock:(apiMyTopicsBlock)completionBlock;

@end
