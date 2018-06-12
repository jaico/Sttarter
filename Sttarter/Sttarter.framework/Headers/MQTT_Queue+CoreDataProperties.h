//
//  MQTT_Queue+CoreDataProperties.h
//  Sttarter
//
//  Created by Prajna Shetty on 24/04/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "MQTT_Queue+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MQTT_Queue (CoreDataProperties)

+ (NSFetchRequest<MQTT_Queue *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *mqttQueue_MessageHash;
@property (nullable, nonatomic, retain) NSObject *mqttQueue_PayloadData;
@property (nullable, nonatomic, copy) NSString *mqttQueue_Topic;

@end

NS_ASSUME_NONNULL_END
