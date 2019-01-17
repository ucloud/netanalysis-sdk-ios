//
//  ViewController.m
//  UNetAnalysisDemo_01
//
//  Created by ethan on 2018/10/24.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "ViewController.h"
#import <UNetAnalysisSDK/UNetAnalysisSDK.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self checkAppNetwork];
}

- (void)checkAppNetwork
{
    [[UCNetAnalysisManager shareInstance] uNetManualDiagNetStatus:^(UCManualNetDiagResult * _Nullable manualNetDiagRes, UCError * _Nullable ucError) {
        if (ucError) {
            if (ucError.type == UCErrorType_Sys) {
                NSLog(@"error info: %@",ucError.error.description);
            }else{
                NSLog(@"error info: %@",ucError.error.description);
            }
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"netType:%@, pingInfo:%@ ",manualNetDiagRes.networkType,manualNetDiagRes.pingInfo);
        });
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
