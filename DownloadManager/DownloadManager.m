//
//  DownloadManager.m
//  Sttarter
//
//  Created by Prajna Shetty on 21/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#import "DownloadManager.h"
#import <Foundation/Foundation.h>
#import "DownloadManagerAdditions.h"
#import "DownloadManagerConstants.h"
#import "GetOtpModel.h"
#import "AFHTTPRequestOperation.h"
#import "LoginModel.h"
#import "CouponModel.h"
#import <CommonCrypto/CommonHMAC.h>
#import "CreateWalletBaseModel.h"
#import "AddmemberBaseModel.h"
#import "GetWalletDetailsModel.h"
#import "WithdrawModel.h"
#import "Utils.h"


@implementation DownloadManager
NSTimeInterval const HYConnectionTimeout = 60.0;

PureSingleton(DownloadManager);

- (NSURL *)URLByEncodingString:(NSString *)url
{
    return [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


-(void)STT_SignUp:(SignUpUserInfoModel*)userModelToSignUp appXToken:(NSString*)strAppXToken completionBlock:(apiSignUpBlock)completionBlock
{
  
    NSString *baseURLString = [[Utils shared] getBaseURLString];
  
    NSString *url = [NSString stringWithFormat:@"%@%@",baseURLString,STT_SIGNUP];
    NSString *postBody = [NSString stringWithFormat:@"name=%@&email=%@&mobile=%@&username=%@&password=%@&meta=%@&avatar=%@",userModelToSignUp.name,userModelToSignUp.email,userModelToSignUp.mobile,userModelToSignUp.username,userModelToSignUp.password,userModelToSignUp.meta,userModelToSignUp.avatar];
    
    NSLog(@" ******Sttarter SignUP API URL: %@ ****",url);
    NSLog(@" ******Sttarter SignUP API postBody: %@ *****",postBody);
    
    
    NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    NSLog(@" ******Sttarter SignUP API Header x-app-token: %@ ****",strAppXToken);
    
    [request setHTTPMethod:@"POST"];
    [request addValue:strAppXToken forHTTPHeaderField:@"x-app-token"];
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         
         NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@" ******Sttarter STT_SignUp success response : %@ *****",dctResponse);
         
         SignUpModel *modelLogin=[[SignUpModel alloc]initWithDictionary:dctResponse error:&err];
         
         
         NSLog(@"***** Login Model :%@******",modelLogin);
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelLogin,nil,nil);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSString *errTitle;
         NSString *errMsg;
         
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"****** STT_SignUp err msg %@ ***********",response);
             
             if (operation.responseData != nil)
             {
                 errTitle = [response objectForKey:@"title"];
                 errMsg = [response objectForKey:@"msg"];
             }
         }
         else{
             errTitle=@"Error";
             errMsg=@"Login error";
         }
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,errTitle,errMsg);});
                 return;
             }
         }
     }];
    [operation start];
    
}
-(void)STT_ApiLogin:(NSString*)strUserName password:(NSString*)strPassword app_XToken:(NSString*)strAppXToken completionBlock:(apiLoginBlock)completionBlock{
    NSString *baseURLString = [[Utils shared] getBaseURLString];

    NSString *url = [NSString stringWithFormat:@"%@%@",baseURLString,STT_LOGIN];
    NSString *postBody = [NSString stringWithFormat:@"username=%@&password=%@",strUserName,strPassword];
    NSLog(@" ******Sttarter LOGIN API URL: %@ ****",url);
    NSLog(@" ******Sttarter LOGIN API postBody: %@ *****",postBody);
    
    NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    NSLog(@" ******Sttarter LOGIN API Header x-app-token: %@ ****",strAppXToken);
    
    [request setHTTPMethod:@"POST"];
    [request addValue:strAppXToken forHTTPHeaderField:@"x-app-token"];
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         
         NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@" ******Sttarter STT_ApiLogin success response : %@ *****",dctResponse);
         
         LoginModel *modelLogin=[[LoginModel alloc]initWithDictionary:dctResponse error:&err];
         
         NSLog(@"***** STT_ApiLogin Login Model :%@******",modelLogin);
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelLogin,nil,nil);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSString *errTitle;
         NSString *errMsg;
         NSLog(@"****** STT_ApiLogin err msg %@ ***********",errMsg);
         
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"****** STT_ApiLogin err msg %@ ***********",response);
             
             if (operation.responseData != nil)
             {
                 errTitle = [response objectForKey:@"title"];
                 errMsg = [response objectForKey:@"msg"];
             }
         }
         else{
             errTitle=@"Error";
             errMsg=@"Login error";
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,errTitle,errMsg);});
                 return;
             }
         }
     }];
    [operation start];
    
}



-(void)ApiAuth:(NSString*)app_key app_secret:(NSString*)strApp_secret completionBlock:(apiAuthBlock)completionBlock{
  
    NSString *baseURLString = [[Utils shared] getBaseURLString];
  
    NSString *url = [NSString stringWithFormat:@"%@%@",baseURLString,STT_AUTH];
    NSString *postBody = [NSString stringWithFormat:@"app_key=%@&app_secret=%@",app_key,strApp_secret];
    
    NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"POST"];
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSLog(@" ******Sttarter AUTH API URL: %@ ****",url);
    NSLog(@" ******Sttarter AUTH API postBody: %@ *****",postBody);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         
         
         NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@" ******Sttarter Auth success response : %@ *****",dctResponse);
         
         
         AuthModel *modelAuth=[[AuthModel alloc]initWithDictionary:dctResponse error:&err];
         NSLog(@"***** ApiAuth AUTH Model :%@******",modelAuth);
         
         [[NSUserDefaults standardUserDefaults] setObject:modelAuth.token forKey:@"STARTTER_X_APP_TOKEN"];
         [[NSUserDefaults standardUserDefaults] synchronize];
         
         
         NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
         NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:modelAuth];
         [prefs setObject:myEncodedObject forKey:@"AUTH_MODEL"];
         
         
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelAuth,nil,nil);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSString *errTitle;
         NSString *errMsg;
         NSLog(@"****** AUTH err msg %@ ***********",err);
         
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"****** AUTH err msg %@ ***********",response);
             
                 errTitle = [response objectForKey:@"title"];
                 errMsg = [response objectForKey:@"msg"];
         }
         else{
             
             errTitle=@"Error";
             errMsg=@"Authentication error";
             
             BOOL isConnected;
             Reachability *reachability = [Reachability reachabilityForInternetConnection];
             NetworkStatus internetStatus = [reachability currentReachabilityStatus];
             if (internetStatus == NotReachable)
             {
                 isConnected = FALSE;
                 errMsg = @"The Internet connection appears to be offline.";
             }
             
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,errTitle,errMsg);});
                 return;
             }
         }
     }];
    [operation start];
    
}

-(void)ApiGetOtp:(NSString*)strPhoneNumber completionBlock:(apiGetOtpBlock)completionBlock
{
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseURLString,API_GET_OTP];
    NSString *postBody = [NSString stringWithFormat:@"mobile=%@",strPhoneNumber];
    
    NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"POST"];
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request addValue:strAppXToken forHTTPHeaderField:@"x-app-token"];
    [request setHTTPBody:postData];
    NSLog(@" ******Sttarter call otp API *****");
    NSLog(@" ******Sttarter call otp API postBody: %@ *****",postBody);
    
    
    //    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //
    //    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    //
    //        if (error) {  // Failure
    //            NSLog(@"Error: %@", error);
    //
    //            NSLog(@" ****** otp API Failed *****");
    //
    //            if (completionBlock) {
    //                if (error) {
    //                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error,nil);});
    //                    return;
    //                }
    //            }
    //        } else {  // success
    //            NSLog(@"*****id responseObject: %@", responseObject);
    //
    //            NSError* err = nil;
    //            NSLog(@" ****** otp API Successful *****");
    //            NSLog(@"************ GetOtp Respnse : %@ ************", response);
    //
    //            NSDictionary* dctResponse = [(NSHTTPURLResponse*)responseObject allHeaderFields];
    //            NSLog(@"************ GetOtp dictionary : %@ ************", dctResponse);
    //
    //            GetOtpModel *modelGetOtp=[[GetOtpModel alloc]initWithDictionary:dctResponse error:&err];
    //
    //            if (completionBlock)
    //            {
    //                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelGetOtp);});
    //            }
    //        }
    //    }];
    //    [dataTask resume];
    
    //******************** top one is new code
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         
         
         NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@" ******Sttarter GetOtp Success response : %@ *****",dctResponse);
         
         GetOtpModel *modelGetOtp=[[GetOtpModel alloc]initWithDictionary:dctResponse error:&err];
         NSLog(@"***** getOtpModel :%@******",modelGetOtp);
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelGetOtp);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         
         NSLog(@" ******Sttarter GetOtp Failure with err: %@ *****",err);
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil);});
                 return;
             }
         }
     }];
    [operation start];
    
    
}


-(void)ApiQuickLogin:(NSString*)strName mobileNo:(NSString*)strMobileNo email:(NSString*)strEmail orgId:(NSString*)strOtp completionBlock:(apiQuickLoginBlock)completionBlock
{
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseURLString,API_QUICK_LOGIN];
    NSString *postBody = [NSString stringWithFormat:@"name=%@&mobile=%@&email=%@&org_id=%@",strName,strMobileNo,strEmail,strOtp];
    
    
    NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"POST"];
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSLog(@" ****** Quick Login Api Call *****");
    NSLog(@" ******Quick Login Api Call API postBody: %@ *****",postBody);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         
         NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@" ******Sttarter Quick login Success response : %@ *****",dctResponse);
         
         NSString *strTitle =  [dctResponse objectForKey:@"title"];
         NSString *strMsg =  [dctResponse objectForKey:@"msg"];
         NSString *strStatus =  [dctResponse objectForKey:@"status"];
         
         NSLog(@" ******Sttarter Quick login (Nsstring*)STATUS : %@ *****",strStatus);
         
         if (completionBlock) // err, status, title msg
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,strStatus,strTitle,strMsg);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSString *strTitle;
         NSString *strMsg;
         
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             
             strTitle = [response objectForKey:@"title"];
             strMsg = [response objectForKey:@"msg"];
         }
         
         
         NSLog(@" ******Sttarter QuickLogin Failure with err: %@ *****",err);
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,strTitle,strMsg);});
                 return;
             }
         }
     }];
    [operation start];
    
}

