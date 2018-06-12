//
//  GetRefCodeModel.h
//  Sttarter
//
//  Created by Vijeesh on 21/12/16.
//  Copyright © 2016 Spurtree. All rights reserved.
//

//#import <Sttarter/Sttarter.h>
#import "JSONModel.h"

@protocol  GetRefCodeModel @end

@interface GetRefCodeModel : JSONModel


@property(strong,nonatomic)NSString*status;
@property(strong,nonatomic)NSString*title;
@property(strong,nonatomic)NSString*msg;
@property(strong,nonatomic)NSString*code;

@end
