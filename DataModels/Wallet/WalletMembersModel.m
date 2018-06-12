//
//  WalletMembersModel.m
//  Sttarter
//
//  Created by Vijeesh on 07/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "WalletMembersModel.h"

@implementation WalletMembersModel
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id": @"walletID"}];
}
@end
