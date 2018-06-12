//
//  WalletMembersModel.h
//  Sttarter
//
//  Created by Vijeesh on 07/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

//#import <Sttarter/Sttarter.h>
#import "JSONModel.h"

//@protocol  WalletMembersModel @end
@interface WalletMembersModel : JSONModel

@property(nonatomic,strong)NSString *member_name;
@property(nonatomic,strong)NSString *created_at;
@property(nonatomic,strong)NSString *updated_at;

@end
