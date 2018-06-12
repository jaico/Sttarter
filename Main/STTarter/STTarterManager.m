//
//  SttarterClass.m
//  SttarterClass
//
//  Created by Prajna Shetty on 21/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#import "STTarterManager.h"
//#import "DatabaseHandler.h"
#import "Topics+CoreDataClass.h"
#import "GetRefCodeModel.h"
#import "STTaterCommunicator.h"

@implementation STTarterManager
{
    NSString *UserName;
    NSString *Password;
    NSDictionary *dctUserInformation;
    SignUpUserInfoModel *signUpModel;
}
static STTarterManager* _sttarterClass = nil;

+(STTarterManager*)sharedSttarterClass
{
    
    @synchronized([STTarterManager class])
    {
        if (!_sttarterClass)
            
            _sttarterClass = [[self alloc] init];
        [_sttarterClass checkInternetReachability];
        return _sttarterClass;
    }
    return nil;
}


-(void)checkInternetReachability{
    NSLog(@"STTarterManager--checkInternetReachability");

    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reachability startNotifier];
}


- (void)reachabilityDidChange:(NSNotification *)notification {
    
    Reachability *reachability = (Reachability *)[notification object];
    if ([reachability isReachable]) { /// isReachableViaWiFi or ReachableViaWWAN
        
        NSLog(@"reachabilityDidChange--Connected");
                /// observer for things to be done in communicator class..
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OnReconnectingToInternet" object:self userInfo:nil];
        
    } else {
        NSLog(@"reachabilityDidChange--Failed");
    }
}


-(void)MakeLoginCall:(NSNotification*)notification//2
{
    
    
    NSLog(@"***Login Deleate Method called***");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallLoginMethod" object:nil];
    
    [self login:UserName password:Password]; // check Delegated method ***
    
}

#pragma mark - Init methods

-(void)STTarterInit:(NSString *)strAppKey appSecret:(NSString *)strAppSecret username:(NSString *)strUsername password:(NSString *)strPassword{
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    if(strXAppToken==nil){
        
        UserName =strUsername;
        Password =strPassword;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MakeLoginCall:)  name:@"CallLoginMethod" object:nil];
        
        [self STTarterInit:strAppKey appSecret:strAppSecret];
        
    }
    else{
        
        NSLog(@" ** STARTTER_x_app_token : %@ **",strXAppToken);
        
        [self login:strUsername password:strPassword];
    }
    
}

-(void)STTarterInit:(NSString *)strAppKey appSecret:(NSString *)strAppSecret username:(NSString *)strUsername password:(NSString *)strPassword andEnvironmentTag:(int)environmentTag{
  [[Utils shared] setEnvironmentTag:environmentTag];

  NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
  
  if(strXAppToken==nil){
    
    UserName =strUsername;
    Password =strPassword;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MakeLoginCall:)  name:@"CallLoginMethod" object:nil];
    
    [self STTarterInit:strAppKey appSecret:strAppSecret];
    
  }
  else{
    
    NSLog(@" ** STARTTER_x_app_token : %@ **",strXAppToken);
    
    [self login:strUsername password:strPassword];
  }
  
}



