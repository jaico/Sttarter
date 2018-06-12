//
//  SignUpModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 07/12/16.
//  Copyright © 2016 Spurtree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "SignUpUserInfoModel.h"


@interface SignUpModel : JSONModel

@property(strong,nonatomic)NSString *status;
@property(strong,nonatomic)NSString *title;
@property(strong,nonatomic)NSString *msg;
@property (nonatomic) SignUpUserInfoModel *user;

@end