-(void)ApiOtpLogin:(NSString*)PhoneNumber OTP:(NSString*)strOtp completionBlock:(apiOtpLoginBlock)completionBlock
{
     NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseURLString,API_OTP_LOGIN];
    
    NSString *postBody = [NSString stringWithFormat:@"mobile=%@&otp=%@",PhoneNumber,strOtp];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"POST"];
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request addValue:strAppXToken forHTTPHeaderField:@"x-app-token"];
    [request setHTTPBody:postData];
    
    NSLog(@"***** OTP Login PostBody %@  *****",postBody);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@"***** OTP Login Response %@  *****",response);
         OtpLoginModel *modelOtpLogin=[[OtpLoginModel alloc]initWithDictionary:response error:&err];
         NSString *strTitle;
         NSString *strMessage;
         strTitle = [response objectForKey:@"title"];
         strMessage = [response objectForKey:@"msg"];
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelOtpLogin,strTitle,strMessage);});
         }
     }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSLog(@"***** OTP Login Response errorrr!! %@  *****",err);
         
         NSString *strTitle;
         NSString *strMessage;
         
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             
             strTitle = [response objectForKey:@"title"];
             strMessage = [response objectForKey:@"msg"];
         }
         else{
             strTitle = @"Error";
             strMessage  =[NSString stringWithFormat:@"%@",err];
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,strTitle,strMessage);});
                 return;
             }
         }
     }];
    [operation start];
    
}


#pragma mark - Referral
//Referrel

//Signup using referral code
//STT_signupUsingReferrelCode


-(void)registerNewUserThroughRefCode:(NSString*)referer_code completionBlock:(ReferellSignup)completionBlock
{
//-(void)registerNewUserThroughReferralCode:(NSString*)externalUserId name:(NSString*)name email:(NSString*)email phone:(NSString*)phone referer_code:(NSString*)referer_code refmodel:(JSONModel*)refmodel completionBlock:(ReferellSignup)completionBlock
//{
    
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];

    NSString *strUrl;
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    if(HeaderUserToken != nil) { // without external id
      
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,SIGNUP_USING_REFERRELCODE];

        NSLog(@"**rrr_Reff_CreateSignUp_rrr** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];

        NSLog(@"x_app_Token(USER_ID) : '%@'",strExternalUserId);
        NSLog(@"x_app_Token(STARTTER_X_APP_TOKEN) : '%@'",strAppXToken);

        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,SIGNUP_USING_REFERRELCODE,strExternalUserId];

        
        NSLog(@"**rrr_Reff_CreateSignUp_rrr** URL (WITH External user Id) : %@ ******",strUrl);
    }

    
    
    NSLog(@"Signup using referrals");

    
//    NSString *postBody = [NSString stringWithFormat:@"name=%@&email=%@&phone=%@&referer_code=%@",name,email,phone,referer_code];
    
    NSString *postBody = [NSString stringWithFormat:@"referer_code=%@",referer_code];

    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];

    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:strUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    [request setHTTPMethod:@"POST"];
    
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**rrr_Reff_CreateSignUp_rrr** x-user-token :%@",HeaderUserToken);
    }
    
    
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request addValue:strAppXToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    
    [request setHTTPBody:postData];
    
    NSLog(@"***** rrr_Reff_CreateSignUp_rrr PostBody %@  *****",postBody);
    NSLog(@"***** rrr_Reff_CreateSignUp_rrr request %@  *****",request);
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@"***** rrr_Reff_CreateSignUp_rrr Response %@  *****",response);
         
         NSLog(@"rrr_Reff_CreateSignUp_rrr success");
         
         NSMutableArray *array = [[NSMutableArray alloc] init];
         
         [array addObject:response];///??? why array
         NSLog(@" rrr_Reff_CreateSignUp_rrrJSON response %@ %%%%%%%%%%%%%%",response);

         NSLog(@" rrr_Reff_CreateSignUp_rrrJSON response Array %@ %%%%%%%%%%%%%%",array);
    
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,nil,nil);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSLog(@"rrr_Reff_CreateSignUp_rrr failure");
         
         NSError *err = operation.error;
         NSLog(@"***** %@  *****",err);
         
         NSString *strTitle;
         NSString *strMessage;
         
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             
             strTitle = [response objectForKey:@"title"];
             strMessage = [response objectForKey:@"msg"];
         }
         else{
             strTitle = @"Error";
             strMessage  =[NSString stringWithFormat:@"%@",err];
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,strTitle,strMessage);});
                 return;
             }
         }
     }];
    [operation start];
}


-(void)GetReferralCode:(GetRefCode)completionBlock // Done new code.
{
    
    
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];

    NSString *strUrl;
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    if(HeaderUserToken != nil) { // without external id
        
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,GET_REF_CODE];
        
        NSLog(@"**GetReferralCode** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        
        NSLog(@" Ext USER_ID : '%@'",strExternalUserId);
        NSLog(@"x_app_Token(STARTTER_X_APP_TOKEN) : '%@'",strAppXToken);
        
        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,GET_REF_CODE,strExternalUserId];
        
        NSLog(@"**GetReferralCode** URL (WITH External user Id) : %@ ******",strUrl);
    }
    
    
    NSLog(@"strUrl:%@",strUrl);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:strUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"GET"];
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"****GetReferralCode**** USER_TOKEN:%@",HeaderUserToken);
    }
    
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:@"Content-Type"];

    NSLog(@"****GetReferralCode**** X_APP_TOKEN:%@",strXAppToken);
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        GetRefCodeModel *modelGetRef = [[GetRefCodeModel alloc]initWithDictionary:response error:&err];
        
        
        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelGetRef,nil,nil);});
        }
    }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         NSLog(@"***** !GetReferralCode! error is : %@  *****",err);
         
         NSString *strTitle;
         NSString *strMessage;
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             
             strTitle = [response objectForKey:@"title"];
             strMessage = [response objectForKey:@"msg"];
         }
         else{
             strTitle = @"Error";
             strMessage  =[NSString stringWithFormat:@"%@",err];
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,strTitle,strMessage);});
                 return;
             }
         }
     }];
    [operation start];

}

//-(void)GetReferralCode:(NSString*)externalUserId name:(NSString*)name email:(NSString*)email phone:(NSString*)phone appXToken:(NSString*)strAppXToken completionBlock:(GetRefCode)completionBlock
//{
//    
//    NSString *url = [NSString stringWithFormat:@"%@%@%@%@",HTTP_PREFIX,BASE_URL,BASE_URL_PORT,GET_REF_CODE];
//    NSLog(@"GetReferralCode_url%@",url);
//    NSString *postBody = [NSString stringWithFormat:@"externalUserId=%@&name=%@&email=%@&phone=%@",externalUserId,name,email,phone];
//    NSLog(@"strAppXToken%@",strAppXToken);
//    
//    
//    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
//    NSMutableURLRequest *request =
//    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
//                        timeoutInterval:HYConnectionTimeout];
//    [request setHTTPMethod:@"POST"];
//    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
//    [request addValue:strAppXToken forHTTPHeaderField:@"x-app-token"];
//    
//    [request setHTTPBody:postData];
//    
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
//     {
//         NSError* err = nil;
//         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
//         GetRefCodeModel *modelGetRef = [[GetRefCodeModel alloc]initWithDictionary:response error:&err];
//         
//         
//         if (completionBlock)
//         {
//             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelGetRef,nil,nil);});
//         }
//     }
//     
//                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
//     {
//         
//         NSError *err = operation.error;
//         NSLog(@"***** !! %@  *****",err);
//         
//         NSString *strTitle;
//         NSString *strMessage;
//         if (operation.responseData != nil)
//         {
//             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
//             
//             strTitle = [response objectForKey:@"title"];
//             strMessage = [response objectForKey:@"msg"];
//         }
//         else{
//             strTitle = @"Error";
//             strMessage  =[NSString stringWithFormat:@"%@",err];
//         }
//         
//         if (completionBlock) {
//             if (error) {
//                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,strTitle,strMessage);});
//                 return;
//             }
//         }
//     }];
//    [operation start];
//    
//    
//    
//    
//}


//Change Referral code

-(void)ChangeReferralCode:(NSString*)code customcode:(NSString*)customcode strAppxToken:(NSString*)strAppxToken completionBlock:(ChangeRefCode)completionBlock
{
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseURLString,CHANGE_REF_CODE];
    NSString *postBody = [NSString stringWithFormat:@"code=%@&custom_code=%@",code,customcode];
    
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"POST"];
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request addValue:strAppxToken forHTTPHeaderField:@"x-app-token"];
    
    [request setHTTPBody:postData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         ChangeRefModel *modelChangeRef = [[ChangeRefModel alloc]initWithDictionary:response error:&err];
         
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelChangeRef,nil,nil);});
         }
     }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSLog(@"***** !! %@  *****",err);
         NSString *strTitle;
         NSString *strMessage;
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             strTitle = [response objectForKey:@"title"];
             strMessage = [response objectForKey:@"msg"];
             
         }
         else{
             strTitle = @"Error";
             strMessage  =[NSString stringWithFormat:@"%@",err];
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,strTitle,strMessage);});
                 return;
             }
         }
     }];
    [operation start];
    
}


