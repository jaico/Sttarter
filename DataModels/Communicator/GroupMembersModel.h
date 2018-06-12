//
//  GroupMembersModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 07/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
@protocol GroupMembersModel @end

@interface GroupMembersModel : JSONModel

@property(strong,nonatomic)NSString *user_id;
@property(strong,nonatomic)NSString *name;
@property(strong,nonatomic)NSString *username;
@property(strong,nonatomic)NSString *email;
@property(strong,nonatomic)NSString *mobile;
@property(strong,nonatomic)NSString <Optional> *avatar;
@property(strong,nonatomic)NSString *group_desc;
@property(nonatomic)NSDictionary <Optional> *meta;

@end
