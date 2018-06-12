//
//  TopicMessage.h
//  Sttarter
//
//  Created by Prajna Shetty on 18/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "TopicMessageDetail.h"

@protocol TopicMessage @end
@interface TopicMessage : JSONModel   // is sent to APP guy as well + Parse Response

@property(strong,nonatomic)NSString *_id;// auto incrment
@property (nonatomic, strong) NSString *topicIDFK;//
@property(nonatomic)NSInteger __v;/// not needed
@property(strong,nonatomic)NSString *client_id;//
@property(strong,nonatomic)NSString *created_at;//
@property(nonatomic)BOOL is_deleted;//
@property(strong,nonatomic) TopicMessageDetail *message;///
@property(strong,nonatomic)NSString *topic;//
@property(nonatomic)BOOL is_read;//

//dB Related Topics-
@property (nonatomic, strong) NSString *is_sender;//
@property (nonatomic, strong) NSString *str_IsRead;// is different from inside is Read
@property (nonatomic, strong) NSString *is_sent;//

// for sort
@property(strong,nonatomic)NSString <Optional> *message_sort;


@end
