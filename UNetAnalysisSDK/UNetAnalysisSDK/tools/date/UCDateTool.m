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

+ (int)daysFrom1970
{
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    return (int)(seconds/kDaySeconds);
}

+ (int)secondsFrom1970
{
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    return (int)seconds;
}

+ (int)currentTimestamp
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970]*1000;
    return (int)currentTime;
}

@end
