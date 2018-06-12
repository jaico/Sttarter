//
//  TopicMessageDetail.h
//  Sttarter
//
//  Created by Prajna Shetty on 18/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "TopicMessageStatus.h"

@protocol TopicMessageDetail @end
@interface TopicMessageDetail : JSONModel


/// _id - project

@property(strong,nonatomic)NSString *messageType;
@property(strong,nonatomic)NSString *messageSubType;
@property(strong,nonatomic)NSString *messageFrom;// The External ID of the user who sent the message
@property(strong,nonatomic)NSString *messageHash;// A Random Hash Generated Hash that needs to be UNIQUE
@property(strong,nonatomic)NSString *messageText;// The message that the user sent
@property(strong,nonatomic)NSString *messageFileType;// A value that can be set by the client IMAGE/PDF/VIDEO etc
@property(strong,nonatomic)NSString *messageFileURL; // A value of the URL where the file has been uploaded to
@property(strong,nonatomic)NSString *messageTimeStamp; // The server side timestamp of when the message was sent.


@property(strong,nonatomic)NSString *messageDeliveredTimeStamp; ///isDelivered - double tick when the message is delivered to all the users.
@property(strong,nonatomic)NSString *messageReadByReceiverTimeStamp; ///isReadByReceiver - blue tick is show if all the memebers have read the message in the group.
@property(strong,nonatomic) TopicMessageStatus *status;


@end
