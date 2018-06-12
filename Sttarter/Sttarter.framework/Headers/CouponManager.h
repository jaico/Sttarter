//
//  CouponManager.h
//  Sttarter
//
//  Created by Vijeesh on 20/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CouponModel.h"

@protocol STTarterCouponsDelegate <NSObject>

-(void)redeemCouponSucces:(CouponModel*)modelCoupon;
-(void)redeemCouponFailed:(NSString*)status;

@end


@interface CouponManager : NSObject

@property (nonatomic,strong) id <STTarterCouponsDelegate> delegate;


//Coupon
-(void)redeemCoupon:(NSString*)order_value coupon_code:(NSString*)coupon_code;

+(CouponManager*)sharedCouponClass;

@end
