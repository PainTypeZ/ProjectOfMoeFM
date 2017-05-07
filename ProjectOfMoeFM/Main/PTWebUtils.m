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
+ (void)requestRadioListInfoWithPage:(NSUInteger)page andPerPage:(NSUInteger)perpage completionHandler:(callback)callback errorHandler:(error)errorHandler {
    NSString *pageStr = [NSString stringWithFormat:@"%lu", page];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeWikiTypeValue forKey:MoeWikiTypeKey];
    [params setObject:pageStr forKey:MoePageKey];
    if (perpage != 0) {
        NSString *perpageStr = [NSString stringWithFormat:@"%lu", perpage];
        [params setObject:perpageStr forKey:MoePerPageKey];
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
                    [callbackDict setObject:[radioResponse.wikis mutableCopy] forKey:MoeCallbackDictRadioKey] ;
                }
                if (radioResponse.information.count) {
                    [callbackDict setObject:radioResponse.information.count forKey:MoeCallbackDictCountKey];
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
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeHotRadiosURL andParams:params];
    
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
                if (radioResponse.hot_radios) {
                    [callbackDict setObject:radioResponse.hot_radios forKey:MoeCallbackDictRadioKey];
                }
                if (radioResponse.information.count) {
                    [callbackDict setObject:radioResponse.information.count forKey:MoeCallbackDictCountKey];
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

// 请求电台条目信息,就是为了拿电台songcount。。。
+ (void)requestRadioSongCountWithRadioId:(NSString *)radioId completionHandler:(callback)callback errorHandler:(error)errorHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:radioId forKey:MoeWikiIdKey];
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeRadioSongCountURL andParams:params];
    
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
                if (radioResponse.information.count) {
                    [callbackDict setObject:radioResponse.information.count forKey:MoeCallbackDictCountKey];
                } else {
                    [callbackDict setObject:@"0" forKey:MoeCallbackDictCountKey];
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

// 请求电台播放列表，需要radio = wiki_id参数，第几页page，每页多少歌曲数量perpage，注意最后一页返回的结果可能不够perpage数量;此请求也可以返回随机的收藏歌曲播放列表
+ (void)requestPlaylistWithRadioId:(NSString *)RadioId andPage:(NSUInteger)page andPerpage:(NSUInteger)perpage completionHandler:(callback)callback errorHandler:(error)errorHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeAPIValue forKey:MoeAPIKey];
    
    [params setObject:RadioId forKey:MoeRadioPlayListKey];
    
    if (page != 0) {
        NSString *pageStr = [NSString stringWithFormat:@"%lu", page];
        [params setObject:pageStr forKey:MoePageKey];
    }
    
    if (perpage != 0) {
        NSString *perpageStr = [NSString stringWithFormat:@"%lu", perpage];
        [params setObject:perpageStr forKey:MoePerPageKey];
    }
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeRadioPlayURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [PTWebUtils handlePlayListTaskWithRequest:request andSession:session andCallback:callback andErrorHandler:errorHandler];
    [task resume];
}

// 以SongIDs请求播放列表，收藏曲目的顺序播放列表和单曲必须使用的方法
+ (void)requestPlaylistWithSongIDs:(NSArray <NSString *> *)songIDs CompletionHandler:(callback)callback errorHandler:(error)errorHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeAPIValue forKey:MoeAPIKey];
    NSString *songIDsStr = @"";
    for (int i = 0; i < songIDs.count; i++) {
        NSString *songID = @"";
        if (i == songIDs.count - 1) {
            songID = [songIDs[i] copy];
        } else {
            songID = [NSString stringWithFormat:@"%@,", songIDs[i]];
        }
        songIDsStr = [songIDsStr stringByAppendingString:songID];
    }
    
    [params setObject:songIDsStr forKey:@"song"];
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeRadioPlayURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [PTWebUtils handlePlayListTaskWithRequest:request andSession:session andCallback:callback andErrorHandler:errorHandler];    [task resume];
    
}

// 请求默认随机播放列表
+ (void)requestRandomPlaylistWithCompletionHandler:(callback)callback errorHandler:(error)errorHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeAPIValue forKey:MoeAPIKey];
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeRadioPlayURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [PTWebUtils handlePlayListTaskWithRequest:request andSession:session andCallback:callback andErrorHandler:errorHandler];
    [task resume];
}

// 请求收藏曲目的随机播放列表
+ (void)requestFavRandomPlaylistWithCompletionHandler:(callback)callback errorHandler:(error)errorHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:MoeAPIValue forKey:MoeAPIKey];
    [params setObject:@"song" forKey:@"fav"];
    
    NSURL *url = [PTWebUtils getCompletedRequestURLWithURLString:MoeRadioPlayURL andParams:params];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [PTWebUtils handlePlayListTaskWithRequest:request andSession:session andCallback:callback andErrorHandler:errorHandler];
    [task resume];
}

// 请求收藏歌曲列表（obj_type = song), 只能拿到收藏曲目的wiki_id数组, 其结果用于请求收藏曲目顺序播放列表和完整的收藏曲目信息;OAuth限定
+ (void)requestFavSongListWithPage:(NSUInteger)page andPerPage:(NSUInteger)perpage completionHandler:(callback)callback errorHandler:(error)errorHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"song" forKey:@"obj_type"];
    if (page != 0) {
        NSString *pageStr = [NSString stringWithFormat:@"%lu", page];
        [params setObject:pageStr forKey:MoePageKey];
    }
    
    if (perpage != 0) {
        NSString *perpageStr = [NSString stringWithFormat:@"%lu", perpage];
        [params setObject:perpageStr forKey:MoePerPageKey];
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
                
                NSMutableArray <NSString *> *songIDs = [NSMutableArray array];
                
                for (Favourite * fav in favsArray) {
                    [songIDs addObject:fav.obj.sub_id];
                }
                
                NSMutableDictionary *callbackDict = [NSMutableDictionary dictionary];
                if (songIDs.count > 0) {
                    [callbackDict setObject:songIDs forKey:MoeCallbackDictSongIDKey];
                }
                if (radioResponse.information.count) {
                    [callbackDict setObject:@(radioResponse.information.count.integerValue) forKey:MoeCallbackDictCountKey];
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

// 播放列表task处理
+ (NSURLSessionTask *)handlePlayListTaskWithRequest:(NSMutableURLRequest *)request andSession:(NSURLSession *)session andCallback:(callback)callback andErrorHandler:(error)errorHandler {
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
                    [callbackDict setObject:[radioResponse.playlist mutableCopy] forKey:MoeCallbackDictSongKey] ;
                }
                if (radioResponse.information.count) {
                    [callbackDict setObject:radioResponse.information.count forKey:MoeCallbackDictCountKey];
                }
                
                callback([callbackDict mutableCopy]);
            }else{
                NSString *errorString = @"request data is nil";
                errorHandler(errorString);
            }
        }
    }];
    return task;
}

@end
