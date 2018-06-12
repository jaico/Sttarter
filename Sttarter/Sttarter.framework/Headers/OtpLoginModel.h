//
//  OtpLoginModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 24/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface OtpLoginModel : JSONModel

@property(nonatomic)NSInteger status;
@property(strong,nonatomic)NSString *stt_token;
@property(strong,nonatomic)NSString *user_token;
@property(strong,nonatomic)NSString *ie_token;
@property(strong,nonatomic)NSString *app_key;
@property(strong,nonatomic)NSString *app_secret;
@property(strong,nonatomic)NSString *username;

@end
