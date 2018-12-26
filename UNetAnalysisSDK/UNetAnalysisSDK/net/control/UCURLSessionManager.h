//
//  UCURLSessionManager.h
//  UFileSDK
//
//  Created by ethan on 2018/11/2.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//extern NSString* _Nullable UFilePercentEscapedStringFromString(NSString* _Nonnull);


@interface UCURLSessionManager : NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

/**
 The dispatch queue for `completionBlock`. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, strong, nullable) dispatch_queue_t uf_completionQueue;
/**
 The dispatch group for `completionBlock`. If `NULL` (default), a private dispatch group is used.
 */
@property (nonatomic, strong, nullable) dispatch_group_t uf_completionGroup;




- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
