//
//  MemberswithWalletModel.h
//  Sttarter
//
//  Created by Vijeesh on 13/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "WalletModel.h"
#import "WalletMemberModel.h"
@protocol MemberswithWalletModel @end
@interface MemberswithWalletModel : JSONModel
@property (nonatomic, strong) WalletModel *wallet;
@property (nonatomic, strong) WalletMemberModel *wallet_member;
@end

