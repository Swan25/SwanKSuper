//
//  SuperProtocol.m
//  HissNew
//
//  Created by Swan on 2017/3/1.
//  Copyright © 2017年 Swan. All rights reserved.
//

#import "SuperProtocol.h"
//#import "LoginViewController.h"
//#import "SVProgressHUD.h"

//#define BUSINESS_URL @"https://service.yeehomechain.com/boardroom-webservice/rest/" //测试
#define BUSINESS_URL @"https://service.yilianchain.com/boardroom-webservice/rest/"  //正式

@implementation SuperProtocol

-(id)init {
    self = [super init];
    if (self != nil) {
        
    }
    return self;
}

-(NSString*)getUrl{
    return BUSINESS_URL;
}

-(NSString *)getCmd{
    return _superCmd;
}

- (NSMutableDictionary*)getUserDicts{
    return _parameterDic;
}
-(void)parse:(NSData*)data{
    if (data != nil) {
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString * _respMessage = [dic objectForKey:@"message"];
        id obj  = [dic objectForKey:@"data"];
        NSLog(@"\ndic:%@\nmessage:%@\n",dic,_respMessage);
        
        if([_superCmd isEqualToString:@"zxNews/searchNewsInfo"]){
            
            if([[[_parameterDic objectForKey:@"params"] objectForKey:@"newsType"] isEqualToString:@"1"]){
                //文章
                [_delegate superCmdSuccess:obj withCmd:[NSString stringWithFormat:@"%@1", _superCmd]];
            } else if([[[_parameterDic objectForKey:@"params"] objectForKey:@"newsType"] isEqualToString:@"6"]){
                //视频
                [_delegate superCmdSuccess:obj withCmd:[NSString stringWithFormat:@"%@6", _superCmd]];
            } else {
                
                [_delegate superCmdSuccess:obj withCmd:_superCmd];
            }
        } else {
            [_delegate superCmdSuccess:obj withCmd:_superCmd];
        }
        
    }else{
        [_delegate superCmdFailed:@"系统异常"];
        
//        [SVProgressHUD dismiss];
//        UserInfo * me =[UserInfo getInstance];
//        me.memberId = @"logout";
//        [me saveToFile];
//        LoginViewController *lvc = [[LoginViewController alloc]init];
//        [lvc setNavigationControllerWithRootController:lvc];
    }
}
- (void)parseMessage:(NSData*)data{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    [_delegate superCmdFailed:[dic objectForKey:@"message"]];
    
    if([_delegate respondsToSelector:@selector(superCmdFailed:withCmd:)]){
        [_delegate superCmdFailed:[dic objectForKey:@"message"] withCmd:_superCmd];
    }
}
@end
