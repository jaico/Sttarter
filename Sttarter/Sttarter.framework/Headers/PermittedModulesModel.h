//
//  PermittedModulesModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 03/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"

@protocol PermittedModulesModel @end

@interface PermittedModulesModel : JSONModel

@property(strong,nonatomic)NSString *created_at;
@property(strong,nonatomic)NSString *desc;
@property(strong,nonatomic)NSString *permittedId;
@property(strong,nonatomic)NSString *is_enabled;
@property(strong,nonatomic)NSString *module_name;
@property(strong,nonatomic)NSString *updated_at;

@end
