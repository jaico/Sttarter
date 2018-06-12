//
//  SignUpUserInfoModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 07/12/16.
//  Copyright © 2016 Spurtree. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol SignUpUserInfoModel @end

@interface SignUpUserInfoModel : JSONModel

@property(strong,nonatomic)NSString *stt_id;
@property(strong,nonatomic)NSString *name;
@property(strong,nonatomic)NSString *email;
@property(strong,nonatomic)NSString *mobile;
@property(strong,nonatomic)NSString *username;
@property(strong,nonatomic)NSString *master_topic;
@property(strong,nonatomic)NSString *org_topic;
@property(strong,nonatomic)NSString *user_token;
@property(strong,nonatomic)NSString *password;
@property(strong,nonatomic)NSString *meta;
@property(strong,nonatomic)NSString *avatar;


@end
