//
//  GetOtpModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 21/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface GetOtpModel : JSONModel

@property(nonatomic)NSInteger status;
@property(nonatomic)NSString *title;
@property(nonatomic)NSString *msg;


@end
