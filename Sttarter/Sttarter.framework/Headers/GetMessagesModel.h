//
//  GetMessagesModel.h
//  Sttarter
//
//  Created by Vijeesh on 15/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
//#import "MessageBaseModel.h"
#import "TopicMessage.h"

@protocol GetMessagesModel @end
@interface GetMessagesModel : JSONModel

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray <TopicMessage> *messages;

//@property (nonatomic, strong) NSArray <MessageBaseModel> *messages;
//
@end
