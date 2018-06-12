//
//  TopicMessageDetailEntity+CoreDataProperties.m
//  Sttarter
//
//  Created by Prajna Shetty on 02/05/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "TopicMessageDetailEntity+CoreDataProperties.h"

@implementation TopicMessageDetailEntity (CoreDataProperties)

+ (NSFetchRequest<TopicMessageDetailEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TopicMessageDetailEntity"];
}

@dynamic isDelivered;
@dynamic isReadBytheReceiver;
@dynamic messageFileType;
@dynamic messageFileURL;
@dynamic messageFrom;
@dynamic messageHash;
@dynamic messageSubType;
@dynamic messageText;
@dynamic messageTimeStamp;
@dynamic messageTypes;
@dynamic topicMessage;
@dynamic topicMessageStatusList;

@end
