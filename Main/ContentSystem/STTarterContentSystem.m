//
//  STTarterContentSystem.m
//  Sttarter
//
//  Created by Prajna Shetty on 23/01/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "STTarterContentSystem.h"
#import "DownloadManager.h"

@implementation STTarterContentSystem


static STTarterContentSystem* sttarterContentSystemClass = nil;

//+(STTarterContentSystem*)sharedContentSystemClass
//{
//    @synchronized([STTarterContentSystem class])
//    {
//        if (!sttarterContentSystemClass)
//            sttarterContentSystemClass = [[self alloc] init];
//        return sttarterContentSystemClass;
//    }
//    return nil;
//}



+ (STTarterContentSystem*)sharedContentSystemClass{
    
    @synchronized([STTarterContentSystem class]) {
        if (!sttarterContentSystemClass){
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSData *myEncodedObject = [prefs objectForKey:@"AUTH_MODEL" ];
            
            if(myEncodedObject == nil || myEncodedObject == (NSData*)[NSNull null]){
                
                return nil;
                
            }
            AuthModel *modelAuth = (AuthModel *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
            
            for (int i=0; i < modelAuth.permitted_modules.count; i++) {
                
                PermittedModulesModel *modelperModules = [modelAuth.permitted_modules objectAtIndex:i];
                
//#ifdef DEBUG
//#   define NSLog(...) NSLog(__VA_ARGS__)
//#else
//#   define NSLog(...) (void)0
//#endif
                
                
                if ([[modelperModules.module_name uppercaseString]isEqualToString:@"CONTENT SYSTEM"] ) {
                    sttarterContentSystemClass = [[self alloc] init];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"is_ContentSystemPermitted"];
                    NSLog(@"!!!!!! Content System is permitted and Initialized !!!!!!");
                    
                    return sttarterContentSystemClass;
                }
            }
            return nil;
            
        }
        return sttarterContentSystemClass;
    }
}

-(void)getContent:(NSString*)strTag contentModel:(id)contentModel{
    
    NSLog(@"*cccccc*CONTENT SYSTEM called***");
    
    NSString *strAppID = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_ID"];
    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    
    NSLog(@" *cccccc* strAppID :%@ ,strXAppToken: %@",strAppID,strXAppToken);
    NSLog(@" *cccccc* ***Content_Tag :'%@'***",strTag);
    NSLog(@" *cccccc* ***Content_Model :'%@'***",strTag);
    
    
    [[DownloadManager shared] STT_ContentSystem_App_XToken:strXAppToken AppKey:strAppID Tag:strTag contentModel:(id)contentModel completionBlock:^(NSError *error,NSArray *arrContentData,NSString *errTitle, NSString *errMsg){
        
        NSMutableDictionary *dctAlertInfo;
        
        if (error) // failed
        {
            NSLog(@"*** Content System API err:  %@ ***",errMsg);
            dctAlertInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            errMsg, @"Alert_Msg",
                            @"Error", @"Alert_Title",
                            nil];
            [self.delegate trackContentFailure:errMsg];
            
        }
        else // success
        {// send the array of Data objects
            [self.delegate trackContentSuccess:arrContentData];
            
            
        }
        
        
    }];
    
}




@end
