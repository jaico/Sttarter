//
//  SubwalletModel.h
//  Sttarter
//
//  Created by Vijeesh on 13/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "AdminwalletModel.h"
#import "MemberswithWalletModel.h"
@protocol SubwalletModel @end
@interface SubwalletModel : JSONModel
@property(nonatomic,strong)NSString *status;
@property(nonatomic,strong)AdminwalletModel *admin_wallet;
@property(nonatomic,strong)NSArray <MemberswithWalletModel> *members_with_wallet;
@end


