//
//  KMDeviceSettingDetailVC.h
//  InstantCare
//
//  Created by 朱正晶 on 15/12/6.
//  Copyright © 2015年 omg. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  KMDeviceSettingVC -> Switchs/GPS on/Upload
 */
@interface KMDeviceSettingDetailVC : UIViewController

/**
 *  设备imei号码；
 */
@property (nonatomic, copy) NSString *imei;

/**
 *  设备类型
 */
@property(nonatomic,copy)NSString * type;


@end
