//
//  STTaterCommunicator.m
//  Sttarter
//
//  Created by Prajna Shetty on 25/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "STTaterCommunicator.h"
#import "AuthModel.h"
#import "PermittedModulesModel.h"
#import "Utils.h"
#import "Reachability.h"
#import "TopicMessageDetailEntity+CoreDataClass.h"
#import "TopicModel.h"


@implementation STTaterCommunicator

static STTaterCommunicator* sttarterCommunicatorClass = nil;
bool isMQTTSessionConnecting = false;

+ (STTaterCommunicator*)sharedCommunicatorClass{
    
    @synchronized([STTaterCommunicator class]) {
        if (sttarterCommunicatorClass == nil){
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSData *myEncodedObject = [prefs objectForKey:@"AUTH_MODEL" ];
            NSLog(@"!!!!!! Communicator is permitted and Initialized !!!!!!%@",myEncodedObject);

            if(myEncodedObject == nil || myEncodedObject == (NSData*)[NSNull null]){
                return nil;
            }
            AuthModel *modelAuth = (AuthModel *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
            
            for (int i=0; i < modelAuth.permitted_modules.count; i++) {
                
                PermittedModulesModel *modelperModules = [modelAuth.permitted_modules objectAtIndex:i];
                
                if ([[modelperModules.module_name uppercaseString]isEqualToString:@"COMMUNICATOR"] ) {
                    
                    sttarterCommunicatorClass = [[self alloc] init];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"is_CommunicatorPermitted"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSLog(@"!!!!!! Communicator is permitted and Initialized !!!!!!");
                    
                    [sttarterCommunicatorClass initialSetup];
                    
                    return sttarterCommunicatorClass;
                }
            }
            return nil;
            
        }
        
        return sttarterCommunicatorClass;
    }
}

//SAC
//-(void)testIsReadAPI:(NSString*)strTopic MessageArray:(NSMutableArray*)srrHash{
//
//  [[DatabaseHandler sharedDatabaseHandler]updateLastMessageToSever:strTopic Messages:srrHash];
//
//}


-(void)getTopicByName:(NSString*)strName withCompletionBlock:(getTopicByNameBlcok)completionBlock{
    NSLog(@"getTopicByName begins...");
    NSLog(@"getTopicByName begins strNamestrName ...%@",strName);
    
    __block NSString *strTopic = [[DatabaseHandler sharedDatabaseHandler] getTopicForNameFromDbFor:strName];
    if ([strTopic isEqualToString:@""]){ // if empty
        NSLog(@"Data not available in DB...");
        NSLog(@"API calling...");
        
        [self getMyTopicForName:strName withComplitionBlock:^(BOOL isSuccess,TopicsModel *model) {
            NSLog(@"API calling completed...");
            
            if(isSuccess == true){
                NSLog(@"API calling completed - Success...");
                strTopic = model.topic;
                if (completionBlock)
                {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (strTopic);
                    });
                }
            }
            else{
                NSLog(@"API calling completed - Failed...");
                if (completionBlock)
                {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (strTopic);
                    });
                }
            }
        }];
    }
    else{
        NSLog(@"Data available in DB...");
        
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus != NotReachable) {
            
            [self subscribeToTopicAndFetchMessages:strTopic withCompletionBlock:^(BOOL isSuccess) {
                
                if (completionBlock)
                {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (strTopic);
                    });
                }
                
            }];
            
        }else{
            
            if (completionBlock)
            {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (strTopic);
                });
            }
        }
        
        
    }
}


-(void)getMyTopicForName:(NSString*)strTopicName withComplitionBlock:(TopicForName)completionBlock{  // MIM
    
    
    [[DownloadManager shared]ApiGetTopicForName:strTopicName completionBlock:^(NSError *error, MyTopicsModel *modelmyTopics, NSString *errTitle, NSString *errMsg) {
        if (error) // failed
        {
            
            if (completionBlock)
            {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);});
            }
            
            
        }
        else // success
        {
            
            if(modelmyTopics.topics.count > 0){
                
                TopicsModel *topicsObject = [modelmyTopics.topics objectAtIndex:0];
                
                NSLog(@"MIM - ApiGetTopicForName - %@",topicsObject);
                
                [self subscibeAndUpdateDb:topicsObject];
                
                if (completionBlock)
                {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true,topicsObject);
                    });
                }
                
            }else{
                if (completionBlock)
                {
                    dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);
                    });
                }
            }
        }
    }];
}



-(void)subscibeAndUpdateDb:(TopicsModel*)topicsModel{
    
    if([topicsModel.type isEqualToString:@"master"]){
        
        [[NSUserDefaults standardUserDefaults] setObject:topicsModel.topic forKey:@"MY_MASTER_TOPIC"];//Your master
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self SttarterClassSubscribeTopic:topicsModel.topic];
        
        for(int j =0;j<topicsModel.interacted_with.count;j++){
            
            TopicsModel *interactedWith = [topicsModel.interacted_with objectAtIndex:j];
            interactedWith.topic_name = interactedWith.topic_name;
            interactedWith.userId = interactedWith.userId;
            
            [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:interactedWith];
            ///*** >>> UNCOMMENT THIS
            /// gets 20 messages for the newly added topics.
            [self ApiGetMessagesForTopic:interactedWith.userId]; /// all interacted / master
            
        }
    }
    else if([topicsModel.type isEqualToString:@"group"])
        
    {
        [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:topicsModel];
        [self ApiGetMessagesForTopic:topicsModel.topic]; /// all interacted / master
        [self SttarterClassSubscribeTopic:topicsModel.topic];
        
    }
}

-(void)initialSetup{
    
    NSLog(@"initilizer--initilizer");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [reachability startNotifier];
}



-(void)CleanCommunicator{
    
    NSLog(@"--- CleanCommunicator ---");
    isLoggedOut = TRUE;
    [self DisconnectCommunicator]; // makes a connection to MQTT
    
    //Clear databases
    
}


#pragma mark - ** Connectivity **

- (void)reachabilityDidChange:(NSNotification *)notification {
    NSLog(@"STTaterCommunicator--reachabilityDidChange");
    
    Reachability *reachability = (Reachability *)[notification object];
    if ([reachability isReachable]) { /// isReachableViaWiFi or ReachableViaWWAN
        
        NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"];
        if(user != nil){ /// to check
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"is_CommunicatorPermitted"] ) {
                [self reconnectToChat];
            }
        }
        self.internetIsReachable = true;
        /// Publish the queud data. Checks if there are any saved data and if it exixts , it will publish it.
        
    } else {
        self.internetIsReachable = false;
        NSLog(@"STTaterCommunicator--reachabilityDidChange--Failed");
    }
}

#pragma mark - APP DELEGATE METHODS



-(BOOL)checkConnectionStateAndReconnect{
    NSLog(@"checkConnectionStateAndReconnect");
    isMQTTSessionConnecting = true;
    BOOL connectionStatus = false;
    if(session!=nil){
        connectionStatus = ([session status] != MQTTSessionStatusConnected) ? [session connectAndWaitTimeout:30] : true;
    }
    else { // Do a new connection
        
        //** MQTT ** view did load
        transport = [[MQTTCFSocketTransport alloc] init];
        transport.host = [[Utils shared] getMQTTHostString];
        transport.port = [[Utils shared] getMQTTPort];
        
        session = [[MQTTSession alloc] init];
        session.transport = transport;
        session.delegate = self;
        session.keepAliveInterval = 30;
        
        NSString *strSavedClientId = [[NSUserDefaults standardUserDefaults] stringForKey:@"MQTT_CLIENT_ID"];
        
        if(strSavedClientId!= nil){
            session.clientId = strSavedClientId;
        }
        else{
            NSString *strClientId = [[Utils shared] getClientId];
            session.clientId = strClientId;
        }
        connectionStatus = ([session status] != MQTTSessionStatusConnected) ? [session connectAndWaitTimeout:30] : true;
    }
    isMQTTSessionConnecting = false;

    return connectionStatus;
}



-(void)didBecomeActiveNotification{
    /// when you reopen the app - called first
    
    NSLog(@"didBecomeActiveNotification called. MQTT Reconnected"); // remove from NPS and test here
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus != NotReachable) {
        NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"];
        if(user != nil){ /// to check
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"is_CommunicatorPermitted"] ) {
                [self reconnectToChat];
            }
        }
    }
}

-(void)reconnectToChat{
    isLoggedOut = FALSE;
    
    if (session != nil) {
        
        NSLog(@"___Session status %ld -- %d",(long)session.status,session.sessionPresent);
        
        
        if ([session status] != MQTTSessionStatusConnected) {
            [sttarterCommunicatorClass connectCommunicator]; // makes a connection to MQTT
        }else{
            [self.connectionDelegate connectionSuccess];
        }
        
        
    }else{
        [sttarterCommunicatorClass connectCommunicator]; // makes a connection to MQTT
    }
}
#pragma mark - ** MQTT,getMyTopics,Subscribe,getMessages **

-(void)subscribeInitialize{  // replace this with reconnectToChat.
    isLoggedOut = FALSE;
    [self connectCommunicator]; // makes a connection to MQTT
}


-(void)updateDbAndSubscribeToTopic:(MyTopicsModel*)modelMyTopics{
    
    NSLog(@"--- getmytopics  ---");
    NSLog(@"******A.3 MyTopics Api called (app/mqtt/mytopics) ***********");
    
    NSLog(@"***** getmyTopics Successs!!!!! with Model :%@ ",modelMyTopics);
    
    for(int i =0;i<modelMyTopics.topics.count;i++){
        
        _TopicsModel =[modelMyTopics.topics objectAtIndex:i]; //TopicsModel*
        
        // MQTT Subscribe to topic
        NSLog(@"_TopicsModel type %@",_TopicsModel.type);
        
        if([_TopicsModel.type isEqualToString:@"master"]){
            
            NSLog(@"A.3.1 If Type = MASTER");
            
            NSLog(@"A.3.1 Subscribe to My master Topic: %@",_TopicsModel.topic);
            
            [[NSUserDefaults standardUserDefaults] setObject:_TopicsModel.topic forKey:@"MY_MASTER_TOPIC"];//Your master
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // saves my master topic
            NSLog(@"##### MyTopics with My Master Topic: %@",_TopicsModel.topic);
            
            NSLog(@"A.3.1.1 Subscribe to My master Topic: %@",_TopicsModel.topic);
            
            [self SttarterClassSubscribeTopic:_TopicsModel.topic];
            
            for(int j =0;j<_TopicsModel.interacted_with.count;j++){
                
                TopicsModel *interactedWith = [_TopicsModel.interacted_with objectAtIndex:j];
                
                NSLog(@"A.3.1.2 Update/Insert data into TOPICS dB for all the interacted users");
                
                interactedWith.topic_name = interactedWith.topic_name;
                interactedWith.userId = interactedWith.userId;
                
                [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:interactedWith];
                
                NSLog(@"A.3.1.3 call getMessages API for all the interacted users (?)");
                NSLog(@"A.3.1.4 save all the messages in Messages DB(?)");
                
                NSLog(@"**** Call get Messages For User id: %@ ****", interactedWith.userId);
                
                ///*** >>> UNCOMMENT THIS
                /// gets 20 messages for the newly added topics.
                [self ApiGetMessagesForTopic:interactedWith.userId]; /// all interacted / master
                
            }
        }
        else if([_TopicsModel.type isEqualToString:@"group"])
            
        {
            NSLog(@"A.3.2 If Type = GROUP");
            
            NSLog(@"A.3.2.1 Update/Insert TOPICS dB with group topic.");
            
            [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:_TopicsModel];
            NSLog(@"##### MyTopics My Group Topics: %@",_TopicsModel.topic);
            
            NSLog(@"A.3.2.2 Subscribe to the group topic.");
            
            [self SttarterClassSubscribeTopic:_TopicsModel.topic];
            
            [self ApiGetMessagesForTopic:_TopicsModel.userId]; /// all interacted / master
        }
    }
    
    NSLog(@"******A.4 Get all the topics from the dB(interated and group) and call 'RefreshUI_Notification' Notifiction for the Observers. ***********");
    
    NSArray *arrTopicDb = [[DatabaseHandler sharedDatabaseHandler] getAllDbTopics];
    if(arrTopicDb.count >=1){
        [self callGetMessagesAPI:20];
    }
    
}


-(TopicModel*)getTopicModelFor:(TopicsModel*)TopicsInfo{
    
    
    TopicModel *topicModelToSend = [[TopicModel alloc]init];
    topicModelToSend.topic_id = TopicsInfo.topic;
    topicModelToSend.topic_name = TopicsInfo.topic_name;
    topicModelToSend.topic_userId = TopicsInfo.userId;
    topicModelToSend.topic_type = TopicsInfo.type;
    topicModelToSend.topic_updated_unix_timestamp = TopicsInfo.messageTimeStamp;
    topicModelToSend.topic_NotificationCount = @"0";
    topicModelToSend.topic_LastReceivedMessage = @"";
    topicModelToSend.topic_group_members = TopicsInfo.group_members;///****Meta
    topicModelToSend.topic_meta = TopicsInfo.meta;
    
    return topicModelToSend;
    
}


//-(void)subscribeInitialize_completionBlock{ // NEW TRy
//
//    if (completionBlock)
//    {
//        dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);});
//    }
//
//}

