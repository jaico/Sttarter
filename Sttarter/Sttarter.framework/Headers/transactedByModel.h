//
//  transactedByModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 23/08/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import "AddMemberModel.h"
@protocol transactedByModel @end
@interface transactedByModel : JSONModel

@property(nonatomic,strong)NSString <Optional> *app_user;//null
@property(nonatomic,strong)AddMemberModel *admin;

@end

//"app_user": null,
//"admin": {
//    "name": "Admin",
//    "email": "admin@sttarter.com",
//    "mobile": "9999440110"
//}
