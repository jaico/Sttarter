//
//  Topic_GroupMembers.h
//  Sttarter
//
//  Created by Prajna Shetty on 30/03/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"


@protocol Topic_GroupMembers @end

@interface Topic_GroupMembers : JSONModel

@property(strong,nonatomic)NSString *user_id;
@property(strong,nonatomic)NSString *name;
@property(strong,nonatomic)NSString *username;
@property(strong,nonatomic)NSString *email;
@property(strong,nonatomic)NSString *mobile;
@property(strong,nonatomic)NSString *avatar;
@property(strong,nonatomic)NSString *meta;

@end