-(void)Trial_withCompletionBlock:(RefreshTopics)completionBlock{ // NEW TRy
    
    self.dctMsgStatus = [[NSMutableDictionary alloc] init];
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    NSString *strXUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];
    
    NSLog(@"***** getMyTopics STARTTER_X_APP_TOKEN :%@ ****",strXAppToken);
    
    [[DownloadManager shared]ApiMyTopics:strXUserToken appToken:strXAppToken completionBlock:^(NSError *error,MyTopicsModel *modelMyTopics,NSString *errTitle, NSString *errMsg)
     {
         if (error) // failed
         {
             
             modelMyTopics                                                                                                                                                                                                              = nil;
             NSLog(@"***** getmyTopics Failed!!!!! with Error Msg :%@  ****",errMsg);
             NSLog(@"***** getmyTopics Failed!!!!! with Error Title :%@  ****",errTitle);
             
             NSMutableArray *arrTopicDb = [self getAllMyTopics];
             
             if(arrTopicDb.count >=1){
                 
                 NSLog(@"---@@@@ getAllMyTopics FAILED so just returned the existing db Data (2)---");
                 
                 
                 if (completionBlock)
                 {
                     dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true,arrTopicDb);});
                 }
                 
                 
             }
             else{
                 NSLog(@"---@@@@ getAllMyTopics FAILED and no db Data as well---");
                 
                 if (completionBlock)
                 {
                     dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);});
                 }
                 
             }
             
         }
         else // success
         {
             
             NSMutableArray *arrGroupsDb = [[NSMutableArray alloc]init];
             
             
             for(int i =0;i<modelMyTopics.topics.count;i++){
                 
                 _TopicsModel =[modelMyTopics.topics objectAtIndex:i]; //TopicsModel*
                 
                 if([_TopicsModel.type isEqualToString:@"master"]){
                     
                     NSLog(@"A.3.1 If Type = MASTER");
                     
                     NSLog(@"A.3.1 Subscribe to My master Topic: %@",_TopicsModel.topic);
                     
                     [[NSUserDefaults standardUserDefaults] setObject:_TopicsModel.topic forKey:@"MY_MASTER_TOPIC"];//Your master
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                     [self SttarterClassSubscribeTopic:_TopicsModel.topic];
                     
                     for(int j =0;j<_TopicsModel.interacted_with.count;j++){
                         
                         TopicsModel *interactedWith = [_TopicsModel.interacted_with objectAtIndex:j];
                         
                         TopicModel *topicModelToSend = [[TopicModel alloc]init];
                         topicModelToSend = [self getTopicModelFor:interactedWith];
                         [arrGroupsDb addObject:topicModelToSend];
                         
                     }
                 }
                 else if([_TopicsModel.type isEqualToString:@"group"])
                     
                 {
                     
                     TopicModel *topicModelToSend = [[TopicModel alloc]init];
                     topicModelToSend = [self getTopicModelFor:_TopicsModel];
                     
                     [arrGroupsDb addObject:topicModelToSend];
                     [self SttarterClassSubscribeTopic:_TopicsModel.topic];
                     
                 }
             }
             
             
             if(arrGroupsDb.count >=1){
                 
                 NSLog(@"---@@@@ getAllMyTopics SUCCESS so send back response as it is : %@---",arrGroupsDb);
                 
                 if (completionBlock)
                 {
                     NSLog(@"---@@@@ getAllMyTopics sent response back (1) ");
                     
                     
                     dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true,arrGroupsDb);});
                 }
                 
                 
                 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
                 dispatch_async(queue, ^{
                     
                     for(int i=0 ; i<=arrGroupsDb.count;i++){
                         
                         TopicModel *topicsObj = [arrGroupsDb objectAtIndex:i];
                         TopicsModel *topicsModel = [[TopicsModel alloc]init];
                         topicsModel.topic = topicsObj.topic_id;
                         topicsModel.topic_name = topicsObj.topic_name;
                         topicsModel.userId = topicsObj.topic_userId ;
                         topicsModel.type = topicsObj.topic_type;
                         topicsModel.messageTimeStamp = topicsObj.topic_updated_unix_timestamp;
                         topicsModel.group_members = topicsObj.topic_group_members;// BASVA DOUBT
                         topicsModel.meta = topicsObj.topic_meta;
                         
                         NSLog(@"topicsObj.topic_group_members : %@ ",topicsObj.topic_group_members);
                         NSLog(@"topicsModel.group_members : %@ ",topicsModel.group_members);
                         [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:topicsModel];
                         
                         
                     }
                     
                     NSLog(@"---@@@@ getAllMyTopics saved response in dB (2) ");
                     
                 });
                 
                 
                 
                 
             }
             else{
                 NSLog(@"---@@@@ getAllMyTopics SUCCESS BUT no data in dB ---");
                 
                 
                 if (completionBlock)
                 {
                     dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);});
                 }
                 
             }
             
             
         }
     }];
}

-(void)GetAllRecentTopics_withCompletionBlock:(RefreshTopics)completionBlock{
    
    self.dctMsgStatus = [[NSMutableDictionary alloc] init];
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    NSString *strXUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];
    
    NSLog(@"***** getMyTopics STARTTER_X_APP_TOKEN :%@ ****",strXAppToken);
    
    BOOL connectionStatus = [self checkConnectionStateAndReconnect];
    NSLog(@"connectionStatus MQTT : %d on GetAllRecentTopics_withCompletionBlock ",connectionStatus);
    
    if (connectionStatus){
        [[DownloadManager shared]ApiMyTopics:strXUserToken appToken:strXAppToken completionBlock:^(NSError *error,MyTopicsModel *modelMyTopics,NSString *errTitle, NSString *errMsg)
         {
             if (error) // failed
             {
                 
                 modelMyTopics = nil;
                 NSLog(@"***** getmyTopics Failed!!!!! with Error Msg :%@  ****",errMsg);
                 NSLog(@"***** getmyTopics Failed!!!!! with Error Title :%@  ****",errTitle);
                 
                 NSMutableArray *arrTopicDb = [self getAllMyTopics];
                 
                 if(arrTopicDb.count >=1){
                     
                     NSLog(@"---@@@@ getAllMyTopics FAILED so just returned the existing db Data (2)---");
                     
                     
                     if (completionBlock)
                     {
                         dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true,arrTopicDb);});
                     }
                     
                     
                 }
                 else{
                     NSLog(@"---@@@@ getAllMyTopics FAILED and no db Data as well---");
                     
                     if (completionBlock)
                     {
                         dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);});
                     }
                     
                 }
                 
             }
             else // success
             {
                 
                 NSLog(@"--- getmytopics  ---");
                 NSLog(@"******A.3 MyTopics Api called (app/mqtt/mytopics) ***********");
                 
                 NSLog(@"***** getmyTopics Successs!!!!! with Model :%@ ",modelMyTopics);
               //#1233 - For specific user, we are not recieving any acknowledgement from Sttarter whether authentication is completed or no
               
              if (modelMyTopics.topics.count == 0) {
                 if (completionBlock)
                 {
                   dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);
                     
                   });
                 }
              }else{
                
                for(int i =0;i<modelMyTopics.topics.count;i++){
                  
                  _TopicsModel =[modelMyTopics.topics objectAtIndex:i]; //TopicsModel*
                  
                  // MQTT Subscribe to topic
                  
                  [self subscibeAndUpdateDb:_TopicsModel];
                  
                  NSMutableArray *arrTopicDb = [self getAllMyTopics];
                  
                  if(arrTopicDb.count >=1){
                    
                    NSLog(@"---@@@@ getAllMyTopics SUCCESS and returned the new data well---");
                    
                    if (completionBlock)
                    {
                      dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true,arrTopicDb);});
                    }
                    
                    
                  }
                  else{
                    NSLog(@"---@@@@ getAllMyTopics SUCCESS BUT no data in dB ---");
                    
                    
                    if (completionBlock)
                    {
                      dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);});
                    }
                    
                  }
                }
              }
             
             }
             
         }];
    }else{
        [[DownloadManager shared]ApiMyTopics:strXUserToken appToken:strXAppToken completionBlock:^(NSError *error,MyTopicsModel *modelMyTopics,NSString *errTitle, NSString *errMsg)
         {
             if (error) // failed
             {
                 
                 modelMyTopics = nil;
                 NSLog(@"***** getmyTopics Failed!!!!! with Error Msg :%@  ****",errMsg);
                 NSLog(@"***** getmyTopics Failed!!!!! with Error Title :%@  ****",errTitle);
                 
                 NSMutableArray *arrTopicDb = [self getAllMyTopics];
                 
                 if(arrTopicDb.count >=1){
                     
                     NSLog(@"---@@@@ getAllMyTopics FAILED so just returned the existing db Data (2)---");
                     
                     
                     if (completionBlock)
                     {
                         dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true,arrTopicDb);});
                     }
                     
                     
                 }
                 else{
                     NSLog(@"---@@@@ getAllMyTopics FAILED and no db Data as well---");
                     
                     if (completionBlock)
                     {
                         dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);});
                     }
                     
                 }
                 
             }
             else // success
             {
                 
                 NSLog(@"--- getmytopics  ---");
                 NSLog(@"******A.3 MyTopics Api called (app/mqtt/mytopics) ***********");
                 
                 NSLog(@"***** getmyTopics Successs!!!!! with Model :%@ ",modelMyTopics);
               //#1233 - For specific user, we are not recieving any acknowledgement from Sttarter whether authentication is completed or no
               if (modelMyTopics.topics.count == 0){
                 if (completionBlock)
                 {
                   dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);
                   });
                 }
               }else{
                 for(int i =0;i<modelMyTopics.topics.count;i++){
                   
                   _TopicsModel =[modelMyTopics.topics objectAtIndex:i]; //TopicsModel*
                   
                   // MQTT Subscribe to topic
                   
                   if([_TopicsModel.type isEqualToString:@"master"]){
                     
                     NSLog(@"A.3.1 If Type = MASTER");
                     
                     NSLog(@"A.3.1 Subscribe to My master Topic: %@",_TopicsModel.topic);
                     
                     [[NSUserDefaults standardUserDefaults] setObject:_TopicsModel.topic forKey:@"MY_MASTER_TOPIC"];//Your master
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                     // saves my master topic
                     NSLog(@"##### MyTopics with My Master Topic: %@",_TopicsModel.topic);
                     
                     NSLog(@"A.3.1.1 Subscribe to My master Topic: %@",_TopicsModel.topic);
                     
                     [self SttarterClassSubscribeTopic:_TopicsModel.topic];
                     
                     for(int j =0;j<_TopicsModel.interacted_with.count;j++){
                       
                       TopicsModel *interactedWith = [_TopicsModel.interacted_with objectAtIndex:j];
                       
                       NSLog(@"A.3.1.2 Update/Insert data into TOPICS dB for all the interacted users");
                       
                       interactedWith.topic_name = interactedWith.topic_name;
                       interactedWith.userId = interactedWith.userId;
                       
                       [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:interactedWith];
                       
                       NSLog(@"A.3.1.3 call getMessages API for all the interacted users (?)");
                       NSLog(@"A.3.1.4 save all the messages in Messages DB(?)");
                       NSLog(@"**** Call get Messages For User id: %@ ****", interactedWith.userId);
                       
                       /// gets 20 messages for the newly added topics.
                       [self ApiGetMessagesForTopic:interactedWith.userId]; /// all interacted / master
                       
                       NSLog(@"#### MyGroups Interacted Topics: %@ ",interactedWith.topic);
                     }
                     
                     
                   }
                   else if([_TopicsModel.type isEqualToString:@"group"])
                     
                   {
                     NSLog(@"A.3.2 If Type = GROUP");
                     
                     NSLog(@"A.3.2.1 Update/Insert TOPICS dB with group topic.");
                     
                     [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:_TopicsModel];
                     NSLog(@"##### MyTopics My Group Topics: %@",_TopicsModel.topic);
                     
                     NSLog(@"A.3.2.2 Subscribe to the group topic.");
                     [self SttarterClassSubscribeTopic:_TopicsModel.topic];
                     
                   }
                 }
                 
                 
                 //     NSArray *arrTopicDb = [[DatabaseHandler sharedDatabaseHandler] getAllDbTopics];
                 NSMutableArray *arrTopicDb = [self getAllMyTopics];
                 
                 if(arrTopicDb.count >=1){
                     
                     NSLog(@"---@@@@ getAllMyTopics SUCCESS and returned the new data well---");
                     
                     if (completionBlock)
                     {
                         dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true,arrTopicDb);});
                     }
                     
                     
                 }
                 else{
                     NSLog(@"---@@@@ getAllMyTopics SUCCESS BUT no data in dB ---");
                     
                     
                     if (completionBlock)
                     {
                         dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,nil);});
                     }
                     
                 }
             }
         }
         }];
    }
    
}








-(void)getmytopics{
    
    self.dctMsgStatus = [[NSMutableDictionary alloc] init];
    
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];//appToken
    NSString *strXUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];//ApiMyTopics
    
    NSLog(@"***** getMyTopics STARTTER_X_APP_TOKEN :%@ ****",strXAppToken);
    
    // GetAllRecentTopics_withCompletionBlock
    [[DownloadManager shared]ApiMyTopics:strXUserToken appToken:strXAppToken completionBlock:^(NSError *error,MyTopicsModel *modelMyTopics,NSString *errTitle, NSString *errMsg)
     {
         if (error) // failed
         {
             NSLog(@"--- getAllMyTopics (2)---");
             modelMyTopics = nil;
             NSLog(@"***** getmyTopics Failed!!!!! with Error Msg :%@  ****",errMsg);
             NSLog(@"***** getmyTopics Failed!!!!! with Error Title :%@  ****",errTitle);
         }
         else // success
         {
             NSLog(@"--- connectCommunicator STOP - MyTopics success---");
             [self updateDbAndSubscribeToTopic:modelMyTopics];
         }
     }];
}


#pragma mark - ** Get Messages "API" **


-(void)synchronizeAllMessages{
  NSLog(@"synchronizeAllMessages : gets messages from dB  >>>");
  [self callGetMessagesAPI:20];
}


-(void)synchronizeAllMessages:(int)maxNumberOfMessages{
  NSLog(@"synchronizeAllMessages : gets messages from dB  >>>");
  [self callGetMessagesAPI:maxNumberOfMessages];
}

//New method to retrieve paginated messages
-(void)getPaginatedMessages:(Topics *)topic maxNumberOfMessages:(int)maxNumberOfMessages withOffset:(int)offset{
  
  [self ApiGetMessagesForTopic:topic.topic_id maxNumberOfMessages:maxNumberOfMessages withOffset:offset];
}

