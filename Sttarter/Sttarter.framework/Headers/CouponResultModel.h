//
//  CouponResultModel.h
//  Sttarter
//
//  Created by Vijeesh on 24/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"

@interface CouponResultModel : JSONModel
@property(nonatomic,retain)NSString *couponId;
@property(nonatomic,retain)NSString *order_amount;
@property(nonatomic,retain)NSString *discount_value;
@property(nonatomic,retain)NSString *app_user_id;
@property(nonatomic,retain)NSString *coupon_id;
@property(nonatomic,retain)NSString *updated_at;
@property(nonatomic,retain)NSString *created_at;
@end

