//
//  AuthModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 06/12/16.
//  Copyright © 2016 Spurtree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "PermittedModulesModel.h"


@interface AuthModel : JSONModel
@property(strong,nonatomic)NSString *token; 
@property (nonatomic) NSArray<PermittedModulesModel> *permitted_modules;

@end
