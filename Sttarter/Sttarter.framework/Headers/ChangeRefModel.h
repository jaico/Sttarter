//
//  ChangeRefModel.h
//  Sttarter
//
//  Created by Vijeesh on 21/12/16.
//  Copyright © 2016 Spurtree. All rights reserved.
//

//#import <Sttarter/Sttarter.h>
#import "JSONModel.h"

@protocol  ChangeRefModel @end

@interface ChangeRefModel : JSONModel

@property(strong,nonatomic)NSString*status;
@property(strong,nonatomic)NSString*title;
@property(strong,nonatomic)NSString*msg;

@end
