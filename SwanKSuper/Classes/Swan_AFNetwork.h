//
//  Swan_AFNetwork.h
//  HissNew
//
//  Created by Swan on 2017/3/1.
//  Copyright © 2017年 Swan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuperProtocol.h"


@interface Swan_AFNetwork : NSObject

-(void)sendWithAFNetWork_POST:(id)protocol;

-(void)sendWithAFNetWork_GET:(id)protocol;

//图片
-(void)uploadWithAFNetWorkingWith:(id)protocol AndImageData:(NSData *)data withAString:(NSString *)photoName AndImageBData:(NSData *)dataB withBString:(NSString *)fileName;

//视频 图片带标点
-(void)uploadWithAFNetWorkingWith:(id)protocol AndVideoData:(NSData *)videoData withAString:(NSString *)videoName andFileExt:(NSString *)fileExt andType:(NSString *)type;

//get 请求
-(void)getRequestAFNetWorking:(NSString *)url;
-(void)postRequestAfNetWorking:(NSString *)url;
@end
