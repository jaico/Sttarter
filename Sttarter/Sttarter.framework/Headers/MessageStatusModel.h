//
//  MessageStatusModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 23/03/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
@protocol MessageStatusModel @end

@interface MessageStatusModel : JSONModel

@property(strong,nonatomic)NSString *message_hash;
@property(strong,nonatomic)NSString *user_id;
@property(strong,nonatomic)NSString *is_deliveredTimestamp;
@property(strong,nonatomic)NSString *is_readByReceiverTimeStamp;

@end
