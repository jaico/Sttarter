//
//  TopicMessageDetailEntity+CoreDataProperties.h
//  Sttarter
//
//  Created by Prajna Shetty on 02/05/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "TopicMessageDetailEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TopicMessageDetailEntity (CoreDataProperties)

+ (NSFetchRequest<TopicMessageDetailEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *isDelivered;
@property (nullable, nonatomic, copy) NSString *isReadBytheReceiver;
@property (nullable, nonatomic, copy) NSString *messageFileType;
@property (nullable, nonatomic, copy) NSString *messageFileURL;
@property (nullable, nonatomic, copy) NSString *messageFrom;
@property (nullable, nonatomic, copy) NSString *messageHash;
@property (nullable, nonatomic, copy) NSString *messageSubType;
@property (nullable, nonatomic, copy) NSString *messageText;
@property (nullable, nonatomic, copy) NSString *messageTimeStamp;
@property (nullable, nonatomic, copy) NSString *messageTypes;
@property (nullable, nonatomic, retain) TopicMessageEntity *topicMessage;
@property (nullable, nonatomic, retain) NSSet<TopicMessageStatusEntity *> *topicMessageStatusList;

@end

@interface TopicMessageDetailEntity (CoreDataGeneratedAccessors)

- (void)addTopicMessageStatusListObject:(TopicMessageStatusEntity *)value;
- (void)removeTopicMessageStatusListObject:(TopicMessageStatusEntity *)value;
- (void)addTopicMessageStatusList:(NSSet<TopicMessageStatusEntity *> *)values;
- (void)removeTopicMessageStatusList:(NSSet<TopicMessageStatusEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