-(void)callGetMessagesAPI:(int)maxNumberOfMessages{
    
    /// Get all topics from db and call get messages API for all the topics.
    
    NSArray *arrTopicDb = [[DatabaseHandler sharedDatabaseHandler] getAllDbTopics];
    NSLog(@"callGetMessagesAPI called with count >>>");
    
    for(int i=0; i<arrTopicDb.count;i++)
    {
        Topics *topicsObj = [arrTopicDb objectAtIndex:i];
        [self ApiGetMessagesForTopic:topicsObj.topic_id maxNumberOfMessages:maxNumberOfMessages withOffset:0];
    }
    
}

-(void)ApiGetMessagesForTopic:(NSString*)strTopic{
  
  [self ApiGetMessagesForTopic:strTopic maxNumberOfMessages:20 withOffset:0];
}


-(void)ApiGetMessagesForTopic:(NSString*)strTopic maxNumberOfMessages:(int)maxNumberOfMessages withOffset:(int)offset
{
    NSLog(@"--- getMessagesForTopic ---(Api)");
    
    [[DownloadManager shared]getAllMessagesForTopic:strTopic maxNumberOfMessages:maxNumberOfMessages withOffset:offset completionBlock:^(NSError *error, GetMessagesModel *model) //GetMessagesModel
     {
         
         if (error) {
             NSLog(@"*** Topic:%@ **get messages failed:%@",strTopic,error.localizedDescription);
         }
         else{
             
             NSLog(@"*** getmessages Success!!!");
             
             for(int i=0;i<model.messages.count;i++){
                 
                 
                 TopicMessage *topicMsgModel = [model.messages objectAtIndex:i];//TopicMessage
                 
                 if(topicMsgModel != nil){
                     
                     
                     NSString *strMyMaster = [[NSUserDefaults standardUserDefaults] stringForKey:@"MY_MASTER_TOPIC"];
                     
                     NSLog(@"MY MASTER TOPIC:%@", strMyMaster);
                     NSLog(@"getMessages will save in dB for topic : %@ with is_sender : %@",topicMsgModel.topic,topicMsgModel.is_sender);
                     
                     /// !@#$%^&
                     
                     if([topicMsgModel.message.messageType isEqualToString:@"message"]){ // avoids system messages
                         
                         
                         NSDateFormatter* dateFormatter1 = [[NSDateFormatter alloc] init];
                         [dateFormatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                         [dateFormatter1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
                         
                         NSDate* utcTime = [dateFormatter1 dateFromString:topicMsgModel.created_at];
                         NSLog(@"UTC time: %@", utcTime);
                         [dateFormatter1 setTimeZone:[NSTimeZone systemTimeZone]];
                         [dateFormatter1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
                         
                         NSString* localTime = [dateFormatter1 stringFromDate:utcTime];
                         NSLog(@"localTime:%@", localTime);
                         /// To Unix
                         NSDate* localDate1 = [dateFormatter1 dateFromString:localTime];
                         NSTimeInterval ti2 = [localDate1 timeIntervalSince1970];
                         NSString *str= [NSString stringWithFormat:@"%f",ti2];
                         
                         
                         
                         if([topicMsgModel.topic containsString:@"-group-"]){
                             
                             NSString *myExternalID = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"];
                             
                             if([topicMsgModel.message.messageFrom isEqualToString:myExternalID]){
                                 // You are the sender
                                 topicMsgModel.is_sender = @"TRUE"; /// You are th sender
                                 topicMsgModel.message.messageReadByReceiverTimeStamp = str;
                             }
                             else{
                                 
                                 topicMsgModel.is_sender = @"FALSE"; /// they are the sender
                             }
                         }
                         
                         else{
                             
                             if([topicMsgModel.topic isEqualToString:strMyMaster]){ // I am the sender
                                 
                                 
                                 NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
                                 topicMsgModel.topic = [NSString stringWithFormat:@"%@-master-%@",strAppKey,topicMsgModel.message.messageFrom];
                                 
                                 //                                 topic = -master-my_iPhone2
                                 //                                 Ext id = my_iPhone2
                                 //                                 "messageText": "uuuuuuuuuuuuuuu",
                                 //                                 "messageFrom": "my_iPhone
                                 //                                 str_IsRead : from Res
                                 //
                                 
                                 topicMsgModel.is_sender = @"FALSE";
                                 if(topicMsgModel.is_read){
                                     topicMsgModel.str_IsRead = @"TRUE";
                                 }
                                 else{
                                     topicMsgModel.str_IsRead = @"FALSE";
                                 }
                                 
                                 
                             }
                             else{ // I am the sender
                                 
                                 topicMsgModel.is_sender = @"TRUE"; /// You are th sender
                                 topicMsgModel.message.messageReadByReceiverTimeStamp = str;
                                 
                                 topicMsgModel.str_IsRead = @"TRUE";// Cos I am the sender. This is used for unread count so
                                 
                                 
                             }
                         }  /// !@#$%^&
                         topicMsgModel.message.messageTimeStamp = str;
                         topicMsgModel.is_sent =str;
                         
                         
                         //TO DO - remove str_IsRead and make is_read as bool everywhere
                         
                         // is_Read needs to be changed to an array according to the new changes in the API. Delivered, Read, sent status time details needs to be implimented.
                         
                         [[DatabaseHandler sharedDatabaseHandler] updateMessagesDatabase:topicMsgModel];
                         NSLog(@"***** Update dB with Topicmessage model('getMessagesForTopic' for Group) : %@**",topicMsgModel);
                         
                     }
                     
                 }
                 
                 else{
                     
                     NSLog(@"*** GetMessages is Null for topic:%@ *** with TopicMessage dct :%@ ",strTopic,topicMsgModel);
                 }
             }
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshUI_Notification" object:self userInfo:nil];
             
         }
     }];
}




//-(int)getCountForTopic:(NSString*)strTopicId{
//
//    NSLog(@"--- getCountForTopic --- (From dB)");
//
//    if(![strTopicId containsString:@"-master-"]&&![strTopicId containsString:@"group"]){
//        // only user id was sent then convert to topic and get data.
//        NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
//        strTopicId = [NSString stringWithFormat:@"%@-master-%@",strAppKey,strTopicId];
//    }
//
//    NSLog(@"*** Get all messages for Topic : %@***",strTopicId);
//
//
//    NSArray *arrAllMessagesDb = [[DatabaseHandler sharedDatabaseHandler] getAllMessages];
//
//    NSMutableArray *arrMessagesForATopic = [[NSMutableArray alloc]init];
//
//    for(int i=0; i<arrAllMessagesDb.count;i++){
//
//        TopicMessageEntity *MsgObj = [arrAllMessagesDb objectAtIndex:i];
//
//        if([MsgObj.topic isEqualToString:strTopicId]){
//
//            [arrMessagesForATopic addObject:MsgObj];
//        }
//    }
//
//    int count=0;
//
//    for(int i=0;i<arrMessagesForATopic.count ;i++){
//
//        TopicMessageEntity *msg = [arrMessagesForATopic objectAtIndex:i];
//       
//        if([msg.is_Read isEqualToString:@"FALSE"])
//            count++;
//
//    }
//
//    if(count <=0){
//        count = 0;
//    }
//
//    return count;
//}


-(int)getCountAccrossAllTopics{
    
    
    NSLog(@"--- getCountAccrossAllTopics --- (From dB)");
    
    NSMutableArray *arrGetAllTopics = [self getAllMyTopics];
    
    
    int totalCount=0;
    for(int i=0; i<arrGetAllTopics.count;i++)
    {
        Topics *topicsObj = [arrGetAllTopics objectAtIndex:i];
        NSLog(@"Total count : %d + %d",totalCount,[self sttGetCountForTopic:topicsObj.topic_id]);
        totalCount = totalCount + [self sttGetCountForTopic:topicsObj.topic_id];
    }
    
    NSLog(@"Final Total count :%d ",totalCount);
    return totalCount;
}


//
//-(TopicMessageEntity*)getLatestMessageObject:(NSString*)strTopicId{
//
//    NSLog(@"---New DB getLatestMessageObject --- (From dB)");
//
//
//    if(![strTopicId containsString:@"-master-"]&&![strTopicId containsString:@"-group-"]){
//        NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
//        strTopicId = [NSString stringWithFormat:@"%@-master-%@",strAppKey,strTopicId];
//    }
//
//    NSArray *arrAllMessagesDb = [[DatabaseHandler sharedDatabaseHandler] getAllMessages];
//
//    NSMutableArray *arrMessagesForATopic = [[NSMutableArray alloc]init];
//    NSLog(@"*** Get latest message Obj for Topic : %@***",strTopicId);
//
//    for(int i=0; i<arrAllMessagesDb.count;i++){
//
//        TopicMessageEntity *MsgObj = [arrAllMessagesDb objectAtIndex:i];
//
//        if([MsgObj.topic isEqualToString:strTopicId]){
//
//            [arrMessagesForATopic addObject:MsgObj];
//        }
//    }
//
//    return  [arrAllMessagesDb lastObject];
//
//
//}


#pragma mark - ** Update Read Messages (DB) **

-(void)updateMessages:(NSString*)strTopic{ /// gets callled when user enters the chat screen to read the messages.
    
    NSLog(@"--- updateMessages --- (From dB)");
    
    if(![strTopic containsString:@"-master-"]&&![strTopic containsString:@"group"]){
        // only user id was sent then convert to topic and get data.
        NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
        strTopic = [NSString stringWithFormat:@"%@-master-%@",strAppKey,strTopic];
    }
    
    NSLog(@"1.2.2 updat read_By_Receiver status in dB");
    // ION async
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DatabaseHandler sharedDatabaseHandler]updateIsReadInMessagesDb:strTopic isRead:@"TRUE"];
    });
    
    if(session == nil){
        NSLog(@"^^^^^^^^^^^^ MQTT session was: nil. Reconnected^^^^^^^^^^^^^");
        [self connectCommunicator];
    }
}

// ION
#pragma mark - ** Get Latest Msg Object **

-(TopicMessage*)sttGetLatestMessageForTopic:(NSString*)strTopicId{
    
    NSMutableArray *arrmsg = [[NSMutableArray alloc]init];
    if(arrmsg != nil){
        [arrmsg removeAllObjects];
        
        /// group name is sent test group
        arrmsg = [self allMessageForTopicFromDb:strTopicId];
    }
    else{
        arrmsg = [self allMessageForTopicFromDb:strTopicId];
    }
    
    return  [arrmsg lastObject];
    
}


// ION
#pragma mark - ** Get Unread Count For Topic **

-(int)sttGetCountForTopic:(NSString*)topic{ /// Can be moved to SDK as it is
    
    int count=0;
    // getAllMessageForTopic goes and marks everything as read... !!
    
    NSMutableArray *arrmsg = [[NSMutableArray alloc]init];
    if(arrmsg != nil){
        [arrmsg removeAllObjects];
        arrmsg = [self allMessageForTopicFromDb:topic];
    }
    else{
        arrmsg = [self allMessageForTopicFromDb:topic];
    }
    
    for(int i=0;i<arrmsg.count ;i++){
        
        TopicMessage *msg = [arrmsg objectAtIndex:i];
        
        if([msg.is_sender isEqualToString:@"FALSE"]){
            
            if([msg.str_IsRead isEqualToString:@"FALSE"])
                count++;
        }
        
    }
    
    if(count <=0){
        count = 0;
    }
    
    return count;
}


// ION NEW
-(NSMutableArray*)allMessageForTopicFromDb:(NSString*)strTopicId{ /// send the array of messages to the user for a topic
    
    NSLog(@"--- allMessageForTopicFromDb ---");
    
    if(![strTopicId containsString:@"-master-"]&&![strTopicId containsString:@"-group-"]){
        NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
        strTopicId = [NSString stringWithFormat:@"%@-master-%@",strAppKey,strTopicId];
    }
    
    NSLog(@"*** allMessageForTopicFromDb - dB only : %@***",strTopicId);
    NSArray *arrAllMessagesDb = [[DatabaseHandler sharedDatabaseHandler] getAllMessages];
    NSMutableArray *arrMessagesForATopic = [[NSMutableArray alloc]init];
    
    for(int i=0; i<arrAllMessagesDb.count;i++){
        
        TopicMessageEntity *topicMessageEntity = (TopicMessageEntity *)[arrAllMessagesDb objectAtIndex:i];
        
        if([topicMessageEntity.topic isEqualToString:strTopicId]){
            
            TopicMessage *topicmessageModel = [[TopicMessage alloc]init];//
            topicmessageModel.topic = topicMessageEntity.topic;
            topicmessageModel.str_IsRead = topicMessageEntity.is_Read;
            topicmessageModel.is_sender = topicMessageEntity.is_sender;
            topicmessageModel.is_sent = topicMessageEntity.is_sent;
            
            TopicMessageDetail *detailModel = [[TopicMessageDetail alloc]init];
            TopicMessageDetailEntity *details = topicMessageEntity.topicMessageDetail;
            
            detailModel.messageFrom = [details messageFrom];
            detailModel.messageHash = details.messageHash;
            detailModel.messageText = details.messageText;
            detailModel.messageType = details.messageFileType;
            detailModel.messageFileURL = details.messageFileURL;
            detailModel.messageTimeStamp = details.messageTimeStamp;
            detailModel.messageReadByReceiverTimeStamp = details.isReadBytheReceiver;
            detailModel.messageSubType = details.messageSubType;
            detailModel.messageDeliveredTimeStamp = details.isDelivered ;
            if(details.messageTimeStamp != nil){
                topicmessageModel.message_sort = details.messageTimeStamp;
            }
            
            
            topicmessageModel.message = detailModel;
            
            /// instead of sending dB model , send the topic Message model with status data as below
            /// Is this needed or can I directly acces from messageDetail dB
            NSLog(@"**** allMessageForTopicFromDb one by one Message Object for topic : %@ are below : %@",strTopicId,topicmessageModel);
            NSLog(@"**** allMessageForTopicFromDb details.messageTimeStamp : %@",topicmessageModel.message_sort);
            
            [arrMessagesForATopic addObject:topicmessageModel];
            
        }
    }
    NSLog(@"**** allMessageForTopicFromDb = all Message Objects for topic : %@ are below : %@",strTopicId,arrMessagesForATopic);
    
    return arrMessagesForATopic;
    
}


