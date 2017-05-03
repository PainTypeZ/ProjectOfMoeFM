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
+ (void)requestRadioListInfoWithPage:(NSUInteger)currentPage andPerPage:(NSUInteger)perpageNumber completionHandler:(callback)callback errorHandler:(error)errorHandler {
    NSString *page = [NSString stringWithFormat:@"%lu", (unsigned long)currentPage];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeWikiTypeValue forKey:MoeWikiTypeKey];
    [params setObject:page forKey:MoePageKey];
    if (perpageNumber != 0) {
        NSString *perpage = [NSString stringWithFormat:@"%lu", (unsigned long)perpageNumber];
        [params setObject:perpage forKey:MoePerPageKey];
    }
    
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeRadioListURL andParams:params];
    
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
                if (jsonModelError) {
                    NSLog(@"%@", jsonModelError);
                }
                NSMutableDictionary *callbackDict = [NSMutableDictionary dictionary];
                if (radioResponse.wikis) {
                    [callbackDict setObject:[radioResponse.wikis mutableCopy] forKey:@"radios"] ;
                }
                if (radioResponse.information.count) {
                    [callbackDict setObject:radioResponse.information.count forKey:@"count"];
                }
                
                callback(callbackDict);
            }else{
                NSString *errorString = @"request data is nil";
//                NSLog(@"%@", errorString);
                errorHandler(errorString);
            }
        }
    }];
    [task resume];
}
// 请求热门电台列表
+ (void)requestHotRadiosWithCompletionHandler:(callback)callback errorHandler:(error)errorHandler {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"json" forKey:@"api"];
    [params setObject:@"1" forKey:@"hot_radios"];
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeHotRadios andParams:params];
    
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
                if (jsonModelError) {
                    NSLog(@"%@", jsonModelError);
                }
                NSMutableArray *callbackMuatableArray = [radioResponse.hot_radios mutableCopy];
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
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeRadioSongsURL andParams:params];
    
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
                if (jsonModelError) {
                    NSLog(@"%@", jsonModelError);
                }
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
  
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeAPIValue forKey:MoeAPIKey];
    
    // 判断是否发送的songidstring
    if ([radio_id containsString:@","]) {
        [params setObject:radio_id forKey:@"song"];
    } else if ([radio_id isEqualToString: @"fav"]) {
        [params setObject:@"song" forKey:@"fav"];
        
        if (currentPage != 0) {
            NSString *page = [NSString stringWithFormat:@"%lu", (unsigned long)currentPage];
            [params setObject:page forKey:MoePageKey];
        }
        
        if (perpageNumber != 0) {
            NSString *perpage = [NSString stringWithFormat:@"%lu", (unsigned long)perpageNumber];
            [params setObject:perpage forKey:MoePerPageKey];
        }
        
    } else if ([radio_id isEqualToString:@"random"]) {
        currentPage = 0;
        perpageNumber = 0;
    } else {
        
        [params setObject:radio_id forKey:MoeRadioPlayListKey];
        if (currentPage != 0) {
            NSString *page = [NSString stringWithFormat:@"%lu", (unsigned long)currentPage];
            [params setObject:page forKey:MoePageKey];
        }
        
        if (perpageNumber != 0) {
            NSString *perpage = [NSString stringWithFormat:@"%lu", (unsigned long)perpageNumber];
            [params setObject:perpage forKey:MoePerPageKey];
        }
    }
    

    
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeRadioPlayURL andParams:params];
    
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
                if (jsonModelError) {
                    NSLog(@"%@", jsonModelError);
                }
                NSMutableDictionary *callbackDict = [NSMutableDictionary dictionary];
                if (radioResponse.playlist) {
                    [callbackDict setObject:radioResponse.playlist forKey:@"songs"];
                }
                if (radioResponse.information.count) {
                    [callbackDict setObject:radioResponse.information.count forKey:@"count"];// 这个api没有返回歌曲总数的功能
                }
                
                callback(callbackDict);
                
            }else{

                NSString *errorString = @"request data is nil";
//                NSLog(@"%@", errorString);
                errorHandler(errorString);
            }
        }
    }];
    [task resume];
}
// 请求有序的收藏曲目列表songID字符串
+ (void)requestFavSongListWithPage:(NSUInteger)currentPage andPerPage:(NSUInteger)perpageNumber completionHandler:(callback)callback errorHandler:(error)errorHandler {   
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"song" forKey:@"obj_type"];
    if (currentPage != 0) {
        NSString *page = [NSString stringWithFormat:@"%lu", (unsigned long)currentPage];
        [params setObject:page forKey:MoePageKey];
    }
    
    if (perpageNumber != 0) {
        NSString *perpage = [NSString stringWithFormat:@"%lu", (unsigned long)perpageNumber];
        [params setObject:perpage forKey:MoePerPageKey];
    }
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeFavSongsURL andParams:params];
    
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
                if (jsonModelError) {
                    NSLog(@"%@", jsonModelError);
                }
                NSMutableArray *favsArray = [radioResponse.favs mutableCopy];
//                NSMutableArray *callbackMuatableArray = [NSMutableArray array];
                NSString *songIDString = @"";
                
                for (Favourite * fav in favsArray) {
                    NSString * favString = [NSString stringWithFormat:@"%@,", fav.obj.sub_id];
                    songIDString = [songIDString stringByAppendingString:favString];
                }
                
                NSMutableDictionary *callbackDict = [NSMutableDictionary dictionary];
                if (songIDString) {
                    [callbackDict setObject:songIDString forKey:@"songID"];
                }
                if (radioResponse.information.count) {
                    [callbackDict setObject:@(radioResponse.information.count.integerValue) forKey:@"count"];
                }
                
                callback([callbackDict mutableCopy]);
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
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:urlString andParams:params];
    
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
                if (jsonModelError) {
                    NSLog(@"%@", jsonModelError);
                }
                
                
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
// 请求用户信息,同时用作登录状态检查
+ (void)requestUserInfoWithCompletionHandler:(callback)callback errorHandler:(error)errorHandler {
    
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeUserInfoURL andParams:nil];
    
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
                if (jsonModelError) {
                    NSLog(@"%@", jsonModelError);
                }
                NSMutableDictionary *callbackdict = [NSMutableDictionary dictionary];
                if (radioResponse.information.has_error == YES) {
                    [callbackdict setObject:@"NO" forKey:@"isOAuth"];
                }else{
                    [callbackdict setObject:@"YES" forKey:@"isOAuth"];
                    [callbackdict setObject:radioResponse.user forKey:@"user"];
                }
                
                callback(callbackdict);
                
            }else{
                NSString *errorString = @"request data is nil";
                errorHandler(errorString);
            }
        }
    }];
    [task resume];
}

#pragma mark - private methods
// 获取API Key请求的完整URL
+ (NSURL *)getCompletedRequestURLWithURLString:(NSString *)url andParams:(NSDictionary *)params {
    
    NSURL *completedGETURL;
    // 判断登录状态，选择正确的url构造方法
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"]) {
        completedGETURL = [PTOAuthTool getCompletedOAuthResourceRequestURLWithURLString:url andParams:params];
    } else {
        // 创建参数字典
        NSMutableDictionary *paramsDictionary;
        if (params) {
           paramsDictionary =[NSMutableDictionary dictionaryWithDictionary:params];
        }else{
            paramsDictionary = [NSMutableDictionary dictionary];
        }
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