//TrackUsage
-(void)TrackUsages:(TrackUsage)completionBlock;
{
     NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSMutableDictionary *dctLoginInfo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"STT_LOGIN_INFO"] mutableCopy];
    NSString *userName=[dctLoginInfo valueForKey:@"username"];
    NSString *url = [NSString stringWithFormat:@"%@%@/%@",baseURLString,TRACK_REF_USAGE,userName];
    NSLog(@"TrackUsages Called %@",url);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSError* err = nil;
         NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         TrackUsageModel *modelTrack = [[TrackUsageModel alloc] initWithDictionary:response error:&err];
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelTrack,nil,nil);});
         }
     }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         NSLog(@"***** !! %@  *****",err);
         NSString *strTitle;
         NSString *strMessage;
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             strTitle = [response objectForKey:@"title"];
             strMessage = [response objectForKey:@"msg"];
             
         }
         else{
             strTitle = @"Error";
             strMessage  =[NSString stringWithFormat:@"%@",err];
         }
         
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (error,nil,strTitle,strMessage);
                 });
                 return;
             }
             
             
         }
     }
     ];
    [operation start];
    
    
}

//Referral Add Transaction
-(void)referralAddTransacrion:(NSString*)userexternaluserId transaction_id:(NSString*)transaction_id transaction_amount:(NSString*)transaction_amount appXToken:(NSString*)strAppXToken completionBlock:(ReferralAddTransaction)completionBlock
{
   NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseURLString,REFERRAL_ADD_TRANSACTION];
    NSString *postBody = [NSString stringWithFormat:@"externalUserId=%@&transaction_id=%@&transaction_amount=%@",userexternaluserId,transaction_id,transaction_amount];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"POST"];
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request addValue:strAppXToken forHTTPHeaderField:@"x-app-token"];
    [request setHTTPBody:postData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         ChangeRefModel *modelChangeRef = [[ChangeRefModel alloc]initWithDictionary:response error:&err];
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelChangeRef.status,modelChangeRef.title,modelChangeRef.msg);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         NSError *err = operation.error;
         NSLog(@"***** !! %@  *****",err);
         NSString *strTitle;
         NSString *strMessage;
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             strTitle = [response objectForKey:@"title"];
             strMessage = [response objectForKey:@"msg"];
             
         }
         else{
             strTitle = @"Error";
             strMessage  =[NSString stringWithFormat:@"%@",err];
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,strTitle,strMessage);});
                 return;
             }
         }
     }];
    [operation start];
    
}



-(void)STT_ContentSystem_App_XToken:(NSString*)strAppXToken AppKey:(NSString*)strAppKey Tag:(NSString*)strTag contentModel:(id)contentModel completionBlock:(apiContentSystemBlock)completionBlock{
    
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];

    NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSString *url = [NSString stringWithFormat:@"%@%@%@/%@",baseURLString,CONTENT_SYSTEM,strAppID,strTag];

    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request addValue:strAppXToken forHTTPHeaderField:@"x-app-token"];
    [request setHTTPMethod:@"GET"];
    
    NSLog(@"*cccccc* ContentSystem API call started");
    NSLog(@"*cccccc* ContentSystem API url: %@",url);
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:  NSJSONReadingAllowFragments error:&err];
         
         NSArray *arrData =[[NSArray alloc] init];
         arrData = [response objectForKey:@"data"];
         
///***
//         NSMutableArray *arrProjects = [response objectForKey:@"data"];
//         NSMutableArray *arrMemberProjects = [[NSMutableArray alloc]init];
//         for (NSDictionary *dct in arrProjects) {
//             
//             contentModel *contentModel = [[contentModel alloc] initWithFile:dct];
//             [self.arrMemberProjects addObject:content_model];
//             _proj=nil;
//         }
///***
         
         NSArray *arrContentModel = [[contentModel class] arrayOfModelsFromDictionaries:arrData error:&err ];
         
         
         NSLog(@"######## Content System Success Response: %@ ########",response);
         NSLog(@"*cccccc* JSON Modellllll if Error :  %@ %%%%%%%%%%%%%%",err);
         NSLog(@"*cccccc* Content_Array : JSON arrayOfModelsFromDictionaries Data Modellllll abc : %@ %%%%%%%%%%%%%%",arrContentModel);
         
         
         if (completionBlock)
             
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,arrContentModel,nil,nil);});
         }
     }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSString *errTitle;
         NSString *errMsg;
         
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"****** Buzz Msgs err Response: %@ ***********",response);
             
             if (operation.responseData != nil)
             {
                 errTitle = [response objectForKey:@"title"];
                 errMsg = [response objectForKey:@"msg"];
                 
             }
             
         }
         else{
             
             errTitle=@"Error";
             errMsg=@"Error msg";
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,errTitle,errMsg);});
                 return;
             }
         }
     }];
    [operation start];
    
}


-(void)redeemCoupon:(NSString*)username order_value:(NSString*)order_value coupon_code:(NSString*)coupon_code completionBlock:(CouponRedeem)completionBlock
{
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSString *url = [NSString stringWithFormat:@"%@%@",baseURLString,COUPON_REDEEM];
    NSString *postBody = [NSString stringWithFormat:@"username=%@&order_value=%@&coupon_code=%@",username,order_value,coupon_code];
    
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    NSLog(@"%@strAppXToken:",strAppXToken);
    
    [request setHTTPMethod:@"POST"];
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:@"Content-Type"];
    [request addValue:strAppXToken forHTTPHeaderField:@"x-app-token"];
    [request setHTTPBody:postData];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSError* err = nil;
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         CouponModel *modelCoupon = [[CouponModel alloc]initWithDictionary:response error:&err];
         NSLog(@"Redeem Coupon response:%@",modelCoupon);
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelCoupon);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSLog(@"RedeemCoupon Failed%@",operation.response);
         NSError *err = operation.error;
         NSLog(@"***** !! %@  *****",err);
         NSString *strTitle;
         NSString *strMessage;
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             strTitle = [response objectForKey:@"title"];
             strMessage = [response objectForKey:@"msg"];
             NSLog(@"failed %@%@",strTitle,strMessage);
             
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil);});
                 return;
             }
         }
     }];
    [operation start];
}

#pragma mark - Wallet


//Wallet
-(void)testWallet:(NSString*)HeaderUserToken appToken:(NSString*)HeaderAppToken completionBlock:(testWallet)completionBlock
{
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    NSString *strXUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    
    
    NSString *strTimeStamp =  [[Utils shared] GetCurrentEpochTime];
    NSLog(@"Time stsamp:%@",strTimeStamp);
    
    //remove
    //strTimeStamp = @"1486010683";
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",WALLET_TEST,strTimeStamp];
    
    NSLog(@"strUrl:%@",strUrl);
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    
    NSLog(@"%@ hEX",strHash);
    
    
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?timestamp=%@&hash_key=%@",strUrl,strTimeStamp,strHash];
    
    NSLog(@"modifiedUrl testWallet:%@",modifiedUrl);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    [request addValue:strXUserToken forHTTPHeaderField:HEADER_USER_TOKEN];
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setHTTPMethod:@"POST"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@"test wallet Response%@",response);
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,nil);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"Failure Response::%@",response);
             
             
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil);});
                 return;
             }
         }
     }];
    [operation start];
    
    
}



//1) Create Wallet - DONE CLEAN UP
-(void)createWallet:(NSString*)wallet_name externalUserId:(NSString*)externalUserId completionBlock:(CreateWallet)completionBlock
{
    
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    
    NSString *strUrl;
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    if(HeaderUserToken != nil) { // without external id
        
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,CREATE_WALLET];
        NSLog(@"**www_CREATE_WALET_www** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,CREATE_WALLET,strExternalUserId];
        
        NSLog(@"**www_CREATE_WALET_www** URL (WITH External user Id) : %@ ******",strUrl);
    }

    
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    NSString *postBody = [NSString stringWithFormat:@"wallet_name=%@&external_id=%@",wallet_name,externalUserId];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    
    /// Add TimeStamp and HASH to the URL
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?timestamp=%@&hash_key=%@",strUrl,strTimeStamp,strHash];

    NSLog(@" **www_CREATE_WALET_www** strUrl:%@",modifiedUrl);
    NSLog(@" **www_CREATE_WALET_www** PostBody:%@",postBody);

    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    
    NSLog(@"**www_CREATE_WALET_www** FINAL_URL (WITH External user Id) : %@ ******",modifiedUrl);
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**www_CREATE_WALET_www** USER_TOKEN:%@",HEADER_USER_TOKEN);
    }
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    NSLog(@"**www_CREATE_WALET_www** X_APP_TOKEN:%@",HEADER_X_APP_TOKEN);

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        
        CreateWalletBaseModel *model=[[CreateWalletBaseModel alloc]initWithDictionary:response error:&err];
        
        NSString *integerAsString = [@(model.wallet.id) stringValue];
        [[NSUserDefaults standardUserDefaults] setObject:integerAsString forKey:@"walletID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Create wallet Response%@",response);
        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,model,nil);});
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"Failure Response::%@",response);
             
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,err.localizedDescription);});
                 return;
             }
         }
     }];
    [operation start];
}

