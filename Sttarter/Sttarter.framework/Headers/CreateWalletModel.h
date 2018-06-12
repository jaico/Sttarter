//
//  CreateWalletModel.h
//  Sttarter
//
//  Created by Vijeesh on 06/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "CreateWalletModel.h"

@protocol  CreateWalletBaseModel @end
@interface CreateWalletModel : JSONModel

@property(nonatomic)NSInteger id;
//@property(nonatomic,strong)NSString *walletId;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *balance;
@property(nonatomic,strong)NSString *is_active;

@end



