//
//  DatabaseHandler.m
//  Sttarter
//
//  Created by Prajna Shetty on 07/11/16.
//  Copyright © 2016 Spurtree. All rights reserved.
//

#import "DatabaseHandler.h"
#import "MessagesModel.h"
#import <CoreData/CoreData.h>
#import "TopicMessageDetail.h"
#import "TopicsModel.h"
#import "STTaterCommunicator.h"
#import "MessageStatusModel.h"
#import "TopicMessageEntity+CoreDataClass.h"
#import "TopicMessageDetailEntity+CoreDataClass.h"

@implementation DatabaseHandler


static DatabaseHandler* _databaseHandler = nil;

+(DatabaseHandler*)sharedDatabaseHandler
{
    
    @synchronized([DatabaseHandler class])
    {
        if (!_databaseHandler)
            _databaseHandler = [[self alloc] init];
        
        return _databaseHandler;
    }
    return nil;
    
}

#pragma mark - Messages
//-(void)updateMessage:(MessagesModel *)messagesModel{
//
//    NSManagedObjectContext *moc = [[SttarterClass sharedSttarterClass] managedObjectContext];
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Messages"];
//
//    NSString *timeStamp = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.timestamp];
//    NSString *from = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.from];
//    NSString *file_type =[[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.file_type];
//    NSString *file_url = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.file_url];
//    NSString *_id = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel._id] ;
//    NSString *type = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.type];
//    NSString *message_topic_id = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.message_topic_id];
//    NSString *is_Sender = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.is_Sender];
//    NSString *is_delivered = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.is_delivered];
//    NSString *is_read = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.is_read];
//    NSString *message_hash = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.message_hash];
//    NSString *unix_timestamp = [[DatabaseHandler sharedDatabaseHandler] validateString:messagesModel.unix_timestamp] ;

//    MessagePayloadModel *payload = (MessagePayloadModel *) messagesModel.payload;
//    NSString *title = [[DatabaseHandler sharedDatabaseHandler] validateString:payload.title];
//    NSString *topic =[[DatabaseHandler sharedDatabaseHandler] validateString:payload.topic] ;
//    NSString *message = payload.message;
//
//    [request setPredicate:[NSPredicate predicateWithFormat:@"topic == %@", topic]];
//
//    NSError *error = nil;
//    NSArray *results = [moc executeFetchRequest:request error:&error];
//    if (error != nil) {
//        if (results.count != 0) {updateNotificationCount

//
//            Messages *object = [results objectAtIndex:0];
//            [object setValue:timeStamp forKey:object.message_timestamp];
//            [object setValue:from forKey:object.message_from];
//            [object setValue:file_type forKey:object.file_type];
//            [object setValue:file_url forKey:object.file_url];
//            [object setValue:payload.description forKey:object.payload];
//            [object setValue:title forKey:object.title];
//            [object setValue:topic forKey:object.topic];
//            [object setValue:message forKey:object.message];
//
//            NSError *error;
//            if (![moc save:&error]) {
//                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
//            }
//        }
//    }
//}

-(NSArray *)getMessages:(NSString *)topicValue{
    
    NSManagedObjectContext *moc = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Messages"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"topic == %@", topicValue]];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching Messages objects: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return results;
}

-(void)deleteMessage:(NSString *)topicValue{
    
    NSManagedObjectContext *moc = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Messages"];
    NSError *error = nil;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_8_0) {
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"topic == %@", topicValue]];
        
        NSFetchRequest *allmessages = [[NSFetchRequest alloc] init];
        [allmessages setEntity:[NSEntityDescription entityForName:@"Messages" inManagedObjectContext:moc]];
        [allmessages setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        
        NSArray *messages = [moc executeFetchRequest:allmessages error:&error];
        //error handling goes here
        for (NSManagedObject *message in messages) {
            [moc deleteObject:message];
        }
        
        if (![moc save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        }
    }else{
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"topic == %@", topicValue]];
        
        NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        
        NSError *deleteError = nil;
        [[STTaterCommunicator sharedCommunicatorClass].persistentStoreCoordinator executeRequest:delete withContext:moc error:&deleteError];
    }
}



#pragma mark - Topics


-(void)updateNotificationCount:(NSString*)strTopicId NotificationCount:(NSString*)count isRead:(NSString*)strRead LastMessage:(NSString*)strLastMessage {
    
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topics"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"topic_id == %@",strTopicId]];
    
    NSError *error = nil;
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    if (error == nil) {
        
        if (results.count >= 1) {
            
            Topics *object = [results objectAtIndex:0]; // will anyway have one item in the array
            object.topic_NotificationCount = count;
            //            object.topic_isMessageRead = strRead;
            
            if(![strLastMessage isEqualToString:@""] ){
                object.topic_LastReceivedMessage = strLastMessage;
            }
            
            //            [contextUpdate save:nil];
            
            NSError *error1;
            if (![contextUpdate save:&error1]) {
                NSLog(@"dB Topics Failed to save UPDATE - error: %@", [error localizedDescription]);
            }
            //            NSLog(@"Updated Is MessageRead = 'topic_isMessageRead':'%@' ******",object.topic_isMessageRead);
        }
    }
    
}
#pragma mark - ** MQTT_Queue Table **


-(void)AddToMQTT_Queue:(MQTT_QueueModel *)MQTTQueueModel{
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"MQTT_Queue"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"mqttQueue_MessageHash == %@", MQTTQueueModel.hash]];
    
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    if (error == nil) {
        
        if (results.count == 0) {  /// insert - if hash doesnot exist
            
            NSManagedObjectContext *contextInsert = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
            
            MQTT_Queue *object = [NSEntityDescription insertNewObjectForEntityForName:@"MQTT_Queue"
                                                               inManagedObjectContext:contextInsert];
            object.mqttQueue_Topic = MQTTQueueModel.topic;
            
            if ([MQTTQueueModel.payLoad isKindOfClass:[NSDictionary class]]) {
                NSData *data = nil;
                data = [NSKeyedArchiver archivedDataWithRootObject:MQTTQueueModel.payLoad];
                object.mqttQueue_PayloadData = data;
            }
            
            object.mqttQueue_MessageHash = MQTTQueueModel.MessageHash;
            
            //            [contextInsert save:nil];
            NSLog(@"*****INSERTED for mqttQueue_PayloadData :'%@' ******",object.mqttQueue_PayloadData);
            NSLog(@"*****INSERTED 'mqttQueue_MessageHash':'%@' ******",object.mqttQueue_MessageHash);
            
            NSError *error1;
            if (![contextInsert save:&error1]) {
                NSLog(@"*** dB Messages failed to save INSERTED values in MQTT_Queue - error: ' %@ ' ***", [error1 localizedDescription]);
            }
            
        }
        
    }
}

