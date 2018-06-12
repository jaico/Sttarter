//
//  TopicMessageEntity+CoreDataProperties.m
//  Sttarter
//
//  Created by Prajna Shetty on 02/05/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "TopicMessageEntity+CoreDataProperties.h"

@implementation TopicMessageEntity (CoreDataProperties)

+ (NSFetchRequest<TopicMessageEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TopicMessageEntity"];
}

@dynamic is_Read;
@dynamic is_sender;
@dynamic is_sent;
@dynamic topic;
@dynamic messageTopic;
@dynamic topicMessageDetail;

@end
