//
//  KMNew_MainVC.m
//  InstantCare
//
//  Created by Jasonh on 16/12/16.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMNew_MainVC.h"
#import "KMPictureCarouselView.h"
#import "KMImageTitleButton.h"
#import "KMLocationVC.h"
#import "KMCallVC.h"
//#import "KMVIPServiceVC.h"
//#import "KMIndexMenuView.h"
#import "KMDeviceSettingVC.h"
#import "KMHealthRecordVC.h"
#import "KMPushMsgModel.h"
#import "KMShowAlertMsgWindow.h"
#import "JPUSHService.h"
#import "KMHealthRecordVC.h"
#import "UIViewController+ECSlidingViewController.h"
#import "UINavigationBar+Awesome.h"
#import "KMiTunesVersionModel.h"
//#import "KMHealthVC.h"
#import "KMGeofenceVC.h"
#import "KMDeviceSettingVC.h"
#import "MJExtension.h"
#import "KMMessageVc.h"
//#import "KMCertificationVc.h"
#import "KMAuthenticationVc.h"
#import "KMNetAPI.h"
#import "KMNewTitleImageBtn.h"
#import "UDNavigationController.h"
#import "UIBarButtonItem+Extension.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

#import "KMCloudWebView.h"
#import "KMBundleDevicesModel.h"
#import "CustomIOSAlertView.h"
#import "KMCommonAlertView.h"


#define kButtonHeight           0.2
#define kCarouselViewHeight     0.6
#define kNewCarouselViewHeight  0.5

#define kButtonFontSize         16
#define kButtonOffset           20

#define kImageTitleButtonOffset 16
#import "KMDeviceSettingModel.h"
@interface KMNew_MainVC ()<KMPictureCarouselViewDelegate, ECSlidingViewControllerDelegate>
    {
        NSString *_userBase64Data;
        BOOL _wearDevice;           // 是否有穿戴设备
    }
/**
 *  防止侧滑时误击的View
 */
@property (nonatomic, strong) UIView *topTouchView;

@property (nonatomic, weak) UIView *topView;
    
@property(nonatomic,strong)CustomIOSAlertView * callAction;

@end

@implementation KMNew_MainVC
    
- (instancetype)init
    {
        self = [super init];
        if (self) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDevicesFromServer) name:@"AddDeviceSuccess" object:nil];
        }
        return self;
    }

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self configRemoteNotification];
    [self configNavBar];
    
    [self checkVersion];
    
    [self configTopView];
    [self configbottomView];
    [self configView];
    
    [self getDevicesFromServer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDevicesFromServer) name:YouJumpIJump object:nil];
}
    
#pragma mark - 获取设备列表
- (void)getDevicesFromServer{
        
        // 创建请求地址
        NSString *deviceListURL = [NSString stringWithFormat:@"getbindDeviceWithWearersInfo/%@", member.loginAccount];
        
        // 发送网络请求
//        [SVProgressHUD show];
        [[KMNetAPI manager] commonGetRequestWithURL:deviceListURL Block:^(int code, NSString *res)
         {
             KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
             
             // 模型解析；
             if (code == 0 && resModel.errorCode <= kNetReqSuccess)
             {
                 KMBundleDevicesModel *devicesListModel = [KMBundleDevicesModel mj_objectWithKeyValues:resModel.content];
                 
                 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"myWear = 1"];
                 NSArray *filterArray = [devicesListModel.list filteredArrayUsingPredicate:predicate];
                 
                 
                 NSLog(@"filterArray%@",filterArray);
                 if (filterArray && filterArray.count > 0) {
                     _wearDevice = YES;
                     [self fetchUserBase64Data:((KMBundleDevicesDetailModel *)filterArray.firstObject).imei];
                     
                     NSLog(@"OMIMEI = %@",((KMBundleDevicesDetailModel *)filterArray.firstObject).imei);
                 }else if (devicesListModel.list.count > 0){
                     _wearDevice = YES;
                     [self fetchUserBase64Data:((KMBundleDevicesDetailModel *)devicesListModel.list.firstObject).imei];
                 }else {
                     [SVProgressHUD showErrorWithStatus:@"还没有设备，请前往\"设备管理\"添加"];
                     self.callAction = [[CustomIOSAlertView alloc] init];
                     KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,300, 200)];
                     view.titleLabel.text = @"没有设备";
                     view.titleLabel.backgroundColor = kRedColor;
                     view.msgLabel.text = @"请前往\"设备管理\"添加设备";
                     view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_YES")];
                     
                     UIButton *cancelButton = view.realButtons[0];
                     [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
                     
                     self.callAction.containerView = view;
                     self.callAction.buttonTitles = nil;
                     [self.callAction setUseMotionEffects:NO];
                     
                     [self.callAction show];
                 }
                 
//                 [SVProgressHUD dismiss];
                 
             } else
             {
                 // 显示错误状态
//                 [SVProgressHUD showErrorWithStatus:@"获取设备号失败"];
                 [self showAlert:@"获取设备号失败" message:@"是否重试"];
             }
         }];
}
    