-(NSMutableArray*)getAllMessageForTopic:(NSString*)strTopicId{ /// send the array of messages to the user for a topic
    
    NSLog(@"--- getAllMessageForTopic ---");
    
    if(![strTopicId containsString:@"-master-"]&&![strTopicId containsString:@"-group-"]){
        /// only user id was sent then convert to topic and get data.
        NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
        strTopicId = [NSString stringWithFormat:@"%@-master-%@",strAppKey,strTopicId];
    }
    
    // 1) call markasread API and update the server everytime we retrive the message from the chat screen.
    // this is called everytime we enter chat screen on the api side and also on receival of every message when in chat screen.
    // updateMessages remove it from the app side.
    
    //check and update in background thread.
    
    [self updateMessages:strTopicId];
    //to show read ticks for other users.
    //Will notify them that we have read it.
    // call only once on entering the chat screen and on each new message.
    
    
    
    NSLog(@"*** Get all messages for Topic from dB : %@***",strTopicId);
    NSArray *arrAllMessagesDb = [[DatabaseHandler sharedDatabaseHandler] getAllMessages];
    NSMutableArray *arrMessagesForATopic = [[NSMutableArray alloc]init];
    
    for(int i=0; i<arrAllMessagesDb.count;i++){
        
        TopicMessageEntity *topicMessageEntity = (TopicMessageEntity *)[arrAllMessagesDb objectAtIndex:i];
        
        if([topicMessageEntity.topic isEqualToString:strTopicId]){
            
            TopicMessage *topicmessageModel = [[TopicMessage alloc]init];//
            topicmessageModel.topic = topicMessageEntity.topic;
            topicmessageModel.str_IsRead = topicMessageEntity.is_Read;
            topicmessageModel.is_sender = topicMessageEntity.is_sender;
            topicmessageModel.is_sent = topicMessageEntity.is_sent;
            
            TopicMessageDetail *detailModel = [[TopicMessageDetail alloc]init];
            TopicMessageDetailEntity *details = topicMessageEntity.topicMessageDetail;
            
            NSLog(@"*** TopicMessageDetailEntity in getAllMessage: %@***",details);
            
            
            //          detailModel.messageType = [details messageFileType];
            detailModel.messageFrom = [details messageFrom];
            detailModel.messageHash = details.messageHash;
            detailModel.messageText = details.messageText;
            detailModel.messageType = details.messageFileType;
            detailModel.messageFileURL = details.messageFileURL;
            detailModel.messageTimeStamp = details.messageTimeStamp;
            detailModel.messageReadByReceiverTimeStamp = details.isReadBytheReceiver;
            detailModel.messageSubType = details.messageSubType;
            detailModel.messageDeliveredTimeStamp = details.isDelivered ;
            if(details.messageTimeStamp != nil){
                topicmessageModel.message_sort = details.messageTimeStamp;
            }
            
            topicmessageModel.message = detailModel;
            
            /// instead of sending dB model , send the topic Message model with status data as below
            /// Is this needed or can I directly acces from messageDetail dB
            NSLog(@"**** one by one Message Object for topic : %@ are below : %@",strTopicId,topicmessageModel);
            NSLog(@"**** details.messageTimeStamp : %@",topicmessageModel.message_sort);
            
            [arrMessagesForATopic addObject:topicmessageModel];
            
        }
    }
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"message_timeStamp" ascending:TRUE];
    
    NSLog(@"**** all Message Objects for topic : %@ are below : %@",strTopicId,arrMessagesForATopic);
    
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"message_sort" ascending:TRUE];
    //
    //    NSLog(@"****** Sort key : %@",sortDescriptor);
    //
    //    [arrMessagesForATopic sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return arrMessagesForATopic;
    
}

#pragma mark - ** GROUP API - ADD **


/// NEW **** !@#$%^
-(void)addMultipleMemebersToGroupWithTopic:(NSString*)strTopic withMember:(NSMutableArray*)arrMembers completionBlock:(addMembersToGroupBlock)completionBlock{
    
    //// NEW !@#$%&
    
    [[ DownloadManager shared]addManyMembersToGroup:arrMembers forGroupTopic:strTopic completionBlock:^(NSError *error, NSDictionary *dictionary) {
        
        if (error)
        {
            NSString* errTitle = [dictionary objectForKey:@"title"];
            
            if(errTitle == nil)
            {
                errTitle = @"Members could not be added to the group. Kindly check if all the members are registered Sttarter User.";
            }
            if (completionBlock)
            {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,errTitle);});
            }
            
        }
        else {
            
            NSString* Title = [dictionary objectForKey:@"title"];
            if (completionBlock)
            {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true,Title);});
            }
            
            NSLog(@" ** Members added SUCESSSFULLY **");
            [self getmytopics];
        }
    }];
    
}


/// Adds single member to group
-(void)addAMemeberToGroupWithTopic:(NSString*)strTopic withMember:(NSString*)member completionBlock:(addAMemberToGroupBlock)completionBlock{
    
    [[DownloadManager shared]addAMemberToGroup:member forGroupTopic:strTopic completionBlock:^(NSError *error, NSDictionary *dictionary) {
        
        if (error)
        {
            NSString* errTitle = [dictionary objectForKey:@"title"];
            
            if(errTitle == nil)
            {
                errTitle = @"Member could not be added to the group.";
            }
            if (completionBlock)
            {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,errTitle);});
            }
            
        }
        else {
            
            NSString* Title = [dictionary objectForKey:@"title"];
            if (completionBlock)
            {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true,Title);});
            }
            
            NSLog(@" ** SUCESSS **");
            //[self getmytopics];
        }
        
    }];
    //[[DownloadManager shared]addameme]
    
    //    [[DownloadManager shared]addManyMembersToGroup:member forGroupTopic:strTopic completionBlock:^(NSError *error, NSDictionary *dictionary) {
    //
    //
    //    }];
    
    
    
}


-(void)createNewGroup:(NSString*)strGroupName Meta:(NSString*)strMeta completionBlock:(createGroupBlock)completionBlock{
    
    NSLog(@"Add new group details sent by the user :");
    NSLog(@"Group Name:%@",strGroupName);
    NSLog(@"Meta :%@",strMeta);
    
    [[DownloadManager shared]createNewGroupApi:strGroupName withMeta:strMeta completionBlock:^(NSError *error,NSDictionary *dctResposnse)
     {
         if (error)
         {
             
             if (completionBlock)
             {
                 dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false,@"");});
             }
             
         }
         else {
             
             NSDictionary *dctTopic= [dctResposnse objectForKey:@"topic"];
             NSString *strGroupTopic = [dctTopic objectForKey:@"topic"];
             //Subscribe topic and insert into Database
             NSString *CurrentUnixTimeStamp = [[Utils shared] GetCurrentEpochTime];
             TopicsModel *topicModel = [[TopicsModel alloc]init];
             topicModel.topic = strGroupTopic;
             topicModel.type =@"group";
             topicModel.messageTimeStamp = CurrentUnixTimeStamp;
             
             NSLog(@" ** SUCESSS **");
             [self subscribeToTopicAndFetchMessages:strGroupTopic withCompletionBlock:^(BOOL isSuccess) {
                 [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:topicModel];
                 
                 if (completionBlock)
                 {
                     dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true,strGroupTopic);});
                 }
             }];
         }
     }];
}






#pragma mark - ** Get All Topics And Messages (DB) **


-(TopicModel*)getTopicDetailsForASingleTopic:(NSString*)strTopic{ // old **
    
    
    Topics *TopicDetails =  [[DatabaseHandler sharedDatabaseHandler] getTopicDetailsForTopic:strTopic];
    
    
    TopicModel *topicModelToSend = [[TopicModel alloc]init];
    topicModelToSend.topic_id = TopicDetails.topic_id;
    topicModelToSend.topic_name = TopicDetails.topic_name;
    topicModelToSend.topic_userId = TopicDetails.topic_userId;
    topicModelToSend.topic_name = TopicDetails.topic_name;
    topicModelToSend.topic_type = TopicDetails.topic_type;
    topicModelToSend.topic_updated_unix_timestamp = TopicDetails.topic_updated_unix_timestamp;
    topicModelToSend.topic_NotificationCount = TopicDetails.topic_NotificationCount;
    topicModelToSend.topic_LastReceivedMessage = TopicDetails.topic_LastReceivedMessage;
    
    //****Meta
    if(TopicDetails.topic_meta != nil){
        
        NSString *string = [[NSString alloc] initWithData:(NSData*)TopicDetails.topic_meta encoding:NSUTF8StringEncoding];
        topicModelToSend.topic_meta = string;
        
    }
    
    if(TopicDetails.topic_group_members != nil){
        
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData*)TopicDetails.topic_group_members];
        topicModelToSend.topic_group_members = array;
        
    }
    
    NSLog(@"####### getTopicDetailsForATopic (2) :%@ #####",topicModelToSend);
    
    return topicModelToSend;
    
}


-(NSMutableArray*)getAllMyTopics{ // old **
    
    NSLog(@"--- getAllMyTopics (1) ---");
    NSLog(@"--- getAllMyTopics --- (From dB)");
    
    NSMutableArray *arrGroupsDb = [[NSMutableArray alloc]init];
    
    NSArray *arrTopicDb = [[DatabaseHandler sharedDatabaseHandler] getAllDbTopics];
    NSLog(@"***** DB respose arrTopic in sttarter for Gruops: %@******",arrTopicDb);
    NSLog(@"--- getAllMyTopics (5)---");
    
    for(int i=0; i<arrTopicDb.count;i++)
    {
        Topics *topicsObj = [arrTopicDb objectAtIndex:i];
        TopicModel *topicModelToSend = [[TopicModel alloc]init];
        topicModelToSend.topic_id = topicsObj.topic_id;
        topicModelToSend.topic_name = topicsObj.topic_name;
        topicModelToSend.topic_userId = topicsObj.topic_userId;
        topicModelToSend.topic_name = topicsObj.topic_name;
        topicModelToSend.topic_type = topicsObj.topic_type;
        topicModelToSend.topic_updated_unix_timestamp = topicsObj.topic_updated_unix_timestamp;
        topicModelToSend.topic_NotificationCount = topicsObj.topic_NotificationCount;
        topicModelToSend.topic_LastReceivedMessage = topicsObj.topic_LastReceivedMessage;
        
        //****Meta
        if(topicsObj.topic_meta != nil){
            
            NSString *string = [[NSString alloc] initWithData:(NSData*)topicsObj.topic_meta encoding:NSUTF8StringEncoding];
            
            topicModelToSend.topic_meta = string;
        }
        
        if(topicsObj.topic_group_members != nil){
            
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData*)topicsObj.topic_group_members];
            topicModelToSend.topic_group_members = array;
            
        }
        [arrGroupsDb addObject:topicModelToSend];
        
    }
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"topic_updated_unix_timestamp" ascending:FALSE];
    [arrGroupsDb sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    
    return [NSMutableArray arrayWithArray:arrGroupsDb];
    
    
} 


//-(NSMutableArray*)getAllMyTopics{
//
//    // call get my topics, send the json model on success , on failure return the existing dB.
//
//    NSLog(@"QWERT MY_TOPICS  getAllMyTopics  ");
//
//    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];//appToken
//    NSString *strXUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];//xUserToken
//
//
//    __block NSMutableArray *array;
//    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
//
//    [self getAllTopics:strXUserToken andAppToken:strXAppToken andCallback:^(NSMutableArray *result) {
//        array = result;
//        dispatch_semaphore_signal(sem);
//    }];
//
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//
//
////     sort before sending
////    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"topic_updated_unix_timestamp" ascending:FALSE];
////    [array sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
////
//    NSLog(@"QWERT MY_TOPICS  array count: %@",array);
//
//
//    return [NSMutableArray arrayWithArray:array];
//
//
//}