//2) DONE CLEAN UP
-(void)getWalletDetails:(NSString*)wallet_id completionBlock:(Getwalletdetails)completionBlock
{

    
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    
    NSString *strUrl;
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    if(HeaderUserToken != nil) { // without external id
        
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,GET_WALLET_DETAILS];
        NSLog(@"**www_WALET_DETAILS_www** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,GET_WALLET_DETAILS,strExternalUserId];
        
        NSLog(@"**www_WALET_DETAILS_www** URL (WITH External user Id) : %@ ******",strUrl);
    }
    

    NSString *postBody = [NSString stringWithFormat:@"wallet_id=%@",wallet_id];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    
    
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];
    NSLog(@"Timestsamp:%@",strTimeStamp);
    
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    NSLog(@"%@ hEX:",strHash);
    
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?timestamp=%@&hash_key=%@",strUrl,strTimeStamp,strHash];
    
    NSLog(@" **www_WALET_DETAILS_www** Final Url:%@",modifiedUrl);
    NSLog(@" **www_WALET_DETAILS_www** PostBody:%@",postBody);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**www_WALET_DETAILS_www** USER_TOKEN:%@",HEADER_USER_TOKEN);
    }
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    NSLog(@"**www_WALET_DETAILS_www** X_APP_TOKEN:%@",strXAppToken);
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    NSLog(@" **www_WALET_DETAILS_www** Request:%@",request);

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        NSLog(@"Get wallet details Success Response%@",response);

        GetWalletDetailsModel *model=[[GetWalletDetailsModel alloc]initWithDictionary:response error:&err];
        
        NSLog(@"Get wallet details Response%@",response);
        NSLog(@"Get wallet details Model : %@",model);

        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,model,nil);});
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"Get wallet details Failure Response%@",response);
             
             
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,err.localizedDescription);});
                 return;
             }
         }
     }];
    [operation start];
}


///
//getWalletTransactions
-(void)getWalletTransactions:(NSString*)walletId completionBlock:(getTransactionsList)completionBlock
{
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,GET_WALLET_TRANSACTIONS];
    
    
    NSLog(@"**GET_WALLET_LIST** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];
    
    NSLog(@"Time stsamp:%@",strTimeStamp);
    NSLog(@"strUrl:%@",strUrl);
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    NSLog(@"%@ hEX:",strHash);
    
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?wallet_id=%@&timestamp=%@&hash_key=%@&fromDate=&toDate=",strUrl,walletId,strTimeStamp,strHash];
    NSLog(@"GET_WALLET_TRANSACTIONS Final modifiedUrl:%@",modifiedUrl);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"GET"];
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**GET_WALLET_TRANSACTIONS** USER_TOKEN:%@",HeaderUserToken);
    }
    
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:@"Content-Type"];
    
    NSLog(@"**GET_WALLET_TRANSACTIONS** X_APP_TOKEN:%@",strXAppToken);
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSArray *arrResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        NSLog(@"GET_WALLET_TRANSACTIONS Response :%@",arrResponse);

        
        //response is an array list of dictionaries/models so send back an array of models
        NSMutableArray *arrWalletList = [[NSMutableArray alloc]init];
        WalletTransactionsModel *model;

        for (NSDictionary *dictionary in arrResponse)
        {
            NSLog(@"GET_WALLET_TRANSACTIONS dictionary items  :%@",dictionary);

            model =[[WalletTransactionsModel alloc]initWithDictionary:dictionary error:&err];
            [arrWalletList addObject:model];
        }
        
        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,arrWalletList,nil);});
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"Get Transaction List Failure Response::%@",response);
             
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,err.localizedDescription);});
                 return;
             }
         }
     }];
    [operation start];
}


////
-(void)getWalletList:(NSString*)externalUserId completionBlock:(getWalletList)completionBlock
{
    
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    
    NSString *strUrl;
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    if(HeaderUserToken != nil) { // without external id
        
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,GET_WALLET_LIST];
        NSLog(@"**GET_WALLET_LIST** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,GET_WALLET_LIST,strExternalUserId];
        
        NSLog(@"**GET_WALLET_LIST** URL (WITH External user Id) : %@ ******",strUrl);
        
    }

    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];
    
    NSLog(@"Time stsamp:%@",strTimeStamp);
    NSLog(@"strUrl:%@",strUrl);
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    NSLog(@"%@ hEX:",strHash);
    
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?timestamp=%@&hash_key=%@",strUrl,strTimeStamp,strHash];
    NSLog(@"modifiedUrl:%@",modifiedUrl);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"GET"];

    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**GET_WALLET_LIST** USER_TOKEN:%@",HeaderUserToken);
    }
    
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:@"Content-Type"];

    NSLog(@"**GET_WALLET_LIST** X_APP_TOKEN:%@",strXAppToken);
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSArray *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        NSLog(@"GET_WALLET_LIST Response :%@",response);

        NSMutableArray *arrWalletList = [[NSMutableArray alloc]init];
        WalletListModel *model;
        
        //response is an array list of dictionaries/models so send back an array of models
        

        for (NSDictionary *dictionary in response)
        {
            NSLog(@"GET_WALLET_LIST dictionary items  :%@",dictionary);
            
            model = [[WalletListModel alloc]initWithDictionary:dictionary error:&err];
            [arrWalletList addObject:model];
        }
        NSLog(@"GET_WALLET_LIST arrWalletList of models :%@",arrWalletList);
        
        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,arrWalletList,nil);});
        }
    }
     
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"Get wallet List Failure Response::%@",response);
             
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,err.localizedDescription);});
                 return;
             }
         }
     }];
    [operation start];
}


-(void)removeMember:(NSString*)wallet_id member_externalUserId:(NSString*)member_externalUserId completionBlock:(removeMember)completionBlock
{
    NSMutableDictionary *dctPost = [[NSMutableDictionary alloc]init];
    [dctPost setValue:wallet_id forKey:@"wallet_id"];
    [dctPost setValue:member_externalUserId forKey:@"member_externalUserId"];
    NSLog(@"postBody:%@",dctPost);
    NSData  *data= [ NSJSONSerialization dataWithJSONObject:dctPost options:0 error:nil];
    
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    
    NSString *strUrl;
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    if(HeaderUserToken != nil) { // without external id
        
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,REMOVE_MEMBER];
        NSLog(@"**ADD_MEMBER_TO_WALLET** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,REMOVE_MEMBER,strExternalUserId];
        
        NSLog(@"**ADD_MEMBER_TO_WALLET** URL (WITH External user Id) : %@ ******",strUrl);
    }
    
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];

    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?timestamp=%@&hash_key=%@",strUrl,strTimeStamp,strHash];
    NSLog(@"modifiedUrl:%@",modifiedUrl);
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    if((HeaderUserToken != nil)) {// needed?
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**ADD_MEMBER_TO_WALLET** USER_TOKEN:%@",HEADER_USER_TOKEN);
    }
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:@"Content-Type"];
    [request setValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"DELETE"];
    [request setHTTPBody:data];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        NSLog(@"Remove member wallet Response%@",response);
        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,[response valueForKey:@"result"]);});
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@" Remove member Failure Response::%@",response);
         }
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,err.localizedDescription);});
                 return;
             }
         }
     }];
    [operation start];
}


//done
-(void)addMember:(NSString*)wallet_id member_externalId:(NSString*)member_externalId completionBlock:(AddMember)completionBlock
{
    
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    
    NSString *strUrl;
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    if(HeaderUserToken != nil) { // without external id
        
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,ADD_MEMBER];
        NSLog(@"**ADD_MEMBER_TO_WALLET** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,ADD_MEMBER,strExternalUserId];
        
        NSLog(@"**ADD_MEMBER_TO_WALLET** URL (WITH External user Id) : %@ ******",strUrl);
    }
    
    ////
    NSString *walletId = [[NSUserDefaults standardUserDefaults]
                          stringForKey:@"walletID"];

    
    NSString *postBody = [NSString stringWithFormat:@"wallet_id=%@&member_externalUserId=%@",wallet_id,member_externalId];


    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];
    NSLog(@"Time stsamp:%@",strTimeStamp);
    
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?timestamp=%@&hash_key=%@",strUrl,strTimeStamp,strHash];
    NSLog(@"ADD_MEMBER_TO_WALLET modifiedUrl:%@",modifiedUrl);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**ADD_MEMBER_TO_WALLET** USER_TOKEN:%@",HEADER_USER_TOKEN);
    }
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    NSLog(@"**ADD_MEMBER_TO_WALLET** X_APP_TOKEN:%@",strXAppToken);
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    NSLog(@" **ADD_MEMBER_TO_WALLET** Request:%@",request);
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        
        AddmemberBaseModel *model=[[AddmemberBaseModel alloc]initWithDictionary:response error:&err];
        
        NSLog(@"Add member wallet Response%@",response);
        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,model,nil);});
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@" Add member Failure Response::%@",response);
             
        }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,err.localizedDescription);});
                 return;
             }
         }
     }];
    [operation start];
}




-(void)walletDeposit:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description tags:(NSString*)tags completionBlock:(Deposit)completionBlock
{
    
    
    
    NSString *x_User_Token = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
     NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSString *strUrl;
    
    if(x_User_Token != nil) { // without external id
        
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,WALLET_DEPOSIT];
        
        NSLog(@"**walletDeposit** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
        
        NSLog(@"x_app_Token(USER_ID) : '%@'",strExternalUserId);
        NSLog(@"x_app_Token(STARTTER_X_APP_TOKEN) : '%@'",strAppXToken);
        
        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,WALLET_DEPOSIT,strExternalUserId];
        
        
        NSLog(@"**walletDeposit** URL (WITH External user Id) : %@ ******",strUrl);
    }
    
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    
    NSString *postBody = [NSString stringWithFormat:@"wallet_id=%@&order_amount=%@&transaction_amount=%@&transaction_id=%@&description=%@&order_id=%@&tags=%@",wallet_id,order_amount,transaction_amount,transaction_id,description,order_id,tags];
    
    
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];
    
    NSLog(@"PostBody:%@",postBody);
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    NSLog(@"%@ hEX:",strHash);
    
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?timestamp=%@&hash_key=%@",strUrl,strTimeStamp,strHash];
    
    NSLog(@"**walletDeposit** final modifiedUrl:%@",modifiedUrl);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    if((x_User_Token != nil)) {
        [request addValue:x_User_Token forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**walletDeposit** x-user-token :%@",x_User_Token);
    }
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        
        WalletDepositBaseModel *model=[[WalletDepositBaseModel alloc]initWithDictionary:response error:&err];
        
        NSLog(@"Wallet Deposit Response%@",response);
        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,model,nil);});
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"Failure Response::%@",response);
             
             
             
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,err.localizedDescription);});
                 return;
             }
         }
     }];
    [operation start];
}


