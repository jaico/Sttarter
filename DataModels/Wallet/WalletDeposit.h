//
//  WalletDeposit.h
//  Sttarter
//
//  Created by Vijeesh on 08/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//


#import "JSONModel.h"
@interface WalletDeposit : JSONModel
@property(nonatomic,strong)NSString *remaining_balance;
@property(nonatomic,strong)NSString *order_amount;
@property(nonatomic,strong)NSString *transaction_amount;
@property(nonatomic,strong)NSString *transaction_id;
@property(nonatomic,strong)NSString *order_id;


@end
