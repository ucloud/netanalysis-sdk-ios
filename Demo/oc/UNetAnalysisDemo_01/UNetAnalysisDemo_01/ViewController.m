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
@property (weak, nonatomic) IBOutlet UITextView *resTV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}



- (IBAction)onpressedButtonCheckNet:(id)sender {
    self.resTV.text = @"";
    
    [[UCNetAnalysisManager shareInstance] uNetManualDiagNetStatus:^(UCManualNetDiagResult * _Nullable manualNetDiagRes, UCError * _Nullable ucError) {
        if (ucError) {
            if (ucError){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resTV.text = [NSString stringWithFormat:@"Manual diagnosis error info: %@",ucError.error.description];
                });
                
            }
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resTV.text = [NSString stringWithFormat:@"NetType: %@, pingRes: %@",manualNetDiagRes.networkType,manualNetDiagRes.pingInfo];
        });
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
