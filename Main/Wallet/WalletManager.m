//
//  WalletManager.m
//  Sttarter
//
//  Created by Vijeesh on 01/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.
//

#import "WalletManager.h"
#import "DownloadManager.h"
@implementation WalletManager

static WalletManager* sttarterWalletClass = nil;

+ (WalletManager*)sharedWalletClass{
    
    @synchronized([WalletManager class]) {
        if (!sttarterWalletClass){
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSData *myEncodedObject = [prefs objectForKey:@"AUTH_MODEL" ];
            if(myEncodedObject == nil || myEncodedObject == (NSData*)[NSNull null]){
                
                return nil;
                
            }
            AuthModel *modelAuth = (AuthModel *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
            
            for (int i=0; i < modelAuth.permitted_modules.count; i++) {
                
                PermittedModulesModel *modelperModules = [modelAuth.permitted_modules objectAtIndex:i];
                
                if ([[modelperModules.module_name uppercaseString]isEqualToString:@"WALLET"] ) {
                    sttarterWalletClass = [[self alloc] init];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"is_WalletPermitted"];
                    NSLog(@"!!!!!! Wallet is permitted and Initialized !!!!!!");
                    
                    return sttarterWalletClass;
                }
            }
            return nil;
            
        }
        return sttarterWalletClass;
    }
}


-(void)testWallet
{

    NSString *strXAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_APP_TOKEN"];
    NSString *strXUserToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"STARTTER_X_USER_TOKEN"];
    [[DownloadManager shared]testWallet:strXUserToken appToken:strXAppToken completionBlock:^(NSError *error, NSString *status) {
        
        
        if (error)
        {
            NSLog(@"testWallet Failed");
        }
        else
        {
            NSLog(@"testWallet Success");
        }
    }];
}

-(void)createWallet:(NSString*)externalId
{
    
    NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id or Username
    
    [[DownloadManager shared]createWallet:externalId externalUserId:strExternalUserId completionBlock:^(NSError *error,CreateWalletBaseModel *modelWalletBase,NSString *strError)
     {
         if (error)
         {
             [self.delegate createWalletFailed:strError];
         }
         else
         {
             [self.delegate createWalletSuccess:modelWalletBase];
         }
     }];
    
}


-(void)getWalletTransactions:(NSString*)wallet_id
{
    
    [[DownloadManager shared]getWalletTransactions:wallet_id completionBlock:^(NSError *error, NSArray *arrWalletList, NSString *strError)
     {
         if (error)
         {
             [self.delegate getWalletTransactionFailed:error.localizedDescription];
         }
         else
         {
             [self.delegate getWalletTransactionSuccess:arrWalletList];
         }
     }];

}


-(void)getWalletList
{
//    NSMutableDictionary *dctLoginInfo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"STT_LOGIN_INFO"] mutableCopy];
//    NSString *userName=[dctLoginInfo valueForKey:@"username"];
//    
    NSString *strExternalUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_ID"]; // external user id or Username
    
    [[DownloadManager shared]getWalletList:strExternalUserId completionBlock:^(NSError *error, NSArray *arrWalletList, NSString *strError)
    {
        if (error)
        {
            [self.delegate getWalletFailed:error.localizedDescription];
        }
        else
        {
            [self.delegate getWalletSucces:arrWalletList];
        }
    }];
}

//done
-(void)addMemberToWallet:(NSString*)wallet_id member_externalId:(NSString*)member_externalId
{
    
    [[DownloadManager shared]addMember:(NSString*)wallet_id member_externalId:(NSString*)member_externalId completionBlock:^(NSError *error,AddmemberBaseModel *model,NSString *strError) {
        if (error)
        {
            [self.delegate addMemberFailed:error.localizedDescription];
        }
        else
        {
            [self.delegate addMemberSuccess:model];
        }
    }];
}

-(void)getWalletDetails:(NSString*)wallet_id
{
    [[DownloadManager shared]getWalletDetails:wallet_id completionBlock:^(NSError *error, GetWalletDetailsModel *model, NSString *strError) {
        
        if (error)
        {
            [self.delegate getWalletDetailsFailed:error.localizedDescription];
        }
        else
        {
            [self.delegate getWalletDetailsSuccess:model];
        }
    }];
}



///done
-(void)depositMoneyToWallet:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount  order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description order_tags:(NSString*)tags
{
    
    [[DownloadManager shared]walletDeposit:wallet_id order_amount:order_amount transaction_amount:transaction_amount order_id:order_id transaction_id:transaction_id description:description tags:tags completionBlock:^(NSError *error, WalletDepositBaseModel *model, NSString *strError)
     {
        if (error)
        {
            [self.delegate depositFailed:error.localizedDescription];
        }
        else
        {
            [self.delegate depositSucces:model];
        }
    }];
}

-(void)transferFundsToUserDefaultWallet:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount  order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description receiver_externalId:(NSString*)receiver_externalId
{
    
    [[DownloadManager shared]transferFunds:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount  order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description receiver_externalId:(NSString*)receiver_externalId completionBlock:^(NSError *error, TransferFundModel *model, NSString *strError)
    {
        if (error)
        {
            [self.delegate transferFundFailed:error.localizedDescription];
        }
        else
        {
            [self.delegate transferFundSuccess:model];
        }
    }];
}


-(void)withdrawMoneyFromWallet:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount  order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description order_tags:(NSString*)tags
{
  
    
    [[DownloadManager shared]withDrawFunds:wallet_id order_amount:order_amount transaction_amount:transaction_amount order_id:order_id transaction_id:transaction_id description:description tags:tags completionBlock:^(NSError *error, WithdrawModel *model, NSString *strError) {
        if (error)
        {
            [self.delegate withDrawFundFailed:error.localizedDescription];
        }
        else
        {
            [self.delegate withDrawFundSucces:model];
        }
    }];
}


-(void)removeMemberFromWallet:(NSString*)wallet_id member_externalId:(NSString*)member_externalId// -DOne **
{
    
    NSLog(@"wallet Manager entered!");
    
    [[DownloadManager shared]removeMember:wallet_id member_externalUserId:member_externalId completionBlock:^(NSError *error, NSString *msg)
    {
        if (error)
        {
            [self.delegate memberRemovedFailed:error.localizedDescription];
        }
        else
        {
            [self.delegate memberRemovedSuccess:msg];
        }
        
    }];
}

-(void)addSubWallet:(NSString*)wallet_name display_name:(NSString*)display_name users_list:(NSArray*)users_list
{
    
    [[DownloadManager shared]subwallet:wallet_name display_name:display_name users_list:users_list completionBlock:^(NSError *error, SubwalletModel *model,NSString *status)
    {
        if (error)
        {
            [self.delegate subwalletFailed:error.localizedDescription];
        }
        else
        {
            [self.delegate subwalletSuccess:model];
        }
    }];
}

@end
