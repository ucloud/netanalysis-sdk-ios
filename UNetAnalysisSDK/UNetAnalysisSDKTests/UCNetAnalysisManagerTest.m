//
//  UCNetAnalysisManagerTest.m
//  UNetAnalysisSDKTests
//
//  Created by ethan on 2019/1/25.
//  Copyright © 2019 ucloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UNetAnalysisSDK/UNetAnalysisSDK.h>
@interface UCNetAnalysisManagerTest : XCTestCase

@end

@implementation UCNetAnalysisManagerTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


#pragma mark- regist SDK
- (void)testRegistSDK_right_params
{
    NSString *appKey = @"";
    NSString *publicToken = @"";
    [[UCNetAnalysisManager shareInstance] uNetRegistSdkWithAppKey:appKey publicToken:publicToken optReportField:nil completeHandler:^(UCError * _Nullable ucError) {
        if (ucError) {
            NSLog(@"regist SDK error , error info:%@",ucError.error.description);
            return;
        }
        
        NSLog(@"regist SDK success..");
        
    }];
}


/**
 appkey和公钥和app对应不上
 */
- (void)testRegistSDK_error_params
{
    NSString *appKey = @"";
    NSString *publicToken = @"";
    [[UCNetAnalysisManager shareInstance] uNetRegistSdkWithAppKey:appKey publicToken:publicToken optReportField:nil completeHandler:^(UCError * _Nullable ucError) {
        if (ucError) {
            NSLog(@"regist SDK error , error info:%@",ucError.error.description);
            return;
        }
        
        NSLog(@"regist SDK success..");
        
    }];
}

#pragma mark- SDK Version
- (void)testSdkVersion
{
    NSLog(@"SDK Version:  %@",[[UCNetAnalysisManager shareInstance] uNetSdkVersion]);
}

@end
