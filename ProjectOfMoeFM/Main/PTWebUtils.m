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

#pragma mark - public methods
// 请求电台列表信息
+ (void)requestRadioListInfoWithCallback:(callback)callback {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeWikiTypeValue forKey:MoeWikiTypeKey];
    [params setObject:MoePageValue forKey:MoePageKey];
    [params setObject:MoePerPageValue forKey:MoePerPageKey];
    
    NSURL *url = [PTWebUtils getCompletedAPIKeyRequestURLWithURLString:MoeRadioListURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSError *jsonModelError;
        
        RadioResponse *radioResponse = [[RadioResponse alloc] initWithDictionary:jsonDictionary[MoeResponseKey] error:&jsonModelError];
        NSMutableArray *callbackMuatableArray = [radioResponse.wikis mutableCopy];
        callback(callbackMuatableArray);
    }];
    [task resume];
    
}

// 请求某个电台专辑的歌曲列表信息，除了获取歌曲总数外，大概是没其他用的接口。。。
+ (void)requestRadioSongsInfoWithWiki_id:(NSString *)wiki_id callback:(callback)callback {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeObjTypeValue forKey:MoeObjTypeKey];
    [params setObject:wiki_id forKey:MoeWikiIdKey];
    
    NSURL *url = [PTWebUtils getCompletedAPIKeyRequestURLWithURLString:MoeRadioSongsURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSError *jsonModelError;
        RadioResponse *radioResponse = [[RadioResponse alloc] initWithDictionary:jsonDictionary[MoeResponseKey] error:&jsonModelError];
        RadioInformation *radioInformation = radioResponse.information;
        callback(radioInformation);
    }];
    
    [task resume];
}

// 请求电台播放列表，需要radio = wiki_id参数, 若填写参数为nil，则返回随机列表
+ (void)requestRadioPlayListWithRadio_id:(NSString *)radio_id callback:(callback)callback {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeAPIValue forKey:MoeAPIKey];
    if (radio_id) {
        [params setObject:radio_id forKey:MoeRadioPlayListKey];
    }

    NSURL *url = [PTWebUtils getCompletedAPIKeyRequestURLWithURLString:MoeRadioPlayURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSError *jsonModelError;
        RadioResponse *radioResponse = [[RadioResponse alloc] initWithDictionary:jsonDictionary[MoeResponseKey] error:&jsonModelError];
        NSMutableArray *callbackMutableArray = [radioResponse.playlist mutableCopy];
        callback(callbackMutableArray);
    }];
    [task resume];
}
// 请求电台播放列表，需要radio = wiki_id参数，第几页page，每页多少歌曲数量perpage，注意最后一页返回的结果可能不够perpage数量; 本工程使用perpage=@"30"测试;
+ (void)requestRadioPlayListWithRadio_id:(NSString *)radio_id andPage:(NSString *)page andPerpage:(NSString *)perpage callback:(callback)callback {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeAPIValue forKey:MoeAPIKey];
    if (radio_id) {
        [params setObject:radio_id forKey:MoeRadioPlayListKey];
    }
    [params setObject:page forKey:MoePageKey];
    [params setObject:perpage forKey:MoePerPageKey];
    
    NSURL *url = [PTWebUtils getCompletedAPIKeyRequestURLWithURLString:MoeRadioPlayURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSError *jsonModelError;
        RadioResponse *radioResponse = [[RadioResponse alloc] initWithDictionary:jsonDictionary[MoeResponseKey] error:&jsonModelError];
        NSMutableArray *callbackMutableArray = [radioResponse.playlist mutableCopy];
        callback(callbackMutableArray);
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