-(void)STTarterInit:(NSString *)strAppKey appSecret:(NSString *)strAppSecret
{
    if(strAppKey != nil && strAppSecret!=nil ){
        
        [[NSUserDefaults standardUserDefaults] setObject:strAppKey forKey:@"APP_ID"];
        [[NSUserDefaults standardUserDefaults] setObject:strAppSecret forKey:@"APP_SECRET"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
        
        
        if(strXAppToken==nil){
            
            [[DownloadManager shared]ApiAuth:strAppKey app_secret:strAppSecret completionBlock:^(NSError *error,AuthModel *modelAuthModel,NSString *errTitle, NSString *errMsg){
                
                
                NSMutableDictionary *dctAlertInfo;
                
                if (error) // failed
                {
                    NSLog(@" Auth Failure in Sttarter class ");
                    
                    dctAlertInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    errMsg, @"Alert_Msg",
                                    @"Error", @"Alert_Title",
                                    nil];
                    NSLog(@" **** authFailureDelegateMethod :%@ ****",dctAlertInfo);

                    
//                    msg = "We Could not find application with given credentials";
//                    status = 401;
//                    title
                    
                    [self.delegate authFailureDelegateMethod:dctAlertInfo];//
                    
                }
                else{
                    
                    
                    
                    NSLog(@" Auth Success in Sttarter class ");
                    
                    [[NSUserDefaults standardUserDefaults] setObject:modelAuthModel.token forKey:@"STARTTER_X_APP_TOKEN"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    
                    NSString *strXAppToken1 = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
                    
                    NSLog(@" *** x-user-token *** from Auth2: %@ ***",strXAppToken1);
                    
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallLoginMethod" object:self userInfo:nil];
                    
                    NSLog(@"Sign Up 2");

                    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallSignUpMethod" object:self userInfo:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"callRegisterNotification" object:self userInfo:nil];
                    
//                    NSLog(@"Will call SaveExternaluserId ");
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SaveExternaluserId" object:self userInfo:nil];


                    [self.delegate authSuccessDelegateMethod:dctAlertInfo];//
                    
                }
                
            }];
        }
        
    }
}


-(void)STTarterInit:(NSString *)strAppKey appSecret:(NSString *)strAppSecret externalUserId:(NSString *)strExternalUserId{
    
    
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    
    if(strXAppToken==nil){
        
        NSLog(@"init with ext user called");
        
        
        [self STTarterInit:strAppKey appSecret:strAppSecret];
        
    }
//    else{
        
    [[NSUserDefaults standardUserDefaults] setObject:strExternalUserId forKey:@"USER_ID" ];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSLog(@"***** INIT with EXTERNAL_USER_ID :%@ ****",strExternalUserId);
        
        
//        [self setUpModules];
//    }
    
    
}


-(void)STTarterInit:(NSString *)strAppKey appSecret:(NSString *)strAppSecret externalUserId:(NSString *)strExternalUserId andEnvironmentTag:(int)environmentTag{
  
  [[Utils shared] setEnvironmentTag:environmentTag];
  
  NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
  
  
  if(strXAppToken==nil){
    
    NSLog(@"init with ext user called");
    
    
    [self STTarterInit:strAppKey appSecret:strAppSecret];
    
  }
  //    else{
  
  [[NSUserDefaults standardUserDefaults] setObject:strExternalUserId forKey:@"USER_ID" ];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  NSLog(@"***** INIT with EXTERNAL_USER_ID :%@ ****",strExternalUserId);
  
  
  //        [self setUpModules];
  //    }
  
  
}




#pragma mark - Push


-(void)RegisterForPush:(NSString*)deviceToken
{
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"DEVICE_TOKEN"];//Your master
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@" RegisterForPush with device token :%@ ",deviceToken);
    
    [[DownloadManager shared]registerForPushNotificationApi:deviceToken  completionBlock:^(NSError *error,NSDictionary *dctResposnse){
        
        if (error) // failed
        {
            NSLog(@"Error!! Register_for_push Failed in SttarterClass.h with Error: %@",error);
        }
        else{
            NSLog(@"Sucess !! Register_for_push !!! ");
        }
    }
     ];
}

-(void)RegisterForPush:(NSString*)deviceToken completionBlock:(registerForPushNotificationBlock)completionBlock
{
  
  [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:@"DEVICE_TOKEN"];//Your master
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  NSLog(@" RegisterForPush with device token :%@ ",deviceToken);
  
  [[DownloadManager shared]registerForPushNotificationApi:deviceToken  completionBlock:^(NSError *error,NSDictionary *dctResposnse){
    
    if (error) // failed
    {
      completionBlock(error,false);
      NSLog(@"Error!! Register_for_push Failed in SttarterClass.h with Error: %@",error);
    }
    else{
      NSLog(@"Sucess !! Register_for_push !!! ");
      completionBlock(nil,true);

    }
  }
   ];
}



#pragma mark - Logout/ Clear All

