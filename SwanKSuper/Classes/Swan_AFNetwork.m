//
//  Swan_AFNetwork.m
//  HissNew
//
//  Created by Swan on 2017/3/1.
//  Copyright © 2017年 Swan. All rights reserved.
//

#import "Swan_AFNetwork.h"
#import "AFNetworking.h"
//#import "LoginViewController.h"
#import "SVProgressHUD.h"



@implementation Swan_AFNetwork

-(id)init {
    self = [super init];
    if (self != nil) {
        [self AfNetWorkingStatus];
    }
    return self;
}

-(void)dealloc {
    
}
-(void)sendWithAFNetWork_POST:(id)protocol{
    
    SuperProtocol *proto = protocol;
    NSString * _strUrl = nil;
    NSDictionary *user = nil;
    NSError *jsonError;
    NSMutableData *tempJsonData;
    
    user = [[NSDictionary alloc] initWithDictionary:[proto getUserDicts]];
    
    if ([NSJSONSerialization isValidJSONObject:user])
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &jsonError];
        tempJsonData = [NSMutableData dataWithData:jsonData];
        
        NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
        _strUrl = [NSString stringWithFormat:@"%@%@",[proto getUrl],[proto getCmd]];
    }
    
    NSLog(@"\n\n\n------POST-----:%@\n\n\n", _strUrl);
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    //请求头
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.requestSerializer.timeoutInterval = 30;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    if([proto.superCmd isEqualToString:@"zxItem/updateItemStream"]){
        [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    } else {
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    __weak typeof(manager) weakManager = manager;
    [manager POST:_strUrl parameters:user progress:^(NSProgress * _Nonnull uploadProgress) {
        
        NSLog(@"progress==%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSData *data = [NSData dataWithData:responseObject];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"😂😂😂😂😂😂😂😂😂😂😂😂\n%@\n😂😂😂😂😂😂😂😂😂😂😂😂",dic);
        NSString * _respType = [NSString stringWithFormat:@"%@", [dic objectForKey:@"type"]];
//        NSString * _respMessage = [dic objectForKey:@"message"];
        if ([_respType isEqualToString:@"success"]) {
            
            [proto parse:data];
            
        }else{
#pragma mark ---- type == error时,解析message
            
                NSLog(@"type[error] ----- %@",[dic objectForKey:@"message"]);
                if([[dic objectForKey:@"message"] isEqualToString:@"logout"]){
                    
//                    [SVProgressHUD dismiss];
//                    UserInfo * me =[UserInfo getInstance];
//                    me.memberId = @"logout";
//                    [me saveToFile];
//                    LoginViewController *lvc = [[LoginViewController alloc]init];
//                    [lvc setNavigationControllerWithRootController:lvc];
                    
                } else {
                   
                    [proto parseMessage:data];
                }
          
        }
        [weakManager invalidateSessionCancelingTasks:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString* string = [error localizedDescription];
        NSLog(@"failure:%s",__func__);
        NSLog(@"failure:error %@",string);
        [proto parse:nil];
        [weakManager invalidateSessionCancelingTasks:YES];
    }];
    
}
-(void)sendWithAFNetWork_GET:(id)protocol{
    SuperProtocol *proto = protocol;
    NSString * _strUrl = nil;
    NSDictionary *user = nil;
    user = [[NSDictionary alloc] initWithDictionary:[proto getUserDicts]];
    _strUrl = [NSString stringWithFormat:@"%@%@",[proto getUrl],[proto getCmd]];
    NSLog(@"\n\n\n-----GET-----:%@\n\n\n", _strUrl);
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [manager GET:_strUrl parameters:user progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"downloadProgress = %@", downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSData *data = [NSData dataWithData:responseObject];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString * _respType = [NSString stringWithFormat:@"%@", [dic objectForKey:@"type"]];
        NSString * _respMessage = [dic objectForKey:@"message"];
        NSLog(@"\ndic:%@\nmessage:%@\n",dic,_respMessage);
        if ([_respType isEqualToString:@"success"]) {
            
            [proto parse:data];
            
        }else{
#pragma mark ---- type == error时,解析message
            if ( [[dic objectForKey:@"message"] isEqualToString: @"用户已注销"]) {
                //用户注销
                NSLog(@"用户已注销");
                
            }else{
                NSLog(@"type[error] ----- %@",[dic objectForKey:@"message"]);
                [proto parseMessage:data];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString* string = [error localizedDescription];
        NSLog(@"failure:%s",__func__);
        NSLog(@"failure:error %@",string);
        [proto parse:nil];
    }];
    
}
//get 请求
-(void)getRequestAFNetWorking:(NSString *)url{
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer.timeoutInterval = 30;
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//
//    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
//    [dictParam setObject:@"token" forKey:@"response_type"];
//    [dictParam setObject:@"31583810" forKey:@"client_id"];
//    [dictParam setObject:@"1212" forKey:@"state"];
//    [dictParam setObject:@"web" forKey:@"view"];
    
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"downloadProgress = %@", downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"responseObject = %@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"error = %@", error);
    }];
}
//post 请求
-(void)postRequestAfNetWorking:(NSString *)url{
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    //请求头
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.requestSerializer.timeoutInterval = 10;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//        [manager.requestSerializer setValue:@"getHelpToken" forHTTPHeaderField:@"Authorization"];
//        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/json",@"text/plain", nil];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"", nil];
    manager.requestSerializer.timeoutInterval = 30;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//
    NSMutableDictionary *dictParam = [[NSMutableDictionary alloc]init];
//    [dictParam setObject:@"token" forKey:@"response_type"];
//    [dictParam setObject:@"code" forKey:@"response_type"];
//    [dictParam setObject:@"31460989" forKey:@"client_id"];
//    [dictParam setObject:@"http://www.oauth.net/2/" forKey:@"redirect_uri"];
//    
//    [dictParam setObject:@"1212" forKey:@"state"];
//    [dictParam setObject:@"web" forKey:@"view"];
    
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSData *data = [NSData dataWithData:responseObject];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"\n%@\n",dic);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
//下载
-(void)downloadWithAfNetWorking:(NSString *)urlStr{
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    NSURL * url = [NSURL URLWithString:@""];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask * task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //打印进度
        NSLog(@"present:%lf",1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //下载地址
        NSLog(@"targetPath=%@", targetPath);
        //设置下载路径，通过沙盒获取缓存地址，最后返回NSURL对象
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        NSLog(@"respone:%@, filePath:%@", response, filePath);
    }];
    
    [task resume];
}
//上传 工程文件
-(void)uploadWithAFNetWorking{
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    NSDictionary * dict = @{@"1":@"1"};
    
    [manager POST:@"url" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        UIImage * image = [UIImage imageNamed:@"oo"];
        NSData *data = UIImagePNGRepresentation(image);
        
        [formData appendPartWithFileData:data name:@"file" fileName:@"oo" mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印进度
        NSLog(@"present:%lf",1.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"success:%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"failed:%@", error);
    }];
}
-(void)uploadWithAFNetWorkingWith:(id)protocol AndImageData:(NSData *)data withAString:(NSString *)photoName AndImageBData:(NSData *)dataB withBString:(NSString *)fileName{
        
        SuperProtocol *proto = protocol;
        NSString * _strUrl = nil;
        NSDictionary *user = nil;
        NSError *jsonError;
        NSMutableData *tempJsonData;
        
        user = [[NSDictionary alloc] initWithDictionary:[proto getUserDicts]];
        
        if ([NSJSONSerialization isValidJSONObject:user])
        {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &jsonError];
            tempJsonData = [NSMutableData dataWithData:jsonData];
            
            NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
            _strUrl = [NSString stringWithFormat:@"%@%@",[proto getUrl],[proto getCmd]];
        } else {
            
            _strUrl = [NSString stringWithFormat:@"%@%@",[proto getUrl],[proto getCmd]];
        }
        
        NSLog(@"\n\n\n------POST-----:%@\n\n\n", _strUrl);
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    //请求头
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.requestSerializer.timeoutInterval = 30;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    if([proto.superCmd isEqualToString:@"zxItem/updateItemStream"] || [proto.superCmd isEqualToString:@"zxTask/uploadTaskFile"] || [proto.superCmd isEqualToString:@"zxNews/uploadNewsFile"]){
        [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    } else {
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    
    
    [manager POST:_strUrl parameters:user constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
//        UIImage * image = [UIImage imageNamed:@"oo"];
//        NSData *data = UIImagePNGRepresentation(image);
         if(![photoName isEqualToString:@""]){
             
             NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
             formatter.dateFormat = @"yyyyMMddHHmmss";
             NSString *str = [formatter stringFromDate:[NSDate date]];
            
            [formData appendPartWithFileData:data name:photoName fileName:str mimeType:@"image/png"];
         }
        
        
            if(![fileName isEqualToString:@""]){
            
            
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyyMMddHHmmss";
                NSString *str = [formatter stringFromDate:[NSDate date]];
            
                [formData appendPartWithFileData:dataB name:fileName fileName:str mimeType:@"image/png"];
            }
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印进度
        NSLog(@"present:%lf",1.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"success:%@", responseObject);
        NSData *data = [NSData dataWithData:responseObject];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"😂😂😂😂😂😂😂😂😂😂😂😂\n%@\n😂😂😂😂😂😂😂😂😂😂😂😂",dic);
        NSString * _respType = [dic objectForKey:@"type"];
        NSString * _respMessage = [dic objectForKey:@"message"];
        if ([_respType isEqualToString:@"success"]) {
            
            [proto parse:data];
            
        }else{
#pragma mark ---- type == error时,解析message
            
            NSLog(@"type[error] ----- %@",[dic objectForKey:@"message"]);
            if([[dic objectForKey:@"message"] isEqualToString:@"logout"]){
                
                //                    [SVProgressHUD dismiss];
                //                    UserInfo * me =[UserInfo getInstance];
                //                    me.memberId = @"logout";
                //                    [me saveToFile];
                //                    LoginViewController *lvc = [[LoginViewController alloc]init];
                //                    [lvc setNavigationControllerWithRootController:lvc];
                //
            } else {
                
                [proto parseMessage:data];
            }
            
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString* string = [error localizedDescription];
        NSLog(@"failure:%s",__func__);
        NSLog(@"failure:error %@",string);
        [proto parse:nil];
    }];
}
-(void)uploadWithAFNetWorkingWith:(id)protocol AndVideoData:(NSData *)videoData withAString:(NSString *)videoName andFileExt:(NSString *)fileExt andType:(NSString *)type{
        
        SuperProtocol *proto = protocol;
        NSString * _strUrl = nil;
        NSDictionary *user = nil;
        NSError *jsonError;
        NSMutableData *tempJsonData;
        
        user = [[NSDictionary alloc] initWithDictionary:[proto getUserDicts]];
        
        if ([NSJSONSerialization isValidJSONObject:user])
        {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error: &jsonError];
            tempJsonData = [NSMutableData dataWithData:jsonData];
            
            NSLog(@"Register JSON:%@",[[NSString alloc] initWithData:tempJsonData encoding:NSUTF8StringEncoding]);
            _strUrl = [NSString stringWithFormat:@"%@%@",[proto getUrl],[proto getCmd]];
        } else {
            
            _strUrl = [NSString stringWithFormat:@"%@%@",[proto getUrl],[proto getCmd]];
        }
        
        NSLog(@"\n\n\n------POST-----:%@\n\n\n", _strUrl);
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    //请求头
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.requestSerializer.timeoutInterval = 30;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    if([proto.superCmd isEqualToString:@"zxItem/updateItemStream"] || [proto.superCmd isEqualToString:@"zxTask/uploadTaskFile"] || [proto.superCmd isEqualToString:@"zxNews/uploadNewsFile"]){
        [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    } else {
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    
    
    [manager POST:_strUrl parameters:user constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
//        UIImage * image = [UIImage imageNamed:@"oo"];
//        NSData *data = UIImagePNGRepresentation(image);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
         if(![videoName isEqualToString:@""] && [type isEqualToString:@"video"]){

            [formData appendPartWithFileData:videoData name:videoName fileName:[NSString stringWithFormat:@"%@.%@", str, fileExt] mimeType:[NSString stringWithFormat:@"video/%@", fileExt]];
         } else if([type isEqualToString:@"image"]){
             
             [formData appendPartWithFileData:videoData name:videoName fileName:[NSString stringWithFormat:@"%@", str] mimeType:@"image/jpg"];
         }
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印进度
        NSLog(@"present:%lf",1.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
        CGFloat precentP = 1.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount;
        if(precentP <= 9){
            [SVProgressHUD showProgress:precentP];
        } else {
            [SVProgressHUD showProgress:9];
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"success:%@", responseObject);
        NSData *data = [NSData dataWithData:responseObject];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"😂😂😂😂😂😂😂😂😂😂😂😂\n%@\n😂😂😂😂😂😂😂😂😂😂😂😂",dic);
        NSString * _respType = [dic objectForKey:@"type"];
        NSString * _respMessage = [dic objectForKey:@"message"];
        if ([_respType isEqualToString:@"success"]) {
            
            [proto parse:data];
            
        }else{
#pragma mark ---- type == error时,解析message
            
            NSLog(@"type[error] ----- %@",[dic objectForKey:@"message"]);
            if([[dic objectForKey:@"message"] isEqualToString:@"logout"]){
                
                //                    [SVProgressHUD dismiss];
                //                    UserInfo * me =[UserInfo getInstance];
                //                    me.memberId = @"logout";
                //                    [me saveToFile];
                //                    LoginViewController *lvc = [[LoginViewController alloc]init];
                //                    [lvc setNavigationControllerWithRootController:lvc];
                //
            } else {
                
                [proto parseMessage:data];
            }
            
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString* string = [error localizedDescription];
        NSLog(@"failure:%s",__func__);
        NSLog(@"failure:error %@",string);
        [proto parse:nil];
    }];
}

//上传 沙盒或者相册照片
-(void)uploadWithAFNetWorkingAnther{
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    NSDictionary * dict = @{@"1":@"1"};
    
    [manager POST:@"url" parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:@"文件路径"] name:@"file" fileName:@"sd.png" mimeType:@"application/octet-stream" error:nil];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印进度
        NSLog(@"present:%lf",1.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"success:%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"failed:%@", error);
    }];
}
//判断网络
-(void)AfNetWorkingStatus{
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        NSLog(@"%ld", (long)[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus);
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络状态");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络");{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请检查网络" preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                       
                    }]];
                   
                    [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
                }
                
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝数据网");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi网络");
                break;
            default:
                break;
        }
    }];
}
-(UIViewController *)getCurrentVC{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}
-(UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC{
    
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {

        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {

        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){

        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {

        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

@end
