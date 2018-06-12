//
//  InteractedWithModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 10/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"
@protocol InteractedWithModel @end

@interface InteractedWithModel : JSONModel

@property(strong,nonatomic)NSString *topic;
@property(strong,nonatomic)NSString *type;
@property(nonatomic)NSInteger is_public;
@property(nonatomic)NSInteger subscriber_count;
@property(nonatomic)NSInteger topic_id;
@property(nonatomic)NSDictionary <Optional> *meta;

@end