//-(void)getAllTopics:(NSString*)strXUserToken andAppToken:(NSString *)appToken andCallback:(void (^)(NSMutableArray *))callback {
//
//    [[DownloadManager shared] ApiMyTopics:strXUserToken appToken:appToken completionBlock:^(NSError *error,MyTopicsModel *modelMyTopics,NSString *errTitle, NSString *errMsg)
//     {
//         NSMutableArray *arrGroupsDb = [[NSMutableArray alloc]init];
//
//         if (error) // failed
//         {
//             NSLog(@"QWERT MY_TOPICS = Failed on fetch data ");
//
//             NSArray *arrTopicDb = [[DatabaseHandler sharedDatabaseHandler] getAllDbTopics];
//             NSLog(@"***** DB respose arrTopic in sttarter for Gruops: %@******",arrTopicDb);
//             NSLog(@"--- getAllMyTopics (5)---");
//
//             for(int i=0; i<arrTopicDb.count;i++)
//             {
//                 Topics *topicsObj = [arrTopicDb objectAtIndex:i];
//                 TopicModel *topicModelToSend = [[TopicModel alloc]init];
//                 topicModelToSend.topic_id = topicsObj.topic_id;
//                 topicModelToSend.topic_name = topicsObj.topic_name;
//                 topicModelToSend.topic_userId = topicsObj.topic_userId;
//                 topicModelToSend.topic_name = topicsObj.topic_name;
//                 topicModelToSend.topic_type = topicsObj.topic_type;
//                 topicModelToSend.topic_updated_unix_timestamp = topicsObj.topic_updated_unix_timestamp;
//                 topicModelToSend.topic_NotificationCount = topicsObj.topic_NotificationCount;
//                 topicModelToSend.topic_LastReceivedMessage = topicsObj.topic_LastReceivedMessage;
//                 [arrGroupsDb addObject:topicModelToSend];
//
//             }
//
//         }
//         else // success
//         {
//
//             NSLog(@"QWERT  MY_TOPICS = Success on fetch data ");
//             NSLog(@" QWERT Response : %@",modelMyTopics);
//
//             for(int i =0;i<modelMyTopics.topics.count;i++){
//
//                 TopicsModel *topicsObj =[modelMyTopics.topics objectAtIndex:i];
//
//
//                 if([topicsObj.type isEqualToString:@"master"]){ // One on one
//
//                     //                     [[NSUserDefaults standardUserDefaults] setObject:_TopicsModel.topic forKey:@"MY_MASTER_TOPIC"];
//                     //                     [[NSUserDefaults standardUserDefaults] synchronize];
//                     //                     [self SttarterClassSubscribeTopic:_TopicsModel.topic];
//
//                     for(int j =0;j<topicsObj.interacted_with.count;j++){
//
//                         TopicsModel *interactedWith = [topicsObj.interacted_with objectAtIndex:j];
//
//                         TopicModel *topicModelToSend = [[TopicModel alloc]init];
//                         NSString *topic = interactedWith.topic;
//                         NSString *type = interactedWith.type;
//                         NSString *userid = interactedWith.userId;
//                         topicModelToSend.topic_id = (NSString*)topic;
//                         topicModelToSend.topic_name = interactedWith.topic_name;
//                         topicModelToSend.topic_userId = interactedWith.userId;
//                         if([userid length] != 0 ){
//                             topicModelToSend.topic_userId = userid;
//                         }
//                         NSString *updatedTimeStamp = interactedWith.messageTimeStamp;
//                         topicModelToSend.topic_name = interactedWith.topic_name;
//                         topicModelToSend.topic_type = type;
//                         topicModelToSend.topic_updated_unix_timestamp = updatedTimeStamp;
//                         topicModelToSend.topic_NotificationCount = @"0";
//                         topicModelToSend.topic_LastReceivedMessage = @"";
//
//                         NSLog(@" QWERT Added new Interacted users to Json Model Array: %@",topicModelToSend);
//                         [arrGroupsDb addObject:topicModelToSend];
//
//                     }
//                 }
//
//                 else if([topicsObj.type isEqualToString:@"group"])
//
//                 {
//
//                     TopicModel *topicModelToSend = [[TopicModel alloc]init];
//
//                     NSString *topic = topicsObj.topic;
//                     NSString *type = topicsObj.type;
//                     NSString *userid = topicsObj.userId;
//                     topicModelToSend.topic_id = (NSString*)topic;
//                     topicModelToSend.topic_name = topicsObj.topic_name;
//                     topicModelToSend.topic_userId = topicsObj.userId;
//                     if([userid length] != 0 ){
//                         topicModelToSend.topic_userId = userid;
//                     }
//                     NSString *updatedTimeStamp = topicsObj.messageTimeStamp;
//                     topicModelToSend.topic_name = topicsObj.topic_name;
//                     topicModelToSend.topic_type = type;
//                     topicModelToSend.topic_updated_unix_timestamp = updatedTimeStamp;
//                     topicModelToSend.topic_NotificationCount = @"0";
//                     topicModelToSend.topic_LastReceivedMessage = @"";
//
//                     //                     [self SttarterClassSubscribeTopic:_TopicsModel.topic];//??
//                     NSLog(@" QWERT Added new Group Topic to Json Model Array: %@",topicModelToSend);
//
//
//                     [arrGroupsDb addObject:topicModelToSend];
//
//                 }
//
//             }
//
//             // 2) In the Back ground - update dB and subscibe etc.
//             //             NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
//             //             [myQueue addOperationWithBlock:^{
//             //                 // Background work.
//             //                 [self updateDbAndSubscribeToTopic:modelMyTopics];
//             //             }];
//
//         }
//         NSLog(@" arrGroupsDb: %lu",(unsigned long)arrGroupsDb.count);
//         callback((NSMutableArray*) arrGroupsDb); //And trigger the callback with the result
//     }];
//}





#pragma mark - **  Send Message **

-(NSString*)getUserMasterTopic:(NSString*)strTopic
{
    NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    NSString *strCheck =[NSString stringWithFormat:@"%@-master-",strAppKey];
    NSString *strUserId2 = [strTopic stringByReplacingOccurrencesOfString:strCheck withString:@""];
    
    NSString *userTopic = [NSString stringWithFormat:@"%@-master-%@",strAppKey,strUserId2]; //* appkey-MASTER-UserID
    NSLog(@"*** Created MasterTopic :%@ ***",userTopic);
    
    return userTopic;
}

//publishMediaToTopicWithCustomUrl


//- (void)SendMessageToUserId:(NSString*)strUserId withMessage:(NSString*)strMessage andType:(NSString*)strType// OneOnOne
//{
//
//
//    NSLog(@" $$$$ 3 Send Message $$$$ ");
//
//    NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
//    NSString *strCheck =[NSString stringWithFormat:@"%@-master-",strAppKey];
//    // check if the user has sent the topic or just te username
//    NSString *strUserIdWithoutMaster = [strUserId stringByReplacingOccurrencesOfString:strCheck withString:@""];
//    NSLog(@"*** User Id in Sttarter : %@",strUserIdWithoutMaster);
//
//    NSString *userTopic = [NSString stringWithFormat:@"%@-master-%@",strAppKey,strUserIdWithoutMaster]; //* appkey-MASTER-UserID
//    NSLog(@"*** created MasterTopic :%@ ***",userTopic);
//
//    NSString *CurrentUnixTimeStamp =  [[Utils shared] GetCurrentEpochTime];
//
//    NSString *strFrom = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; //EXTERNAL_USER_ID or Username ///
//
//    /// ** Create hash **
//    NSString *uuid = [[NSUUID UUID] UUIDString];
//    NSString *UniqueString = [[NSString stringWithFormat:@"%@ - %@ - %@",strFrom,uuid,CurrentUnixTimeStamp]uppercaseString];
//    NSString *strHash =[UniqueString MD5String];///
//    NSLog(@"***** HASH generated :%@ ******",strMessage);
//
//
//    TopicMessage *topicMessageModel = [[TopicMessage alloc]init];//
//    TopicMessageDetail *detailModel = [[TopicMessageDetail alloc]init];
//
//    if(strType.length == 0 || strType ==  nil)
//    {
//        detailModel.messageSubType = @"message";
//    }
//    else{
//        detailModel.messageSubType = strType;
//    }
//
//    detailModel.messageType = @"message"; // ***
//    detailModel.messageFrom = strFrom;// ***
//    detailModel.messageHash = strHash;//***
//    detailModel.messageText = strMessage;//***
//    detailModel.messageTimeStamp = CurrentUnixTimeStamp;//***
//    detailModel.messageFileType = @"";//***
//    detailModel.messageFileURL = @"";//***
//
//    topicMessageModel.message = detailModel;//***
//    topicMessageModel.is_sender =  @"TRUE";//***
//    topicMessageModel.str_IsRead = @"TRUE"; // *** ChecK - blue tik n also count
//    topicMessageModel.topic = userTopic;//***
//
//    TopicsModel *topicModel = [[TopicsModel alloc]init];
//    topicModel.topic = userTopic;
//    topicModel.type =  @"master";// ***
//    topicModel.userId = strUserIdWithoutMaster;//***
//    topicModel.messageTimeStamp = CurrentUnixTimeStamp;//abc
//
//    ///*** Inserts into Topics dB
//    [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:topicModel];
//    ///*** Inserts into Message dB
//    [[DatabaseHandler sharedDatabaseHandler] updateMessagesDatabase:topicMessageModel];
//
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshUI_Notification" object:self userInfo:nil]; /// Might not be needed _PRAJNA
//
//    /// Publishes to MQTT
//    [self SttarterClassPublishTopic:userTopic withData:detailModel];
////  [self SttarterClassPublishTopic:userTopic messagehash:strHash strData:dctTopicmessageDetail];
//
//    /// insert the new message into the datatbase
//    MessageStatusModel *messageStatusModel = [[MessageStatusModel alloc]init];
//    messageStatusModel.message_hash = strHash;
//    messageStatusModel.user_id = strUserIdWithoutMaster;//strUserId; check
//
//    NSLog(@" ***** message status will Inser now the model: %@ ******",messageStatusModel);
//    NSLog(@" $$$$$ 3.1 ONE ON ONE $$$$$ ");
//    NSLog(@" $$$$$ 3.1.1 Insert sent msgs into status Db $$$$$ ");
//    NSLog(@" $$$$ Check if One On One's sent message is inserted into the status dB here ---> ******");
//
//    [[DatabaseHandler sharedDatabaseHandler] updateTopicMessageStatusTableForOneOnOne:messageStatusModel];
//
//}

- (void)publishMediaToTopicWithCustomUrl:(NSString*)strTopic withMessage:(NSString*)strMessage andMedialist:(NSMutableArray*)arrMedia{
    
    // some api need to be called. Check Android SDK code but ios hadnt got the requirement to impliment it yet. As of now implimented what was needed for TFT only.
    
    
    
    
}


- (void)PublishMediaToTopicWithCustomUrl:(NSString*)strUserId withMessage:(NSString*)strMessage  withPathUrl:(NSArray*)arrPathstoMedia{
    
    // for images - Might have to call an API (Future implimentation)
    for(int i=0;i<arrPathstoMedia.count;i++){
        
        NSString *strUrl = [arrPathstoMedia objectAtIndex:i];
        if([strUrl isEqualToString:@""]){
        [self sendMessage:strUserId withMessage:strMessage Type:@"" andUrl:strUrl];

        }
        [self sendMessage:strUserId withMessage:strMessage Type:@"media" andUrl:strUrl];
    }
}


- (void)SendMessageToTopic:(NSString*)strTopic withMessage:(NSString*)strMessage andType:(NSString*)strType{// called by demo
    
    [self sendMessage:strTopic withMessage:strMessage Type:strType andUrl:@""];
    
}



-(void)sendMessage:(NSString*)strTopic withMessage:(NSString*)strMessage Type:(NSString*)strType andUrl:(NSString*)strURL{
    
    
    NSString *CurrentUnixTimeStamp =  [[Utils shared] GetCurrentEpochTime];
    NSString *strMyExtId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; //EXTERNAL_USER_ID or Username ///
    NSString* strHash = [self createHashForMessage:strMessage];
    
    
    TopicMessageDetail *detailModel = [[TopicMessageDetail alloc]init];
    if(strType.length == 0 || strType ==  nil){
        detailModel.messageSubType = @"message";
    }
    else{
        detailModel.messageSubType = strType;
    }
    detailModel.messageTimeStamp = CurrentUnixTimeStamp;
    detailModel.messageType = @"message";
    detailModel.messageFrom = strMyExtId;
    detailModel.messageHash = strHash;
    detailModel.messageText = strMessage;
    detailModel.messageFileType = @"";
    detailModel.messageFileURL = strURL;
    
    TopicMessage *topicMessageModel = [[TopicMessage alloc]init];
    topicMessageModel.message = detailModel;
    topicMessageModel.is_sender =  @"TRUE";
    topicMessageModel.str_IsRead = @"TRUE";
    
    TopicsModel *topicModel = [[TopicsModel alloc]init];
    topicModel.messageTimeStamp = CurrentUnixTimeStamp;//abc
    
    if([strTopic containsString:@"group"]){// Group
        
        topicMessageModel.topic = strTopic;
        topicModel.topic = strTopic;
        topicModel.type =  @"group";
    }
    
    else{// if One_on_One
        
        // check if the user has sent the topic or just the username , if its just the username then create topic out of it..
        NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
        NSString *strCheck =[NSString stringWithFormat:@"%@-master-",strAppKey];
        NSString *strUserIdWithoutMaster = [strTopic stringByReplacingOccurrencesOfString:strCheck withString:@""];
        NSString *userTopic = [NSString stringWithFormat:@"%@-master-%@",strAppKey,strUserIdWithoutMaster]; //* appkey-MASTER-UserID
        NSLog(@"*** User Id in Sttarter : %@  and  created new MasterTopic :%@ ***",strUserIdWithoutMaster,userTopic);
        
        topicMessageModel.topic = userTopic;//***
        topicModel.topic = userTopic;
        topicModel.type =  @"master";// ***
        topicModel.userId = strUserIdWithoutMaster;//***
        
    }
    
    [self sendMessageWith_TopicsDbModel:topicModel andMessagesDbModel:topicMessageModel];
    
    
}

-(void)sendMessageWith_TopicsDbModel:(TopicsModel*)topicModel andMessagesDbModel:(TopicMessage*)topicMessageModel{
    
    [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:topicModel];
    [[DatabaseHandler sharedDatabaseHandler] updateMessagesDatabase:topicMessageModel];
    
    TopicMessageDetail *detailModel = topicMessageModel.message;
    NSLog(@"******QWERTY topicModel:%@  topicMessageModel:%@ *****" ,topicModel,topicMessageModel);
    [self SttarterClassPublishTopic:topicMessageModel.topic withData:detailModel];
    
    // if group
    if([topicMessageModel.topic containsString:@"group"]){
        
        NSString* strHash = [self createHashForMessage:detailModel.messageText];
        NSString *strMyExtId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"];
        NSString *CurrentUnixTimeStamp =  [[Utils shared] GetCurrentEpochTime];
        
        NSArray *arrGroupUsers = [[DatabaseHandler sharedDatabaseHandler]getAllGroupMembers:topicModel.topic];
        NSLog(@"**** ++Group memebers array for Group Topic : %@ is : %@ ****",topicModel.topic,arrGroupUsers);
        
        if(arrGroupUsers != nil){
            
            for(int i = 0; i<arrGroupUsers.count;i++){
                
                Topic_GroupMembers *groupMembersObject = [[Topic_GroupMembers alloc]init];
                groupMembersObject = [arrGroupUsers objectAtIndex:i];
                
                MessageStatusModel *messageStatusModel = [[MessageStatusModel alloc]init];
                messageStatusModel.message_hash = strHash;
                messageStatusModel.user_id = groupMembersObject.username;
                
                if([groupMembersObject.username isEqualToString:strMyExtId]){
                    // if I am the sender then make read n delivered true cos while doing the read count, we will be automatically included.
                    NSLog(@"++if sender is me then update my timestame.");
                    messageStatusModel.is_deliveredTimestamp = CurrentUnixTimeStamp;
                    messageStatusModel.is_readByReceiverTimeStamp = CurrentUnixTimeStamp;
                }
                
                NSLog(@" ++$$$$$ 3.2 ON SENDING A GROUP MESSAGE $$$$$ ");
                NSLog(@" ++$$$$$ 3.2.1 Insert sent msgs into status Db $$$$$ ");
                [[DatabaseHandler sharedDatabaseHandler] updateTopicMessageStatusTableForGroupUser:messageStatusModel];
                
            }
        }
    }
    
    else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshUI_Notification" object:self userInfo:nil]; /// Might not be needed _PRAJNA
        
        MessageStatusModel *messageStatusModel = [[MessageStatusModel alloc]init];
        messageStatusModel.message_hash = detailModel.messageHash;
        messageStatusModel.user_id = topicModel.userId;
        
        NSLog(@" ***** message status will Inser now the model: %@ ******",messageStatusModel);
        NSLog(@" $$$$$ 3.1 ONE ON ONE $$$$$ ");
        NSLog(@" $$$$$ 3.1.1 Insert sent msgs into status Db $$$$$ ");
        NSLog(@" $$$$ Check if One On One's sent message is inserted into the status dB here ---> ******");
        
        [[DatabaseHandler sharedDatabaseHandler] updateTopicMessageStatusTableForOneOnOne:messageStatusModel];
        
        
    }
    
}