/// USED
-(void)RetiveMQTT_Queue{
    
    
    NSLog(@"** MQTT_Queue:4.1.1 Send the Queued messages on reconnecting to internet. **");
    
    
    NSManagedObjectContext *moc = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MQTT_Queue" inManagedObjectContext:moc];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    
    
    if (results.count>=1) {
        
        for(int i=0;i<results.count;i++){
            
            MQTT_Queue *object = [results objectAtIndex:i];
            
            /// check internet, if yes then send and delete else skip
            BOOL isReachable = [[Utils shared] checkIfInternetConnectionExists];
            if(isReachable == TRUE){
                
                NSDictionary *dctMeta =[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)object.mqttQueue_PayloadData];
                
                NSLog(@"** MQTT_Queue:1 Publish stored dct:%@ **",dctMeta);
                
                
                TopicMessageDetail *detailModel = [[TopicMessageDetail alloc]init];
                detailModel.messageFrom = [dctMeta objectForKey:@"messageFrom"];
                detailModel.messageType = [dctMeta objectForKey:@"messageType"];
                detailModel.messageSubType = [dctMeta objectForKey:@"messageSubType"];
                detailModel.messageHash = [dctMeta objectForKey:@"messageHash"];
                detailModel.messageFileURL =[dctMeta objectForKey:@"messageFileURL"];
                detailModel.messageFileType =[dctMeta objectForKey:@"messageFileType"];

                NSLog(@"** MQTT_Queue:1 Publish stored dct as Model:%@ **",detailModel);

                [[STTaterCommunicator sharedCommunicatorClass]SttarterClassPublishTopic:object.mqttQueue_Topic withData:detailModel];

                /// 1. publish already saved message
                
                
//                [[STTaterCommunicator sharedCommunicatorClass]SttarterClassPublishTopic:object.mqttQueue_Topic messagehash:object.mqttQueue_MessageHash strData:dctMeta];//POIU
                
                /// EROOOOORRRRRRRRR : Instead of getting Updated, it is getting added.!!!!
                
                NSLog(@"** MQTT_Queue:2 Update timestamp in messages dB**");
                NSLog(@"*** MQTT_Queue:2.1 update MSG DB with Hash : %@ ***",object.mqttQueue_MessageHash);
                /// 2. Update timestamp of already saved message
                NSString *CurrentUnixTimeStamp =  [[Utils shared] GetCurrentEpochTime];;
                
                TopicMessageDetail *messaeDetail = [[TopicMessageDetail alloc]init];
                messaeDetail.messageHash =object.mqttQueue_MessageHash;
                messaeDetail.messageTimeStamp = CurrentUnixTimeStamp;
                
                TopicMessage *messagemodel = [[TopicMessage alloc]init];
                messagemodel.message =messaeDetail;
                
                NSLog(@"** MQTT_Queue:2.2 print 'TopicMessage' Model : %@ **",messagemodel);
                
                [self updateMessagesDatabase:messagemodel];
                
                NSLog(@"** MQTT_Queue:3 Delete row **");
                /// 3.  Delete that Row from Queue
                [self deleteMqttQueuedRow:object.mqttQueue_MessageHash];
                
            }
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshUI_Notification" object:self userInfo:nil];
        
        
    }
    
    else{
        
        NSLog(@"Error fetching MQTT_Queue objects: %@\n%@", [error localizedDescription], [error userInfo]);
        
        
    }
    
    
}


-(void)deleteMqttQueuedRow:(NSString*)strHash{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"MQTT_Queue"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mqttQueue_MessageHash == %@",strHash];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];//Get your ManagedObjectContext;
    if (managedObjectContext != nil) {///opop
        NSArray *result = [managedObjectContext executeFetchRequest:request error:&error];
        
        if (!error && result.count > 0) {
            
            for(NSManagedObject *managedObject in result){
                [managedObjectContext deleteObject:managedObject];
            }
            //            [managedObjectContext save:nil];
        }
        NSLog(@"** MQTT_Queue:4 After deleting a row %@", result);
    }
}




#pragma mark - ** MessageStatus DATABASE **


/// ** MESSAGES SENT - DOUBLE TICK and BLUE TICK **


-(void)UpdateDeliverdAndReadByReceiverStatus:(MessageStatusModel *)messageStatusModel{
    /// check if the particular hash has timestamp for all users(one user - one on one)(all users - group) - If yes then set it in the MESSAGES db for same hash --->
    
    
    /// DB Restructure - DONE
    NSLog(@" $$$$ 1.1.3 we check if the particular hash has timestamp for all users(check all users - group)(check one user - one on one) - If yes then set it in the MESSAGES db for same hash --->");
    
    
    NSString *strIsDelivered = @"";
    NSString *strIsReadByTheReceiver = @"";
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TopicMessageStatusEntity"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"message_hash == %@",messageStatusModel.message_hash];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    /// result will have one eliment if oneOneOne else it if it is groups, then many users will be there.
    
    if(results.count != 0){
        
        NSLog(@" $$$$ 1.1.3 result count = %lu objects for a perticular hash in status dB and array = %@ ->",(unsigned long)results.count,results);
        
        
        /// for is_delivered Status
        for(int i=0 ; i<= results.count-1 ;i++){
            TopicMessageStatusEntity *object = [results objectAtIndex:i];
            
            if(object.is_delivered == nil){
                strIsDelivered = @"";/// for group
                break;
            }
            else{
                if(messageStatusModel.is_deliveredTimestamp != nil){
                    strIsDelivered = messageStatusModel.is_deliveredTimestamp;
                    
                    NSLog(@"^^^^DELIVERED user:%@ has --NOT-- Read the message :%@ with hash :%@ ",object.topicMessageDetail.messageFrom,object.topicMessageDetail.messageText,object.topicMessageDetail.messageHash );
                    
                }
            }
        }
        /// !@#$%^
        /// for is_readByTheReceiver Status loop through
        for(int i=0 ; i<= results.count-1 ;i++){
            TopicMessageStatusEntity *object =(TopicMessageStatusEntity*)[results objectAtIndex:i];//TopicMessageStatusEntity
            
            if(object.is_readByTheReceiver == nil){
                strIsReadByTheReceiver = @"";
                
                NSLog(@"^^^^READ user:%@ has --NOT-- Read the message :%@ with hash :%@ ",object.topicMessageDetail.messageFrom,object.topicMessageDetail.messageText,object.topicMessageDetail.messageHash );
                
                break;
            }
            else{
                if(messageStatusModel.is_readByReceiverTimeStamp != nil){
                    strIsReadByTheReceiver = messageStatusModel.is_readByReceiverTimeStamp;
                    NSLog(@"^^^^READ user:%@ has Read the message :%@ with hash :%@ ",object.topicMessageDetail.messageFrom,object.topicMessageDetail.messageText,object.topicMessageDetail.messageHash );
                }
            }
        }
        
    }
    
    NSLog(@" $$$$ 1.1.3 with readByReceiverTimestamp = '%@'  and delivered TimeStamp = '%@'--->",strIsReadByTheReceiver,strIsDelivered);
    
    
    if(![strIsDelivered isEqualToString:@""] || ![strIsReadByTheReceiver isEqualToString:@""]){
        
        NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"TopicMessageDetailEntity"];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"messageHash == %@",messageStatusModel.message_hash];
        [request1 setPredicate:predicate1];
        
        NSError *error1 = nil;
        NSManagedObjectContext *contextUpdate1 = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
        NSArray *results1 = [contextUpdate1 executeFetchRequest:request1 error:&error1];
        
        /// result will have one eliment if oneOneOne else if it is groups, then many users will be there.
        
        NSLog(@" $$$$ 1.1.3 Print the Array object for the Hash to update the final timestamp values : %@",results1);
        if(results1.count != 0){
            
            
            TopicMessageDetailEntity  *msgDbdetailObject = [results1 objectAtIndex:0];
            
            NSLog(@" BEFORE msgDbObject.message_deliveredTime : %@",msgDbdetailObject.isDelivered);
            NSLog(@" BEFORE msgDbObject.message_readByTheReceiverTime : %@ For hash =  %@",msgDbdetailObject.isReadBytheReceiver, msgDbdetailObject.messageHash);
            
            if(![strIsDelivered isEqualToString:@""]){
                
                if(msgDbdetailObject.isDelivered == nil){
                    msgDbdetailObject.isDelivered = strIsDelivered ;
                }
                
            }
            if(![strIsReadByTheReceiver isEqualToString:@""]){
                if(msgDbdetailObject.isReadBytheReceiver == nil){
                    msgDbdetailObject.isReadBytheReceiver = strIsReadByTheReceiver ;
                }
            }
            
            //[contextUpdate1 save:nil];
            
            NSError *error2;
            if (![contextUpdate1 save:&error2]) {
                NSLog(@"*** dB Messages db status updation failed with error: ' %@ ' ***", [error2 localizedDescription]);
            }
            NSLog(@"------ DB Restructure -------");
            
            NSLog(@" $$$$$ 1.1.3 print final 'DELIVERED' timestamp : %@",strIsDelivered);
            NSLog(@" $$$$$ 1.1.3 print final 'IS_READ_BY_RECEIVER' timestamp  : %@",strIsReadByTheReceiver);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshUI_Notification" object:self userInfo:nil];
            
        }
        
    }
}


