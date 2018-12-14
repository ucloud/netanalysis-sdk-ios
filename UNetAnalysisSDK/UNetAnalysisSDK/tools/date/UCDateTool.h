//
//  UCDateTool.h
//  UCloudNetAnalysisSDK
//
//  Created by ethan on 15/08/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCDateTool : NSObject


/**
 Get the number of days form 1970.1.1

 @return the number of dasy form 1970.1.1
 */
+ (int)daysFrom1970;


/**
 Get the number of seconds form 1970.1.1

 @return the number of seconds form 1970.1.1
 */
+ (int)secondsFrom1970;


/**
 Get the timestamp

 @return The current timestamp
 */
+ (int)currentTimestamp;

@end
