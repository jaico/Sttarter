//
//  CouponManager.m
//  Sttarter
//
//  Created by Vijeesh on 20/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "CouponManager.h"
#import "DownloadManager.h"
#import "CouponModel.h"

@implementation CouponManager

static CouponManager* sttarterCouponClass = nil;

+(CouponManager*)sharedCouponClass
{
    @synchronized([CouponManager class])
    {
        if (!sttarterCouponClass)
            sttarterCouponClass = [[self alloc] init];
        
        return sttarterCouponClass;
    }
    return nil;
}




//Redeem coupon
-(void)redeemCoupon:(NSString*)order_value coupon_code:(NSString*)coupon_code
{
    NSLog(@"RedeemCoupon Start%@%@",order_value,coupon_code);
    
    NSMutableDictionary *dctLoginInfo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"STT_LOGIN_INFO"] mutableCopy];
    NSString *userName=[dctLoginInfo valueForKey:@"username"];
    
    NSMutableDictionary *dctJSon = [[NSMutableDictionary alloc]init];
    [dctJSon setValue:userName forKey:@"username"];
    [dctJSon setValue:order_value forKey:@"order_value"];
    [dctJSon setValue:coupon_code forKey:@"coupon_code"];
    
    NSLog(@"json%@",dctJSon);
    
 
   [[DownloadManager shared]redeemCoupon:userName order_value:order_value coupon_code:coupon_code completionBlock:^(NSError *error, CouponModel *modelCoupon)
    {
        if (error)
        {
            [self.delegate redeemCouponFailed:modelCoupon.status];
        }
        else
        {
            [self.delegate redeemCouponSucces:modelCoupon];

        }
    }];
    
}

@end
