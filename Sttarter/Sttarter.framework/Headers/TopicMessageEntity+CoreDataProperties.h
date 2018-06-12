//
//  TopicMessageEntity+CoreDataProperties.h
//  Sttarter
//
//  Created by Prajna Shetty on 02/05/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "TopicMessageEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TopicMessageEntity (CoreDataProperties)

+ (NSFetchRequest<TopicMessageEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *is_Read;
@property (nullable, nonatomic, copy) NSString *is_sender;
@property (nullable, nonatomic, copy) NSString *is_sent;
@property (nullable, nonatomic, copy) NSString *topic;
@property (nullable, nonatomic, retain) Topics *messageTopic;
@property (nullable, nonatomic, retain) TopicMessageDetailEntity *topicMessageDetail;

@end

NS_ASSUME_NONNULL_END