-(void)dismiss{
    [self.callAction close];
}

-(void)fetchUserBase64Data:(NSString *)imei{
    NSMutableString *resultStr = [NSMutableString string];
    
    unsigned long userCode = arc4random();
    
    NSData *basedata = [[NSString stringWithFormat:@"%@:%lu",imei,userCode] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *basedataStr = [basedata base64EncodedStringWithOptions:0];
    
    [resultStr appendString:basedataStr];
    [resultStr appendString:@"&userCode="];
    [resultStr appendString:[NSString stringWithFormat:@"%lu",userCode]];
    
    _userBase64Data = resultStr;
}
    
    
-(void)showAlert:(NSString *)title message:(NSString *)msg{
    self.callAction = [[CustomIOSAlertView alloc] init];
    KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,300, 200)];
    view.titleLabel.text = title;
    view.titleLabel.backgroundColor = kRedColor;
    view.msgLabel.text = msg;
    view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_YES"),kLoadStringWithKey(@"DeviceSetting_VC_NO")];
    
    UIButton *againButton = view.realButtons[0];
    [againButton addTarget:self action:@selector(getDevicesFromServerAgain) forControlEvents:UIControlEventTouchUpInside];
    UIButton *cancelButton = view.realButtons[1];
    [cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.callAction.containerView = view;
    self.callAction.buttonTitles = nil;
    [self.callAction setUseMotionEffects:NO];
    
    [self.callAction show];
}
    
- (void)getDevicesFromServerAgain {
    [self.callAction close];
    
    [self getDevicesFromServer];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
//    DMLog(@"%@",UIStatusBarStyleLightContent);
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UDNavigationController *nav = (UDNavigationController *)self.navigationController;
    [nav setAlph];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    UDNavigationController *nav = (UDNavigationController *)self.navigationController;
    [nav setAlph];
}

#pragma mark - configTopView
- (void)configTopView{
    UIImageView *topView = [[UIImageView alloc]init];
    [topView setImage:[UIImage imageNamed:@"home_head_bg"]];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(SCREEN_WIDTH * 456.0/750.0));
    }];
    
    UIImageView *topImageView = [[UIImageView alloc]init];
    self.topView = topImageView;
    [topImageView setImage:[UIImage imageNamed:@"home_head_image"]];
    [self.view addSubview:topImageView];
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView).offset(95.0);
        make.left.equalTo(topView).offset(10.0);
        make.right.equalTo(topView).offset(-10.0);
        make.height.equalTo(@((SCREEN_WIDTH - 20.0) * 388.0/708.0));
    }];
    
    /*
     UIImageView *bgView = [[UIImageView alloc] init];
     [bgView setImage:[UIImage imageNamed:@"home_head_bg"]];
     [self.view addSubview:bgView];
     [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.left.right.equalTo(self.view);
     make.height.equalTo(@(SCREEN_WIDTH * 456.0/750.0));
     }];
     
     UIImageView *topImageView = [[UIImageView alloc]init];
     self.topView = topImageView;
     [topImageView setImage:[UIImage imageNamed:@"home_head_image"]];
     [self.view addSubview:topImageView];
     [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.equalTo(self.view).offset(95.0);
     make.left.right.equalTo(self.view).offset(10.0);
     make.height.equalTo(@((SCREEN_WIDTH - 20.0) * 388.0/708.0));
     }];
     */
}

