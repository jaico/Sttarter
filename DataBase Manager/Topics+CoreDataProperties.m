//
//  Topics+CoreDataProperties.m
//  Sttarter
//
//  Created by Prajna Shetty on 24/04/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "Topics+CoreDataProperties.h"

@implementation Topics (CoreDataProperties)

+ (NSFetchRequest<Topics *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Topics"];
}

@dynamic topic_group_members;
@dynamic topic_id;
@dynamic topic_is_public;
@dynamic topic_is_subscribed;
@dynamic topic_isMessageRead;
@dynamic topic_LastReceivedMessage;
@dynamic topic_meta;
@dynamic topic_name;
@dynamic topic_NotificationCount;
@dynamic topic_type;
@dynamic topic_updated_unix_timestamp;
@dynamic topic_userId;
@dynamic relation_TopicMessage;

@end