-(void)transferFunds:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description receiver_externalId:(NSString*)receiver_externalId completionBlock:(TransferFund)completionBlock
{
    
    
    NSString *x_User_Token = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id

    NSString *strUrl;
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    if(x_User_Token != nil) { // without external id
        
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,TRANSFER_FUND];
        
        NSLog(@"**TRANSFER_FUND** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        
        NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
        
        NSLog(@"x_app_Token(USER_ID) : '%@'",strExternalUserId);
        NSLog(@"x_app_Token(STARTTER_X_APP_TOKEN) : '%@'",strAppXToken);
        
        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,TRANSFER_FUND,strExternalUserId];
        
        
        NSLog(@"**TRANSFER_FUND** URL (WITH External user Id) : %@ ******",strUrl);
    }
    
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    
    NSString *postBody = [NSString stringWithFormat:@"from_wallet_id=%@&order_amount=%@&transaction_amount=%@&transaction_id=%@&description=%@&order_id=%@&sender_externalUserId=%@&receiver_externalUserId=%@",wallet_id,order_amount,transaction_amount,transaction_id,description,order_id,strExternalUserId,receiver_externalId];
    
    
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];
    
    NSLog(@"Time stsamp:%@",strTimeStamp);
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    NSLog(@"%@ hEX:",strHash);

    
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?timestamp=%@&hash_key=%@",strUrl,strTimeStamp,strHash];
    NSLog(@"**TRANSFER_FUND** final modifiedUrl:%@",modifiedUrl);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    if((x_User_Token != nil)) {
        [request addValue:x_User_Token forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**TRANSFER_FUND** x-user-token :%@",x_User_Token);
    }
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        
        TransferFundModel *model=[[TransferFundModel alloc]initWithDictionary:response error:&err];
        
        NSLog(@"Wallet Transfer fund Response%@",response);
        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,model,nil);});
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"Failure Response::%@",response);
             
             
             
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,err.localizedDescription);});
                 return;
             }
         }
     }];
    [operation start];
}


-(void)withDrawFunds:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description tags:(NSString*)tags completionBlock:(WithDrawFund)completionBlock
{
    
    
    NSString *x_User_Token = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
     NSString *baseURLString = [[Utils shared] getBaseURLString];
    NSString *strUrl;
    
    if(x_User_Token != nil) { // without external id
        
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,WITHDRAW];
        
        NSLog(@"**walletWITHDRAWAL** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
        
        NSLog(@"x_app_Token(USER_ID) : '%@'",strExternalUserId);
        NSLog(@"x_app_Token(STARTTER_X_APP_TOKEN) : '%@'",strAppXToken);
        
        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,WITHDRAW,strExternalUserId];
        
        
        NSLog(@"**walletWITHDRAWAL** URL (WITH External user Id) : %@ ******",strUrl);
    }
    
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    
    NSString *postBody = [NSString stringWithFormat:@"wallet_id=%@&order_amount=%@&transaction_amount=%@&transaction_id=%@&description=%@&order_id=%@&tags=%@",wallet_id,order_amount,transaction_amount,transaction_id,description,order_id,tags];
    
    NSData *postData = [NSData dataWithBytes:[postBody UTF8String] length:[postBody length]];
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];
    
    NSLog(@"Time stsamp:%@",strTimeStamp);
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    NSLog(@"%@ hEX:",strHash);
    
    
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?timestamp=%@&hash_key=%@",strUrl,strTimeStamp,strHash];
    NSLog(@"**walletWITHDRAWAL** final modifiedUrl:%@",modifiedUrl);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    if((x_User_Token != nil)) {
        [request addValue:x_User_Token forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**walletWITHDRAWAL** x-user-token :%@",x_User_Token);
    }
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        
        WithdrawModel *model=[[WithdrawModel alloc]initWithDictionary:response error:&err];
        
        NSLog(@"withdraw Response%@",model);
        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,model,nil);});
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"Failure Response::%@",response);
             
             
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,err.localizedDescription);});
                 return;
             }
         }
     }];
    [operation start];
}



-(void)subwallet:(NSString*)wallet_name display_name:(NSString*)display_name users_list:(NSArray*)users_list completionBlock:(Subwallet)completionBlock
{
    
    NSString *x_User_Token = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    
    NSString *strUrl;
    NSString *baseURLString = [[Utils shared] getBaseURLString];
    if(x_User_Token != nil) { // without external id
        
        strUrl = [NSString stringWithFormat:@"%@%@",baseURLString,SUBWALLET];
        
        NSLog(@"**SUBWALLET** URL(WITH_OUT External user Id) : %@ ***********",strUrl);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
        
        NSLog(@"x_app_Token(USER_ID) : '%@'",strExternalUserId);
        NSLog(@"x_app_Token(STARTTER_X_APP_TOKEN) : '%@'",strAppXToken);
        
        
        strUrl = [NSString stringWithFormat:@"%@%@%@",baseURLString,SUBWALLET,strExternalUserId];
        
        
        NSLog(@"**SUBWALLET** URL (WITH External user Id) : %@ ******",strUrl);
    }
    
    NSMutableDictionary *dctPost = [[NSMutableDictionary alloc]init];
    [dctPost setValue:wallet_name forKey:@"wallet_name"];
    [dctPost setValue:users_list forKey:@"users_list"];
    [dctPost setValue:display_name forKey:@"display_name"];
    NSLog(@"dctPost:%@",dctPost);
    NSData  *data= [ NSJSONSerialization dataWithJSONObject:dctPost options:0 error:nil];
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    
    NSString *strTimeStamp =   [[Utils shared] GetCurrentEpochTime];
    NSLog(@"Time stsamp:%@",strTimeStamp);
    NSString *strHash = [self generateHashedString:strUrl apptoken:strAppID];
    NSLog(@"%@ hEX:",strHash);
    
    NSString *modifiedUrl = [NSString stringWithFormat:@"%@?timestamp=%@&hash_key=%@",strUrl,strTimeStamp,strHash];
    NSLog(@"modified FInal URL:%@",modifiedUrl);
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:modifiedUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    NSLog(@" strXUserToken:%@",strXAppToken);
    
    if((x_User_Token != nil)) {
        [request addValue:x_User_Token forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        NSLog(@"**SUBWALLET** x-user-token :%@",x_User_Token);
    }
    [request addValue:strXAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* err = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
        
        SubwalletModel *model=[[SubwalletModel alloc]initWithDictionary:response error:&err];
        NSLog(@"Subwallet Response%@",response);
        
        NSLog(@"Subwallet model%@",model);
        if (completionBlock)
        {
            dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,model,nil);});
        }
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         NSError *err = operation.error;
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"Failure Response::%@",response);
             
     }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,err.localizedDescription);});
                 return;
             }
         }
     }];
    [operation start];
}



#pragma mark - Notification Register and UnRegister

-(void)unRegisterForPushNotificationApi_completionBlock:(registerForPushBlock)completionBlock{
    
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"DEVICE_TOKEN"];//appToken
    
    
    NSString *url;
    NSString *HeaderAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];//app Token from Auth API
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    
    NSString *baseURLString = [[Utils shared] getBaseURLString];

    if(HeaderUserToken != nil) { // without external id
        
        url = [NSString stringWithFormat:@"%@%@",baseURLString,STT_UNREGISTER_FOR_PUSH];
        NSLog(@"******Sttarter unRegister_for_push URL (WITHOUT External user Id) : %@ ***********",url);
        
    }
    else{// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        url = [NSString stringWithFormat:@"%@%@/%@",baseURLString,STT_UNREGISTER_FOR_PUSH,strExternalUserId];
        
        NSLog(@"******Sttarter unRegister_for_push URL (with External user Id) : %@ ***********",url);
    }
    
    
    
    
    
    NSString *strClientId = [[NSUserDefaults standardUserDefaults] stringForKey:@"MQTT_CLIENT_ID"];//appToken
    
    if(strClientId == nil){
        NSString *stringClientId = [[Utils shared] getClientId];
        strClientId = stringClientId;
    }
    
    
    NSLog(@" ****** CLIENT ID (unRegister_For_push): %@ *****",strClientId);
    
    
    
    NSString *postBody = [NSString stringWithFormat:@"pushtoken=%@&platform=1&client_id=%@",deviceToken,strClientId];
    
    NSLog(@" ******Sttarter unRegister_for_push  Post body: %@ *****",postBody);
    
    NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    [request setHTTPMethod:@"POST"];
    
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
    }
    
    [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN]; //"x-app-token
    
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:CONTENT_TYPE];//@"Content-Type"
    
    [request setHTTPBody:postData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         
         NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@"  ******Sttarter UnRegister_for_push Response : %@ *****",dctResponse);
         
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,dctResponse);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSString *errTitle;
         NSString *errMsg;
         
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             
             if (operation.responseData != nil)
             {
                 errTitle = [response objectForKey:@"title"];
                 errMsg = [response objectForKey:@"msg"];
             }
             
             NSLog(@"  ******Sttarter UnRegister_for_push Error: %@ *****",err);
             NSLog(@"  ******Sttarter UnRegister_for_push Error Msg : %@ *****",errMsg);
         }
         else{
             errTitle=@"Error";
             errMsg=@" error";
         }
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil);});
                 return;
             }
         }
     }];
    [operation start];
    
    
    
}


