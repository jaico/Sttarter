//
//  DownloadManagerAdditions.h
//  Sttarter
//
//  Created by Prajna Shetty on 21/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#import "GetOtpModel.h"
#import "OtpLoginModel.h"
#import "MyTopicsModel.h"
#import "BuzzMessagesModel.h"
#import "AuthModel.h"
#import "LoginModel.h"
#import "SignUpModel.h"
#import "GetRefCodeModel.h"
//#import "ReferrelSignupModel.h"
#import "ChangeRefModel.h"
#import "TrackUsageModel.h"
#import "CouponModel.h"
#import "CreateWalletBaseModel.h"
#import "WalletListModel.h"
#import "AddmemberBaseModel.h"
#import "GetWalletDetailsModel.h"
#import "WalletDepositBaseModel.h"
#import "TransferFundBaseModel.h"
#import "WithdrawModel.h"
#import "SubwalletModel.h"
#import "GetMessagesModel.h"
#ifndef DownloadManagerAdditions_h
#define DownloadManagerAdditions_h


typedef void (^getMessageBlock)(NSError *error,GetMessagesModel *model);//
typedef void (^registerForPushBlock)(NSError *error,NSDictionary *dctResposnse);//
typedef void (^messageReadBlock)(NSError *error,NSDictionary *dctResposnse);//

typedef void (^createNewGroupBlock)(NSError *error,NSDictionary *dctResposnse);//
typedef void (^registerForPushNotificationBlock)(NSError *error,bool status);//



typedef void (^apiGetOtpBlock)(NSError *error,GetOtpModel *modelGetOtp);
typedef void (^apiOtpLoginBlock)(NSError *error,OtpLoginModel *modelOtpLogin,NSString *errTitle, NSString *errMsg);
typedef void (^apiQuickLoginBlock)(NSError *error,NSString *strStatus, NSString *errTitle, NSString *errMsg);
typedef void (^apiMyTopicsBlock)(NSError *error,MyTopicsModel *modelmyTopics,NSString *errTitle, NSString *errMsg);
typedef void (^apiBuzzMessagesBlock)(NSError *error,BuzzMessagesModel *modelmyTopics,NSString *errTitle, NSString *errMsg);
typedef void (^apiAuthBlock)(NSError *error,AuthModel *modelAuthModel,NSString *errTitle, NSString *errMsg);
typedef void (^apiLoginBlock)(NSError *error,LoginModel *modelLogin,NSString *errTitle, NSString *errMsg);
typedef void (^apiSignUpBlock)(NSError *error,SignUpModel *modelSignUp,NSString *errTitle, NSString *errMsg);

typedef void (^apiRegistrationBlock)(NSString *errorMessage,BOOL status);


typedef void (^ReferellSignup)(NSError *error,NSString *errTitle, NSString *errMsg);// not sending any model

//typedef void (^ReferellSignup)(NSError *error,id modelRefSignUp,NSString *errTitle, NSString *errMsg);
typedef void (^GetRefCode)(NSError *error,GetRefCodeModel *modelGetRef,NSString *errTitle, NSString *errMsg);
typedef void (^ChangeRefCode)(NSError *error,ChangeRefModel *modelChangeRef,NSString *errTitle, NSString *errMsg);
typedef void (^TrackUsage)(NSError *error,TrackUsageModel *modelTrackUsage,NSString *errTitle, NSString *errMsg);

typedef void (^CouponRedeem)(NSError *error,CouponModel *modelCoupon);
typedef void (^ReferralAddTransaction)(NSError *error,NSString *status,NSString *title, NSString *msg);



//Content System
typedef void (^apiContentSystemBlock)(NSError *error,NSArray *arrContentData,NSString *errTitle, NSString *errMsg);



//Redeem Coupon API



//Wallet
typedef void (^testWallet)(NSError *error,NSString *status);
typedef void (^CreateWallet)(NSError *error,CreateWalletBaseModel *modelcreateWallet,NSString *strError);

typedef void (^getTransactionsList)(NSError *error,NSArray *arrWallet,NSString *strError);

typedef void (^getWalletList)(NSError *error,NSArray *arrWallet,NSString *strError);
typedef void (^AddMember)(NSError *error,AddmemberBaseModel *modelcreateWallet,NSString *strError);
typedef void (^Getwalletdetails)(NSError *error,GetWalletDetailsModel *model,NSString *strError);
typedef void (^Deposit)(NSError *error,WalletDepositBaseModel *model,NSString *strError);
typedef void (^TransferFund)(NSError *error,TransferFundModel *model,NSString *strError);
typedef void (^WithDrawFund)(NSError *error,WithdrawModel *model,NSString *strError);
typedef void (^removeMember)(NSError *error,NSString *status);
typedef void (^Subwallet)(NSError *error,SubwalletModel *model,NSString *strError);


// Communicator
typedef void (^addAMemberBlock)(NSError *error,NSDictionary *dictionary);
typedef void (^addManyMembersBlock)(NSError *error,NSDictionary *dictionary);

////    public void getUserListForExternalIDs(List<String> externalUserIds, final STTGetUserListInterface getUserSuccessListener, final STTErrorListener errorListener) {

// Sync multiple users
typedef void (^errorListenerBlock)(NSError *error);
typedef void (^getUserSuccessListenerBlock)(NSError *error, NSArray *usersList);


#endif /* DownloadManagerAdditions_h */
