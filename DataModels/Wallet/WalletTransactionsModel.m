//
//  WalletTransactionsModel.m
//  Sttarter
//
//  Created by Vijeesh on 08/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "WalletTransactionsModel.h"

@implementation WalletTransactionsModel
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

//@property(nonatomic)NSInteger id;
//@property(nonatomic,strong)NSString *transaction_id;
//@property(nonatomic,strong)NSString <Optional> *order_id;// null
//@property(nonatomic,strong)NSString <Optional> *order_amount;// null
//@property(nonatomic,strong)NSString *transaction_amount;
//@property(nonatomic,strong)NSString *type;
//@property(nonatomic,strong)NSString *closing_balance;
//@property(nonatomic,strong)NSString *description;
//@property(nonatomic,strong)NSString *sttarter_reference_id;
//@property(nonatomic,strong)NSString *pending_balance;
//@property(nonatomic,strong)NSString *created_at;
//@property(nonatomic,strong)NSString *updated_at;
//@property(nonatomic,strong)NSString <Optional> *sent_from;// null
//@property(nonatomic,strong)NSString <Optional> *sent_to;// null
//@property(nonatomic,strong)TransactionsWalletModel *wallet;
//@property(nonatomic,strong)transactedByModel *transacted_by;
//@property(nonatomic,strong)NSArray *tags;

//-(id)initWithDictionary:(NSDictionary*)dict error:(NSError**)err{
//    
//    self = [super init];
//    if (self) {
//        self.wallet_members = [NSMutableArray<WalletMembersModel> new];
//        
//        self._id = [[dict objectForKey:@"id"] integerValue];
//        self.transaction_id = [self validateString:[dict objectForKey:@"transaction_id"]];
//        self.owner = [self validateString:[dict objectForKey:@"owner"]];
//        self.part_of = [self validateString:[dict objectForKey:@"part_of"]];
//        self.updated_at = [self validateString:[dict objectForKey:@"updated_at"]];
//        self.wallet_external_id = [self validateString:[dict objectForKey:@"wallet_external_id"]];
//        
//        if ([[dict objectForKey:@"wallet_members"] isKindOfClass:[NSArray class]]) {
//            for (NSDictionary *item in [dict objectForKey:@"wallet_members"]) {
//                NSError *err;
//                WalletMembersModel *fieldModel = [[WalletMembersModel alloc] initWithDictionary:item error:&err];
//                [self.wallet_members addObject:fieldModel];
//            }
//        }
//    }
//    return self;
//}
//
//
//-(NSString *)validateString:(NSString *)inputString{
//    if (inputString == nil || [inputString isEqualToString:@""]) {
//        return @"";
//    }
//    return inputString;
//    
//}
//


@end