-(void)registerForPushNotificationApi:(NSString*)deviceToken completionBlock:(registerForPushBlock)completionBlock{
    
    
    NSString *url;
    NSString *HeaderAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];//app Token from Auth API
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    
    NSString *baseURLString = [[Utils shared] getBaseURLString];

    if(HeaderUserToken != nil) { // without external id
        
        url = [NSString stringWithFormat:@"%@%@",baseURLString,STT_REGISTER_FOR_PUSH];
        NSLog(@"******Sttarter Register_for_push URL (WITHOUT External user Id) : %@ ***********",url);
        
    }
    else{// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        
        url = [NSString stringWithFormat:@"%@%@/%@",baseURLString,STT_REGISTER_FOR_PUSH,strExternalUserId];
        
        NSLog(@"******Sttarter Register_for_push URL (with External user Id) : %@ ***********",url);
    }
    
    
    NSString *strClientId = [[Utils shared] getClientId];
    NSLog(@" ****** CLIENT ID (Register_For_push): %@ *****",strClientId);
    
    
    
    NSString *postBody = [NSString stringWithFormat:@"pushtoken=%@&platform=1&client_id=%@",deviceToken,strClientId];
    NSLog(@" ******Sttarter Register_for_push  Post body: %@ *****",postBody);
    
    NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    [request setHTTPMethod:@"POST"];
    
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
    }
    
    [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN]; //"x-app-token
    
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:CONTENT_TYPE];//@"Content-Type"
    
    [request setHTTPBody:postData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         
         NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@"  ******Sttarter Register_for_push Response : %@ *****",dctResponse);
         
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,dctResponse);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSString *errTitle;
         NSString *errMsg;
         
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             
             if (operation.responseData != nil)
             {
                 errTitle = [response objectForKey:@"title"];
                 errMsg = [response objectForKey:@"msg"];
             }
             
             NSLog(@"  ******Sttarter Register_for_push Error: %@ *****",err);
             NSLog(@"  ******Sttarter Register_for_push Error Msg : %@ *****",errMsg);
         }
         else{
             errTitle=@"Error";
             errMsg=@"Notification error";
         }
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil);});
                 return;
             }
         }
     }];
    [operation start];
    
    
}





#pragma mark - Communicator

-(void)getAllMessagesForTopic:(NSString*)topicId maxNumberOfMessages:(int)maxNumberOfMessages withOffset:(int)offset completionBlock:(getMessageBlock)completionBlock
{
    
    NSString *url;
    
    NSLog(@" >>> get all msgs for topic %@ ",topicId);
  NSString *baseURLString = [[Utils shared] getBaseURLString];

    if([topicId containsString:@"group"]){
        
        url = [NSString stringWithFormat:@"%@%@%@/%d/%d",baseURLString,GET_MESSAGES,topicId,maxNumberOfMessages,offset];
    }
    
    else{
        
        NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
        NSString *strCheck =[NSString stringWithFormat:@"%@-master-",strAppKey];
        NSString *myExtUserId = [topicId stringByReplacingOccurrencesOfString:strCheck withString:@""];
        NSLog(@"*** User Id in Sttarted : %@",myExtUserId);
        // here topic id actually userId
        NSString *strMyMaster = [[NSUserDefaults standardUserDefaults] stringForKey:@"MY_MASTER_TOPIC"];
        
        url = [NSString stringWithFormat:@"%@%@%@/%d/%d/%@",baseURLString,GET_MESSAGES,strMyMaster,maxNumberOfMessages,offset,myExtUserId];
        // instead of their master and me, I am doing mymaster and their extId  **TEST with post man**
        
    }
    
    NSLog(@"****** Get Mesages with url:%@ **** ",url);
    
    
    NSMutableURLRequest * request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    [request setHTTPMethod:@"GET"];
    
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    [request addValue:strAppXToken forHTTPHeaderField:@"x-app-token"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSError* err = nil;
         NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         
         NSLog(@"*** Get messages for Topic: %@ ** With response:%@ ****",topicId,response);
         GetMessagesModel *model = [[GetMessagesModel alloc]initWithDictionary:response error:&err];
         NSLog(@"****** Get Mesages Model :%@",model);
         NSLog(@"****** Get Mesages Model if err exists :%@ ***",err);
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,model);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSError *err = operation.error;
         NSLog(@"****** Get messages : %@ ***********",err);
         NSString *errTitle;
         NSString *errMsg;
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             errTitle = [response objectForKey:@"title"];
             errMsg = [response objectForKey:@"msg"];
         }
         else{
             errTitle = @"Error";
             errMsg  =[NSString stringWithFormat:@"%@",err];
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil);});
                 return;
             }
         }
     }];
    [operation start];
}

//// Add Multiple memebers to group - API Works  (2)
-(void)addManyMembersToGroup:(NSMutableArray*)arrMemebers forGroupTopic:(NSString*)strTopic completionBlock:(addManyMembersBlock)completionBlock{
    
    NSLog(@"ADD multiple members : %@ TO the Group :%@",arrMemebers,strTopic);
    NSString *url;
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
  NSString *baseURLString = [[Utils shared] getBaseURLString];

    if(HeaderUserToken != nil) { // without external id
        
        url = [NSString stringWithFormat:@"%@%@",baseURLString,ADD_MANY_MEMEBERS_TO_GROUP]; ///app/mqtt/group
        // adduser
        NSLog(@"******Sttarter ADD_MEMEBER_TO_GROUP URL (WITH_OUT External user Id) : %@ ***********",url);
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        url = [NSString stringWithFormat:@"%@%@/%@",baseURLString,ADD_MANY_MEMEBERS_TO_GROUP,strExternalUserId];
        NSLog(@"******Sttarter ADD_MEMEBER_TO_GROUP URL (WITH External user Id) : %@ ***********",url);
    }
    
//    NSString *postBody = [NSString stringWithFormat:@"topic=%@&members=%@",strTopic,arrMemebers];
//    NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//
//    NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
  
  NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
  [requestParams setObject:strTopic forKey:@"topic"];
  [requestParams setObject:arrMemebers forKey:@"members"];
  NSError *error;
  
  NSData *postData = [NSJSONSerialization dataWithJSONObject:requestParams
                                                     options:0
                                                       error:&error];
  NSString *string = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
  NSLog(@"Add meembers to group request: %@",string);
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
  

    [request setHTTPMethod:@"POST"];
    if((HeaderUserToken != nil)) {
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
    }
    NSString *HeaderAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];//app Token from Auth API
    
    [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN]; //"x-app-token
    [request addValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:@"Accept"];
    [request addValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:CONTENT_TYPE];//@"Content-Type"
    [request setHTTPBody:postData];
    NSLog(@"Add members to group HeaderAppToken %@",HeaderAppToken);
    NSLog(@"Add members to group request %@",request);
    NSDictionary *dictionary = [request allHTTPHeaderFields];
    NSLog(@"Add members to group request headers %@",[dictionary description]);

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         
         NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@"  ******Sttarter ADD_MEMEBER_TO_GROUP : Response : %@ *****",dctResponse);
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,dctResponse);});
         }
         
         
         
     }
failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
       NSError *err = operation.error;
       NSLog(@"  ******Sttarter ADD_MEMEBER_TO_GROUP : Error Response : %@ *****",err);

       NSDictionary *response = nil;
       if(operation.responseData != nil){
         
         response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
       }
       if (completionBlock) {
         if (error) {
           dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,response);});
           return;
         }
       }
       
     }];
    [operation start];

}


// add single member to a group
-(void)addAMemberToGroup:(NSString*)strMemeberId forGroupTopic:(NSString*)strGroupTopic completionBlock:(addAMemberBlock)completionBlock{

        NSLog(@"ADD member : %@ TO the Group :%@",strMemeberId,strGroupTopic);
        
        NSString *url;
        NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
        NSString *baseURLString = [[Utils shared] getBaseURLString];

        if(HeaderUserToken != nil) { // without external id
            
            url = [NSString stringWithFormat:@"%@%@",baseURLString,ADD_MEMEBER_TO_GROUP]; ///app/mqtt/group
            // adduser
            NSLog(@"******Sttarter ADD_MEMEBER_TO_GROUP URL (WITH_OUT External user Id) : %@ ***********",url);
            
        }
        else{/// with external id
            
            NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
            url = [NSString stringWithFormat:@"%@%@/%@",baseURLString,ADD_MEMEBER_TO_GROUP,strExternalUserId];
            NSLog(@"******Sttarter ADD_MEMEBER_TO_GROUP URL (WITH External user Id) : %@ ***********",url);
        }
        
//        NSString *postBody = [NSString stringWithFormat:@"topic=%@&member=%@",strGroupTopic,strMemeberId];
//        NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//
//        NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
  
  NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] init];
  [requestParams setValue:strGroupTopic forKey:@"topic"];
  [requestParams setValue:strMemeberId forKey:@"member"];
  NSError *error;
  
  NSData *postData = [NSJSONSerialization dataWithJSONObject:requestParams
                                                     options:0
                                                       error:&error];
        NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                            timeoutInterval:HYConnectionTimeout];
        
        [request setHTTPMethod:@"POST"];
        
        if((HeaderUserToken != nil)) {
            
            [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
        }
        
        
        NSString *HeaderAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];//app Token from Auth API
        [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN]; //"x-app-token
        [request addValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:@"Accept"];
        [request addValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:CONTENT_TYPE];//@"Content-Type"
    
        [request setHTTPBody:postData];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
         {
             NSError* err = nil;
             
             NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
             NSLog(@"  ******Sttarter ADD_MEMEBER_TO_GROUP : Response : %@ *****",dctResponse);
             
             if (completionBlock)
             {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,dctResponse);});
             }

             
             
         }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
         {
             
           NSError *err = operation.error;
           NSDictionary *response = nil;
           if(operation.responseData != nil){
             response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             
           }
           if (completionBlock) {
             if (error) {
               dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,response);});
               return;
             }
           }
         }];
        [operation start];

}


