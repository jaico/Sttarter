//
//  TopicMessageStatusEntity+CoreDataProperties.h
//  Sttarter
//
//  Created by Prajna Shetty on 02/05/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "TopicMessageStatusEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TopicMessageStatusEntity (CoreDataProperties)

+ (NSFetchRequest<TopicMessageStatusEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *is_delivered;
@property (nullable, nonatomic, copy) NSString *is_readByTheReceiver;
@property (nullable, nonatomic, copy) NSString *message_hash;
@property (nullable, nonatomic, copy) NSString *topic_user_id;
@property (nullable, nonatomic, retain) TopicMessageDetailEntity *topicMessageDetail;

@end

NS_ASSUME_NONNULL_END
