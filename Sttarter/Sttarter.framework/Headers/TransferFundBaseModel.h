//
//  TransferFundBaseModel.h
//  Sttarter
//
//  Created by Vijeesh on 08/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "TransferFundModel.h"
@interface TransferFundBaseModel : JSONModel
@property(nonatomic,strong)NSString *status;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)TransferFundModel *result;
@end