/// Add Multiple users one by one  - adduser API
//-(void)addMemeberToGroup:(NSMutableArray*)arrMemebers forGroupTopic:(NSString*)strGroupTopic{
//
//    NSLog(@"members count: %@",arrMemebers);
//
//    for (NSString *member in arrMemebers) { //adduser
//
//        NSLog(@"ADD member : %@ TO the Group :%@",member,strGroupTopic);
//
//        NSString *url;
//        NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
//
//        if(HeaderUserToken != nil) { // without external id
//
//            url = [NSString stringWithFormat:@"%@%@%@%@",HTTP_PREFIX,BASE_URL,BASE_URL_PORT,ADD_MEMEBER_TO_GROUP]; ///app/mqtt/group
//           // adduser
//            NSLog(@"******Sttarter ADD_MEMEBER_TO_GROUP URL (WITH_OUT External user Id) : %@ ***********",url);
//
//        }
//        else{/// with external id
//
//            NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
//            url = [NSString stringWithFormat:@"%@%@%@%@/%@",HTTP_PREFIX,BASE_URL,BASE_URL_PORT,ADD_MEMEBER_TO_GROUP,strExternalUserId];
//            NSLog(@"******Sttarter ADD_MEMEBER_TO_GROUP URL (WITH External user Id) : %@ ***********",url);
//        }
//
//        NSString *postBody = [NSString stringWithFormat:@"topic=%@&member=%@",strGroupTopic,member];
//        NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//
//        NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
//        NSMutableURLRequest *request =
//        [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
//                            timeoutInterval:HYConnectionTimeout];
//
//        [request setHTTPMethod:@"POST"];
//
//        if((HeaderUserToken != nil)) {
//
//            [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
//        }
//
//
//        NSString *HeaderAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];//app Token from Auth API
//
//        [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN]; //"x-app-token
//
//        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
//        [request addValue:HEADER_CONTENT_TYPE forHTTPHeaderField:CONTENT_TYPE];//@"Content-Type"
//
//
//        [request setHTTPBody:postData];
//
//        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//
//        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
//         {
//             NSError* err = nil;
//
//             NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
//             NSLog(@"  ******Sttarter ADD_MEMEBER_TO_GROUP : Response : %@ *****",dctResponse);
//         }
//                                         failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
//         {
//
//             NSError *err = operation.error;
//             NSString *errTitle;
//             NSString *errMsg;
//
//             if(operation.responseData != nil){
//
//                 NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
//                 errTitle = [response objectForKey:@"title"];
//                 errMsg = [response objectForKey:@"msg"];
//
//                 NSLog(@"  ******Sttarter ADD_MEMEBER_TO_GROUP Error: %@ *****",err);
//                 NSLog(@" ******Sttarter ADD_MEMEBER_TO_GROUP Error Msg : %@ *****",errMsg);
//             }
//             else{
//                 errTitle=@"Error";
//                 errMsg=@" error";
//             }
//         }];
//        [operation start];
//    }
//}


-(void)createNewGroupApi:(NSString*)strGroupName withMeta:(NSString*)strMeta completionBlock:(createNewGroupBlock)completionBlock
{
    
    NSString *url;
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    NSString *baseURLString = [[Utils shared] getBaseURLString];

    if(HeaderUserToken != nil) { // without external id
        
        url = [NSString stringWithFormat:@"%@%@",baseURLString,CREATE_NEW_GROUP]; ///app/mqtt/group
        
        NSLog(@"******Sttarter read_Messae_API URL (WITH_OUT External user Id) : %@ ***********",url);

    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        url = [NSString stringWithFormat:@"%@%@/%@",baseURLString,CREATE_NEW_GROUP,strExternalUserId];
        NSLog(@"******Sttarter read_Messae_API URL (WITH External user Id) : %@ ***********",url);
    }

    NSString *postBody = [NSString stringWithFormat:@"topic_name=%@&meta=%@",strGroupName,strMeta];
    NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    [request setHTTPMethod:@"POST"];
    
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
    }
    
    
    NSString *HeaderAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];//app Token from Auth API
    
    [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN]; //"x-app-token
    
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
    [request addValue:HEADER_CONTENT_TYPE_URL_Encoded forHTTPHeaderField:CONTENT_TYPE];//@"Content-Type"
    
    
    [request setHTTPBody:postData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         
         NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@"  ******Sttarter add_new_Group_API SUCCESS Response : %@ *****",dctResponse);
         
         NSDictionary *dctTopic= [dctResponse objectForKey:@"topic"];
         NSString *strGroupTopic = [dctTopic objectForKey:@"topic"];
       
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,dctResponse);});
         }
     }
    
    failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSString *errTitle;
         NSString *errMsg;
         
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             errTitle = [response objectForKey:@"title"];
             errMsg = [response objectForKey:@"msg"];
             
             NSLog(@"  ******Sttarter add_new_Group_API Error: %@ *****",err);
             NSLog(@" ******Sttarter add_new_Group_API Error Msg : %@ *****",errMsg);
         }
         else{
             errTitle=@"Error";
             errMsg=@" error";
         }
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil);});
                 return;
             }
         }
     }];
    [operation start];

}

-(void)messageRead_Api_forTopic:(NSString*)strTopic messageHash:(NSMutableArray*)arrMessageHash completionBlock:(messageReadBlock)completionBlock{
    
    NSLog(@"******* markAaRead_Messae_API method called ");

    NSString *url;
    NSString *HeaderAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];//app Token from Auth API
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];// App Token from Login, sign up etc
    NSString *baseURLString = [[Utils shared] getBaseURLString];

    if(HeaderUserToken != nil) { // without external id
        
        url = [NSString stringWithFormat:@"%@%@",baseURLString,STT_MESSAGE_READ];
        
    }
    else{/// with external id
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id
        // BASE_URL
        url = [NSString stringWithFormat:@"%@%@/%@",baseURLString,STT_MESSAGE_READ,strExternalUserId];
        NSLog(@"******Sttarter markAaRead_Messae_API URL (with External user Id) : %@ ***********",url);
    }
    
//// POST BODY as String
//    NSString *postBody = [NSString stringWithFormat:@"topic=%@&messageHash=%@",strTopic,arrMessageHash];
//    NSString *escapedPath = [postBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    NSData *postData = [NSData dataWithBytes:[escapedPath UTF8String] length:[escapedPath length]];
//    NSLog(@"******* markAaRead_Messae_API with postBody :%@",postBody);
//    NSLog(@"******* markAaRead_Messae_API with postData  :%@",postData);
//
    // POST Body as DCT
    NSMutableDictionary *dctPost = [[NSMutableDictionary alloc]init];
    [dctPost setObject:arrMessageHash forKey:@"messageHash"];
    [dctPost setObject:strTopic forKey:@"topic"];
//    NSData *postData = [NSKeyedArchiver archivedDataWithRootObject:dctPost];
    NSError* error;
//    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:dctPost
//                                                         options:kNilOptions
//                                                           error:&error];
//    
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dctPost options:kNilOptions error:&error];
    NSLog(@"markAaRead_Messae_API URL = %@",url);
    NSLog(@"markAaRead_Messae_API hash array = %@",arrMessageHash);
    NSLog(@"markAaRead_Messae_API post dct = %@",dctPost);
    NSLog(@"markAaRead_Messae_API postData = %@",postData); // ION

    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    [request setHTTPMethod:@"POST"];
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];//x-user-token
    }
    
    [request addValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"json" forHTTPHeaderField:@"Accept"];
    [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN]; //"x-app-token
//    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
//    [request addValue:HEADER_CONTENT_TYPE forHTTPHeaderField:CONTENT_TYPE];//@"Content-Type"
    [request setHTTPBody:postData];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSLog(@"  ******Sttarter markAaRead_Messae_API Operation : %@ *****",operation);
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         
         NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@"  ******Sttarter markAaRead_Messae_API Response : %@ *****",dctResponse);
         
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,dctResponse);});
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         NSError *err = operation.error;
         NSString *errTitle;
         NSString *errMsg;
         
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             
             NSLog(@"  ******Sttarter markAaRead_Messae_API FAILED Response: %@ *****",response);

             errTitle = [response objectForKey:@"title"];
             errMsg = [response objectForKey:@"msg"];
             
             NSLog(@"  ******Sttarter markAaRead_Messae_API Error: %@ *****",err);
             NSLog(@"  ******Sttarter markAaRead_Messae_API Error Msg : %@ *****",errMsg);
         }
         else{
             errTitle=@"Error";
             errMsg=@" error";
         }
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil);});
                 return;
             }
         }
     }];
    [operation start];
    
    
}


