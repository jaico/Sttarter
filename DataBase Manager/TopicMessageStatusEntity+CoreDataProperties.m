//
//  TopicMessageStatusEntity+CoreDataProperties.m
//  Sttarter
//
//  Created by Prajna Shetty on 02/05/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "TopicMessageStatusEntity+CoreDataProperties.h"

@implementation TopicMessageStatusEntity (CoreDataProperties)

+ (NSFetchRequest<TopicMessageStatusEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TopicMessageStatusEntity"];
}

@dynamic is_delivered;
@dynamic is_readByTheReceiver;
@dynamic message_hash;
@dynamic topic_user_id;
@dynamic topicMessageDetail;

@end