-(void)logout{
    
    [[DownloadManager shared]unRegisterForPushNotificationApi_completionBlock:^(NSError *error,NSDictionary *dctResposnse){
        
        if (error) // failed
        {
            NSLog(@"Error!! UnRegister_for_push Failed during Logout: %@",error);
        }
        else{
            NSLog(@"Sucess !! UnRegister_for_push !!! ");
        }
    }
     ];
    
    // Disconnect MQTT, Clears the database.
    [[STTaterCommunicator sharedCommunicatorClass] CleanCommunicator];
    [[DatabaseHandler sharedDatabaseHandler] clearDataBase];
    [self clearAllSttarterUserDefaults];
    [self removeAllSttarterObservers];
    // Remove observers
    [STTaterCommunicator destroyInstance];
  
    NSString *strFrom = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"];
    NSLog(@" Test Cleared data: USER_ID = %@",strFrom);
    [self resetDefaults];
}

- (void)resetDefaults {
  
  NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
  NSDictionary * dict = [defs dictionaryRepresentation];
  for (id key in dict) {
    [defs removeObjectForKey:key];
  }
  [defs synchronize];
}

-(void)removeAllSttarterObservers{

  //  [[NSNotificationCenter defaultCenter] removeObserver:self];

    /// Note : We cannot use the above method because it will delete all the  observers even the app side ones and not just the SDK Observers.

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallLoginMethod" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshUI_Notification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallSignUpMethod" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"callRegisterNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginFailureNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MQTTNewMsgReceived" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OnReconnectingToInternet" object:nil];

}

-(void)clearAllSttarterUserDefaults{

//    Clear UserDafaults
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//    
//    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
//    NSDictionary * dict = [defs dictionaryRepresentation];
//    for (id key in dict) {
//        [defs removeObjectForKey:key];
//    }
//    [defs synchronize];
    
     [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STT_LOGIN_INFO"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STARTTER_X_APP_TOKEN"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STARTTER_X_USER_TOKEN"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"walletID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"APP_ID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_ID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DEVICE_TOKEN"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"APP_USERNAME"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MY_MASTER_TOPIC"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MQTT_CLIENT_ID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_WalletPermitted"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_CommunicatorPermitted"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_ReferralsPermitted"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isUserAuthenticated"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_ContentSystemPermitted"];

    [[NSUserDefaults standardUserDefaults] synchronize];

}


-(void)loginwithCustomAuth:(NSString*)externalUserId
{
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    if(strXAppToken==nil){
        // Raise an error. With the message. App Key and Secret not set and not initialized
        [self.delegate loginwithCustomAuthFailure:@"Failed."];
    }else{
        
        [[NSUserDefaults standardUserDefaults] setObject:externalUserId forKey:@"USER_ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"***** INIT with EXTERNAL_USER_ID :%@ ****",externalUserId);
        NSLog(@"loginwithCustomAuth method called");
        //Successfully saved his external ID
       // [self setUpModules];
        [self.delegate loginwithCustomAuthSuccess:@""];
    }
}


-(BOOL)isUserAuthenticated;
{
    
    BOOL isLoggedIn = ([[NSUserDefaults standardUserDefaults] boolForKey:@"isUserAuthenticated"]);
    
    NSLog(isLoggedIn ? @"*** isUserAuthenticated is: Yes" : @"*** isUserAuthenticated is: No");
    
    return isLoggedIn;
}



-(NSString*)getAppId{// appKey
    
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    
    return strAppID;
    
}

-(NSString*)getAppSecret{
    
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_SECRET"];
    
    return strAppID;
    
}

-(NSString*)getUsername{
    
    NSString *strUserName = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_USERNAME"];
    
    return strUserName;
    
}

-(void)MakeSignUpCall:(NSNotification*)notification//2
{
    NSLog(@"Sign Up 3");

//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CallSignUpMethod" object:nil];
//    SignUpUserInfoModel *theUserToSignUp = [notification object];

    if(signUpModel !=nil){
    [self signUp:signUpModel];
    }
    
}


-(void)signUp:(NSString *)strAppKey appSecret:(NSString *)strAppSecret userData:(SignUpUserInfoModel*)userModelToSignUp{ // Auth+ SignUp
    
    signUpModel = userModelToSignUp;
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    if(strXAppToken==nil){

        NSLog(@"Sign Up 1");
        

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MakeSignUpCall:)  name:@"CallSignUpMethod" object:nil];
        
        [self STTarterInit:strAppKey appSecret:strAppSecret];
        
    }
    else{
        
        [self signUp:signUpModel];
        
    }
    
}

