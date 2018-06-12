//
//  GetWalletDetailsModel.h
//  Sttarter
//
//  Created by Vijeesh on 08/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "WalletMembersModel.h"
#import "WalletTransactionsModel.h"

@protocol WalletMembersModel @end


@interface GetWalletDetailsModel : JSONModel

@property(nonatomic)NSInteger id;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *owner;
@property(nonatomic,strong)NSString *is_default;
@property(nonatomic,strong)NSString *balance;
@property(nonatomic,strong)NSString *is_active;
@property(nonatomic,strong)NSString *created_at;
@property(nonatomic,strong)NSString *updated_at;
@property(nonatomic,strong)NSString *part_of;
@property(nonatomic,strong)NSArray <WalletMembersModel *> *wallet_members;
@property(nonatomic,strong)NSString *wallet_external_id;


@end