-(void)updateWithSystemTimeStamp:(NSString*)strTimeStamp forHash:(NSString*)strHash{
    
    /// DB Restructure - DONE
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TopicMessageDetailEntity"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"messageHash == %@", strHash]];
    
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    if (error == nil) {
        
        if (results.count != 0)
        {
            
            TopicMessageDetailEntity *object = [results objectAtIndex:0];
            // will anyway have one item in the array.
            // Update only timestamp, isRead, Delivered.
            
            if(strTimeStamp!=nil){
                object.messageTimeStamp = strTimeStamp;
            }
            //            [contextUpdate save:nil];
            
            NSError *error;
            if (![contextUpdate save:&error]) {
                NSLog(@"Messages dB Failed to save UPDATE - error: %@", [error localizedDescription]);
            }
            
            NSLog(@"------ DB Restructure -------");
            
            NSLog(@"$$$$ 1.1.4 UPDATED Message dB with SystemTimestamp :%@ for hash: %lu and text: %@ ***** ",object.messageTimeStamp,(unsigned long)object.hash,object.messageText);
            
        }
    }
}



-(void)updateTopicMessageStatusTableForGroupUser:(MessageStatusModel *)messageStatusModel{
    /// check if message already exists , if yes thn update it else add (Using hash).
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TopicMessageStatusEntity"];
    
    NSString *PredString1 = [NSString stringWithFormat:@"message_hash == '%@' AND topic_user_id == '%@'",messageStatusModel.message_hash,messageStatusModel.user_id];
    [request setPredicate:[NSPredicate predicateWithFormat:PredString1]];
    
    
    
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    
    if (error == nil) {
        
        if (results.count == 0) {  // insert
            
            NSManagedObjectContext *contextInsert = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
            
            TopicMessageStatusEntity *objects = [NSEntityDescription insertNewObjectForEntityForName:@"TopicMessageStatusEntity"
                                                                              inManagedObjectContext:contextInsert];
            if(messageStatusModel.message_hash != nil){
                
                objects.message_hash = messageStatusModel.message_hash;
                
                if(messageStatusModel.user_id != nil){
                    objects.topic_user_id = messageStatusModel.user_id;
                }
                if(messageStatusModel.is_deliveredTimestamp != nil || ![messageStatusModel.is_deliveredTimestamp isEqualToString:@""]){
                    objects.is_delivered = messageStatusModel.is_deliveredTimestamp;
                }
                if(messageStatusModel.is_readByReceiverTimeStamp != nil || ![messageStatusModel.is_readByReceiverTimeStamp isEqualToString:@""]){
                    
                    objects.is_readByTheReceiver =  messageStatusModel.is_readByReceiverTimeStamp;
                    NSLog(@" ^^^^is_readByReceiverTimeStamp updated for Group user =  %@ and hash = %@^^^",messageStatusModel.user_id,messageStatusModel.message_hash);
                }
                
                //                [contextInsert save:nil];
                
                //@#@#@#@#@
                [contextInsert performBlockAndWait:^{
                    NSError *error;
                    
                    if (![contextInsert save:&error]) {
                        NSLog(@"*** dB Messages failed to save INSERTED values in MessageStatusDB- error: ' %@ ' ***", [error localizedDescription]);
                    }
                }];
                
            }
            
        }
        else{
            
            
            /// update the contents for that perticular hash.
            /// gets called during getMessage APi call, send messages
            
            TopicMessageStatusEntity *object = [results objectAtIndex:0];
            /// will anyway have one item in the array.
            
            if(messageStatusModel.message_hash != nil){
                
                object.message_hash = messageStatusModel.message_hash;
                
                if(messageStatusModel.user_id != nil){
                    object.topic_user_id = messageStatusModel.user_id;
                }
                if(messageStatusModel.is_deliveredTimestamp != nil || ![messageStatusModel.is_deliveredTimestamp isEqualToString:@""]){
                    if(object.is_delivered.length == 0){
                        object.is_delivered = messageStatusModel.is_deliveredTimestamp;
                    }
                }
                if(messageStatusModel.is_readByReceiverTimeStamp != nil || ![messageStatusModel.is_readByReceiverTimeStamp isEqualToString:@""]){
                    if(object.is_readByTheReceiver.length == 0){
                        object.is_readByTheReceiver =  messageStatusModel.is_readByReceiverTimeStamp;
                    }
                }
            }
            
            //            [contextUpdate save:nil];
            [contextUpdate performBlockAndWait:^{
                NSError *error;
                if (![contextUpdate save:&error]) {
                    NSLog(@"Messages dB Failed to save UPDATE - error: %@", [error localizedDescription]);
                }
            }];
        }
        
        //updateTopicMessageStatusTableForGroupUser
        if(messageStatusModel.is_readByReceiverTimeStamp != nil || messageStatusModel.is_deliveredTimestamp != nil){
            
            
            [self UpdateDeliverdAndReadByReceiverStatus:messageStatusModel]; /// updates the message dB with the FINAL delivered and readByReceiver timestamp
        }
        
    }
    
}


