//
//  WalletListModel.h
//  Sttarter
//
//  Created by Vijeesh on 07/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "WalletMembersModel.h"


@protocol  WalletMembersModel @end
@interface WalletListModel : JSONModel

@property(nonatomic,strong)NSString *created_at;
@property(nonatomic)NSInteger _id;
@property(nonatomic)BOOL is_active;
@property(nonatomic)BOOL is_default;
//@property(nonatomic,strong)NSString *balance;
@property(nonatomic)NSInteger balance;

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *owner;
@property(nonatomic,strong)NSString *part_of;
@property(nonatomic,strong)NSString *updated_at;
@property(nonatomic,strong)NSString *wallet_external_id;
@property(nonatomic,strong)NSMutableArray <WalletMembersModel> *wallet_members;



@end

