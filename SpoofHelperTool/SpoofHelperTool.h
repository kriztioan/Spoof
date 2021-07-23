/**
 *  @file   SpoofHelperTool.h
 *  @brief  SpoofHelperTool Class Definition
 *  @author KrizTioaN (christiaanboersma@hotmail.com)
 *  @date   2021-07-23
 *  @note   BSD-3 licensed
 *
 ***********************************************/

#ifndef SPOOFHELPERTOOL_H_
#define SPOOFHELPERTOOL_H_

#import <Foundation/Foundation.h>

#define kHelperToolMachServiceName @"com.christiaanboersma.SpoofHelperTool"
#define kHelperToolVersion @"1.0"

NS_ASSUME_NONNULL_BEGIN

@protocol SpoofHelperToolProtocol

@required

- (void)getVersionwithReply:(void(^)(NSString * version))reply;
- (void)spoofInterface:(NSString *)interface withMac:(NSString *)mac andReply:(void(^)(NSString *status))reply;
@end

@interface SpoofHelperTool : NSObject

- (id)init;

- (void)run;

@end

NS_ASSUME_NONNULL_END

#endif // End of SPOOFHELPERTOOL_H_
