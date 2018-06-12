//
//  MQTT_QueueModel.h
//  Sttarter
//
//  Created by Prajna Shetty on 10/03/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "JSONModel.h"

@interface MQTT_QueueModel : JSONModel

@property(strong,nonatomic)NSString *topic;
@property(strong,nonatomic)NSString *MessageHash;
@property(nonatomic)NSDictionary <Optional> *payLoad;

@end
