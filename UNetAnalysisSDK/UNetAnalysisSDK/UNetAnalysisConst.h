//
//  UNetAnalysisConst.h
//  UNetAnalysisSDK
//
//  Created by ethan on 26/07/2018.
//  Copyright © 2018 ucloud. All rights reserved.
//

#ifndef UNetAnalysisConst_h
#define UNetAnalysisConst_h


/**********   For log4cplus    *************/
#ifndef UCLOUD_IOS
#define UCLOUD_IOS
#endif


/***********  About http Interface   ***********/
#define     U_Get_Public_Ip_Url   @"https://net-trace.ucloud.cn:8098/v1/ipip"   //get public ip info interface
#define     U_Get_UCloud_iplist_URL   @"https://net-trace.ucloud.cn:8000/api/iplist/getpinglist/"  // get ucloud ip list interface


/***********      Global define       ***********/
#define      UCNotification       [NSNotificationCenter defaultCenter]
#define      UCUserDefaults       [NSUserDefaults standardUserDefaults]

/***********      Ping model       ***********/
#define   KPingIcmpIdBeginNum     8000

/***********      Tracert model       ***********/

typedef enum  Enum_Tracert_UC_Hosts_State
{
    Enum_Tracert_UC_Hosts_State_Doing = 0,
    Enum_Tracert_UC_Hosts_State_Complete
}Enum_Tracert_UC_Hosts_State;

#define KSDKVERSION   @"1.0.0"

#endif /* UNetAnalysisConst_h */
