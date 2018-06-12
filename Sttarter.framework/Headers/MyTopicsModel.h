//
//  MyTopicsModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 27/10/16.
//  Copyright © 2016 Spurtree Technologies. All rights reserved.
//

#import "JSONModel.h"
#import "TopicsModel.h"

@interface MyTopicsModel : JSONModel

@property(strong,nonatomic)NSString *status;
@property(strong,nonatomic)NSArray <TopicsModel> *topics;


@end
