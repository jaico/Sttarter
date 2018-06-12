//
//  PermittedModulesModel.m
//  Sttarter
//
//  Created by Prajna Shetty on 03/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "PermittedModulesModel.h"

@implementation PermittedModulesModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id": @"permittedId"}];
}


@end