-(void)updateTopicMessageStatusTableForOneOnOne:(MessageStatusModel *)messageStatusModel{
    
    NSLog(@"***** MESSAGES STATUS DATABASE with MessageHash :%@***",messageStatusModel.message_hash);
    
    
    
    /// check if message already exists , if yes thn update it else add (Using hash).
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TopicMessageStatusEntity"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"message_hash == %@", messageStatusModel.message_hash]];
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    
    if (error == nil) {
        
        if (results.count == 0) {  // insert
            
            NSManagedObjectContext *contextInsert = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
            
            TopicMessageStatusEntity *objects = [NSEntityDescription insertNewObjectForEntityForName:@"TopicMessageStatusEntity"
                                                                              inManagedObjectContext:contextInsert];
            
            if(messageStatusModel.message_hash != nil){
                
                objects.message_hash = messageStatusModel.message_hash;
                
                if(messageStatusModel.user_id != nil){
                    objects.topic_user_id = messageStatusModel.user_id;
                }
                if(messageStatusModel.is_deliveredTimestamp != nil || ![messageStatusModel.is_deliveredTimestamp isEqualToString:@""]){
                    objects.is_delivered = messageStatusModel.is_deliveredTimestamp;
                }
                if(messageStatusModel.is_readByReceiverTimeStamp != nil || ![messageStatusModel.is_readByReceiverTimeStamp isEqualToString:@""]){
                    objects.is_readByTheReceiver =  messageStatusModel.is_readByReceiverTimeStamp;
                }
                
                //                [contextInsert save:nil];
                
                NSError *error;
                if (![contextInsert save:&error]) {
                    NSLog(@"*** dB Messages failed to save INSERTED values in MessageStatusDB- error: ' %@ ' ***", [error localizedDescription]);
                }
                
            }
            
            if(messageStatusModel.is_readByReceiverTimeStamp != nil || messageStatusModel.is_deliveredTimestamp != nil){
                
                ///
                NSLog(@"$$$$ 1.1.3 IF THE SYSTEM MESSAGE (One On One) is a valid delivery or read report then go ahead and update the timesstamp in MESSAGES dB ");
                
                [self UpdateDeliverdAndReadByReceiverStatus:messageStatusModel];
            }
            
        }
        else{ // update the contents for that perticular hash.
            
            /// gets called during getMessage APi call, send messages
            
            
            TopicMessageStatusEntity *object = [results objectAtIndex:0];
            /// will anyway have one item in the array.
            
            NSLog(@"***** UPDATE Message STATUS dB with Hash %@ ***** ",messageStatusModel.message_hash);
            
            if(messageStatusModel.message_hash != nil){
                
                object.message_hash = messageStatusModel.message_hash;
                
                if(messageStatusModel.user_id != nil){
                    object.topic_user_id = messageStatusModel.user_id;
                }
                if(messageStatusModel.is_deliveredTimestamp != nil || ![messageStatusModel.is_deliveredTimestamp isEqualToString:@""]){
                    
                    if(object.is_delivered == nil){
                        object.is_delivered = messageStatusModel.is_deliveredTimestamp;
                    }
                    
                }
                
                if(messageStatusModel.is_readByReceiverTimeStamp != nil || ![messageStatusModel.is_readByReceiverTimeStamp isEqualToString:@""]){
                    
                    if(object.is_readByTheReceiver == nil){
                        object.is_readByTheReceiver =  messageStatusModel.is_readByReceiverTimeStamp;
                    }
                    
                }
            }
            
            //            [contextUpdate save:nil];
            
            
            NSLog(@"$$$$ UPDATED into Status dB for (OneOnOne) message_hash :'%@' ******",object.message_hash);
            NSLog(@"$$$$ UPDATED into Status dB for (OneOnOne) topic_user_id :'%@' ******",object.topic_user_id);
            NSLog(@"$$$$ UPDATED into Status dB for (OneOnOne) is_deliveredTimestamp :'%@' ******",object.is_delivered);
            NSLog(@"$$$$ UPDATED into Status dB for (OneOnOne) is_readByTheReceiver :'%@' ******",object.is_readByTheReceiver);
            NSError *error;
            if (![contextUpdate save:&error]) {
                NSLog(@"Messages dB Failed to save UPDATE - error: %@", [error localizedDescription]);
            }
            
            
            if(messageStatusModel.is_readByReceiverTimeStamp != nil || messageStatusModel.is_deliveredTimestamp != nil){
                
                ///
                NSLog(@"$$$$ 1.1.3 IF THE SYSTEM MESSAGE (One On One) is a valid delivery or read report then go ahead and update the timesstamp in MESSAGES dB ");
                
                [self UpdateDeliverdAndReadByReceiverStatus:messageStatusModel];
            }
        }
        
    }
    
}


/// ** MESSAGES SENT - clock and singlr tick **

