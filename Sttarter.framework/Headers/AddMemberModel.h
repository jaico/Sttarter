//
//  AddMemberModel.h
//  Sttarter
//
//  Created by Vijeesh on 07/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"

@interface AddMemberModel : JSONModel
@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *mobile;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *username;
@end

//"admin": {
//    "name": "Admin",
//    "email": "admin@sttarter.com",
//    "mobile": "9999440110"
//}
