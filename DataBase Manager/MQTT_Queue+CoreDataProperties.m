//
//  MQTT_Queue+CoreDataProperties.m
//  Sttarter
//
//  Created by Prajna Shetty on 24/04/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "MQTT_Queue+CoreDataProperties.h"

@implementation MQTT_Queue (CoreDataProperties)

+ (NSFetchRequest<MQTT_Queue *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MQTT_Queue"];
}

@dynamic mqttQueue_MessageHash;
@dynamic mqttQueue_PayloadData;
@dynamic mqttQueue_Topic;

@end
