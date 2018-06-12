//
//  BuzzMessagesModel.h
//  Sttarter
//io
//  Created by Prajna Shetty on 27/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#import "JSONModel.h"
#import "MessagesModel.h"

@interface BuzzMessagesModel : JSONModel

@property(nonatomic)NSInteger status;
@property (nonatomic) NSArray<MessagesModel> *messages;

@end