-(void)signUp:(SignUpUserInfoModel*)userModelToSignUp{ // Sign Up with Sttarter Auth
    
    NSLog(@"Sign Up 4");

    // Auth Check
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    if(strXAppToken==nil){
        
        // throw an error to Authenticate
        NSString *errMsg = @"kindly Auntenticate App before Sign Up.";
        [self.delegate signUpFailureDelegateMethod:errMsg];
        
    }
    else{
        
        
        NSLog(@"*** strXAppToken :%@ ***",strXAppToken);
        
        [[DownloadManager shared] STT_SignUp:userModelToSignUp appXToken:strXAppToken completionBlock:^(NSError *error,SignUpModel *modelSignUp,NSString *errTitle, NSString *errMsg){
            
            
            if (error) // failed
            {
                NSLog(@"*** STT_SignUp Failed with error :  %@ ***",errMsg);
                
                
                [self.delegate signUpFailureDelegateMethod:errMsg];
                
            }
            else // success
            {
                
                NSLog(@"**** STT_SignUp Successss: ****");
                SignUpUserInfoModel *_SignUpInfo = modelSignUp.user;
                
                [[NSUserDefaults standardUserDefaults] setObject:_SignUpInfo.username forKey:@"APP_USERNAME"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSMutableDictionary *dctLoginData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     _SignUpInfo.stt_id, @"stt_id",
                                                     _SignUpInfo.name, @"name",
                                                     _SignUpInfo.email, @"email",
                                                     _SignUpInfo.mobile, @"mobile",
                                                     _SignUpInfo.username, @"username",
                                                     _SignUpInfo.master_topic, @"master_topic",
                                                     _SignUpInfo.org_topic, @"org_topic",
                                                     _SignUpInfo.user_token, @"user_token",
                                                     nil];
                
                [[NSUserDefaults standardUserDefaults] setObject:dctLoginData forKey:@"STT_LOGIN_INFO"];
                
                [[NSUserDefaults standardUserDefaults] setObject:_SignUpInfo.user_token forKey:@"STARTTER_X_USER_TOKEN"];
                
                [[NSUserDefaults standardUserDefaults] setObject:_SignUpInfo.username  forKey:@"USER_ID"];
                
                
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isUserAuthenticated"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                [self.delegate signUpSuccessDelegateMethod];
                
            }
            
        }];
        
        
    }
}

-(void)signUp:(SignUpUserInfoModel*)userModelToSignUp completionHandler:(apiRegistrationBlock) completionBlock{ // Sign Up with Sttarter Auth
  
  NSLog(@"Sign Up 4");
  
  // Auth Check
  NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
  if(strXAppToken==nil){
    // throw an error to Authenticate
    NSString *errMsg = @"kindly Auntenticate App before Sign Up.";
    completionBlock(errMsg, false);
  }
  else{
      NSLog(@"*** strXAppToken :%@ ***",strXAppToken);
    
    [[DownloadManager shared] STT_SignUp:userModelToSignUp appXToken:strXAppToken completionBlock:^(NSError *error,SignUpModel *modelSignUp,NSString *errTitle, NSString *errMsg){
      if (error) // failed
      {
        NSLog(@"*** STT_SignUp Failed with error :  %@ ***",errMsg);
        completionBlock(errMsg, false);
      }
      else // success
      {
        NSLog(@"**** STT_SignUp Successss: ****");
        SignUpUserInfoModel *_SignUpInfo = modelSignUp.user;
        
        [[NSUserDefaults standardUserDefaults] setObject:_SignUpInfo.username forKey:@"APP_USERNAME"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSMutableDictionary *dctLoginData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             _SignUpInfo.stt_id, @"stt_id",
                                             _SignUpInfo.name, @"name",
                                             _SignUpInfo.email, @"email",
                                             _SignUpInfo.mobile, @"mobile",
                                             _SignUpInfo.username, @"username",
                                             _SignUpInfo.master_topic, @"master_topic",
                                             _SignUpInfo.org_topic, @"org_topic",
                                             _SignUpInfo.user_token, @"user_token",
                                             nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:dctLoginData forKey:@"STT_LOGIN_INFO"];
        
        [[NSUserDefaults standardUserDefaults] setObject:_SignUpInfo.user_token forKey:@"STARTTER_X_USER_TOKEN"];
        
        [[NSUserDefaults standardUserDefaults] setObject:_SignUpInfo.username  forKey:@"USER_ID"];
        
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isUserAuthenticated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        completionBlock(nil, true);
      }
    }];
  }
  
}

