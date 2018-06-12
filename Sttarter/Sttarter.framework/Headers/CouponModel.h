//
//  CouponModel.h
//  Sttarter
//
//  Created by Vijeesh on 24/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "CouponResultModel.h"
@protocol  CouponModel @end
@interface CouponModel : JSONModel

@property(nonatomic,retain)NSString *status;
@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *msg;
@property(nonatomic,retain)CouponResultModel *result;

@end
