//
//  WithdrawModel.h
//  Sttarter
//
//  Created by Vijeesh on 10/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "TransferFundModel.h"
@protocol WithdrawModel @end
@interface WithdrawModel : JSONModel

//@property(nonatomic,strong)NSString *status;
//@property(nonatomic,strong)NSString *title;
//@property(nonatomic,strong)TransferFundModel *result;

@property(nonatomic)NSInteger id;
@property(nonatomic,strong)NSString *closing_balance;
@property(nonatomic,strong)NSString *transaction_amount;
@property(nonatomic,strong)NSString *type;
@property(nonatomic,strong)NSString *order_id;
@property(nonatomic,strong)NSString *order_amount;
@property(nonatomic,strong)NSString *transaction_id;
@property(nonatomic,strong)NSString *wallet_id;
@property(nonatomic,strong)NSString *sttarter_reference_id;
@property(nonatomic,strong)NSString *app_user_id;
@property(nonatomic,strong)NSString *pending_balance;
@property(nonatomic,strong)NSString *updated_at;
@property(nonatomic,strong)NSString *created_at;
@property(nonatomic,strong)NSString *description;


@end

