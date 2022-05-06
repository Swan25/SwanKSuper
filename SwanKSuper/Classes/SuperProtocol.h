//
//  SuperProtocol.h
//  HissNew
//
//  Created by Swan on 2017/3/1.
//  Copyright © 2017年 Swan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SwanNoInterestDelegate <NSObject>

@optional
//点击 不感兴趣
- (void)didSelectNoInterestCell:(NSDictionary *)dictionary;

@end

@protocol SuperCmdDelegate <NSObject>
-(void)superCmdSuccess:(id)data withCmd:(NSString*)cmd;
-(void)superCmdFailed:(NSString*)resp;
@optional
-(void)superCmdFailed:(NSString*)resp withCmd:(NSString*)cmd;
@end


@interface SuperProtocol : NSObject


-(NSString*)getUrl;
-(NSString*)getCmd;
- (NSMutableDictionary*)getUserDicts;
-(void)parse:(NSData*)data;
- (void)parseMessage:(NSData*)data;

@property (nonatomic, strong) id<SuperCmdDelegate> delegate;
@property (nonatomic,copy) NSString * superCmd;
@property (nonatomic, retain) NSMutableDictionary * parameterDic;

@end
