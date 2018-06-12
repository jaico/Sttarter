//
//  WalletTransactionsModel.h
//  Sttarter
//
//  Created by Vijeesh on 08/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "WalletModel.h"
#import "TransactionsWalletModel.h"
#import "transactedByModel.h"

@protocol WalletTransactionsModel @end
@interface WalletTransactionsModel : JSONModel

@property(nonatomic)NSInteger id;
@property(nonatomic,strong)NSString *transaction_id;
@property(nonatomic,strong)NSString <Optional> *order_id;// null
@property(nonatomic,strong)NSString <Optional> *order_amount;// null
@property(nonatomic,strong)NSString *transaction_amount;
@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSString *closing_balance;
@property(nonatomic,strong)NSString *description;
@property(nonatomic,strong)NSString *sttarter_reference_id;
@property(nonatomic,strong)NSString *pending_balance;
@property(nonatomic,strong)NSString *created_at;
@property(nonatomic,strong)NSString *updated_at;
@property(nonatomic,strong)NSString <Optional> *sent_from;// null
@property(nonatomic,strong)NSString <Optional> *sent_to;// null
@property(nonatomic,strong)TransactionsWalletModel *wallet;
@property(nonatomic,strong)transactedByModel *transacted_by;
@property(nonatomic,strong)NSArray *tags;

@end
