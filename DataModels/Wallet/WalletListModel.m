//
//  WalletListModel.m
//  Sttarter
//
//  Created by Vijeesh on 07/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "WalletListModel.h"

@implementation WalletListModel
/*
 @property(nonatomic,strong)NSString *created_at;
 @property(nonatomic)NSInteger id;
 @property(nonatomic,strong)NSString *is_active;
 @property(nonatomic,strong)NSString *is_default;
 @property(nonatomic,strong)NSString *balance;
 @property(nonatomic,strong)NSString *name;
 @property(nonatomic,strong)NSString *owner;
 @property(nonatomic,strong)NSArray *part_of;
 @property(nonatomic,strong)NSString *updated_at;
 @property(nonatomic,strong)NSString *wallet_external_id;
 @property(nonatomic,strong)NSArray <WalletMembersModel> *wallet_members;

 */

-(id)initWithDictionary:(NSDictionary*)dict error:(NSError**)err{
    
    self = [super init];
    if (self) {
        self.wallet_members = [NSMutableArray<WalletMembersModel> new];
        
        self.created_at = [self validateString:[dict objectForKey:@"created_at"]];
        self._id = [[dict objectForKey:@"id"] integerValue];
        self.is_active = [[dict objectForKey:@"is_active"] boolValue];
        self.is_default = [[dict objectForKey:@"is_default"] boolValue];
        self.balance =[[dict objectForKey:@"balance"] integerValue];
        self.name = [self validateString:[dict objectForKey:@"name"]];
        self.owner = [self validateString:[dict objectForKey:@"owner"]];
        self.part_of = [self validateString:[dict objectForKey:@"part_of"]];
        self.updated_at = [self validateString:[dict objectForKey:@"updated_at"]];
        self.wallet_external_id = [self validateString:[dict objectForKey:@"wallet_external_id"]];

        if ([[dict objectForKey:@"wallet_members"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in [dict objectForKey:@"wallet_members"]) {
                NSError *err;
                    WalletMembersModel *fieldModel = [[WalletMembersModel alloc] initWithDictionary:item error:&err];
                    [self.wallet_members addObject:fieldModel];
            }
        }
    }
    return self;
}


-(NSString *)validateString:(NSString *)inputString{
    if (inputString == nil || [inputString isEqualToString:@""]) {
        return @"";
    }
    return inputString;
    
}



//
//+ (JSONKeyMapper *)keyMapper
//{
//    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
//                                                                  @"created_at": @"created_at",
//                                                                  @"id": @"id",
//                                                                  @"is_active": @"is_active",
//                                                                  @"is_default": @"is_default",
//                                                                   @"balance": @"balance",
//                                                                   @"name": @"name",
//                                                                   @"owner": @"owner",
//                                                                   @"part_of": @"part_of",
//                                                                   @"updated_at": @"updated_at",
//                                                                   @"wallet_external_id": @"wallet_external_id"
//                                                                  }];
//}

@end
