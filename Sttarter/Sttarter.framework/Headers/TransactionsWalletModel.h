//
//  TransactionsWalletModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 23/08/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"

@protocol TransactionsWalletModel @end
@interface TransactionsWalletModel : JSONModel

@property(nonatomic)NSInteger id;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *transaction_id;
@property(nonatomic,strong)NSString *balance;
@property(nonatomic,strong)NSString *is_default;
@property(nonatomic,strong)NSString *is_active;
@property(nonatomic,strong)NSString *external_id;
@property(nonatomic,strong)NSString *created_at;
@property(nonatomic,strong)NSString *updated_at;
@property(nonatomic,strong)NSString *app_user_id;
@property(nonatomic,strong)NSString <Optional> *wallet_group_id;//null
@property(nonatomic,strong)NSArray *tags;

@end

