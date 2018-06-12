//
//  CreateWalletBaseModel.h
//  Sttarter
//
//  Created by Vijeesh on 06/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//
#import "JSONModel.h"
#import"CreateWalletModel.h"
@interface CreateWalletBaseModel : JSONModel
@property(nonatomic,strong)NSString *status;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)CreateWalletModel *wallet;


@end
