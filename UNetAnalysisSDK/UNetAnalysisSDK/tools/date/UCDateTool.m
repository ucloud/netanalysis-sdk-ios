//
//  UCDateTool.m
//  UCloudNetAnalysisSDK
//
//  Created by ethan on 15/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UCDateTool.h"

#define  kDaySeconds   (24*60*60)

@implementation UCDateTool

+ (NSInteger)daysFrom1970
{
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    return (NSInteger)(seconds/kDaySeconds);
}

+ (NSInteger)secondsFrom1970
{
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    return (NSInteger)seconds;
}

+ (NSInteger)currentTimestamp
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    return (NSInteger)currentTime;
}

@end
