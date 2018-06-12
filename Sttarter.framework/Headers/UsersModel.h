//
//  UsersModel.h
//  Sttarter
//
//  Created by Vijeesh on 21/12/16.
//  Copyright © 2016 Spurtree. All rights reserved.
//

#import "JSONModel.h"

@protocol  UsersModel @end
@interface UsersModel : JSONModel


@property(strong,nonatomic)NSString*name;
@property(strong,nonatomic)NSString*username;
@property(strong,nonatomic)NSString*avatar;
@property(strong,nonatomic)NSString*mobile;
@property(strong,nonatomic)NSString*email;
@property(strong,nonatomic)NSString*signup_date;



@end
