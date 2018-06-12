//
//  AddmemberBaseModel.h
//  Sttarter
//
//  Created by Vijeesh on 07/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "AddMemberModel.h"
@interface AddmemberBaseModel : JSONModel

@property(nonatomic,strong)NSString *result;
@property(nonatomic,strong)NSString *status;
@property(nonatomic,strong)AddMemberModel *member;

@property(nonatomic,strong)NSString *msg;
@property(nonatomic,strong)NSString *title;
@end


