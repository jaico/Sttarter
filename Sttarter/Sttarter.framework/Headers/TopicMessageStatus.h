//
//  TopicMessageStatus.h
//  Sttarter
//
//  Created by Prajna Shetty on 20/04/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"


@protocol TopicMessageStatus @end
@interface TopicMessageStatus : JSONModel

@property(strong,nonatomic)NSString *TopicMessageStatus;
@property(strong,nonatomic)NSString *user;
@property(strong,nonatomic)NSString *is_ReadByReceiver;
@property(strong,nonatomic)NSString *is_Delivered;

@end
