//
//  STTarterContentSystem.h
//  Sttarter
//
//  Created by Prajna Shetty on 23/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STTarterContentSystemDelegate <NSObject>
-(void)trackContentSuccess:(NSArray*)arrContentData;
-(void)trackContentFailure:(NSString*)strErrorMessage;
@end



@interface STTarterContentSystem : NSObject
@property (nonatomic,strong) id <STTarterContentSystemDelegate> delegate;

+(STTarterContentSystem*)sharedContentSystemClass;
-(void)getContent:(NSString*)strTag contentModel:(id)contentModel;

@end
