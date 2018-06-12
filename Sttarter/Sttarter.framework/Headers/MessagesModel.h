//
//  MessagesModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 27/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#import "JSONModel.h"

@protocol MessagesModel @end

@interface MessagesModel : JSONModel


@property(strong,nonatomic)NSString *_id;
@property(strong,nonatomic)NSString *client_id;
@property(strong,nonatomic)NSString *topic;
//@property (nonatomic) MessageInfoModel<Optional> *message;
@property(strong,nonatomic)NSString *created_at;
@property(nonatomic)BOOL is_deleted;
@property(nonatomic)NSInteger __v;


@end