-(void)login:(NSString*)strUsername password:(NSString*)strPassword{
    
    NSLog(@"*** Login called with username:%@ and password :%@ ***",strUsername,strPassword);
    NSString *strAppXToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    NSLog(@"*** strAppXToken :%@ ***",strAppXToken);
    
    [[DownloadManager shared]STT_ApiLogin:strUsername password:strPassword app_XToken:strAppXToken completionBlock:^(NSError *error,LoginModel *_LoginModel ,NSString *errTitle, NSString *errMsg){
        
        NSLog(@"*** LOGIN Entered ***");
        
        
        if (error) // failed
        {
            NSMutableDictionary *dctAlertInfo;
            
            NSLog(@"*** Username password Login failed with error :  %@ ***",errMsg);
            dctAlertInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            errMsg, @"Alert_Msg",
                            @"Error", @"Alert_Title",
                            nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailureNotification" object:self userInfo:dctAlertInfo];
            
            [self.delegate loginFailureDelegateMethod:dctAlertInfo];//
            
        }
        else // success
        {
            
            NSMutableDictionary *dctLoginData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 _LoginModel.stt_id, @"stt_id",
                                                 _LoginModel.name, @"name",
                                                 _LoginModel.email, @"email",
                                                 _LoginModel.mobile, @"mobile",
                                                 _LoginModel.username, @"username",
                                                 _LoginModel.master_topic, @"master_topic",
                                                 _LoginModel.org_topic, @"org_topic",
                                                 _LoginModel.user_token, @"user_token",
                                                 nil];
            
            [[NSUserDefaults standardUserDefaults] setObject:_LoginModel.username forKey:@"APP_USERNAME"];
            [[NSUserDefaults standardUserDefaults] setObject:_LoginModel.user_token forKey:@"STARTTER_X_USER_TOKEN"];
            
            [[NSUserDefaults standardUserDefaults] setObject:_LoginModel.username  forKey:@"USER_ID"];// either STARTTER_EXTERNAL_USER_ID or Username
            
            [[NSUserDefaults standardUserDefaults] setObject:dctLoginData forKey:@"STT_LOGIN_INFO"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessNotification" object:self userInfo:dctAlertInfo];
            
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isUserAuthenticated"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            [self.delegate loginSuccessDelegateMethod];//remove dct
            
           // [self setUpModules];
            
        }
    }];
}



-(void)signupWithOTP:(NSString*)strName mobileNo:(NSString*)strMobileNo email:(NSString*)strEmail orgId:(NSString*)strOtp{
    
    [[DownloadManager shared]ApiQuickLogin:strName mobileNo:strMobileNo email:strEmail orgId:strOtp completionBlock:^(NSError *error,NSString *strStatus, NSString *strTitle, NSString *strMsg)
     {
         
         NSMutableDictionary *dctAlertInfo;
         BOOL isEmpty;
         
         if (error) // failed
         {
             if(strMsg.length == 0){
                 
                 strMsg = @"Kindly try again later.";
             }
             
             //  [self.delegate quickLoginDelegateMethod:dctAlertInfo];
             [self.delegate signupWithOTPFailureDelegateMethod:strMsg];
             
         }
         else // success
         {
             
             isEmpty = ([dctAlertInfo count] == 0);
             if(!isEmpty){
                 [dctAlertInfo removeAllObjects];
             }
             
             dctAlertInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             strStatus, @"Alert_Status",
                             strMsg, @"Alert_Msg",
                             strTitle, @"Alert_Title",
                             nil];
             
             [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isUserAuthenticated"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             //              [self.delegate quickLoginDelegateMethod:dctAlertInfo];
             [self.delegate signupWithOTPSuccessDelegateMethod:dctAlertInfo];
         }
     }];
}


//-(void)setUpModules{
//    //Check what and all modules are active - based on the app authenticated permitted models and then initiate.
//    
//    
//    STTaterCommunicator *objComSttarter;
//   // First check for communicator
//    objComSttarter =[STTaterCommunicator sharedCommunicatorClass];
//    
//    if(objComSttarter != nil){
//        [objComSttarter subscribeInitialize];
//    }
//}

@end
