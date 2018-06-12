//
//  CouponResultModel.m
//  Sttarter
//
//  Created by Vijeesh on 24/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "CouponResultModel.h"

@implementation CouponResultModel
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id": @"couponId"}];
}

@end