-(NSString*)createHashForMessage:(NSString*)strMessage{
    
    NSString *CurrentUnixTimeStamp =  [[Utils shared] GetCurrentEpochTime];
    
    NSString *strFrom = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; //EXTERNAL_USER_ID or Username
    
    // ** Create hash **
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSString *UniqueString = [[NSString stringWithFormat:@"%@ - %@ - %@",strFrom,uuid,CurrentUnixTimeStamp]uppercaseString];
    NSString *strHash =[UniqueString MD5String];
    NSLog(@"***** HASH generated :%@ ******",strHash);
    
    return strHash;
}



#pragma mark - ### MQTT other methods ###

-(void)DisconnectCommunicator{
    
    NSLog(@"--- DisconnectCommunicator ---");
    
    [session disconnect];
    NSLog(@"****Disconnectd MQTT *****");
    
}

//-(void)ReConnectCommunicator{
//    
//    NSLog(@"--- ReConnectCommunicator ---");
//    
//    
//    if(session!=nil){
//        [session disconnect];
//    }
//    
//    //** MQTT ** view did load
//    transport = [[MQTTCFSocketTransport alloc] init];
//    transport.host = MQTT_HOST;
//    transport.port = MQTT_PORT;
//    
//    session = [[MQTTSession alloc] init];
//    session.transport = transport;
//    session.delegate = self;
//    session.keepAliveInterval = 30;
//    
//    NSString *strSavedClientId = [[NSUserDefaults standardUserDefaults] stringForKey:@"MQTT_CLIENT_ID"];
//    
//    if(strSavedClientId!= nil){
//        session.clientId = strSavedClientId;
//        NSLog(@" ****** CLIENT ID (MQTT): %@ *****",strSavedClientId);
//        
//    }
//    else{
//        
//        NSString *strClientId = [[Utils shared] getClientId];
//        session.clientId = strClientId;
//        NSLog(@" ****** CLIENT ID (MQTT): %@ *****",strClientId);
//        
//    }
//    
//    [session connectAndWaitTimeout:30];////this is part of the synchronous API
//    
//    NSLog(@"*********Started MQTT Connection********");
//    
//    [self getmytopics]; //gets all topics and also subscribes the topics to MQTT
//    
//}



-(void)connectCommunicator{
    NSLog(@"---A.2 connectCommunicator(connect MQTT) ---");
    
    /// What if we are not reconnected to wifi again. we have to send saved data
    //    [[DatabaseHandler sharedDatabaseHandler]RetiveMQTT_Queue]; // BASVA DOUBT
    
    isLoggedOut = FALSE;
    
    if(session==nil){
        //** MQTT ** view did load
        transport = [[MQTTCFSocketTransport alloc] init];
        transport.host = [[Utils shared] getMQTTHostString];
        transport.port = [[Utils shared] getMQTTPort];
        
        session = [[MQTTSession alloc] init];
        session.transport = transport;
        session.delegate = self;
        session.keepAliveInterval = 30;
        
        NSString *strSavedClientId = [[NSUserDefaults standardUserDefaults] stringForKey:@"MQTT_CLIENT_ID"];//appToken
        
        if(strSavedClientId!= nil){
            session.clientId = strSavedClientId;
            NSLog(@" ****** CLIENT ID (MQTT): %@ *****",strSavedClientId);
        }
        else{
            NSString *strClientId = [[Utils shared] getClientId];
            session.clientId = strClientId;
            NSLog(@" ****** CLIENT ID (MQTT): %@ *****",strClientId);
        }
    }
    
    NSLog(@"*********Started MQTT Connection********");
    // if Connected.
    
    NSLog(@"connectedconnectedconnected Start");
    
    if(session!=nil){
        NSLog(@"MQTTSession connecting...");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Connection_Start" object:self userInfo:nil];
        BOOL connectionStatus = ([session status] != MQTTSessionStatusConnected) ? [session connectAndWaitTimeout:30] : true;
        if (connectionStatus) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Connection_End" object:self userInfo:nil];
            
            [[DatabaseHandler sharedDatabaseHandler]RetiveMQTT_Queue];
            
            NSLog(@"MQTTSession connected successfully...");
            [self GetAllRecentTopics_withCompletionBlock:^(BOOL isSuccess, NSMutableArray *arrDbTopicsData) {
                if (isSuccess == true) {
                    NSLog(@"Get All topic sync success...");
                    [self.connectionDelegate connectionSuccess];
                    
                }else{
                    [self.connectionDelegate connectionSuccess];
                    NSLog(@"Get All topic sync failed...");
                }
            }]; // BASVA ?
            
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Connection_End" object:self userInfo:nil];
            
            NSLog(@"MQTTSession connection failed...");
            [self.connectionDelegate connectionFailure];
        }
    }
    
    NSLog(@"********* getmytopics will be called********");
}

-(BOOL)checkMQTTConnection{
    
    if(session == nil){
        return FALSE;
    }
    else {
        if ([session status] == MQTTSessionStatusConnected) {
            return TRUE;
        }else{
            return FALSE;
        }
    }
}

#pragma mark - ### MQTT ### Subscribe **
// MQTT Methods https://github.com/hapim/IOS-MQTT-Websocket-Client/blob/master/MQTTClient/MQTTClient/MQTTSession.h

-(void)SttarterClassSubscribeTopic:(NSString*)strTopic{
    
    NSLog(@"***** MQTT Subscribed on topic : %@******", strTopic);
    
    [session subscribeToTopic:strTopic atLevel:1 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
        if (error) {
            NSLog(@"Subscription failed %@", error.localizedDescription);
        } else {
            
            NSLog(@"****Subscription c! Granted Qos: %@ ****", gQoss);
            
            
            NSString *strMyMaster = [[NSUserDefaults standardUserDefaults] stringForKey:@"MY_MASTER_TOPIC"];
            
            if(![strTopic isEqualToString:strMyMaster]){/// not my master then call get msgs for the topic
                NSLog(@"**** MY MASTER : %@ ****", strMyMaster);
                NSLog(@"**** Call get Messages For subscribed Topic : %@ ****", strTopic);
                [self ApiGetMessagesForTopic:strTopic];
                
            }
            
        }
    }];
    
    
    
}

-(void)subscribeToTopicAndFetchMessages:(NSString*)strTopic withCompletionBlock:(SubscribeTopicAndFetachMessagesBlock)completionBlock{
    
    NSLog(@"***** MQTT Subscribed on topic : %@******", strTopic);
    //    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //    [queue addOperationWithBlock:^{
    [session subscribeToTopic:strTopic atLevel:1 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
        if (error) {
            NSLog(@"Subscription failed %@", error.localizedDescription);
            if (completionBlock)
            {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (false);
                });
            }
        } else {
            
            NSLog(@"****Subscription c! Granted Qos: %@ ****", gQoss);
            
            NSString *strMyMaster = [[NSUserDefaults standardUserDefaults] stringForKey:@"MY_MASTER_TOPIC"];
            //            21dc2ebf100cf324becc27e8db6fde8d-master-3
            
            if(![strTopic isEqualToString:strMyMaster]){/// not my master then call get msgs for the topic
                NSLog(@"**** MY MASTER : %@ ****", strMyMaster);
                NSLog(@"**** Call get Messages For subscribed Topic : %@ ****", strTopic);
                [self ApiGetMessagesForTopic:strTopic];
            }
            
            if (completionBlock)
            {
                dispatch_async (dispatch_get_main_queue (), ^{ completionBlock (true);
                });
            }
        }
    }];
    //    }];
}

#pragma mark - ### MQTT ### Events - CLOSE , CONNECTED etc

-(void)handleEvent:(MQTTSession *)session1 event:(MQTTSessionEvent)eventCode error:(NSError *)error{
    
    if (eventCode == MQTTSessionEventConnected) {
        NSLog(@"handleEvent--MQTTSessionEventConnected");
    }
    else if(eventCode == MQTTSessionEventConnectionClosedByBroker){
        NSLog(@"handleEvent--MQTTSessionEventConnectionClosedByBroker");
    }
    else if(eventCode == MQTTSessionEventConnectionError){
        NSLog(@"handleEvent--MQTTSessionEventConnectionError");
    }
    else if(eventCode == MQTTSessionEventConnectionRefused){
        NSLog(@"handleEvent--MQTTSessionEventConnectionRefused");
    }
    else if(eventCode == MQTTSessionEventConnectionClosed){
        NSLog(@"handleEvent--MQTTSessionEventConnectionClosed");
    }
}

- (void)connectionClosed:(MQTTSession *)session{
    NSLog(@"handleEvent--connectionClosed");
  UIApplicationState state = [[UIApplication sharedApplication] applicationState];
  if (state == UIApplicationStateActive && !(isMQTTSessionConnecting))
  {
    [self checkConnectionStateAndReconnect];
  }

}

- (void)session:(MQTTSession*)session handleEvent:(MQTTSessionEvent)eventCode{
    NSLog(@"handleEvent--eventCode %ld",(long)eventCode);
}



#pragma mark - ### MQTT ### SENT,DELIVERED  ** sent status

- (void)messageDelivered:(MQTTSession *)session msgID:(UInt16)msgID {
    
    NSMutableDictionary *dctSent = self.dctMsgStatus;
    
    NSNumber *sentMessageID = [dctSent objectForKey:[NSNumber numberWithUnsignedInt:msgID]];
    
    if (sentMessageID) {
        
        [self.dctMsgStatus setObject:@"SENT" forKey:[NSNumber numberWithUnsignedInt:msgID]];
        
        NSLog(@"*** testing Delivery ** in messageDelivered: %@",self.dctMsgStatus);
    }
}

//- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained{
//    ////** gets called when a published message was actually delivered
//
//    NSError* error;
//
//    NSDictionary* dctData = [[NSDictionary alloc]init];
//    dctData= [NSJSONSerialization JSONObjectWithData:data
//                                             options:kNilOptions
//                                               error:&error];
//    NSLog(@"*^*^*^*^*^* 1 testing Delivery in handleMessage: %@ *^*^*^*^*^*^*",dctData);
//    NSLog(@"*^*^*^*^*^* 1 testing Delivery in handleMessage data: %@ *^*^*^*^*^*^*",data);
//
//
//
//
//}

#pragma mark - ### MQTT ### SENT  ** sent status

- (void)sending:(MQTTSession *)session type:(MQTTCommandType)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data{
    
    NSError* error;
    NSDictionary* dctData;
    NSString *string;
    
    
    if(data != nil){
        dctData = [NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments //
                                                    error:&error];
        
        string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        ///kNilOptions -JSON text did not start with array or object and option to allow fragments not set.
        ///NSJSONReadingAllowFragments -Code=3840 "Invalid value around character 0.
    }
    
    
    
    ///    MQTTPublish = 3, on new message - SEND - full data
    /////    MQTTPingreq = 12, everytime
    /// 12 and 4 on receiving
    
    /// NEED TO CONVERT THIS TO READABLE FORMAT
    
    unsigned char* bytes = (unsigned char*) [data bytes];
    
    for(int i=0;i< [data length];i++)
    {
        NSString* op = [NSString stringWithFormat:@"%d:%X",i,bytes[i],nil];
    }
    
    
}



//- (void)received:(MQTTSession *)session type:(MQTTCommandType)type qos:(MQTTQosLevel)qos retained:(BOOL)retained duped:(BOOL)duped mid:(UInt16)mid data:(NSData *)data{
//    ///** gets called when a command is received from the MQTT broker
//
//    NSError* error;
//
//    NSDictionary* dctData = [NSJSONSerialization JSONObjectWithData:data
//                                             options:kNilOptions
//                                               error:&error];
//    NSLog(@"*^*^*^*^*^* 2 testing Delivery in handleMessage type: %hhu *^*^*^*^*^*^*",type);
//    NSLog(@"*^*^*^*^*^* 2 testing Delivery in handleMessage qos: %hhu *^*^*^*^*^*^*",qos);
//    NSLog(@"*^*^*^*^*^* 2 testing Delivery in handleMessage data: %@ *^*^*^*^*^*^*",data);
//    NSLog(@"*^*^*^*^*^* 2 testing Delivery in handleMessage data dct: %@ *^*^*^*^*^*^*",dctData);
//
// //   NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//    MQTT_None = 0,
//    MQTTConnect = 1,
//    MQTTConnack = 2,
///    MQTTPublish = 3, on new message - RECEIVE - full data
////    MQTTPuback = 4, gets called on publish - SENDDDDD - small data
//    MQTTPubrec = 5,
//    MQTTPubrel = 6,
//    MQTTPubcomp = 7,
//    MQTTSubscribe = 8,
//    MQTTSuback = 9,
//    MQTTUnsubscribe = 10,
//    MQTTUnsuback = 11,
//    MQTTPingreq = 12,
///    MQTTPingresp = 13, keeps coming
//    MQTTDisconnect = 14
//}
//
//


