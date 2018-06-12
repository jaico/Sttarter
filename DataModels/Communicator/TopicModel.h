//
//  TopicModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 24/10/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface TopicModel : JSONModel


@property (strong,nonatomic) NSArray *topic_group_members;
@property (strong,nonatomic) NSString *topic_meta;
@property (strong,nonatomic) NSString *topic_id;
@property (strong,nonatomic) NSString <Optional> *topic_is_public;
@property (strong,nonatomic) NSString <Optional> *topic_is_subscribed;
@property (strong,nonatomic) NSString <Optional> *topic_isMessageRead;
@property (strong,nonatomic) NSString <Optional> *topic_LastReceivedMessage;
@property (strong,nonatomic) NSString <Optional> *topic_name;
@property (strong,nonatomic) NSString <Optional> *topic_NotificationCount;
@property (strong,nonatomic) NSString <Optional> *topic_type;
@property (strong,nonatomic) NSString <Optional> *topic_updated_unix_timestamp;
@property (strong,nonatomic) NSString <Optional> *topic_userId;
//@property (nullable, nonatomic, retain) NSOrderedSet<TopicMessage *> *relation_TopicMessage;


@end
