//
//  ViewController.swift
//  UNetAnalysisSwiftDemo_01
//
//  Created by ethan on 2018/10/24.
//  Copyright © 2018 ucloud. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        checkAppNetwork()
    }
    
    
    func checkAppNetwork(){
        
        UCNetAnalysisManager.shareInstance().uNetManualDiagNetStatus { (manualNetDiagRes:UCManualNetDiagResult?, ucError:UCError?) in
            if(ucError != nil){
                let error = ucError!.error as NSError
                print("Manual diagnosis,error info:%s",error.description)
                return
            }
            
            DispatchQueue.main.async {
                print("netType:%s , pingInfo:%s",manualNetDiagRes!.networkType,manualNetDiagRes!.pingInfo);
            }
        }
        
       
    }


}

