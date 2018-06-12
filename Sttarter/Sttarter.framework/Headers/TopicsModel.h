//
//  TopicsModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 27/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "InteractedWithModel.h"
#import "Topic_GroupMembers.h"

@protocol TopicsModel @end
@interface TopicsModel : JSONModel

@property(strong,nonatomic)NSString <Optional> *topic;
@property(strong,nonatomic)NSString <Optional> *type;
@property(nonatomic)NSInteger is_public;
@property(nonatomic)NSInteger subscriber_count;
@property(nonatomic)NSInteger topic_id;
@property(nonatomic)NSString <Optional> *meta;
@property(strong,nonatomic)NSString <Optional> *topic_name;
@property(strong,nonatomic)NSString <Optional> *userId;
@property(strong,nonatomic)NSArray <TopicsModel> *interacted_with;
@property(strong,nonatomic)NSString <Optional> *messageTimeStamp;
@property(strong,nonatomic)NSArray <Topic_GroupMembers> *group_members;


@end
