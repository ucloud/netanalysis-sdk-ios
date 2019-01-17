//
//  UCloudNetAnalysisSDKTests.m
//  UCloudNetAnalysisSDKTests
//
//  Created by ethan on 25/07/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UNetAnalysis.h"

@interface UCloudNetAnalysisSDKTests : XCTestCase

@end

@implementation UCloudNetAnalysisSDKTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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

#pragma mark -Test
- (void)testSingleton
{
    @autoreleasepool{
        /* Test UCloudNetAnalysis */
        UNetAnalysis *obj1 = [UNetAnalysis shareInstance];
        UNetAnalysis *obj2 = [UNetAnalysis shareInstance];
        UNetAnalysis *obj3 = [[UNetAnalysis alloc] init];
        UNetAnalysis *obj4 = [[UNetAnalysis alloc] init];
        NSLog(@"obj1 = %p \n obj2 = %p \n obj3 = %p \n obj4 = %p \n",obj1,obj2,obj3,obj4);
        
    }
}

- (void)testDevicePublicIp
{
//    [[UNetAnalysis shareInstance] ucloudGetDevicePublicIp];
}

@end
