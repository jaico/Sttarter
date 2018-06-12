//
//  WalletMemberModel.h
//  Sttarter
//
//  Created by Vijeesh on 13/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
@protocol WalletMemberModel @end
@interface WalletMemberModel : JSONModel
//@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *username;
//@property (nonatomic, strong) NSString *mobile;
//@property (nonatomic, strong) NSString *name;
@end
