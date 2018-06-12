//
//  TrackUsageModel.h
//  Sttarter
//
//  Created by Vijeesh on 21/12/16.
//  Copyright © 2016 Spurtree. All rights reserved.
//

#import "JSONModel.h"
#import"UsersModel.h"
@protocol  TrackUsageModel @end
@interface TrackUsageModel : JSONModel

@property(strong,nonatomic)NSString*status;
@property(strong,nonatomic)NSArray <UsersModel> *users;


@end
