//
//  WalletManager.h
//  Sttarter
//
//  Created by Vijeesh on 01/02/17.
//  Copyright © 2017 Spurtree. All rights reserved.


#import <Foundation/Foundation.h>
#import "CreateWalletBaseModel.h"
#import "WalletListModel.h"
#import "GetWalletDetailsModel.h"
#import "AddmemberBaseModel.h"
#import "WalletDepositBaseModel.h"
#import "TransferFundBaseModel.h"
#import "WithdrawModel.h"
#import "SubwalletModel.h"
#import "WalletTransactionsModel.h"

@protocol STTarterWalletDelegate <NSObject>

//@optional
-(void)getWalletFailed:(NSString*)error;
-(void)getWalletSucces:(NSArray*)arrWalletList;

-(void)createWalletFailed:(NSString*)error;
-(void)createWalletSuccess:(CreateWalletBaseModel*)model;

-(void)addMemberSuccess:(AddmemberBaseModel*)model;
-(void)addMemberFailed:(NSString*)error;

-(void)getWalletDetailsFailed:(NSString*)error;
-(void)getWalletDetailsSuccess:(GetWalletDetailsModel*)model;

-(void)depositFailed:(NSString*)error;
-(void)depositSucces:(WalletDepositBaseModel*)model;

-(void)transferFundFailed:(NSString*)error;
-(void)transferFundSuccess:(TransferFundModel*)model;

-(void)withDrawFundFailed:(NSString*)error;
-(void)withDrawFundSucces:(WithdrawModel*)model;

-(void)memberRemovedFailed:(NSString*)error;
-(void)memberRemovedSuccess:(NSString*)msg;

-(void)subwalletFailed:(NSString*)error;
-(void)subwalletSuccess:(SubwalletModel*)model;

-(void)getWalletTransactionFailed:(NSString*)error;
-(void)getWalletTransactionSuccess:(NSArray*)arrTransactionsList;

@end

@interface WalletManager : NSObject

+(WalletManager*)sharedWalletClass;

@property (nonatomic,strong) id <STTarterWalletDelegate> delegate;
 
-(void)createWallet:(NSString*)externalId; //-DONE**

-(void)getWalletDetails:(NSString*)wallet_id; //-DONE**

-(void)depositMoneyToWallet:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount  order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description order_tags:(NSString*)tags; // -DONE**

-(void)withdrawMoneyFromWallet:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount  order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description order_tags:(NSString*)tags; // -DONE**

-(void)transferFundsToUserDefaultWallet:(NSString*)wallet_id order_amount:(NSString*)order_amount transaction_amount:(NSString*)transaction_amount  order_id:(NSString*)order_id transaction_id:(NSString*)transaction_id description:(NSString*)description receiver_externalId:(NSString*)receiver_externalId ; // -DONE**

-(void)addMemberToWallet:(NSString*)wallet_id member_externalId:(NSString*)member_externalId;//-DONE**

-(void)addSubWallet:(NSString*)wallet_name display_name:(NSString*)display_name users_list:(NSArray*)users_list; // DOne**

-(void)removeMemberFromWallet:(NSString*)wallet_id member_externalId:(NSString*)member_externalId;// -DOne **

-(void)getWalletList;

-(void)getWalletTransactions:(NSString*)wallet_id; // DOne**

-(void)testWallet;

@end
