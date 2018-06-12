//
//  STTaterCommunicator.h
//  Sttarter
//
//  Created by Prajna Shetty on 25/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManager.h"
#import "JSONModel.h"
#import "MQTTClient.h"
#import "TopicsModel.h"
#import "MQTTSessionManager.h"
#import "GetMessagesModel.h"
#import "NSString+MD5.h"
#import "TopicMessage.h"
#import "DatabaseHandler.h"
#import "Topics+CoreDataClass.h"
#import "GetRefCodeModel.h"
#import "MyTopicsModel.h"
#import "Topic_GroupMembers.h"

typedef void (^createGroupBlock)(BOOL isSuccess,NSString *groupTopic);
typedef void (^RefreshTopics)(BOOL isSuccess,NSMutableArray *arrDbTopicsData);
typedef void (^addAMemberToGroupBlock)(BOOL isSuccess,NSString *status);
typedef void (^addMembersToGroupBlock)(BOOL isSuccess,NSString *status);
typedef void (^TopicForName)(BOOL isSuccess,TopicsModel *_TopicModel);
typedef void (^getTopicByNameBlcok)( NSString *topicId);
typedef void (^SubscribeTopicAndFetachMessagesBlock)(BOOL isSuccess);

@protocol STTCommunicationConnectionDelegateProtocol <NSObject>

-(void)connectionSuccess;
-(void)connectionFailure;

@end

@interface STTaterCommunicator : NSObject<MQTTSessionDelegate,MQTTSessionManagerDelegate>
{
    MQTTCFSocketTransport *transport;
    MQTTSession *session;
    TopicsModel *_TopicsModel;
    BOOL isLoggedOut;
}


@property (nonatomic,weak) id <STTCommunicationConnectionDelegateProtocol> connectionDelegate;

@property (nonatomic,readwrite) BOOL isMQTTSessionInitialized;
@property (nonatomic,readwrite) BOOL internetIsReachable;

@property (nonatomic) UInt16 deliveredMessageMid;
@property (strong, nonatomic) NSMutableDictionary *dctMsgStatus;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (STTaterCommunicator*)sharedCommunicatorClass;

- (void)getUnreadMessageCountForTopic:(NSString*)strTopic;
- (void)updateMessageRead:(NSString*)strTopic;
- (void)addTopic:(NSString*)strUserName;
//-(void)ReConnectCommunicator;
-(void)ConnectCommunicator;

-(void)reconnectToChat;
-(BOOL)connectionON;

- (void)subscribeInitialize;
- (void)getBuzzMessagesAppToken;
- (void)getmytopics;
- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;
- (NSMutableArray*)getAllMyTopics;
- (void)SttarterClassPublishTopic:(NSString*)strTopic withData:(TopicMessageDetail*)messageDetailModel;

//- (void)SttarterClassPublishTopic:(NSString*)strTopic messagehash:(NSString*)strHash strData:(NSDictionary*)dctMessage;//group

//- (void)SendMessageToUserId:(NSString*)strUserId withMessage:(NSString*)strMessage;// single id
//- (void)SendMessageToGroupWithTopic:(NSString*)strTopic withMessage:(NSString*)strMessage;// group id
- (void)SendMessageToTopic:(NSString*)strTopic withMessage:(NSString*)strMessage andType:(NSString*)strType;



-(void)ApiGetMessagesForTopic:(NSString*)strTopic;

- (void)CleanCommunicator;
- (void)updateTopic;

- (int)getCountForTopic:(NSString*)strTopicId;
- (void)updateMessages:(NSString*)strTopic;

-(int)getCountAccrossAllTopics;
-(void)synchronizeAllMessages;
//Synchronize message and set initial message count
-(void)synchronizeAllMessages:(int)maxNumberOfMessages;
//Added new method to retrieve paginated messages
-(void)getPaginatedMessages:(Topics *)topic maxNumberOfMessages:(int)maxNumberOfMessages withOffset:(int)offset;
- (TopicMessageDetailEntity*)getLatestMessageObject:(NSString*)strTopicId;

///------
- (NSMutableArray*)getAllMessageForTopic:(NSString*)strTopicId;///***
-(NSString*)getUserMasterTopic:(NSString*)strTopic;

/// Communicator

-(void)GetAllRecentTopics_withCompletionBlock:(RefreshTopics)completionBlock;
// calls get my Topic , subscribes to the new topics , updates db and returns the dB. If GetMyTopic fails, it returns the saved dB.
// used in mimsha Groups

-(void)Trial_withCompletionBlock:(RefreshTopics)completionBlock; // NEW TRy

-(TopicModel*)getTopicDetailsForASingleTopic:(NSString*)strTopic; // old **

-(BOOL)checkConnectionStateAndReconnect;


/// Groups API

//addMembers
-(void)addMultipleMemebersToGroupWithTopic:(NSString*)strTopic withMember:(NSMutableArray*)arrMembers completionBlock:(addMembersToGroupBlock)completionBlock;  /// new !@#$ needs to be tested new API. API does not work.

-(void)addAMemeberToGroupWithTopic:(NSString*)strTopic withMember:(NSString*)member completionBlock:(addAMemberToGroupBlock)completionBlock;

// create group
-(void)createNewGroup:(NSString*)strGroupName Meta:(NSString*)strMeta completionBlock:(createGroupBlock)completionBlock;

//Topic
-(void)getTopicByName:(NSString*)strName withCompletionBlock:(getTopicByNameBlcok)completionBlock;
-(void)subscribeToTopicAndFetchMessages:(NSString*)strTopic withCompletionBlock:(SubscribeTopicAndFetachMessagesBlock)completionBlock;

// newly moved to avoid isRead API Call.
-(int)sttGetCountForTopic:(NSString*)topic; /// Can be moved to SDK as it is
-(TopicMessage*)sttGetLatestMessageForTopic:(NSString*)strTopicId;
- (void)PublishMediaToTopicWithCustomUrl:(NSString*)strUserId withMessage:(NSString*)strMessage  withPathUrl:(NSArray*)arrPathstoMedia;

//-(void)testIsReadAPI:(NSString*)strTopic MessageArray:(NSMutableArray*)srrHash; // Revome this

//Sync multiple users
-(void)getUserListForExternalIDs:(NSArray *)usersList getUserSuccessListenerBlock:(getUserSuccessListenerBlock)successBlock andErrorListenerBlock:(errorListenerBlock)failureBlock;

//Clear singleton object
+(void) destroyInstance;
@end
