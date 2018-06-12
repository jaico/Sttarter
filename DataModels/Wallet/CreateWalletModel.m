//
//  CreateWalletModel.m
//  Sttarter
//
//  Created by Vijeesh on 06/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "CreateWalletModel.h"

@implementation CreateWalletModel
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

//+(JSONKeyMapper*)keyMapper  Below code also works

//{
//    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id": @"walletId"}];
//}

@end