//Creating hash
-(NSString*)generateHashedString:(NSString*)str apptoken:(NSString*)appToken{
    
    NSLog(@"generating hash");
    NSLog(@"key:%@",appToken);
    NSString *data = [NSString stringWithFormat:@"%@",str];
    const char *cKey  = [appToken cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    NSUInteger dataLength = [HMAC length];
    NSMutableString *string = [NSMutableString stringWithCapacity:dataLength*2];
    const unsigned char *dataBytes = [HMAC bytes];
    for (NSInteger idx = 0; idx < dataLength; ++idx) {
        [string appendFormat:@"%02x", dataBytes[idx]];
    }
    
    return string;
    
}


-(void)ApiBuzzMessages:(NSString*)HeaderUserToken appToken:(NSString*)HeaderAppToken strTopicId:(NSString*)TopicId completionBlock:(apiBuzzMessagesBlock)completionBlock{
    
    
    NSString *url;
    NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"];
    
    NSString *baseURLString = [[Utils shared] getBaseURLString];

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"is_X_UserToken_Exist"]||(HeaderUserToken == nil)) {
        
        url = [NSString stringWithFormat:@"%@%@%@",baseURLString,API_BUZZ_MESSAGES,TopicId];
    }
    else{
        url = [NSString stringWithFormat:@"%@%@%@/%@",baseURLString,API_BUZZ_MESSAGES,TopicId,strExternalUserId];
    }
    
    NSMutableURLRequest * request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"is_X_UserToken_Exist"]||(HeaderUserToken == nil)) {
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];
    }
    
    [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setHTTPMethod:@"GET"];
    
    
    //    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@",HTTP_PREFIX,BASE_URL,BASE_URL_PORT,API_BUZZ_MESSAGES,TopicId];
    //
    //    NSMutableURLRequest *request =
    //    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
    //                        timeoutInterval:HYConnectionTimeout];
    //
    //    [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];
    //    [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    //    [request setHTTPMethod:@"GET"];
    
    NSLog(@"######## BUZZ URL: %@ ########",url);
    NSLog(@"######## BUZZ  HeaderUserToken: %@ ########",HeaderUserToken);
    NSLog(@"######## BUZZ HeaderAppToken: %@ ########",HeaderAppToken);
    NSLog(@"****** MyTopics STARTTER_EXTERNAL_USER_ID : %@ ***********",strExternalUserId);
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         NSLog(@"######## Buzz Msgs Success Response: %@ ########",response);
         
         BuzzMessagesModel *modelBuzzMsgs=[[BuzzMessagesModel alloc]initWithDictionary:response error:&err];
         NSLog(@"######## BuzzMessagesModel: %@ ####****####",modelBuzzMsgs);
         
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelBuzzMsgs,nil,nil);});
         }
     }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSString *errTitle;
         NSString *errMsg;
         
         if(operation.responseData != nil){
             
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             NSLog(@"****** Buzz Msgs err Response: %@ ***********",response);
             
             if (operation.responseData != nil)
             {
                 errTitle = [response objectForKey:@"title"];
                 errMsg = [response objectForKey:@"msg"];
                 
             }
             
         }
         else{
             
             errTitle=@"Error";
             errMsg=@"Error msg";
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,errTitle,errMsg);});
                 return;
             }
         }
     }];
    [operation start];
    
    
    
    
}


// MIM _ API
-(void)ApiGetTopicForName:(NSString*)strGroupName completionBlock:(apiMyTopicsBlock)completionBlock{
    
    NSString *HeaderAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    NSString *HeaderUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];

    NSString *url;
    NSString *baseURLString = [[Utils shared] getBaseURLString];

    if(HeaderUserToken != nil) {
        
        url = [NSString stringWithFormat:@"%@%@?name=%@",baseURLString,API_MY_TOPICS,strGroupName];
        
        NSLog(@"****** MyTopics URL without External user Id : %@ ***********",url);
        
    }
    else{
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"];
        
        url = [NSString stringWithFormat:@"%@%@/%@?name=%@",baseURLString,API_MY_TOPICS,strExternalUserId,strGroupName];
        
        NSLog(@"****** MyTopics URL with External user Id : %@ ***********",url);
        
        
    }
    
    NSMutableURLRequest * request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];
        NSLog(@"****** MyTopics USER TOKEN : %@ ***********",HeaderUserToken);
        
    }
    
    [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setHTTPMethod:@"GET"];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSLog(@"****** MyTopics operation: %@ ***********",operation);
    NSLog(@"****** MyTopics Xapp Token: %@ ***********",HeaderAppToken);
    NSLog(@"****** MyTopicsApi Called with URL :' %@ ' ***********",url);
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         
         NSLog(@"****** My Topics Response: %@ *********** %@",response, [response class]);
         
         MyTopicsModel *modelGetOtp=[[MyTopicsModel alloc]initWithDictionary:response error:&err];
         NSLog(@"Error: %@",err);
         NSLog(@"****** MyTopics Model Created: %@ ***********",modelGetOtp);
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelGetOtp,nil,nil);});
         }
     }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSLog(@"****** My Topics err : %@ ***********",err);
         
         
         
         NSString *errTitle;
         NSString *errMsg;
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             errTitle = [response objectForKey:@"title"];
             errMsg = [response objectForKey:@"msg"];
         }
         else{
             errTitle = @"Error";
             errMsg  =[NSString stringWithFormat:@"%@",err];
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,errTitle,errMsg);});
             }else{
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,errTitle,errMsg);});
             }
         }
     }];
    [operation start];
    
}// MIM - end


-(void)ApiMyTopics:(NSString*)HeaderUserToken appToken:(NSString*)HeaderAppToken  completionBlock:(apiMyTopicsBlock)completionBlock{
    

    NSString *url;
    
    NSString *baseURLString = [[Utils shared] getBaseURLString];

    if(HeaderUserToken != nil) {
        
        //[[NSUserDefaults standardUserDefaults] boolForKey:@"is_X_UserToken_Exist"]
        //
        url = [NSString stringWithFormat:@"%@%@",baseURLString,API_MY_TOPICS];
        
        NSLog(@"****** MyTopics URL without External user Id : %@ ***********",url);
        
    }
    else{
        
        NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"];
        
        url = [NSString stringWithFormat:@"%@%@/%@",baseURLString,API_MY_TOPICS,strExternalUserId];
        
        NSLog(@"****** MyTopics URL with External user Id : %@ ***********",url);
        
        
    }
    
    NSMutableURLRequest * request =
    [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                        timeoutInterval:HYConnectionTimeout];
    
    if((HeaderUserToken != nil)) {
        
        [request addValue:HeaderUserToken forHTTPHeaderField:HEADER_USER_TOKEN];
        NSLog(@"****** MyTopics USER TOKEN : %@ ***********",HeaderUserToken);
        
    }
    
    [request addValue:HeaderAppToken forHTTPHeaderField:HEADER_X_APP_TOKEN];
    [request setHTTPMethod:@"GET"];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSLog(@"****** MyTopics operation: %@ ***********",operation);
    NSLog(@"****** MyTopics Xapp Token: %@ ***********",HeaderAppToken);
    NSLog(@"****** MyTopicsApi Called with URL :' %@ ' ***********",url);
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
     {
         NSError* err = nil;
         NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
         
         NSLog(@"****** My Topics Response: %@ *********** %@",response, [response class]);
         
         MyTopicsModel *modelGetOtp=[[MyTopicsModel alloc]initWithDictionary:response error:&err];
         NSLog(@"Error: %@",err);
         NSLog(@"****** MyTopics Model Created: %@ ***********",modelGetOtp);
         
         if (completionBlock)
         {
             dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (nil,modelGetOtp,nil,nil);});
         }
     }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
     {
         
         NSError *err = operation.error;
         NSLog(@"****** My Topics err : %@ ***********",err);
         
         
         
         NSString *errTitle;
         NSString *errMsg;
         if (operation.responseData != nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
             errTitle = [response objectForKey:@"title"];
             errMsg = [response objectForKey:@"msg"];
         }
         else{
             errTitle = @"Error";
             errMsg  =[NSString stringWithFormat:@"%@",err];
         }
         
         if (completionBlock) {
             if (error) {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (err,nil,errTitle,errMsg);});
                 return;
             }
             return;

         }
     }];
    [operation start];
    
}

-(void)getUserListForExternalIDs:(NSArray*)externalUserIds getUserSuccessListenerBlock:(getUserSuccessListenerBlock)successBlock andErrorListenerBlock:(errorListenerBlock)failureBlock {
  NSString *baseURLString = [[Utils shared] getBaseURLString];

  NSString *url = [NSString stringWithFormat:@"%@%@",baseURLString,SYNC_MULTIPLE_USERS];

  NSMutableDictionary *requestParams = [[NSMutableDictionary alloc]init];
  [requestParams setObject:externalUserIds forKey:@"users"];

  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestParams
                                                     options:0
                                                       error:&error];

  NSMutableURLRequest *request =
  [NSMutableURLRequest requestWithURL:[self URLByEncodingString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData
                      timeoutInterval:HYConnectionTimeout];
  
  NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
  
  [request setHTTPMethod:@"POST"];
  [request addValue:strXAppToken forHTTPHeaderField:@"x-app-token"];
  [request addValue:HEADER_CONTENT_TYPE_JSON forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:jsonData];
  NSLog(@" ******Sttarter getUserListForExternalIDs API URL: %@ **** %@",request ,requestParams);
  NSLog(@" ******Sttarter x-app-token: %@",strXAppToken);
  
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) //If Success
   {
     NSError* err = nil;
     
     NSDictionary *dctResponse = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&err];
     
     NSMutableArray *usersList = [NSMutableArray new];
     if (dctResponse != nil){
       id usersArray = [dctResponse objectForKey:@"users"];
       
       if ([usersArray isKindOfClass:[NSArray class]]){
         
         NSArray *tempArray = (NSArray*)usersArray;
         
         for (NSDictionary *tempDict in tempArray) {
           UsersModel *userModel=[[UsersModel alloc]initWithDictionary:tempDict error:&err];
           [usersList addObject:userModel];
        
         }
       }
     }
     
     if (successBlock)
     {
       dispatch_async (dispatch_get_main_queue (), ^{
         successBlock(nil,usersList);
       });
     }
   }
   
failure:^(AFHTTPRequestOperation *operation, NSError *error)  //If failure
   {
     
     NSError *err = operation.error;
     NSString *errTitle;
     NSString *errMsg;
     NSLog(@"****** STT_ApiLogin err msg %@ ***********",errMsg);
     
     if(operation.responseData != nil){
       
       NSDictionary *response = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
       NSLog(@"****** STT_ApiLogin err msg %@ ***********",response);
       
       if (operation.responseData != nil)
       {
         errTitle = [response objectForKey:@"title"];
         errMsg = [response objectForKey:@"msg"];
       }
     }
     else{
       errTitle=@"Error";
       errMsg=@"Login error";
     }
     
     if (failureBlock) {
       if (error) {
         dispatch_async (dispatch_get_main_queue (), ^{
           failureBlock(err);
         });
       }
     }
   }];
  
  [operation start];
}

@end
