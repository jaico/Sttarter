//
//  WalletModel.h
//  Sttarter
//
//  Created by Vijeesh on 13/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
@protocol WalletModel @end
@interface WalletModel : JSONModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *balance;
@property (nonatomic, strong) NSString *is_active;

@end