#pragma mark - ### MQTT ### Publish Message **


//TopicMessageDetail
- (void)SttarterClassPublishTopic:(NSString*)strTopic withData:(TopicMessageDetail*)messageDetailModel{
    
    
    NSMutableDictionary *dctMessage = [[NSMutableDictionary alloc]init];
    [dctMessage setValue:messageDetailModel.messageType forKey:@"messageType"];
    [dctMessage setValue:messageDetailModel.messageSubType forKey:@"messageSubType"];
    [dctMessage setValue:messageDetailModel.messageFrom forKey:@"messageFrom"];
    [dctMessage setValue:messageDetailModel.messageHash forKey:@"messageHash"];
    [dctMessage setValue:messageDetailModel.messageText forKey:@"messageText"];
    [dctMessage setValue:messageDetailModel.messageFileURL forKey:@"messageFileURL"];
    [dctMessage setValue:messageDetailModel.messageFileType forKey:@"messageFileType"];

    
    
    NSLog(@" $$$$$ 4.0 Send MQtt Message Method called. $$$$$ ");
    
    
    NSString *CurrentUnixTimeStamp =  [[Utils shared] GetCurrentEpochTime];;
    NSLog(@"*** SENT Timestamp updated ***");
    
    NSError *error= nil;
    
    BOOL connectionStatus = [self checkMQTTConnection];
    BOOL networkConnectionStatus = [[Utils shared] checkIfInternetConnectionExists];
    NSLog(@" connectionStatus :%d: networkConnectionStatus : %d",connectionStatus,networkConnectionStatus);
    
    if(networkConnectionStatus && connectionStatus)
    {
        ///BASVA - if there is internet connection and MQTT is connected.
        
        NSLog(@" $$$$$ 4.1 Internet connection exists: $$$$$ ");
        
        
        /// [session publishData:data onTopic:strTopic];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dctMessage
                                                       options:0
                                                         error:&error];
        
        NSLog(@"***** MQTT Published on Topic : %@ with with publishData : %@ ******" , strTopic, dctMessage);
        //        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        //
        //        [queue addOperationWithBlock:^{
        
        UInt16 sentMessageMid =  [session publishData:data onTopic:strTopic retain:false qos:MQTTQosLevelAtLeastOnce];
        
        
        ///*** is used to show clock or single tick
        if(![[dctMessage objectForKey:@"messageType"]isEqualToString:@"system"]){/// Not Of the type System
            
            NSLog(@"*** since the Type was not system, we go ahead and update the status dB with the timestamp. ***");
            
            [[DatabaseHandler sharedDatabaseHandler]updateMessageSentStatus:messageDetailModel.messageHash withTimestamp:CurrentUnixTimeStamp];
            
        }
        
        NSLog(@"*** testing Delivery - publish with Msgid %d", sentMessageMid);
        [self.dctMsgStatus setObject:@"PUBLISH" forKey:[NSNumber numberWithUnsignedInt:sentMessageMid]];
        
        NSLog(@"*** testing Delivery ** in publishData: %@",self.dctMsgStatus);
        
        //  [self saveInMessageStatusTable:dctMessage];
        
        
    }
    else{
        
        NSLog(@" $$$$$ 4.2 Save the message in MQTT Queuing database until the internet is connected and show clock sign on the message. $$$$$ ");
        /// save in MQTT Database
        
        MQTT_QueueModel *MqttModel = [[MQTT_QueueModel alloc]init];
        MqttModel.topic = strTopic;
        MqttModel.payLoad = dctMessage;
        MqttModel.MessageHash = messageDetailModel.messageHash;// send hash in while publishing.
        
        [[DatabaseHandler sharedDatabaseHandler] AddToMQTT_Queue:MqttModel];
        
    }
    
}


//- (void)SttarterClassPublishTopic:(NSString*)strTopic messagehash:(NSString*)strHash strData:(NSDictionary*)dctMessage{
//
//    NSLog(@" $$$$$ 4.0 Send MQtt Message Method called. $$$$$ ");
//
//    NSError *error= nil;
//
//    BOOL connectionStatus = [self checkMQTTConnection];
//    BOOL networkConnectionStatus = [[Utils shared] checkIfInternetConnectionExists];
//    NSLog(@" connectionStatus :%d: networkConnectionStatus : %d",connectionStatus,networkConnectionStatus);
//
//
//
//
//    if(networkConnectionStatus && connectionStatus)
//    {
//
//        NSLog(@" $$$$$ 4.1 Internet connection exists: $$$$$ ");
//
//
//        /// [session publishData:data onTopic:strTopic];
//        NSData *data = [NSJSONSerialization dataWithJSONObject:dctMessage
//                                                       options:0
//                                                         error:&error];
//
//        NSLog(@"***** MQTT Published on Topic : %@ with with publishData : %@ ******" , strTopic, dctMessage);
//
//        UInt16 sentMessageMid =  [session publishData:data onTopic:strTopic retain:false qos:MQTTQosLevelAtLeastOnce];
//
//        NSString *CurrentUnixTimeStamp =  [[Utils shared] GetCurrentEpochTime];;
//        NSLog(@"*** SENT Timestamp updated ***");
//
//
//        ///*** is used to show clock or single tick
//        if(![[dctMessage objectForKey:@"messageType"]isEqualToString:@"system"]){/// Not Of the type System
//
//            NSLog(@"*** since the Type was not system, we go ahead and update the status dB with the timestamp. ***");
//
//            [[DatabaseHandler sharedDatabaseHandler]updateMessageSentStatus:strHash withTimestamp:CurrentUnixTimeStamp];
//
//        }
//
//        NSLog(@"*** testing Delivery - publish with Msgid %d", sentMessageMid);
//        [self.dctMsgStatus setObject:@"PUBLISH" forKey:[NSNumber numberWithUnsignedInt:sentMessageMid]];
//
//        NSLog(@"*** testing Delivery ** in publishData: %@",self.dctMsgStatus);
//
//        //  [self saveInMessageStatusTable:dctMessage];
//
//
//    }
//    else{
//
//
//        NSLog(@" $$$$$ 4.2 Save the message in MQTT Queuing database until the internet is connected and show clock sign on the message. $$$$$ ");
//
//        /// save in MQTT Database
//
//        MQTT_QueueModel *MqttModel = [[MQTT_QueueModel alloc]init];
//        MqttModel.topic = strTopic;
//        MqttModel.payLoad = dctMessage;
//        MqttModel.MessageHash = strHash;// send hash in while publishing.
//
//        [[DatabaseHandler sharedDatabaseHandler] AddToMQTT_Queue:MqttModel];
//
//    }
//
//}



#pragma mark - ### MQTT ### New Message **