- (void)configbottomView{
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom).offset(20.0);
        make.left.right.bottom.equalTo(self.view);
    }];

    // 下面四个按钮
    // 1. 健康档案
    KMNewTitleImageBtn *locationBtn = [[KMNewTitleImageBtn alloc] initWithImage:[UIImage imageNamed:@"main_icon_1"]  title:NSLocalizedStringFromTable(@"MAIN_VC_healthdocument_btn", APP_LAN_TABLE, nil)];
    locationBtn.tag = 100;
    locationBtn.label.font = [UIFont systemFontOfSize:kImageTitleButtonOffset];
    [locationBtn addTarget:self action:@selector(btnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn];
    [locationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView);
        make.left.equalTo(bottomView);
        make.height.equalTo(bottomView).multipliedBy(0.39);
        make.width.equalTo(bottomView).multipliedBy(0.5);
    }];

    // 2. 健康记录
    KMNewTitleImageBtn *healthBtn = [[KMNewTitleImageBtn alloc] initWithImage:[UIImage imageNamed:@"main_icon_2"]title:NSLocalizedStringFromTable(@"MAIN_VC_healthRecord_btn", APP_LAN_TABLE, nil)];
    healthBtn.tag = 101;
    healthBtn.label.font = [UIFont systemFontOfSize:kImageTitleButtonOffset];
    [healthBtn addTarget:self action:@selector(btnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:healthBtn];
    [healthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView);
        make.right.equalTo(bottomView);
        make.height.equalTo(locationBtn);
        make.width.equalTo(locationBtn);
    }];
    
    // 3. 健康学院
    KMNewTitleImageBtn *callBtn = [[KMNewTitleImageBtn alloc] initWithImage:[UIImage imageNamed:@"main_icon_3"] title:NSLocalizedStringFromTable(@"MAIN_VC_healthSchool_btn", APP_LAN_TABLE, nil)];
    callBtn.tag = 102;
    callBtn.label.font = [UIFont systemFontOfSize:kImageTitleButtonOffset];
    [callBtn addTarget:self action:@selector(btnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:callBtn];
    [callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(locationBtn.mas_bottom);
        make.left.equalTo(bottomView);
        make.height.equalTo(locationBtn);
        make.width.equalTo(locationBtn);
    }];
    
    // 4. 咨询服务
    NSString * title;
    // 设置马来差异
#ifdef kApplicationMLVersion
    title  = kLoadStringWithKey(@"SlideVC_device_manage");
#else
    title  = kLoadStringWithKey(@"MAIN_VC_healthadvisory_btn");
#endif
    
    KMNewTitleImageBtn *vipBtn = [[KMNewTitleImageBtn alloc] initWithImage:[UIImage imageNamed:@"main_icon_4"] title:title];
    
    //    KMImageTitleButton *vipBtn = [KMImageTitleButton buttonWithType:UIButtonTypeCustom];
    //    [vipBtn setImage:[UIImage imageNamed:@"omg_main_btn_service_icon"] forState:UIControlStateNormal];
    //    [vipBtn setTitle:title forState:UIControlStateNormal];
    vipBtn.tag = 103;
    //    vipBtn.label.textAlignment = NSTextAlignmentCenter;
    
    vipBtn.label.font = [UIFont systemFontOfSize:kImageTitleButtonOffset];
    [vipBtn addTarget:self action:@selector(btnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:vipBtn];
    [vipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(healthBtn.mas_bottom);
        make.right.equalTo(bottomView);
        make.height.equalTo(locationBtn);
        make.width.equalTo(locationBtn);
    }];

}

#pragma mark - 推送相关

- (void)configRemoteNotification
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kmReceiveRemoteNotification:) name:@"kmReceiveRemoteNotification" object:nil];
    WS(ws);
    if (member.deviceToken.length != 0) {
        [self updateDeviceTokenToServer];
    } else {                                    // 否则等待10秒再上传(这里使用监听可能效果更好)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (member.deviceToken.length != 0) {
                [ws updateDeviceTokenToServer];
            }
        });
    }
    
    // 检查是否有推送消息
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *data = [userDefault valueForKey:@"pushNotificationKey"];
    if (data) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kmReceiveRemoteNotification"
                                                            object:data];
        // 清楚之前保存的信息
        [userDefault setObject:nil forKey:@"pushNotificationKey"];
    }
    
    
}

- (void)updateDeviceTokenToServer
{
    NSString *request = [NSString stringWithFormat:@"addJPushToken/%@/%@",
                         member.loginAccount,
                         [JPUSHService registrationID]];
    
    [[KMNetAPI manager] commonGetRequestWithURL:request Block:^(int code, NSString *res) {
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            
        } else {
            NSLog(@"JPush upload errors");
        }
    }];
}

