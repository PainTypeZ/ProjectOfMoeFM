//
//  PTWebUtils.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/9.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTWebUtils.h"

#import "MoefmAPIConst.h"
#import "PTOAuthTool.h"
#import "NSString+PTCollection.h"
#import "RadioResponse.h"

@implementation PTWebUtils

/* 要学习异常处理,现在的处理方式太差劲了 */

#pragma mark - public methods
// 请求电台列表信息
+ (void)requestRadioListInfoWithPagea:(NSUInteger)currentPage andPerPage:(NSUInteger)perpageNumber completionHandler:(callback)callback errorHandler:(error)errorHandler {
    NSString *page = [NSString stringWithFormat:@"%lu", (unsigned long)currentPage];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeWikiTypeValue forKey:MoeWikiTypeKey];
    [params setObject:page forKey:MoePageKey];
    if (perpageNumber != 0) {
        NSString *perpage = [NSString stringWithFormat:@"%lu", (unsigned long)perpageNumber];
        [params setObject:perpage forKey:MoePerPageKey];
    }
    
    
    NSURL *url = [PTWebUtils getCompletedAPIKeyRequestURLWithURLString:MoeRadioListURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSString *errorString = [NSString stringWithFormat:@"%@", error];
            NSLog(@"%@", errorString);
            errorHandler(errorString);
        }else{
            if (data) {
                NSError *jsonModelError;
                
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                RadioResponse *radioResponse = [[RadioResponse alloc] initWithDictionary:jsonDictionary[MoeResponseKey] error:&jsonModelError];
                NSLog(@"%@", jsonModelError);
                NSMutableArray *callbackMuatableArray = [radioResponse.wikis mutableCopy];
                callback(callbackMuatableArray);
            }else{
                NSString *errorString = @"request data is nil";
//                NSLog(@"%@", errorString);
                errorHandler(errorString);
            }
        }
    }];
    [task resume];
}

// 请求某个电台专辑的歌曲列表信息，除了获取歌曲总数外，大概是没其他用的接口。。。
+ (void)requestRadioSongsInfoWithWiki_id:(NSString *)wiki_id completionHandler:(callback)callback errorHandler:(error)errorHandler {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeObjTypeValue forKey:MoeObjTypeKey];
    if ([wiki_id  isEqualToString: @"fav"]) {
        [params setObject:@"song" forKey:@"fav"];
    }else{
        [params setObject:wiki_id forKey:MoeWikiIdKey];
    }
    
    NSURL *url = [PTWebUtils getCompletedAPIKeyRequestURLWithURLString:MoeRadioSongsURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {

            NSString *errorString = [NSString stringWithFormat:@"%@", error];
            NSLog(@"%@", errorString);
            errorHandler(errorString);
        }else{
            if (data) {
                NSError *jsonModelError;
                
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                RadioResponse *radioResponse = [[RadioResponse alloc] initWithDictionary:jsonDictionary[MoeResponseKey] error:&jsonModelError];
                NSLog(@"%@", jsonModelError);
                RadioInformation *radioInformation = radioResponse.information;
                callback(radioInformation);
            }else{

                NSString *errorString = @"request data is nil";
//                NSLog(@"%@", errorString);
                errorHandler(errorString);
            }
        }
    }];
    
    [task resume];
}

