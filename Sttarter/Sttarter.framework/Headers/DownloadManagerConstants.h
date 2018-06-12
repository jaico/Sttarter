//
//  DownloadManagerConstants.h
//  Sttarter
//
//  Created by Prajna Shetty on 21/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#ifndef DownloadManagerConstants_h
#define DownloadManagerConstants_h

#define PureSingleton(className) \
+ (className *)shared { \
static className *__main; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ __main = [[className alloc] init]; }); \
return __main; }


#define HTTP_PREFIX @"http://"


//// DEV
//#define MQTT_PORT 1884
//#define MQTT_HOST @"dev.sttarter.com"
//#define BASE_URL @"dev.sttarter.com"



// Live
//// MQTT
//#define MQTT_PORT 1884
//#define MQTT_HOST @"sttarter.com"
//#define BASE_URL @"sttarter.com"
//#define BASE_URL_PORT @":9000/"

//
////DEV
//#define MQTT_PORT 1884
//#define MQTT_HOST @"sttarter.com" // for Mqqtt it is always sttarter.com
//#define BASE_URL @"api.sttarter.com"
//#define BASE_URL_PORT @"/"


//DEV
#define MQTT_PORT 1884
#define MQTT_HOST @"sttarter.com" // for Mqqtt it is always sttarter.com
#define BASE_URL @"dev.sttarter.com"
#define BASE_URL_PORT @":9000/"


//LOCAL
//#define MQTT_PORT 1884
//#define MQTT_HOST @"sttarter.com" // for Mqqtt it is always sttarter.com
//#define BASE_URL @"10.10.0.208"
//#define BASE_URL_PORT @":9000/"
//


#define PrintLogs 1 // 1 -> Print logs, 0 -> Disable logs
#if PrintLogs
//#define NSLog(...)
#else
#define NSLog(...)
#endif



#define STT_AUTH @"auth"
#define STT_LOGIN @"login"
#define STT_SIGNUP @"app/user"

#define HEADER_CONTENT_TYPE @"application/x-www-form-urlencoded"
#define CONTENT_TYPE @"Content-Type"

//Push notification API

#define STT_REGISTER_FOR_PUSH @"registerforpush"
#define STT_UNREGISTER_FOR_PUSH @"unregisterforpush"
#define STT_MESSAGE_READ @"app/messages/markasread"

//OTP Login API
#define API_GET_OTP @"mobile/getotp"
#define API_OTP_LOGIN @"mobile/otplogin"
#define API_QUICK_LOGIN @"mobile/quicklogin"

//MY Topics Api
#define API_MY_TOPICS @"app/mqtt/mytopics"
#define API_BUZZ_MESSAGES @"app/messages/"
#define HEADER_USER_TOKEN @"x-user-token"
#define HEADER_X_APP_TOKEN @"x-app-token" // STT TOKEN
#define GET_MESSAGES @"app/messages/"

/// groups
#define CREATE_NEW_GROUP @"app/mqtt/group"   //POST
#define ADD_MEMEBER_TO_GROUP @"app/mqtt/group/adduser"   //POST
#define ADD_MANY_MEMEBERS_TO_GROUP @"app/mqtt/group/addmultipleusers"   //POST

///group/adduser
//{{host}}:9000/app/mqtt/group/adduser/123456789

//STTarter Referrels
#define TRACK_REF_USAGE @"referral/trackusage"
#define SIGNUP_USING_REFERRELCODE @"referral/newsignup/"
#define GET_REF_CODE @"referral/getreferralcode"
#define CHANGE_REF_CODE @"referral/changereferralcode"
#define REFERRAL_ADD_TRANSACTION @"referral/addtransaction"

//Content System
#define CONTENT_SYSTEM @"contentsystem/"
#define API_GETDATA_BANNERS @"contentsystem/"

//Sttarter Coupons

#define COUPON_REDEEM @"coupons/couponredeem"

//Wallet

#define WALLET_TEST @"10.1.3.140:9000/testencryption/test/?timestamp="
#define BASE_URL_WALLET_LOCAL_SERVER @"10.1.3.195"

#define CREATE_WALLET @"wallet/createwallet/"//createWallet// TFT
#define GET_WALLET_DETAILS @"wallet/getWalletDetails/"//getWalletDetails TFT
#define WALLET_DEPOSIT @"wallet/deposit/"//depositMoneyToWallet POST
#define WITHDRAW @"wallet/withdraw/"//withdrawMoneyFromWallet
#define ADD_MEMBER @"wallet/addMember/"//addMemberToWallet
#define REMOVE_MEMBER @"wallet/removeMember/"//removeMemberFromWallet  hahaha membe
#define TRANSFER_FUND @"wallet/transferFunds/"//transferFundsToUserDefaultWallet
#define SUBWALLET @"wallet/addsubwallet/"//addSubWallet 
#define GET_WALLET_LIST @"wallet/getWalletList/"//getWalletList

#define GET_WALLET_TRANSACTIONS @"api/getWalletTransactions"   //getWalletTransactions ** NEW **


#endif /* DownloadManagerConstants_h */