- (void)kmReceiveRemoteNotification:(NSNotification*)notify
{
    NSDictionary *userInfo = notify.object;
    
    if (userInfo) {
        KMPushMsgModel *pushModel = [KMPushMsgModel mj_objectWithKeyValues:userInfo];
        if ([pushModel.content.type isEqualToString:@"SOS"] ||
            [pushModel.content.type isEqualToString:@"FALL"]) {          // 跳转到地图界面
            KMLocationVC *vc = [[KMLocationVC alloc] init];
            vc.pushModel = pushModel;
            
            [self.navigationController pushViewController:vc animated:YES];
        } else if ([pushModel.content.type isEqualToString:@"BO"] ||
                   [pushModel.content.type isEqualToString:@"BS"] ||
                   [pushModel.content.type isEqualToString:@"BP"]) {
            KMHealthRecordVC *vc = [[KMHealthRecordVC alloc] init];
            vc.pushModel = pushModel;
            [self.navigationController pushViewController:vc animated:YES];
        } else if ([pushModel.content.type isEqualToString:@"BATTERY"]) {
            NSString *msg = [NSString stringWithFormat:@"%@%@",
                             pushModel.content.imei,
                             kLoadStringWithKey(@"Device_low_power")];
            [[KMShowAlertMsgWindow sharedInstance] showMsg:msg];
        }else if ([pushModel.content.type isEqualToString:@"LVGF"]){
            
            KMGeofenceVC *geofenceVC = [[KMGeofenceVC alloc] initGeofenceWithModel:pushModel];
            [self.navigationController pushViewController:geofenceVC animated:YES];
            
        }else {
            // 其余信息只显示alert信息
            NSLog(@"%@", pushModel.aps.alert);
            //[[KMShowAlertMsgWindow sharedInstance] showMsg:pushModel.aps.alert];
        }
    }
}

/**
 *  显示推送过来的消息
 *
 *  @param msg 消息
 */
- (void)showAlertMsg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"远程推送"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"退出"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)configNavBar
{
    self.title = kLoadStringWithKey(@"MAIN_VC_KM_title");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-button"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarButtonDidClicked:)];
    //右边 消息
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage2:@"home_message" hightImage:nil target:self action:@selector(messageAction:)];
}

- (void)messageAction:(UIButton *)item
{
    DMLog(@"---------消息---------");
    
    //消息
    KMMessageVc *msVc = [[KMMessageVc alloc]init];
    msVc.fd_interactivePopDisabled = YES;
    [self.navigationController pushViewController:msVc animated:YES];
}

- (void)configView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 添加侧滑手势
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    [self.view addGestureRecognizer:self.slidingViewController.resetTapGesture];
    self.slidingViewController.delegate = self;
   
    self.topTouchView = [[UIView alloc] init];
    self.topTouchView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topTouchView];
    self.topTouchView.userInteractionEnabled = YES;
    [self.topTouchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.topTouchView.hidden = YES;
}

- (void)checkVersion {
    [[KMNetAPI manager] checkVersionWithAPPID:KM_APPID block:^(int code, NSString *res) {
        KMiTunesVersionModel *model = [KMiTunesVersionModel mj_objectWithKeyValues:res];
        if (code == 0 && model.resultCount > 0) {
            KMiTunesVersionDetailModel *versionModel = model.results[0];
            NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
            double currentVersion = [infoDic[@"CFBundleShortVersionString"] doubleValue];
            double latesVersion = [versionModel.version doubleValue];
            if (currentVersion < latesVersion) {
                [self showUpdateAlertViewWithModel:versionModel];
            }
        } else {
            DMLog(@"获取软件版本失败");
        }
    }];
}

- (void)showUpdateAlertViewWithModel:(KMiTunesVersionDetailModel *)model {
    NSString *msg = [NSString stringWithFormat:kLoadStringWithKey(@"MAIN_VC_new_version_msg"), model.version];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kLoadStringWithKey(@"MAIN_VC_new_version")
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 取消
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:kLoadStringWithKey(@"Common_cancel")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:actionCancel];
    
    // 升级
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:kLoadStringWithKey(@"MAIN_VC_new_version_update")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.trackViewUrl]];
                                                     }];
    [alertController addAction:OKAction];
    
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popPresenter = alertController.popoverPresentationController;
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = self.view.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 侧滑
- (void)leftBarButtonDidClicked:(UIBarButtonItem *)item
{
    if (self.slidingViewController.currentTopViewPosition != ECSlidingViewControllerTopViewPositionCentered) {
        self.topTouchView.hidden = NO;
        [self.slidingViewController resetTopViewAnimated:YES];
    } else {
        self.topTouchView.hidden = YES;
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
    }
}