// 请求电台播放列表，需要radio = wiki_id参数，第几页page，每页多少歌曲数量perpage，注意最后一页返回的结果可能不够perpage数量; 本工程使用perpage=@"9"测试;登录后需要将radio参数改为fav = "song"
+ (void)requestRadioPlayListWithRadio_id:(NSString *)radio_id andPage:(NSUInteger)currentPage andPerpage:(NSUInteger)perpageNumber completionHandler:(callback)callback errorHandler:(error)errorHandler {
    
    NSString *page = [NSString stringWithFormat:@"%lu", (unsigned long)currentPage];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeAPIValue forKey:MoeAPIKey];
    
    if ([radio_id  isEqualToString: @"fav"]) {
        [params setObject:@"song" forKey:@"fav"];
    }else{
        [params setObject:radio_id forKey:MoeRadioPlayListKey];
    }
    [params setObject:page forKey:MoePageKey];
    if (perpageNumber != 0) {
        NSString *perpage = [NSString stringWithFormat:@"%lu", (unsigned long)perpageNumber];
        [params setObject:perpage forKey:MoePerPageKey];
    }
    
    NSURL *url = [PTWebUtils getCompletedAPIKeyRequestURLWithURLString:MoeRadioPlayURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {

            NSString *errorString = [NSString stringWithFormat:@"%@", error];
            NSLog(@"%@", errorString);
            errorHandler(errorString);
        }else{
            if (data) {
                NSError *jsonModelError;
                
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                RadioResponse *radioResponse = [[RadioResponse alloc] initWithDictionary:jsonDictionary[MoeResponseKey] error:&jsonModelError];
                NSLog(@"%@", jsonModelError);
                
                NSMutableArray *callbackMutableArray = [radioResponse.playlist mutableCopy];
                callback(callbackMutableArray);
                
            }else{

                NSString *errorString = @"request data is nil";
//                NSLog(@"%@", errorString);
                errorHandler(errorString);
            }
        }
    }];
    [task resume];
}
// 添加或者删除收藏
+ (void)requestUpdateToAddOrDelete:(NSString *)addOrDelete andObjectType:(NSString *)fav_obj_type andObjectID:(NSString *)fav_obj_id completionHandler:(callback)callback errorHandler:(error)errorHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fav_obj_type forKey:@"fav_obj_type"];
    [params setObject:fav_obj_id forKey:@"fav_obj_id"];
    NSString *urlString;
    if ([addOrDelete  isEqualToString: @"add"]) {
        urlString = MoeAddFavURL;
        [params setObject:@"1" forKey:@"fav_type"];
    }else if([addOrDelete  isEqualToString: @"delete"]){
        urlString = MoeDeleteFavURL;
    }
    
    NSURL *url = [PTWebUtils getCompletedAPIKeyRequestURLWithURLString:urlString andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {

            NSString *errorString = [NSString stringWithFormat:@"%@", error];
            NSLog(@"%@", errorString);
            errorHandler(errorString);
        }else{
            if (data) {
                NSError *jsonModelError;
                
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                RadioResponse *radioResponse = [[RadioResponse alloc] initWithDictionary:jsonDictionary[MoeResponseKey] error:&jsonModelError];
                NSLog(@"%@", jsonModelError);
                
                
                NSString *callbackString;
                if(radioResponse.fav) {
                    callbackString = @"添加收藏成功";
                }
                if (radioResponse.fav_id) {
                    callbackString = @"取消收藏成功";
                }

                callback(callbackString);
                
            }else{
                //                tryTimes++;
                NSString *errorString = @"request data is nil";
                //                NSLog(@"%@", errorString);
                errorHandler(errorString);
            }
        }
    }];
    [task resume];
}

#pragma mark - private methods
// 获取API Key请求的完整URL
+ (NSURL *)getCompletedAPIKeyRequestURLWithURLString:(NSString *)url andParams:(NSDictionary *)params {
    
    NSURL *completedGETURL;
    // 判断登录状态，选择正确的url构造方法
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"]) {
        completedGETURL = [PTOAuthTool getCompletedOAuthResourceRequestURLWithURLString:url andParams:params];
    } else {
        // 创建参数字典
        NSMutableDictionary *paramsDictionary =[NSMutableDictionary dictionaryWithDictionary:params];
        NSString *api_key = [[NSUserDefaults standardUserDefaults] objectForKey:@"consumer_key"];
        [paramsDictionary setObject:api_key forKey:@"api_key"];
        
        // 得到参数字符串(升序)
        NSString *paramsString = [NSString ascendingOrderGETRequesetParamsDictionary:paramsDictionary];
        
        // 拼接完整地址
        NSString *path = [NSString stringWithFormat:@"%@?%@", url, paramsString];
        completedGETURL = [NSURL URLWithString:path];
    }
    return completedGETURL;
}

@end
