//
//  Topics+CoreDataProperties.h
//  Sttarter
//
//  Created by Prajna Shetty on 24/04/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "Topics+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Topics (CoreDataProperties)

+ (NSFetchRequest<Topics *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSObject *topic_group_members;
@property (nullable, nonatomic, copy) NSString *topic_id;
@property (nullable, nonatomic, copy) NSString *topic_is_public;
@property (nullable, nonatomic, copy) NSString *topic_is_subscribed;
@property (nullable, nonatomic, copy) NSString *topic_isMessageRead;
@property (nullable, nonatomic, copy) NSString *topic_LastReceivedMessage;
@property (nullable, nonatomic, retain) NSObject *topic_meta;
@property (nullable, nonatomic, copy) NSString *topic_name;
@property (nullable, nonatomic, copy) NSString *topic_NotificationCount;
@property (nullable, nonatomic, copy) NSString *topic_type;
@property (nullable, nonatomic, copy) NSString *topic_updated_unix_timestamp;
@property (nullable, nonatomic, copy) NSString *topic_userId;
@property (nullable, nonatomic, retain) NSOrderedSet<TopicMessage *> *relation_TopicMessage;



@end

@interface Topics (CoreDataGeneratedAccessors)

- (void)insertObject:(TopicMessage *)value inRelation_TopicMessageAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRelation_TopicMessageAtIndex:(NSUInteger)idx;
- (void)insertRelation_TopicMessage:(NSArray<TopicMessage *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRelation_TopicMessageAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRelation_TopicMessageAtIndex:(NSUInteger)idx withObject:(TopicMessage *)value;
- (void)replaceRelation_TopicMessageAtIndexes:(NSIndexSet *)indexes withRelation_TopicMessage:(NSArray<TopicMessage *> *)values;
- (void)addRelation_TopicMessageObject:(TopicMessage *)value;
- (void)removeRelation_TopicMessageObject:(TopicMessage *)value;
- (void)addRelation_TopicMessage:(NSOrderedSet<TopicMessage *> *)values;
- (void)removeRelation_TopicMessage:(NSOrderedSet<TopicMessage *> *)values;

@end

NS_ASSUME_NONNULL_END
