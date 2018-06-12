//
//  ReferrelSignupModel.h
//  Sttarter
//
//  Created by Vijeesh on 21/12/16.
//  Copyright © 2016 Spurtree. All rights reserved.
//

//#import <Sttarter/Sttarter.h>
#import "JSONModel.h"

@protocol  ReferrelSignupModel @end
@interface ReferrelSignupModel : JSONModel


@property(strong,nonatomic)NSString*title;
@property(strong,nonatomic)NSString*msg;
@property(strong,nonatomic)NSString*code;
@property(strong,nonatomic)NSString*referer_code;
@property(strong,nonatomic)NSString*amount_credited;
@property(strong,nonatomic)NSArray *trigger;


@end