#pragma mark - ECSlidingViewControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController animationControllerForOperation:(ECSlidingViewControllerOperation)operation topViewController:(UIViewController *)topViewController {
    
    // 回到正常位置
    if (operation == ECSlidingViewControllerOperationResetFromRight) {
        // 显示侧滑，添加手势识别
        self.topTouchView.hidden = YES;
    } else {
        // 显示主界面，移除手势识别
        self.topTouchView.hidden = NO;
    }
    return nil;
}
#pragma mark ------------------------------------------------------------------HostFlag-------------------------------------------------

#pragma mark - KMPictureCarouselViewDelegate
- (void)BannerViewDidClicked:(NSUInteger)index
{
    //[SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"Clicked %lu", (unsigned long)index]];
}

- (void)btnDidClicked:(UIButton *)sender
{
//    KMHealthRecordVC *vc = [[KMHealthRecordVC alloc] init];
//    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
//    [self presentViewController:navVC animated:NO completion:nil];
    
    
#if DEBUG
    //默认环境是生产
    NSString *string = KMShengChan;
    if (HostFlag == 0) {//生产
        
        string = KMShengChan;
    }
    else if (HostFlag == 1){//演示
        string = KMYanShi;
    }
    else if (HostFlag == 2){//测试
        string = KMCeShi;
    }
    
    else if (HostFlag == 3){//外网
        string = @"";
    }
    else if (HostFlag == 4){//灰度
        string = @"";
    }
    NSLog(@"string = %@",string);


#else
    
    NSString *string = KMShengChan;
    
#endif
    switch (sender.tag) {
        case 100:           // 健康档案
        {
//            KeyboardViewController *ctl = [[KeyboardViewController alloc] init];
//            [self.navigationController pushViewController:ctl animated:YES];
//            return;
            KMCloudWebView *webVC = [KMCloudWebView new];
            webVC.url = [NSString stringWithFormat:@"%@%@%@",string,@"/#/tab/healthArchive/basicInfoCompleteness?Authorization=Basic%20",_userBase64Data];
            NSLog(@"\n string = %@,\n webVC.url = %@  \n _userBase64Data =  %@",string,webVC.url,_userBase64Data);
            [self.navigationController pushViewController:webVC animated:YES];
//            KMLocationVC *vc = [[KMLocationVC alloc] init];
//            vc.fd_interactivePopDisabled = YES;
//            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case 101:           // 健康记录
        {
            KMCloudWebView *webVC = [KMCloudWebView new];
            webVC.url = [NSString stringWithFormat:@"%@%@%@",string,@"/#/tab/healthRecord/bloodPressure?Authorization=Basic%20",_userBase64Data];
            [self.navigationController pushViewController:webVC animated:YES];
//            KMHealthRecordVC *vc = [[KMHealthRecordVC alloc] init];
//            vc.fd_interactivePopDisabled = YES;
//            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case 102:           // 健康学院
        {
            KMCloudWebView *webVC = [KMCloudWebView new];
            webVC.url = [NSString stringWithFormat:@"%@%@%@",string,@"/#/tab/category?Authorization=Basic%20",_userBase64Data];
            [self.navigationController pushViewController:webVC animated:YES];
//            KMCallVC *vc = [[KMCallVC alloc] init];
//            vc.fd_interactivePopDisabled = YES;
//            [self.navigationController pushViewController:vc animated:YES];
        } break;
        case 103:           // 咨询服务
        {
            KMCloudWebView *webVC = [KMCloudWebView new];
            webVC.url = [NSString stringWithFormat:@"%@%@%@",string,@"/#/tab/consultation?Authorization=Basic%20",_userBase64Data];
            [self.navigationController pushViewController:webVC animated:YES];
//            // 设置马来差异
//            UIViewController * vc;
//#ifdef kApplicationMLVersion
//            vc = [[KMDeviceSettingVC alloc] init];
//#else
//            vc = [[KMAuthenticationVc alloc] init];
//#endif
//            vc.fd_interactivePopDisabled = YES;
//            [self.navigationController pushViewController:vc animated:YES];
        } break;
            
        default:
            break;
    }
    
}

- (void)dealloc
{
    DMLog(@"*** MainVC dealloc ***");
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter removeObserver:self
                             name:@"receiveRemoteNotification"
                           object:nil];
}
@end
