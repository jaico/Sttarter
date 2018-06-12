//
//  DatabaseHandler.h
//  Sttarter
//
//  Created by Prajna Shetty on 07/11/16.
//  Copyright © 2016 Spurtree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Topics+CoreDataClass.h"
#import "TopicMessageEntity+CoreDataClass.h"
//#import "Messages+CoreDataClass.h"
#import "MQTT_Queue+CoreDataClass.h"
#import "TopicMessageStatusEntity+CoreDataClass.h"
#import "STTarterImports.h"
#import "Utils.h"

@class MessagesModel;
@class TopicsModel;
@class TopicMessage;
@class MQTT_QueueModel;
@class MessageStatusModel;

@interface DatabaseHandler : NSObject
+(DatabaseHandler*)sharedDatabaseHandler;

-(void)insertDataToMessages:(NSDictionary *)dctMessagesData;//
//-(void)updateMessage:(MessagesModel *)messagesModel;
-(NSArray *)getMessages:(NSString *)topicValue;
-(void)deleteMessage:(NSString *)topicValue;

-(void)insertTopics:(TopicsModel *)topicModel;//
-(void)deleteTopic:(NSString *)topicID;

#pragma mark -
-(void)updateMessagesDatabase:(TopicMessage *)msgInfoModel;
-(void)updateTopicDatabase:(TopicsModel *)topicModel;

-(NSArray *)getAllDbTopics;
-(NSArray *)getAllMessages;

//Delete
//-(void)deleteAllMessages;/////
//-(void)deleteAllTopics;
//-(void)deleteAllMQTTQueuedData;
-(void)clearDataBase;

-(void)updateIsReadInMessagesDb:(NSString*)strTopic isRead:(NSString*)isRead;
//-(void)updateIsReadInTopicDb:(NSString*)strTopic unreadMessageCount:(NSString*)count;

/// MQTTQueue
-(void)AddToMQTT_Queue:(MQTT_QueueModel *)MQTTQueueModel;
-(void)deleteMqttQueuedRow:(NSString*)strHash;
-(void)RetiveMQTT_Queue;

/// Delivered status - sent, delivered, read
-(void)updateMessageSentStatus:(NSString*)strMessageHash withTimestamp:(NSString*)strTimestamp;

-(void)updateTopicMessageStatusTableForOneOnOne:(MessageStatusModel *)messageStatusModel;
-(void)updateTopicMessageStatusTableForGroupUser:(MessageStatusModel *)messageStatusModel;

/// get All GroupMemebers array
-(NSArray *)getAllGroupMembers:(NSString*)strTopic;

/// Update timestamp for the received message
-(void)updateWithSystemTimeStamp:(NSString*)strTimeStamp forHash:(NSString*)strHash;
-(Topics*)getTopicDetailsForTopic:(NSString*)strTopic;
-(NSString*)getTopicForNameFromDbFor:(NSString*)strName;//MIM


-(void)updateLastMessageToSever:(NSString*)strTopic Messages:(NSMutableArray*)arrMsgHash;


@end