-(void)updateMessageSentStatus:(NSString*)strMessageHash withTimestamp:(NSString*)strTimestamp ///!@!@!
{
    /// DB Restructure - DONE
    NSLog(@"***** MESSAGES updateMessageSentStatus with MessageHash:%@***",strMessageHash);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TopicMessageDetailEntity"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"messageHash == %@", strMessageHash]];
    
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    if (error == nil) {
        if (results.count != 0) {
            
            TopicMessageDetailEntity *object = [results objectAtIndex:0];
            /// will anyway have one item in the array.
            /// Update only timestamp
            
            NSLog(@"***** UPDATE Message dB with Hash %@ ***** ",strMessageHash);
            
            NSLog(@"***** is_sent : %@ in dB ***** ",strTimestamp);
            
            if(strTimestamp!=nil || strTimestamp.length >= 1){
                object.topicMessage.is_sent = strTimestamp;
            }
            else{
                object.topicMessage.is_sent = nil;
            }
            
            //            [contextUpdate save:nil];
            
            
            //     NSLog(@"$$$$ Updated messages databasw with Sent TimeStamp ",object.is_sent,object.message_hash);
            
            NSLog(@"###### UPDATED is_Sent with timestamp:%@ for 'message_hash' :'%@' ######",object.topicMessage.is_sent,object.messageHash);
            
            
            [contextUpdate performBlockAndWait:^{
                NSError *error;
                
                if (![contextUpdate save:&error]) {
                    NSLog(@"Messages dB Failed to save UPDATE - error: %@", [error localizedDescription]);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshUI_Notification" object:self userInfo:nil];
            }];
        }
    }
}






#pragma mark - ** MESSAGES DATABASE **

//-(void)deleteAllMessages{
//    
//    NSLog(@"***** DELETED MESSAGES TABLE **** ");
//    NSManagedObjectContext *moc = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:moc];
//    [fetchRequest setEntity:entity];
//    
//    NSError *error;
//    NSArray *items = [moc executeFetchRequest:fetchRequest error:&error];
//    
//    
//    for (NSManagedObject *managedObject in items) {
//        [moc deleteObject:managedObject];
//    }
//    if (![moc save:&error]) {
//        NSLog(@"Error deleting %@ - error:%@",kSecAttrDescription,error);
//    }
//}

#pragma mark - ** MESSAGES  - T A B L E  **

/// check if message already exists , if not thn update it else add (Using hash).
/// ** IMP **

-(void)updateMessagesDatabase:(TopicMessage *)topicmessageModel{ ////!@!@!@
    
    /// DB Restructure - DONE   // TopicMessageEntity --> TopicMessageDetailEntity
    
    NSLog(@"***** MESSAGES DATABASE with MessageHash :%@***",topicmessageModel.message.messageHash);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TopicMessageDetailEntity"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"messageHash == %@", topicmessageModel.message.messageHash]];
    
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    if (error == nil) {
        
        if (results.count == 0) {  // insert - hash doesnot exist
            
            NSManagedObjectContext *contextInsert = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
            
            /// TOPIC_MESSAGE
            
            TopicMessageEntity *topicMessageEntityObject = [NSEntityDescription insertNewObjectForEntityForName:@"TopicMessageEntity"
                                                                                         inManagedObjectContext:contextInsert];
            
            topicMessageEntityObject.is_Read = topicmessageModel.str_IsRead;
            topicMessageEntityObject.is_sender = topicmessageModel.is_sender;
            topicMessageEntityObject.topic = topicmessageModel.topic;
            topicMessageEntityObject.is_sent = topicmessageModel.is_sent;
            
            TopicMessageDetailEntity *topicMessageDetailEntityObj = [NSEntityDescription insertNewObjectForEntityForName:@"TopicMessageDetailEntity" inManagedObjectContext:contextInsert];
            
            topicMessageDetailEntityObj.messageFrom = topicmessageModel.message.messageFrom;
            topicMessageDetailEntityObj.messageHash = topicmessageModel.message.messageHash;
            topicMessageDetailEntityObj.messageText = topicmessageModel.message.messageText;
            topicMessageDetailEntityObj.messageTypes = topicmessageModel.message.messageType;
            topicMessageDetailEntityObj.messageFileType = topicmessageModel.message.messageType;

            topicMessageDetailEntityObj.messageFileURL = topicmessageModel.message.messageFileURL;
            topicMessageDetailEntityObj.messageSubType = topicmessageModel.message.messageSubType;
            
            if(topicmessageModel.message.messageTimeStamp != nil && ![topicmessageModel.message.messageTimeStamp isEqualToString:@""]){
                topicMessageDetailEntityObj.messageTimeStamp = topicmessageModel.message.messageTimeStamp;
            }
            else if(topicmessageModel.message.messageReadByReceiverTimeStamp != nil && ![topicmessageModel.message.messageReadByReceiverTimeStamp isEqualToString:@""]){
                topicMessageDetailEntityObj.isReadBytheReceiver = topicmessageModel.message.messageReadByReceiverTimeStamp ;
            }
            
            if(topicmessageModel.message.messageDeliveredTimeStamp !=nil && ![topicmessageModel.message.messageDeliveredTimeStamp isEqualToString:@""]){
                topicMessageDetailEntityObj.isDelivered = topicmessageModel.message.messageDeliveredTimeStamp;
            }
            
            topicMessageEntityObject.topicMessageDetail = topicMessageDetailEntityObj;
            
            [contextInsert performBlockAndWait:^{
                NSError *error;
                if (![contextInsert save:&error]) {
                    NSLog(@"*** dB Messages failed to save INSERTED values - error: ' %@ ' ***", [error localizedDescription]);
                }
            }];
            
            
        }
        else{ /// update the contents for that perticular  message hash.
            
            /// gets called during getMessage APi call, send messages
            
            TopicMessageDetailEntity *detailObject = (TopicMessageDetailEntity*)[results firstObject];
            
            ///    TopicMessageEntity *object = [results objectAtIndex:0];
            /// will anyway have one item in the array.
            /// Update only timestamp, isRead, Delivered.
            
            
            if(topicmessageModel.message.messageTimeStamp!=nil && ![topicmessageModel.message.messageTimeStamp isEqualToString:@""]){
                detailObject.messageTimeStamp = topicmessageModel.message.messageTimeStamp;
            }
            
            if(topicmessageModel.is_sender!=nil){
                detailObject.topicMessage.is_sender = topicmessageModel.is_sender;
            }
            if(topicmessageModel.topic!=nil){
                detailObject.topicMessage.topic = topicmessageModel.topic;
            }
            
            
            if(topicmessageModel.message.messageReadByReceiverTimeStamp !=nil && ![topicmessageModel.message.messageReadByReceiverTimeStamp isEqualToString:@""]){
                detailObject.isReadBytheReceiver = topicmessageModel.message.messageReadByReceiverTimeStamp ;
            }
            if(topicmessageModel.message.messageDeliveredTimeStamp !=nil && ![topicmessageModel.message.messageDeliveredTimeStamp isEqualToString:@""]){
                detailObject.isDelivered = topicmessageModel.message.messageDeliveredTimeStamp;
            }
            
            
            [contextUpdate performBlockAndWait:^{
                NSError *error;
                if (![contextUpdate save:&error]) {
                    NSLog(@"Messages dB Failed to save UPDATE - error: %@", [error localizedDescription]);
                }
            }];

        }
    }
    
}



-(NSArray *)getAllMessages{ //
    
    /// "**** NEW DB : fetches all the messages for the demo user.
    
    NSManagedObjectContext *moc = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TopicMessageEntity" inManagedObjectContext:moc];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"topicMessageDetail.messageTimeStamp" ascending:YES];
    //topicMessageDetail.@max.messageTimeStamp
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    // Optionally add a sort descriptor too
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    
    ///
    
    NSLog(@"**** NEW DB getAllMessages count :%lu ****",(unsigned long)results.count);
    
    if (!results) {
        NSLog(@"Error fetching Messages objects: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return results;
    
    
}



#pragma mark - ** TOPIC DATABASE **

//-(void)deleteAllTopics  { //
//    
//    NSManagedObjectContext *moc = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
//    //TopicMessageDetailEntity
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Topics" inManagedObjectContext:moc];
//    [fetchRequest setEntity:entity];
//    
//    NSError *error;
//    NSArray *items = [moc executeFetchRequest:fetchRequest error:&error];
//    
//    
//    for (NSManagedObject *managedObject in items) {
//        [moc deleteObject:managedObject];
//    }
//    if (![moc save:&error]) {
//        NSLog(@"Error deleting %@ - error:%@",kSecAttrDescription,error);
//    }
//    
//    NSLog(@"***** DELETED TOPICS TABLE **** ");
//    
//}


//-(void)deleteAllMQTTQueuedData  {
//    
//    NSManagedObjectContext *moc = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MQTT_Queue" inManagedObjectContext:moc];
//    [fetchRequest setEntity:entity];
//    
//    NSError *error;
//    NSArray *items = [moc executeFetchRequest:fetchRequest error:&error];
//    
//    
//    for (NSManagedObject *managedObject in items) {
//        [moc deleteObject:managedObject];
//    }
//    if (![moc save:&error]) {
//        NSLog(@"Error deleting %@ - error:%@",kSecAttrDescription,error);
//    }
//    
//    NSLog(@"***** DELETED MQTT_Queue TABLE **** ");
//    
//}


#pragma mark - ** Update isRead in Messages and Topics**
///USED

-(void)updateIsReadInMessagesDb:(NSString*)strTopic isRead:(NSString*)isRead{
    
    // RECERVER'S PERSPECTIVE.

    NSLog(@"***** Read_Message_DB_check : Method entered ******");
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TopicMessageEntity"];
    
    // unread messages,sent by them.
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:
                              @"topic = %@ and is_Read = %@ and is_sender = %@",strTopic,@"FALSE",@"FALSE"];
    NSArray *results;
    NSError *error = nil;
    results = [[[STTaterCommunicator sharedCommunicatorClass]managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (results) {
        if ([results count]) {
            
            NSLog(@"***** Read_Message_DB_check Count:%ld ******",(unsigned long)results.count);
            
            
            NSMutableArray *arrMsgHash = [[NSMutableArray alloc]init];
            
            for(int i=0 ; i<results.count ; i++){
                
                TopicMessageEntity *objectReadMessages = [results objectAtIndex:i];
                
                [arrMsgHash addObject:objectReadMessages.topicMessageDetail.messageHash];
             
                NSLog(@" %@ added to arrMsgHash",objectReadMessages.topicMessageDetail.messageHash);
                NSLog(@"***** Read_Message_DB_check -> Topic = %@ ,message = %@,is_sender = %@ , is_Read = %@ Success ! ******",objectReadMessages.topic,objectReadMessages.topicMessageDetail.messageText,objectReadMessages.is_sender,objectReadMessages.is_Read);
                
                //1) mark as read in the dB First
                
                NSLog(@"1.2.2 is now finally read. so update Read_By_Receiver");
                [self sendReadByReceiverStatus:objectReadMessages]; //(Calls 1.2.2)
                objectReadMessages.is_Read = @"TRUE";
                NSError *error;
                if (![[[STTaterCommunicator sharedCommunicatorClass]managedObjectContext] save:&error]) {
                    NSLog(@"Read_Message_DB_check Failed to UPDATE dB- error: %@", [error localizedDescription]);
                }
                else{
                    
                    NSLog(@"***** Read_Message_DB_check -> Db Updated in DB for : Text = %@ , is_read : %@ Success ! ******",objectReadMessages.topicMessageDetail.messageText,objectReadMessages.is_Read);
                }
                
            }
            
            //2) make an api call for all the unread hash.
            
            if(arrMsgHash){
                
                NSLog(@" Read_Message_DB_check - Unread messages has array is: %@", arrMsgHash);
                
//                dispatch_queue_t myQueue = dispatch_queue_create("UpdateTopic",NULL);
//                dispatch_async(myQueue, ^{
                    // Perform long running process
                
                [self updateLastMessageToSever:strTopic Messages:arrMsgHash];
                
//                });
                
            }
   
        }
        
    }
    
//
//     // On receiving a message, is_Read is always false
//     NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TopicMessageEntity"];
//     NSString *PredString1 = [NSString stringWithFormat:@"topic == '%@' AND is_Read == '%@'",strTopic,@"FALSE"];
//     NSLog(@"PredString for unread topics :%@",PredString1);
//     [request setPredicate:[NSPredicate predicateWithFormat:PredString1]];
//
//     NSError *error = nil;
//     NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
//     NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
//     NSLog(@" unread topics count:%@",results);
//
//     if (error == nil) {
//
//     if (results.count != 0) {
//
//     /// Mark the read messages and notify the server to show the right unread count
//     /// api call only for the read messages
//
//     /// check for a perticular topic, if sender is someone else and for those messages, get the last object and also check if the last message object is already read or not. If not read then o nly make the API call.
//     //// UNCOMMENT BELOW CODE -
//
//
//     NSFetchRequest *requestReadMessages = [NSFetchRequest fetchRequestWithEntityName:@"TopicMessageEntity"];
//     // If they are the sender , then on readingthe message, send the last message to the server.
//     NSString *PredString = [NSString stringWithFormat:@"topic == '%@' AND is_sender == '%@'",strTopic,@"FALSE"];//They are the sender
//
//     NSLog(@"PredString %@",PredString);
//     [requestReadMessages setPredicate:[NSPredicate predicateWithFormat:PredString]];
//     NSError *error1 = nil;
//     NSManagedObjectContext *contextUpdateReadMessages = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
//
//     NSArray *resultsReadMessages = [contextUpdateReadMessages executeFetchRequest:requestReadMessages error:&error1];
//     NSLog(@"***** read_Messae_API *1.1* isSender = false count : %lu ******",(unsigned long)resultsReadMessages.count);
//
//     NSLog(@"***** Result dB : %lu ******",(unsigned long)resultsReadMessages);
//
//
//     if (error1 == nil) {
//
//     if (resultsReadMessages.count != 0) { ///00000000000
//
//     NSLog(@"***** read_Messae_API *2* is_sender = FALSE (Sender is them)******");
//     TopicMessageEntity *objectReadMessages = [resultsReadMessages firstObject]; //firstObject actully gives the last one here.
//
//     if([objectReadMessages.is_Read isEqualToString:@"FALSE"]){
//
//     NSLog(@"***** read_Messae_API *3* last message object: %@ ***",objectReadMessages );
//     NSLog(@"***** read_Messae_API *4* is_read = FALSE for message: %@ ***",objectReadMessages.topicMessageDetail.messageText );
//     dispatch_queue_t myQueue = dispatch_queue_create("UpdateTopic",NULL);
//     dispatch_async(myQueue, ^{
//     // Perform long running process
//     [self updateLastMessageToSever:strTopic Messages:objectReadMessages];
//     });
//
//
//     }
//     else{
//     NSLog(@"read_Messae_API *6* Not called cos is_read = %@ for message :%@",objectReadMessages.is_Read,objectReadMessages.topicMessageDetail.messageText);
//     }
//     }
//     }
//     else{
//
//     NSLog(@"Error!! is_sender == FALSE Failed in Db Handler : %@",error1);
//
//     }
    
     
     
     
     //--------------------------------Send Back is_read = true-----------------------------------
     
     // is_read --> unread shows msg count , blue ticks
     /// mark all the unread messages as read.
     
     //// send a delivery status back to the sender saying the messages are now read.
     // irrespective of API call we go ahead and make everything read.
//
//     NSLog(@"***** read_Messae_API *# 2 #* with count: %lu ******",(unsigned long)resultsReadMessages.count);
//     for(int i=0;i<resultsReadMessages.count;i++){
//
//     TopicMessageEntity *object = [resultsReadMessages objectAtIndex:i];
//
//     if([object.is_Read isEqualToString:@"FALSE"]){
//     NSLog(@"1.2.2 is now finally read. so update Read_By_Receiver");
//     [self sendReadByReceiverStatus:object]; //(Calls 1.2.2)
//     }
//     object.is_Read = @"TRUE";
//     NSLog(@"*****UPDATED 'is_read':'%@' ******",object.is_Read);
//     NSError *error;
//
//     if (![contextUpdate save:&error]) {
//     NSLog(@"Messages dB Failed to save UPDATE - error: %@", [error localizedDescription]);
//     }
//     else{
//     NSLog(@" 'read by receiver updated in the dB'");
//     }
//
//     //                    MessageStatusModel *messageStatusModel = [[MessageStatusModel alloc]init];
//     //                    messageStatusModel.message_hash = object.topicMessageDetail.messageHash;
//     //                    messageStatusModel.user_id = object.topicMessageDetail.messageFrom;
//     //                    [self updateTopicMessageStatusTableForGroupUser:messageStatusModel];
//
//     }
//     }// all unread msg array
//
//     }
//     */
}


-(void)sendReadByReceiverStatus:(TopicMessageEntity*)msgObject{
    
    
    // in group --> messageType=system and messageFrom = ME  - Ignore
    
    NSString *strFrom = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; //EXTERNAL_USER_ID or Username
    
    /// check if it is group ??MNBV
    
//    NSMutableDictionary *dctTopicmessageDetail = [[NSMutableDictionary alloc]init];
//    [dctTopicmessageDetail setValue:@"" forKey:@"messageFileType"];
//    [dctTopicmessageDetail setValue:@"" forKey:@"messageFileURL"];
//    [dctTopicmessageDetail setValue:@"read_by_receiver" forKey:@"messageSubType"];
//    [dctTopicmessageDetail setValue:@"system" forKey:@"messageType"];
//    [dctTopicmessageDetail setValue:strFrom forKey:@"messageFrom"];//messageFrom
//
//    [dctTopicmessageDetail setValue:msgObject.topicMessageDetail.messageHash forKey:@"messageHash"];
//    [dctTopicmessageDetail setValue:msgObject.topicMessageDetail.messageText forKey:@"messageText"];
//
//
//    NSLog(@"***** 1.2.2 Send System message for  'read_by_receiver'  with payload :%@",dctTopicmessageDetail);
    
    ///***# * * * 2.1.1 PUBLISH A SYSTEM MESSAGE BACK TO SENDER - ONE ON ONE & group
//    [[STTaterCommunicator sharedCommunicatorClass] SttarterClassPublishTopic:msgObject.topic messagehash:msgObject.topicMessageDetail.messageHash strData:dctTopicmessageDetail];
    
    
    TopicMessageDetail *detailModel = [[TopicMessageDetail alloc]init];
    detailModel.messageFrom = strFrom;
    detailModel.messageType = @"system";
    detailModel.messageSubType = @"read_by_receiver";
    detailModel.messageText = msgObject.topicMessageDetail.messageText;
    detailModel.messageHash = msgObject.topicMessageDetail.messageHash ;
    detailModel.messageFileType =msgObject.topicMessageDetail.messageFileType;
    detailModel.messageFileURL =msgObject.topicMessageDetail.messageFileURL;
    
    NSLog(@"** MQTT_Queue:1 Publish stored dct as Model:%@ **",detailModel);
    NSLog(@"***** 1.2.2 Send System message for  'read_by_receiver'  with payload :%@",detailModel);

    [[STTaterCommunicator sharedCommunicatorClass]SttarterClassPublishTopic:msgObject.topic withData:detailModel];
//    [[STTaterCommunicator sharedCommunicatorClass]SttarterClassPublishTopic:object.mqttQueue_Topic  withData:detailModel];
    
//    [[STTaterCommunicator sharedCommunicatorClass] SttarterClassPublishTopic:msgObject.topic messagehash:msgObject.topicMessageDetail.messageHash strData:dctTopicmessageDetail];

}

-(void)updateLastMessageToSever:(NSString *)topic Messages:(NSMutableArray *)arrHash {
   
    /// also send back a system message with subtype = 'read_by_receiver'
    NSLog(@"+++ Update read messages to server called with arrOfHashMessages :%@ +++",arrHash);
    
    
    [[DownloadManager shared]messageRead_Api_forTopic:topic messageHash:arrHash completionBlock:^(NSError *error,NSDictionary *dctResposnse){
        if (error)
        {
            NSLog(@"Error!! read_Messae_API *5* Failed in Db Handler : %@",error);
        }
        else{
            NSLog(@"Sucess !! read_Messae_API *5*");
        }
    }
     ];
}


-(void)updateIsReadInTopicDb:(NSString*)strTopic unreadMessageCount:(NSString*)count{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topics"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"topic_id == %@", strTopic]];
    
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    if (error == nil) {
        
        if (results.count != 0) {
            Topics *object = [results objectAtIndex:0]; // will anyway have one item in the array
            object.topic_NotificationCount = count;
            
//            [contextUpdate save:nil];
            [contextUpdate performBlockAndWait:^{
                NSError *error;
                
                if (![contextUpdate save:&error]) {
                    NSLog(@"dB Topics Failed to save UPDATE - error: %@", [error localizedDescription]);
                }
            }];

        }
    }
    
}


-(void)updateLatestTopicWithTopic:(NSString*)strTopic Time:(NSString*)strTimeStamp Count:(NSString*)strCount isRead:(NSString*)strRead LastMessage:(NSString*)strLastMessage{
    
    NSLog(@"***** UPDATE TOPICS DB with Latest Message **** ");
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topics"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"topic_id == %@", strTopic]];
    
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    if (error == nil) {
        
        if (results.count != 0) {
            
            Topics *object = [results objectAtIndex:0]; // will anyway have one item in the array
            
            
            
            object.topic_updated_unix_timestamp = strTimeStamp;
            object.topic_NotificationCount = strCount;
            //            object.topic_isMessageRead =strRead;
            object.topic_LastReceivedMessage =strLastMessage;
           

            [contextUpdate performBlockAndWait:^{
                NSError *error;
                if (![contextUpdate save:&error]) {
                    NSLog(@"dB Topics Failed to save UPDATE - error: %@", [error localizedDescription]);
                }
            }];

            
            
            
        }
    }
    
    
}

#pragma mark - ** TOPIC  - T A B L E  **


-(void)updateTopicDatabase:(TopicsModel *)topicModel{  //// UPDATE Topics Table
    
    NSLog(@"***** TOPICS DATABASE **** ");
    
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    
    if(contextUpdate != nil){
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topics"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"topic_id == %@", topicModel.topic]];
        
        NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
        
        NSString *topic = topicModel.topic;
        NSString *type = topicModel.type;
        NSString *topicName = topicModel.topic_name;
        NSString *userid = topicModel.userId;
        NSString *updatedTimeStamp = topicModel.messageTimeStamp;
        NSInteger is_public;
        
        if(topicModel.is_public){
            is_public = topicModel.is_public;
        }
        else{
            is_public = 1;
        }
        
        NSData *metadata = nil;
        if ([topicModel.meta isKindOfClass:[NSString class]]) {
            metadata = [topicModel.meta dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSData *groupMembersData = nil;
        if ([topicModel.group_members isKindOfClass:[NSArray class]]) {
            groupMembersData = [NSKeyedArchiver archivedDataWithRootObject:topicModel.group_members];
            
        }
        
        NSString *isTopicSubscribed =@"TRUE";
        
        if (error == nil) {
            
            if (results.count == 0) {  // insert
                
                NSManagedObjectContext *contextInsert = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
                
                Topics *object = [NSEntityDescription insertNewObjectForEntityForName:@"Topics"
                                                               inManagedObjectContext:contextInsert];
                NSLog(@"***** INSERT New Topics menthod entered ***** ");
                
                object.topic_group_members = groupMembersData;
                object.topic_meta = metadata;
                object.topic_name = topicName;
                if([userid length] != 0 ){
                    object.topic_userId = userid;
                }
                object.topic_id = (NSString*)topic;
                object.topic_type = type;
                object.topic_is_subscribed = isTopicSubscribed;
                object.topic_is_public = [NSString stringWithFormat:@"%ld",(long)is_public];
                object.topic_updated_unix_timestamp = updatedTimeStamp;
                object.topic_NotificationCount = @"0";
                object.topic_LastReceivedMessage = @"";
                

                [contextInsert performBlockAndWait:^{
                    NSError *error;
                    if (![contextInsert save:&error]) {
                        NSLog(@"***dB Topics Failed to save INSERT - error: ' %@ ' ***", [error localizedDescription]);
                    }
                }];

                
                
            }
            
            else{ // Update if it already exists
                
                Topics *object = [results firstObject]; // will anyway have one item in the array
                
                if(metadata != nil ){
                    object.topic_meta = metadata;
                }
                if(topicName != nil && ![topicName isEqualToString:@""]){
                    object.topic_name = topicName;
                }
                if(userid != nil && ![userid isEqualToString:@""]){
                    object.topic_userId = userid;
                }
                if((NSString*)topic != nil && ![(NSString*)topic isEqualToString:@""]){
                    object.topic_id = (NSString*)topic;
                }
                if(type != nil && ![type isEqualToString:@""]){
                    object.topic_type = type;
                }
                if(isTopicSubscribed != nil && ![isTopicSubscribed isEqualToString:@""]){
                    object.topic_is_subscribed = isTopicSubscribed;
                }
                NSString *str = [NSString stringWithFormat:@"%ld",(long)is_public];
                if(str != nil && ![str isEqualToString:@""]){
                    object.topic_is_public = str;
                    
                }
                if(updatedTimeStamp != nil && ![updatedTimeStamp isEqualToString:@""]){
                    object.topic_updated_unix_timestamp = updatedTimeStamp;
                }
                if(groupMembersData != nil){
                    object.topic_group_members = groupMembersData;
                }
                
                if(object.topic_LastReceivedMessage == nil || [object.topic_LastReceivedMessage isEqualToString:@""]){
                    object.topic_LastReceivedMessage = @"";
                }

                
                [contextUpdate performBlockAndWait:^{
                    NSError *error;
                    if (![contextUpdate save:&error]) {
                        NSLog(@"dB Topics Failed to save UPDATE - error: %@", [error localizedDescription]);
                    }
                }];
                
                
                NSLog(@"####### TOPICS DATABASE Updated:%@ #####",object);
                
            }
            
        }
        
        
    }
    
}

-(Topics*)getTopicDetailsForTopic:(NSString*)strTopic{
    
    Topics *object;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topics"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"topic_id == %@", strTopic]];
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    NSLog(@"####### getTopicDetailsForATopic DB.2 :%@ #####",results);
    
    if (error == nil) {
        
        if (results.count != 0) {
            object = [results objectAtIndex:0]; // will anyway have one item in the array
        }
    }
    return object;
}


-(NSString*)getTopicForNameFromDbFor:(NSString*)strName{//MIM
    
    NSString* topic = @"";
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topics"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"topic_name == %@", strName]];
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    NSLog(@"resultsresults %lu",(unsigned long)results.count);
    NSLog(@"strNamestrName %@",strName);
    
    if (error == nil) {
        if (results.count != 0) {
            Topics *object = [results objectAtIndex:0]; // will anyway have one item in the array
            topic = object.topic_id;
        }
    }
    return topic;
}

-(NSArray *)getAllDbTopics{
    
    // always dB in background.
    
    NSManagedObjectContext *moc = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Topics" inManagedObjectContext:moc];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    
    NSLog(@"****DB getAllTopics core data **** %@",results);
    
    if (!results) {
        NSLog(@"Error fetching Messages objects: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return results;
}

-(NSArray *)getAllGroupMembers:(NSString*)strTopic{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topics"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"topic_id == %@", strTopic]];
    NSError *error = nil;
    NSManagedObjectContext *contextUpdate = [[STTaterCommunicator sharedCommunicatorClass]managedObjectContext];
    NSArray *results = [contextUpdate executeFetchRequest:request error:&error];
    
    NSArray *arGroupMemebers;
    
    if (error == nil) {
        
        if (results.count != 0) {
            Topics *object = [results objectAtIndex:0]; // will anyway have one item in the array
            
            arGroupMemebers = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)object.topic_group_members];
            
        }
        
        
    }
    return arGroupMemebers;
}



#pragma mark -  DELETE


-(void)deleteTopic:(NSString *)topicID{
    
    NSManagedObjectContext *moc = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Topics"];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_8_0) {
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"topic_id == %@", topicID]];
        
        NSFetchRequest *allmessages = [[NSFetchRequest alloc] init];
        [allmessages setEntity:[NSEntityDescription entityForName:@"Topics" inManagedObjectContext:moc]];
        [allmessages setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        __block NSError *error = nil;

        NSArray *messages = [moc executeFetchRequest:allmessages error:&error];
        //error handling goes here
        for (NSManagedObject *message in messages) {
            [moc deleteObject:message];
        }
        [moc performBlockAndWait:^{
            if (![moc save:&error]) {
                NSLog(@"Failed to save - error: %@", [error localizedDescription]);
            }
        }];
        
    }else{
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"topic_id == %@", topicID]];
        
        NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        
        NSError *deleteError = nil;
        [[STTaterCommunicator sharedCommunicatorClass].persistentStoreCoordinator executeRequest:delete withContext:moc error:&deleteError];
    }
}


-(NSString *)validateString:(NSString *)input{
    if (input == nil || [input isEqualToString:@""]) {
        input = @"";
    }
    return input;
    
}

#pragma mark - ** NEW AND UPDATED **

-(void)clearDataBase {
    
    NSManagedObjectContext *moc4 = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    //TopicMessageDetailEntity
    
    if(moc4 != nil){
        NSFetchRequest *fetchRequest4 = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity4 = [NSEntityDescription entityForName:@"MQTT_Queue" inManagedObjectContext:moc4];
        [fetchRequest4 setEntity:entity4];
        
        __block NSError *error4;
        NSArray *items4 = [moc4 executeFetchRequest:fetchRequest4 error:&error4];
        
        for (NSManagedObject *managedObject in items4) {
            [moc4 deleteObject:managedObject];
        }
        
        [moc4 performBlockAndWait:^{
            if (![moc4 save:&error4]) {
                NSLog(@"Error deleting MQTT_Queue : %@ - error:%@",kSecAttrDescription,error4);
            }
        }];
        
        
        NSLog(@"***** DELETED MQTT_Queue TABLE **** ");
        
    }
    
    
    ////>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    
    NSManagedObjectContext *moc3 = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    if (moc3 != nil){
        
        NSFetchRequest *fetchRequest3 = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity3 = [NSEntityDescription entityForName:@"TopicMessageStatusEntity" inManagedObjectContext:moc3];
        [fetchRequest3 setEntity:entity3];
        
        __block NSError *error3;
        NSArray *items3 = [moc3 executeFetchRequest:fetchRequest3 error:&error3];
        
        for (NSManagedObject *managedObject in items3) {
            [moc3 deleteObject:managedObject];
        }
        [moc3 performBlockAndWait:^{
            if (![moc3 save:&error3]) {
                NSLog(@"Error deleting TopicMessageStatusEntity : %@ - error:%@",kSecAttrDescription,error3);
            }
        }];
       
        
        NSLog(@"***** DELETED TopicMessageStatusEntity TABLE **** ");
    }
    
    
    
    
    ////>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    NSManagedObjectContext *moc2 = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    //TopicMessageDetailEntity
    if (moc2 != nil){
        
        NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"TopicMessageEntity" inManagedObjectContext:moc2];
        [fetchRequest2 setEntity:entity2];
        
       __block  NSError *error2;
        NSArray *items2 = [moc2 executeFetchRequest:fetchRequest2 error:&error2];
        
        
        for (NSManagedObject *managedObject in items2) {
            [moc2 deleteObject:managedObject];
        }
        [moc2 performBlockAndWait:^{
            if (![moc2 save:&error2]) {
                NSLog(@"Error deleting %@ - error:%@",kSecAttrDescription,error2);
            }
        }];
        
        
        NSLog(@"***** DELETED TopicMessageEntity TABLE **** ");
        
        ////>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
    }
    
    NSManagedObjectContext *moc1 = [[STTaterCommunicator sharedCommunicatorClass] managedObjectContext];
    if (moc1 != nil){
        
        //TopicMessageDetailEntity
        NSFetchRequest *fetchRequest1 = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity1 = [NSEntityDescription entityForName:@"TopicMessageDetailEntity" inManagedObjectContext:moc1];
        [fetchRequest1 setEntity:entity1];
        
        __block NSError *error1;
        NSArray *items1 = [moc1 executeFetchRequest:fetchRequest1 error:&error1];
        
        
        for (NSManagedObject *managedObject in items1) {
            [moc1 deleteObject:managedObject];
        }
        [moc1 performBlockAndWait:^{
            if (![moc1 save:&error1]) {
                NSLog(@"Error deleting TopicMessageDetailEntity: %@ - error:%@",kSecAttrDescription,error1);
            }
        }];
        
        
        NSLog(@"***** DELETED TopicMessageDetailEntity TABLE **** ");
        
    }
}

@end