- (void)newMessage:(MQTTSession *)session1  //*******
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    
    NSLog(@"***** New Message MQTT received on Topic: %@******",topic);
    
    NSError* error;
    NSDictionary* dctData = [[NSDictionary alloc]init];
    dctData= [NSJSONSerialization JSONObjectWithData:data
                                             options:kNilOptions
                                               error:&error];
    
    
    if (self.dctMsgStatus) {
        NSLog(@"*** testing Delivery ** in New Msg: %d (removed)",mid);
        [self.dctMsgStatus removeObjectForKey:[NSNumber numberWithUnsignedInt:mid]];
        
    }
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"***** !!!! ** New Message MQTT received with dctData: %@** !!!! ******",dctData);
    NSLog(@"***** !!!! ** New Message MQTT received with strData: %@** !!!! ******",string);
    
    /// check if Topic is equal to MyMaster = Recived then OneOnOne else group
    /// Check if received messageType is System or not
    NSString *strMyMaster = [[NSUserDefaults standardUserDefaults] stringForKey:@"MY_MASTER_TOPIC"];
    
    
    ///*** WE RECEIVED A NEW MESSAGE FROM SOMEONE :)
    //messageSubType = "messageTimeStamp-Update"
    
    if(![[dctData objectForKey:@"messageType"]isEqualToString:@"system"] && ![[dctData objectForKey:@"messageSubType"]isEqualToString:@"messageTimeStamp-Update"]){
        // MessageType = Message
        
        NSLog(@" $$$$ 1.2 NEW MSG : NOT SYSTEM MESSAGE with text:%@ $$$$ ",[dctData objectForKey:@"messageText"]);
        
        
        
        if([topic isEqualToString:strMyMaster]){ /// is new oneOneOne -  1***
            
            NSLog(@" $$$$ 1.2.1 NEW MSG : TYPE ONE ONE ONE $$$$ ");
            
            NSString *CurrentUnixTimeStamp = [[Utils shared]GetCurrentEpochTime];
            
            NSLog(@"***** !!!! ** New Message of Type MASTER - OneOneOne *****");
            NSString *strAppKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
            NSString *strUserId =[dctData objectForKey:@"messageFrom"];
            NSString *userTopic = [NSString stringWithFormat:@"%@-master-%@",strAppKey,strUserId];
            
            ///    = = = = = = = = = = = = = = = = =
            ///    ** Update Topics dB **
            
            NSMutableDictionary *dctTopic = [[NSMutableDictionary alloc]init];
            [dctTopic setValue:userTopic == nil ? @"" : userTopic forKey:@"topic"];
            [dctTopic setValue:@"master" forKey:@"type"];
            [dctTopic setValue:strUserId forKey:@"userId"];
            
            /// Done **
            TopicsModel *topicsModel = [[TopicsModel alloc]initWithDictionary:dctTopic error:nil];
            /// Checks and updates Topics dB
            
            topicsModel.messageTimeStamp = CurrentUnixTimeStamp;
            topicsModel.topic_name = strUserId;
            
            [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:topicsModel];
            
            NSMutableDictionary *dctMessage = [[NSMutableDictionary alloc]init];
            [dctMessage setValue:userTopic == nil ? @"" : userTopic  forKey:@"topic"];
            [dctMessage setValue:dctData forKey:@"message"];
            [dctMessage setValue:@"FALSE" forKey:@"is_sender"]; //Never me . I will only receive from someone
            
            NSLog(@"Created dctMessage: %@",dctMessage);
            
            //Inserts into Message dB
            TopicMessage *topicMessageModel = [[TopicMessage alloc]initWithDictionary:dctMessage error:nil];
            
            // We dont trust the time given by the other phone as they may be off. So we will save our current time and then it should get updated via the API to use the server time.
            
            topicMessageModel.message.messageTimeStamp =CurrentUnixTimeStamp;
            topicMessageModel.str_IsRead = @"FALSE";
            topicMessageModel.message.messageSubType = [dctData objectForKey:@"messageSubType"];
            topicMessageModel.message.messageFileURL = [dctData objectForKey:@"messageFileURL"];

            //** Update if hash exists **
            NSLog(@"***** Update dB with Topicmessage model('MQTT newMessage' for OneOnOne) : %@**",topicMessageModel);
            
            [[DatabaseHandler sharedDatabaseHandler] updateMessagesDatabase:topicMessageModel];
            
            
            ///***# * * *  PUBLISH A SYSTEM MESSAGE BACK TO SENDER - ONE ON ONE
            
            NSLog(@" $$$$ 1.2.1 NEW MSG : TYPE ONE ONE ONE $$$$ ");
            NSLog(@" $$$$ PUBLISH A SYSTEM MESSAGE BACK TO THE SENDER SAYING IT IS DELIVERED (OneOnOne) ---> ");
            NSString *strFrom = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; //EXTERNAL_USER_ID or Username
            
//            NSMutableDictionary *dctSendSystemMessage = [[NSMutableDictionary alloc]init];
//            dctSendSystemMessage = [dctData mutableCopy];
//            [dctSendSystemMessage setObject:@"delivered" forKey:@"messageSubType"];
//            [dctSendSystemMessage setObject:@"system" forKey:@"messageType"];
//            [dctSendSystemMessage setValue:strFrom forKey:@"messageFrom"];
//            [self SttarterClassPublishTopic:userTopic messagehash:[dctData objectForKey:@"messageHash"] strData:dctSendSystemMessage];

            
            TopicMessageDetail *detailModel = [[TopicMessageDetail alloc]init];
            detailModel.messageFrom = strFrom;//
            detailModel.messageType = @"system";//
            detailModel.messageSubType = @"delivered";//
            detailModel.messageHash = [dctData objectForKey:@"messageHash"];//
            detailModel.messageFileURL =[dctData objectForKey:@"messageFileURL"];//
            detailModel.messageFileType =[dctData objectForKey:@"messageFileType"];//

            NSLog(@"***# 1.2.1 sends System message back with Payload : %@ #***",detailModel);
            [self SttarterClassPublishTopic:topic withData:detailModel];
            
            
        }
        else{ ///new group Message
            
            NSLog(@" $$$$ 1.2.1 GROUP: NEW MSG RECERVED $$$$ ");
            
            
            NSString *CurrentUnixTimeStamp = [[Utils shared]GetCurrentEpochTime];
            
            NSString *strUserId =[dctData objectForKey:@"messageFrom"];
            
            NSMutableDictionary *dctMessage = [[NSMutableDictionary alloc]init];
            
            [dctMessage setValue:dctData forKey:@"message"];
            [dctMessage setValue:@"FALSE" forKey:@"is_Read"]; // We get it back
            [dctMessage setValue:topic forKey:@"topic"];
            
            NSString *strMYuserid = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"];
            
            
            if([strMYuserid isEqualToString:[dctData objectForKey:@"messageFrom"]]){
                // we get back our own group message.
                //                NSLog(@" ^^^^^^ this was sent by me :%@ so isSender=TRUE "[[dctData objectForKey:@"messageFrom"]);
                
                [dctMessage setValue:@"TRUE" forKey:@"is_sender"];// Sender is me
            }
            else{
                
                //NSLog(@" ^^^^^^ this was NOT sent by me :%@ so isSender=FALSE "[dctData objectForKey:@"messageFrom"]);
                
                [dctMessage setValue:@"FALSE" forKey:@"is_sender"];
            }
            
            //** Update Topics dB **
            NSMutableDictionary *dctTopic = [[NSMutableDictionary alloc]init];
            [dctTopic setValue:topic forKey:@"topic"];
            [dctTopic setValue:@"group" forKey:@"type"];
            [dctTopic setValue:strUserId forKey:@"userId"];
            
            /// userId is the external user id of the msg owner. It is not the name of the group. topic_name is the actual name of the group.
            
            ////Done **
            TopicsModel *topicsModel = [[TopicsModel alloc]initWithDictionary:dctTopic error:nil];
            //checks and updates Topics dB
            topicsModel.messageTimeStamp =CurrentUnixTimeStamp;
            [[DatabaseHandler sharedDatabaseHandler] updateTopicDatabase:topicsModel];
            
            
            //Inserts into Message dB
            TopicMessage *topicMessageModel = [[TopicMessage alloc]initWithDictionary:dctMessage error:nil];
            
            /// We dont trust the time given by the other phone as they may be off. So we will save our current time and then it should get updated via the API to use the server time.
            topicMessageModel.message.messageTimeStamp =CurrentUnixTimeStamp;
            topicMessageModel.str_IsRead = @"FALSE"; // (used later in 1.2.2)
            topicMessageModel.message.messageSubType = [dctData objectForKey:@"messageSubType"];
            topicMessageModel.message.messageFileURL = [dctData objectForKey:@"messageFileURL"];

            
            //** Update if hash exists **
            NSLog(@"***** Update dB with Topicmessage model('MQTT newMessage' for Group) : %@**",topicMessageModel);
            
            [[DatabaseHandler sharedDatabaseHandler] updateMessagesDatabase:topicMessageModel];
            
            ///***# PUBLISH A SYSTEM MESSAGE BACK TO SENDER SAYING IT IS DELIVERED :)
            
            NSLog(@" $$$$ 1.2.1 NEW MSG : TYPE GROUP $$$$ ");
            NSLog(@" $$$$ PUBLISH A SYSTEM MESSAGE BACK TO THE SENDER SAYING IT IS DELIVERED(group) ---> ");
            NSString *strFrom = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; //EXTERNAL_USER_ID or Username
            
//            NSMutableDictionary *dctSendSystemMessage = [[NSMutableDictionary alloc]init];
//
//            dctSendSystemMessage = [dctData mutableCopy];
//            [dctSendSystemMessage setObject:@"delivered" forKey:@"messageSubType"];
//            [dctSendSystemMessage setObject:@"system" forKey:@"messageType"];
//            [dctSendSystemMessage setValue:strFrom forKey:@"messageFrom"];
//
            ////***
            
//            detailModel.messageText = details.messageText;
//            detailModel.messageFileURL = details.messageFileURL;
//            detailModel.messageTimeStamp = details.messageTimeStamp;
//            detailModel.messageReadByReceiverTimeStamp = details.isReadBytheReceiver;
//            detailModel.messageDeliveredTimeStamp = details.isDelivered ;
//           [self SttarterClassPublishTopic:topic messagehash:[dctData objectForKey:@"messageHash"] strData:dctSendSystemMessage];//POIU
            
            TopicMessageDetail *detailModel = [[TopicMessageDetail alloc]init];
            detailModel.messageFrom = strFrom;
            detailModel.messageType = @"system";
            detailModel.messageSubType = @"delivered";
            detailModel.messageHash = [dctData objectForKey:@"messageHash"];
            detailModel.messageFileURL =[dctData objectForKey:@"messageFileURL"];
            detailModel.messageFileType =[dctData objectForKey:@"messageFileType"];//

            NSLog(@"***# 1.2.1 sends System message back with Payload : %@ #***",detailModel);
            [self SttarterClassPublishTopic:topic withData:detailModel];
            
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MQTTNewMsgReceived" object:self userInfo:dctData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshUI_Notification" object:self userInfo:nil];
        
        // ASDF
        
    }
    
    
    else if([[dctData objectForKey:@"messageType"]isEqualToString:@"system"] && ![[dctData objectForKey:@"messageSubType"]isEqualToString:@"messageTimeStamp-Update"]){
        
        // else{ /// if messagetype = SYSTEM, message_Subtype = delivered / read_by_receiver
        
        NSLog(@" $$$$ 1.1 NEW SYSTEM MESSAGE : %@ ",dctData);
        
        
        /// messageSubType = "messageTimeStamp-Update"
        
        NSString *strMyMaster = [[NSUserDefaults standardUserDefaults] stringForKey:@"MY_MASTER_TOPIC"];
        
        if([topic isEqualToString:strMyMaster]){ /// SYSTEM oneOneOne -  1***
            
            NSLog(@" $$$$ 1.1.1 NEW SYSTEM MESSAGE - ONE ON ONE : %@ ",dctData);
            
            ///*** If DELIVERED
            if([[dctData objectForKey:@"messageSubType"] isEqualToString:@"delivered"]){
                
                NSLog(@" $$$$ 1.1.1 NEW SYSTEM MESSAGE - ONE ON ONE - DELIVERED : %@ ",dctData);
                
                
                NSString *CurrentUnixTimeStamp =  [[Utils shared] GetCurrentEpochTime];
                MessageStatusModel *messageStatusModel = [[MessageStatusModel alloc]init];
                messageStatusModel.message_hash = [dctData objectForKey:@"messageHash"];
                
                NSLog(@" $$$$ 1.1.1 With MessageSubType = '%@' $$$$ ",[dctData objectForKey:@"messageSubType"]);
                NSLog(@" $$$$ 1.1.1 system message Payload = '%@' $$$$ ",dctData);
                
                NSLog(@" $$$$ IF SYSTEM MESSGAE(One on One) HAS A SUBTYPE 'delivered' THEN UPDATE STATUS DATABASE WITH DELIVERED TIMESTAMP ---> ");
                
                messageStatusModel.is_deliveredTimestamp = CurrentUnixTimeStamp;
                [[DatabaseHandler sharedDatabaseHandler] updateTopicMessageStatusTableForOneOnOne:messageStatusModel];
                NSLog(@"***** message Delivered(One on One) status will Insert now the model: %@ ******",messageStatusModel);
                
            }
            ///*** If READ BY RECEIVER
            else if([[dctData objectForKey:@"messageSubType"] isEqualToString:@"read_by_receiver"]){
                
                NSLog(@" $$$$ 1.1.1 NEW SYSTEM MESSAGE - ONE ON ONE - READ_BY_RECEIVER : %@ ",dctData);
                
                NSString *CurrentUnixTimeStamp =  [[Utils shared] GetCurrentEpochTime];
                MessageStatusModel *messageStatusModel = [[MessageStatusModel alloc]init];
                messageStatusModel.message_hash = [dctData objectForKey:@"messageHash"];
                
                
                NSLog(@" $$$$ 1.1.1 With MessageSubType = '%@' $$$$ ",[dctData objectForKey:@"messageSubType"]);
                NSLog(@" $$$$ 1.1.1 system message Payload = '%@' $$$$ ",dctData);
                
                NSLog(@" $$$$ IF SYSTEM MESSGAE(One on One) HAS A SUBTYPE 'read_by_receiver' THEN UPDATE STATUS DATABASE WITH THE TIMESTAMP ---> ");
                
                messageStatusModel.is_readByReceiverTimeStamp = CurrentUnixTimeStamp;
                [[DatabaseHandler sharedDatabaseHandler] updateTopicMessageStatusTableForOneOnOne:messageStatusModel];
                NSLog(@"***** message Read_BY_Receiver(One on One) status will Insert now the model: %@ ******",messageStatusModel);
                
            }
        } /// SYSTEM - ONE ON ONE
        else{ /// SYSTEM - group
            
            /// check if the group user exists and update the status for a perticular hash.
            /// so get all the users for a hash and update the respective Status
            
            NSLog(@" $$$$ 1.1.2 NEW SYSTEM MESSAGE - GROUP : %@ ",dctData);
            
            NSString *strFrom = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; //EXTERNAL_USER_ID or Username
            
            if(![[dctData objectForKey:@"messageFrom"] isEqualToString:strFrom]){
                
                NSLog(@" $$$$ 1.1.1 NEW SYSTEM MESSAGE -> GROUP -> messageFrom(%@) != myExtId(%@)is not me ",[dctData objectForKey:@"messageFrom"],strFrom);
                
                ////****
                // because when we send system messages back to a group, not just the other users, but even we receive it back so we need it ignore the system messages we only sent. and consider the ones sent by them only.
                
                if([[dctData objectForKey:@"messageSubType"] isEqualToString:@"delivered"]){
                    
                    NSLog(@" $$$$ 1.1.1 NEW SYSTEM MESSAGE -> GROUP -> DELIVERED : %@ ",dctData);
                    
                    
                    NSString *CurrentUnixTimeStamp =  [[Utils shared] GetCurrentEpochTime];
                    MessageStatusModel *messageStatusModel = [[MessageStatusModel alloc]init];
                    messageStatusModel.message_hash = [dctData objectForKey:@"messageHash"];
                    
                    NSLog(@" $$$$ 1.1.2 With MessageSubType = '%@' $$$$ ",[dctData objectForKey:@"messageSubType"]);
                    NSLog(@" $$$$ 1.1.2 DELIVERED system message Payload = '%@' $$$$ ",dctData);
                    NSLog(@" $$$$ IF SYSTEM MESSGAE(group) HAS A SUBTYPE 'delivered' THEN UPDATE STATUS DATABASE WITH THE TIMESTAMP ---> ");
                    
                    
                    messageStatusModel.user_id = [dctData objectForKey:@"messageFrom"];
                    messageStatusModel.is_deliveredTimestamp = CurrentUnixTimeStamp;
                    messageStatusModel.is_readByReceiverTimeStamp = @"";
                    
                    NSLog(@"***** message Delivered(Group) status will Insert now the model: %@ ******",messageStatusModel);
                    
                    [[DatabaseHandler sharedDatabaseHandler] updateTopicMessageStatusTableForGroupUser:messageStatusModel];
                    
                } /// Greoup = Delivered ***
                
                else if([[dctData objectForKey:@"messageSubType"] isEqualToString:@"read_by_receiver"]){
                    
                    NSLog(@" $$$$ 1.1.1 NEW SYSTEM MESSAGE -> GROUP -> read_by_receiver : %@ ",dctData);
                    
                    NSString *CurrentUnixTimeStamp1 =  [[Utils shared] GetCurrentEpochTime];
                    MessageStatusModel *messageStatusModel = [[MessageStatusModel alloc]init];
                    messageStatusModel.message_hash = [dctData objectForKey:@"messageHash"];
                    
                    
                    NSLog(@" $$$$ 1.1.2 With MessageSubType = '%@' $$$$ ",[dctData objectForKey:@"messageSubType"]);
                    NSLog(@" $$$$ 1.1.2 READ_BY_USER system message Payload = '%@' $$$$ ",dctData);
                    NSLog(@" $$$$ IF SYSTEM MESSAGE(group) HAS A SUBTYPE 'read_by_receiver' THEN UPDATE STATUS DATABASE WITH THE TIMESTAMP ---> ");
                    
                    messageStatusModel.user_id = [dctData objectForKey:@"messageFrom"];
                    messageStatusModel.is_readByReceiverTimeStamp = CurrentUnixTimeStamp1;
                    
                    NSLog(@"****read_by_receiver time = %@ ",CurrentUnixTimeStamp1);
                    NSLog(@"**** StatusModel read_by_receiver time = %@ ",messageStatusModel.is_readByReceiverTimeStamp);
                    
                    
                    [[DatabaseHandler sharedDatabaseHandler] updateTopicMessageStatusTableForGroupUser:messageStatusModel];
                    NSLog(@"***** message read_by_receiver(Group) status will Insert now the model: %@ ******",messageStatusModel);
                    
                }
            }
            
            else{
                
                NSLog(@" $$$$ SYSTEM MESSAGE IGNORED!!!! -> GROUP -> messageFrom(%@) == myExtId(%@) ",[dctData objectForKey:@"messageFrom"],strFrom);
                
            }
        }//*** System Msg for Group
    }
    else{
        
        NSLog(@" $$$$ !!! messageSubType = 'messageTimeStamp-Update' Ignored :) !!!! data: %@ ",dctData);
        
    }
}

#pragma mark - Sync multiple users
-(void)getUserListForExternalIDs:(NSArray *)usersList getUserSuccessListenerBlock:(getUserSuccessListenerBlock)successBlock andErrorListenerBlock:(errorListenerBlock)failureBlock {
  
  [[DownloadManager shared] getUserListForExternalIDs:usersList getUserSuccessListenerBlock:^(NSError *error, NSArray *usersList) {
    //Success block
    successBlock(nil,usersList);
  } andErrorListenerBlock:^(NSError *error) {
    //Failure block
    failureBlock(error);
  }];
  
}

+(void) destroyInstance {
  sttarterCommunicatorClass = nil;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Spurtee.SttarterCoredataApp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.Spurtee.Sttarter"];
    NSURL *modelURL = [bundle URLForResource:@"Sttarter" withExtension:@"momd"];
    
    
    // NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"STTarterModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    
    @synchronized (self) {//opop
        
        // Create the coordinator and store
        if (_persistentStoreCoordinator == nil) {
            
            _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
            NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Sttarter.sqlite"];
            NSError *error = nil;
            NSString *failureReason = @"There was an error creating or loading the application's saved data.";
            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])  {
                // Report any error we got.
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
                dict[NSLocalizedFailureReasonErrorKey] = failureReason;
                dict[NSUnderlyingErrorKey] = error;
                error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
                // Replace this with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
              if([[Utils shared] environmentTag] == 0){
                abort();
              }
            }
        }
    }
    
    return _persistentStoreCoordinator;
}



- (NSManagedObjectContext *)managedObjectContext {
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {//opop
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    NSLog(@"managedObjectContext %@", _managedObjectContext);
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
          if([[Utils shared] environmentTag] == 0){
            abort();
          }
        }
    }
}



@end
