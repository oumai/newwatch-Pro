//
//  KMLocationVC.m
//  InstantCare
//
//  Created by bruce-zhu on 15/12/1.
//  Copyright © 2015年 omg. All rights reserved.
//

#import "KMLocationVC.h"
#import "KMAnnotation.h"
#import "KMRecordsButton.h"
#import "KMLocationCardCell.h"
#import "KMBundleDevicesModel.h"
#import "KMValModel.h"
#import "KMCheckRecordsModel.h"
#import "KMHisRecordsModel.h"
#import "KMEmgRecordsModel.h"
#import "KMFallModel.h"
#import "KMBindDeviceListVC.h"
#import "KMCommonAlertView.h"
#import "KMDeviceSettingVC.h"
#import "KMLocationService.h"
#import "KMNetAPI.h"
#import "MJRefresh.h"
#import "EXTScope.h"
#import "UIImage+Extension.h"
#import "MJExtension.h"
#import "UIImageView+SDWebImage.h"
#import "NSString+Extension.h"
#import <MessageUI/MessageUI.h>


#define kButtonTagCard      0           // 打卡记录
#define kButtonTagHis       1           // 历史记录
#define kButtonTagSos       2           // 救援记录
//#define kButtonTagFalldown  3           // 跌倒记录

#define kBaiduMapZoomLevel  21
#define kGoogleMapZoomLevel 17

#define kUserViewHeight     (SCREEN_HEIGHT*0.45)
// 底部记录按钮宽度
#define kRecordBtnWidth     (SCREEN_WIDTH/3.0)
#define kRecordBtnHeight    40
// 底部view最上面的Label高度
#define kTopLabelHeight     80

@interface KMLocationVC () <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, KMLocationCardCellDelegate, UIGestureRecognizerDelegate, KMBindDeviceListVCDelegate, UIScrollViewDelegate,MFMessageComposeViewControllerDelegate>
/**
 *  iOS自带的地图
 */
@property (nonatomic, strong) MKMapView *mapView;
/**
 *  地图图标
 */
@property (nonatomic, strong) KMAnnotation *annotation;

/**
 *  SOS导航按钮
 */
@property (nonatomic, strong) UIButton *navButton;

/**
 *  当前选择的按钮序号(打卡记录、历史记录、救援记录、跌倒记录)
 */
@property (nonatomic, assign) NSInteger currentSelectBtn;
/**
 *  返回
 */
@property (nonatomic, strong) UIButton *leftNavButton;
/**
 *  设备切换按钮
 */
@property (nonatomic, strong) UIButton *rightNarBtn;
/**
 *  最下面显示记录的view
 */
@property (nonatomic, strong) UIView *userView;
/**
 *  用户头像
 */
@property (nonatomic, strong) UIImageView *userImageView;
/**
 *  用户名
 */
@property (nonatomic, strong) UILabel *userName;
/**
 *  打卡点数
 */
@property (nonatomic, strong) UILabel *userVal;
/**
 *  放置四个按钮的容器
 */
@property (nonatomic, strong) UIScrollView *scrollView;
/**
 *  打卡记录按钮
 */
@property (nonatomic, strong) KMRecordsButton *cardBtn;
/**
 *  救援记录按钮
 */
@property (nonatomic, strong) KMRecordsButton *sosBtn;
/**
 *  历史记录按钮
 */
@property (nonatomic, strong) KMRecordsButton *hisBtn;
///**
// *  跌倒记录按钮
// */
//@property (nonatomic, strong) KMRecordsButton *falldownBtn;
/**
 *  放置下面四个tableview的容器
 */
@property (nonatomic, strong) UIScrollView *tableScrollView;

@property (nonatomic, strong) UITableView *cardTableView;
@property (nonatomic, strong) UITableView *hisTableView;
@property (nonatomic, strong) UITableView *sosTableView;
//@property (nonatomic, strong) UITableView *falldownTableView;
/**
 *  设备列表
 */
@property (nonatomic, strong) KMBundleDevicesModel *deviceListModel;
/**
 *  进入此VC默认选择第一个设备
 */
@property (nonatomic, strong) KMBundleDevicesDetailModel *deviceDetailModel;
/**
 *  打卡点数
 */
@property (nonatomic, strong) KMValDetailModel *valDetailModel;
/**
 *  打卡记录
 */
@property (nonatomic, strong) KMCheckRecordsModel *checkRecordsModel;
/**
 *  历史记录
 */
@property (nonatomic, strong) KMHisRecordsModel *hisRecordsModel;
/**
 *  紧急救援
 */
@property (nonatomic, strong) KMEmgRecordsModel *emgRecordsModel;
/**
 *  跌倒记录
 */
//@property (nonatomic, strong) KMFallModel *fallRecordsModel;
/**
 *  当前选择的坐标, 每次更新地图坐标都必须设置这个值！
 */
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@property (nonatomic,strong) CustomIOSAlertView *addNewDeviceAlertView;
/**
 *  第一次进入显示定位信息，后面切换设备时还会显示定位信息
 *  0 -> 关闭显示功能
 *  其他值指示显示延时时间
 */
@property (nonatomic, assign) NSInteger historyShowFirstRecordTime;

/** 显示上拉状态的图片 */
@property (nonatomic, strong) UIImageView *stateImage;

/** 立即前往 */
@property (nonatomic, strong) UIButton *travelToButton;


@property (nonatomic, strong) KMNetAPI* checkRecordManager;

@property (nonatomic, strong) KMNetAPI* recordsRecordManager;

@property (nonatomic, strong) KMNetAPI* emgRecordsManager;

//@property (nonatomic, strong) KMNetAPI* checkRecordManager;
/** 当前手表类型 */
@property (nonatomic, copy) NSString *currentType;

@end

@implementation KMLocationVC
//  TravelTo
- (UIButton *)travelToButton
{
    if(_travelToButton == nil)
    {
        _travelToButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _travelToButton.layer.cornerRadius = 3;
        _travelToButton.clipsToBounds = YES;
        _travelToButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_travelToButton setBackgroundImage:[UIImage imageWithColor:kMainColor] forState:UIControlStateNormal];
        [_travelToButton setTitle:kLoadStringWithKey(@"Location_VC_Travle_to")
                         forState:UIControlStateNormal];
//        [_TravelTo setTitle:@"测试"  forState:UIControlStateNormal];
        [_travelToButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _travelToButton.frame = CGRectMake(10,82,100, 30);
        _travelToButton.titleLabel.numberOfLines = 1;
        _travelToButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_travelToButton addTarget:self action:@selector(travelToNetwork) forControlEvents:UIControlEventTouchUpInside];
    }
    return _travelToButton;
}

/** 立即前往网络请求  */
- (void)travelToNetwork
{
    //8010通过短信立即定位
    if ([self.deviceDetailModel.type isEqualToString:@"85"]) {
        [self showMessageView:@[self.deviceDetailModel.phone] title:kLoadStringWithKey(@"Location_VC_Travle_to") body:@"*#B6A8*#"];
    }else{
        // 开始更改操作
        [SVProgressHUD show];
        
        // URL
        NSString * reuqest = [NSString stringWithFormat:@"immediate/address/%@/%@",member.loginAccount,self.deviceDetailModel.imei];
        
        // 网络请求
        [[KMNetAPI manager] commonGetRequestWithURL:reuqest Block:^(int code, NSString *res) {
            
            KMNetworkResModel * resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
            if (code == 0 && resModel.errorCode <= kNetReqSuccess)
            {
                // 提示成功
                [SVProgressHUD showSuccessWithStatus:kLoadStringWithKey(@"Common_network_request_OK")];
            }else
            {
                [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
            }
        }];
    }
}


- (void)viewDidLoad
{
    // 如果是因为推送信息进入, 则不显示历史记录, 否则默认延时两秒显示
    if (_pushModel) {
        _historyShowFirstRecordTime = 0;
    } else {
        _historyShowFirstRecordTime = 2;
    }
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configNavBar];
    [self configView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceListFromServer) name:@"kmIMADDNotification" object:nil];
    
    [self updateDeviceListFromServer];
}

//-(void)updateDeviceListFromServerForNotifaction:(NSNotification*)notify{
//    
//    NSDictionary *userInfo = notify.object;
//     self.pushModel = [KMPushMsgModel mj_objectWithKeyValues:userInfo];
//
//    [self updateDeviceListFromServer];
//}

- (void)configNavBar
{
    self.leftNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftNavButton setBackgroundImage:[UIImage imageNamed:@"return_normal"]
                                  forState:UIControlStateNormal];
    [self.leftNavButton addTarget:self
                           action:@selector(backBarButtonDidClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
    self.leftNavButton.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftNavButton];

    self.rightNarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightNarBtn setBackgroundImage:[UIImage imageNamed:@"pick_normal"]
                                forState:UIControlStateNormal];
    [self.rightNarBtn addTarget:self
                         action:@selector(rightBarButtonDidClicked:)
               forControlEvents:UIControlEventTouchUpInside];
    self.rightNarBtn.frame = CGRectMake(0, 0, 30, 30);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightNarBtn];

    self.navigationItem.title = kLoadStringWithKey(@"MAIN_VC_location_btn");
}


- (void)configView
{
    WS(ws);

    // 地图
    switch (member.userMapType) {
        case KM_USER_MAP_TYPE_IOS:
        {
            self.mapView = [[MKMapView alloc] init];
            self.mapView.delegate = self;
            [self.view addSubview:self.mapView];
            [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(ws.view);
            }];
            
            // 加一个导航按钮
            self.navButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.navButton setImage:[UIImage imageNamed:@"nav"] forState:UIControlStateNormal];
            [self.navButton addTarget:self action:@selector(loadMapView) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.navButton];
            [self.navButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@30);
                make.right.equalTo(self.view).offset(-20);
                make.top.equalTo(self.view).offset(64+20);
            }];
        } break;
        default:
            break;
    }

    [self.view addSubview:self.userView];
    [self.view addSubview:self.travelToButton];
    self.travelToButton.hidden = !([self.deviceDetailModel.type isEqualToString:@"20"]||[self.deviceDetailModel.type isEqualToString:@"85"]);
    [self.userName addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
}

/**
 *   监听类型切换
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    self.travelToButton.hidden = !([self.deviceDetailModel.type isEqualToString:@"20"]||[self.deviceDetailModel.type isEqualToString:@"85"]);
}



/// 跳转到苹果地图进行导航
- (void)loadMapView
{
    //目的地位置
    NSLog(@"开始导航，目的地：%f, %f", self.currentLocation.longitude, self.currentLocation.latitude);
    
    //当前的位置
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    
    //目的地的位置
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.currentLocation
                                                                                       addressDictionary:nil]];
    
    toLocation.name = [NSString stringWithFormat:@"[%f, %f]", self.currentLocation.longitude, self.currentLocation.latitude];
    
    NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
    // 打开苹果自身地图应用，并呈现特定的item
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

- (UIView *)userView {
    if (_userView) return _userView;
    
    WS(ws);
    CGFloat startX = SCREEN_HEIGHT - kTopLabelHeight;
    CGRect frame = CGRectMake(0, startX, SCREEN_WIDTH, kUserViewHeight);
    _userView = [[UIView alloc] initWithFrame:frame];
    _userView.backgroundColor = [UIColor whiteColor];
    
    // 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handTap)];
    tap.delegate = self;
    [_userView addGestureRecognizer:tap];
    
    // 添加拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_userView addGestureRecognizer:pan];
    
    self.stateImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,25, 12)];
    self.stateImage.image = [UIImage imageNamed:@"up"];
    [_userView addSubview:_stateImage];
    [self.stateImage mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.mas_equalTo(5);
        make.centerX.equalTo(_userView);
    }];
    
    
    // 头像
    CGFloat userHeaderSize = 40;
    _userImageView = [UIImageView new];
    _userImageView.backgroundColor = [UIColor whiteColor];
    _userImageView.image = [UIImage imageNamed:@"home_button_member_normal"];
    _userImageView.contentMode = UIViewContentModeScaleAspectFit;
    _userImageView.clipsToBounds = YES;
    _userImageView.layer.cornerRadius = userHeaderSize / 2.0;
    [_userView addSubview:_userImageView];
    [_userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userView).offset(20);
//        make.centerY.equalTo(_userView.mas_top);
        make.top.mas_equalTo(30);
        make.width.height.equalTo(@(userHeaderSize));
    }];
    
    // 用户名
    _userName = [UILabel new];
    [_userView addSubview:_userName];
    [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userImageView.mas_right).offset(15);
        make.right.equalTo(_userView.mas_centerX);
        make.bottom.equalTo(_userImageView);
    }];
    
    _userVal = [UILabel new];
    _userVal.textColor = kGrayTipColor;
    _userVal.font = [UIFont systemFontOfSize:16];
    [_userView addSubview:_userVal];
    [_userVal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userName.mas_right);
        make.bottom.equalTo(_userImageView);
    }];
    
    frame = CGRectMake(0, kTopLabelHeight, SCREEN_WIDTH, kRecordBtnHeight);
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.contentSize = CGSizeMake(kRecordBtnWidth*3, kRecordBtnHeight);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [_userView addSubview:_scrollView];
    
    // 改变按钮顺序
    // 救援记录 -> 历史记录 -> 跌倒记录 -> 打卡记录
    // 2016.08.08 -> 去掉跌倒记录
    
    // 打卡记录
    _cardBtn = [KMRecordsButton buttonWithType:UIButtonTypeCustom];
    _cardBtn.tag = kButtonTagCard;
    [_cardBtn setTitle:kLoadStringWithKey(@"Location_VC_check_records") forState:UIControlStateNormal];
    [_cardBtn setTitleColor:kGrayColor forState:UIControlStateNormal];
    [_cardBtn setTitleColor:kMainColor forState:UIControlStateSelected];
    [_cardBtn setImage:[UIImage imageNamed:@"position_button_clock_normal"] forState:UIControlStateNormal];
    [_cardBtn setImage:[UIImage imageNamed:@"position_button_clock_sel"] forState:UIControlStateSelected];
    [_cardBtn addTarget:self action:@selector(recordBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    frame = CGRectMake(kRecordBtnWidth*2, 0, kRecordBtnWidth, kRecordBtnHeight);
    _cardBtn.frame = frame;
    [_scrollView addSubview:_cardBtn];
    
    // 历史记录
    _hisBtn = [KMRecordsButton buttonWithType:UIButtonTypeCustom];
    _hisBtn.tag = kButtonTagHis;
    [_hisBtn setTitle:kLoadStringWithKey(@"Location_VC_his_records") forState:UIControlStateNormal];
    [_hisBtn setTitleColor:kGrayColor forState:UIControlStateNormal];
    [_hisBtn setTitleColor:kMainColor forState:UIControlStateSelected];
    [_hisBtn setImage:[UIImage imageNamed:@"position_button_history_normal"] forState:UIControlStateNormal];
    [_hisBtn setImage:[UIImage imageNamed:@"position_button_history_sel"] forState:UIControlStateSelected];
    [_hisBtn addTarget:self action:@selector(recordBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    _hisBtn.frame = CGRectMake(kRecordBtnWidth, 0, kRecordBtnWidth, kRecordBtnHeight);
    [_scrollView addSubview:_hisBtn];
    
    // 救援记录
    _sosBtn = [KMRecordsButton buttonWithType:UIButtonTypeCustom];
    _sosBtn.tag = kButtonTagSos;
    [_sosBtn setTitle:kLoadStringWithKey(@"Location_VC_emg_records") forState:UIControlStateNormal];
    [_sosBtn setTitleColor:kGrayColor forState:UIControlStateNormal];
    [_sosBtn setTitleColor:kMainColor forState:UIControlStateSelected];
    [_sosBtn setImage:[UIImage imageNamed:@"position_button_rescue_normal"] forState:UIControlStateNormal];
    [_sosBtn setImage:[UIImage imageNamed:@"position_button_rescue_sel"] forState:UIControlStateSelected];
    [_sosBtn addTarget:self action:@selector(recordBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    _sosBtn.frame = CGRectMake(0, 0, kRecordBtnWidth, kRecordBtnHeight);
    _sosBtn.selected = YES;
    [_scrollView addSubview:_sosBtn];
    self.currentSelectBtn = kButtonTagSos;
    
    // 跌倒记录
//    _falldownBtn = [KMRecordsButton buttonWithType:UIButtonTypeCustom];
//    _falldownBtn.tag = kButtonTagFalldown;
//    [_falldownBtn setTitle:kLoadStringWithKey(@"Location_VC_fall_records") forState:UIControlStateNormal];
//    [_falldownBtn setTitleColor:kGrayColor forState:UIControlStateNormal];
//    [_falldownBtn setTitleColor:kMainColor forState:UIControlStateSelected];
//    [_falldownBtn setImage:[UIImage imageNamed:@"position_button_fall_normal"] forState:UIControlStateNormal];
//    [_falldownBtn setImage:[UIImage imageNamed:@"position_button_fall_sel"] forState:UIControlStateSelected];
//    [_falldownBtn addTarget:self action:@selector(recordBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
//    _falldownBtn.frame = CGRectMake(kRecordBtnWidth*2, 0, kRecordBtnWidth, kRecordBtnHeight);
//    [_scrollView addSubview:_falldownBtn];

    frame = CGRectMake(0, kTopLabelHeight+kRecordBtnHeight, SCREEN_WIDTH, kUserViewHeight - (kTopLabelHeight+kRecordBtnHeight));
    _tableScrollView = [[UIScrollView alloc] initWithFrame:frame];
    _tableScrollView.contentSize = CGSizeMake(3*SCREEN_WIDTH, 0);
    _tableScrollView.pagingEnabled = YES;
    _tableScrollView.showsVerticalScrollIndicator = NO;
    _tableScrollView.showsHorizontalScrollIndicator = NO;
    _tableScrollView.delegate = self;
    [_userView addSubview:_tableScrollView];

    // 打卡记录
    frame = CGRectMake(0, 0, SCREEN_WIDTH, _tableScrollView.frame.size.height);
    frame.origin.x = SCREEN_WIDTH*2;
    UILabel *noRecordsLabel = [[UILabel alloc] initWithFrame:frame];
    noRecordsLabel.text = kLoadStringWithKey(@"HealthRecord_VC_no_records");
    noRecordsLabel.font = [UIFont systemFontOfSize:20];
    noRecordsLabel.textAlignment = NSTextAlignmentCenter;
    [_tableScrollView addSubview:noRecordsLabel];
    self.cardTableView = [[UITableView alloc] init];
    self.cardTableView.frame = frame;
    self.cardTableView.delegate = self;
    self.cardTableView.dataSource = self;
    [self.cardTableView registerClass:[KMLocationCardCell class] forCellReuseIdentifier:@"cell"];
    [_tableScrollView addSubview:self.cardTableView];
    self.cardTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws updateCheckRecordsFromServer];
    }];
    // 下拉刷新高度低一点
    self.cardTableView.mj_header.mj_h = 30;

    // 历史记录
    frame.origin.x = SCREEN_WIDTH;
    noRecordsLabel = [[UILabel alloc] initWithFrame:frame];
    noRecordsLabel.text = kLoadStringWithKey(@"HealthRecord_VC_no_records");
    noRecordsLabel.font = [UIFont systemFontOfSize:20];
    noRecordsLabel.textAlignment = NSTextAlignmentCenter;
    [_tableScrollView addSubview:noRecordsLabel];
    self.hisTableView = [[UITableView alloc] init];
    self.hisTableView.frame = frame;
    self.hisTableView.delegate = self;
    self.hisTableView.dataSource = self;
    [self.hisTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableScrollView addSubview:self.hisTableView];
    @weakify(self)
    self.hisTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self updateHisRecordsFromServer];
    }];
    self.hisTableView.mj_header.mj_h = 30;

    // 救援记录
    frame.origin.x = 0;
    noRecordsLabel = [[UILabel alloc] initWithFrame:frame];
    noRecordsLabel.text = kLoadStringWithKey(@"HealthRecord_VC_no_records");
    noRecordsLabel.font = [UIFont systemFontOfSize:20];
    noRecordsLabel.textAlignment = NSTextAlignmentCenter;
    [_tableScrollView addSubview:noRecordsLabel];
    self.sosTableView = [[UITableView alloc] init];
    self.sosTableView.frame = frame;
    self.sosTableView.delegate = self;
    self.sosTableView.dataSource = self;
    [self.sosTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableScrollView addSubview:self.sosTableView];
    self.sosTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [ws updateEmgRecordsFromServer];
    }];
    self.sosTableView.mj_header.mj_h = 30;

    // 跌倒记录
//    frame.origin.x = SCREEN_WIDTH*2;
//    noRecordsLabel = [[UILabel alloc] initWithFrame:frame];
//    noRecordsLabel.text = kLoadStringWithKey(@"HealthRecord_VC_no_records");
//    noRecordsLabel.font = [UIFont systemFontOfSize:20];
//    noRecordsLabel.textAlignment = NSTextAlignmentCenter;
//    [_tableScrollView addSubview:noRecordsLabel];
//    self.falldownTableView = [[UITableView alloc] init];
//    self.falldownTableView.frame = frame;
//    self.falldownTableView.delegate = self;
//    self.falldownTableView.dataSource = self;
//    [self.falldownTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
//    [_tableScrollView addSubview:self.falldownTableView];
//    self.falldownTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [ws updateFallRecordsFromServer];
//    }];
//    self.falldownTableView.mj_header.mj_h = 30;

    return _userView;
}

#pragma mark - 地图上添加一个标注
- (void)addUserLocationAnnotationWithName:(NSString *)name
                                 location:(CLLocation *)location
                                  Address:(NSString *)address
                                      Out:(BOOL)endOut
{
    switch (member.userMapType) {
        case KM_USER_MAP_TYPE_IOS:
        case KM_USER_MAP_TYPE_IOS_CHINA:
        {
            // 地图上只会存在一个标签
            if (self.annotation) {
                [self.mapView removeAnnotation:self.annotation];
            }
            self.annotation = [[KMAnnotation alloc] init];
            self.annotation.title = name;
            self.annotation.subtitle = address;
            self.annotation.coordinate = location.coordinate;
            if (endOut) {
                self.annotation.image = [UIImage imageNamed:@"icon_pin_floating"];
            } else {
                self.annotation.image = [UIImage imageNamed:@"icon_paopao_waterdrop_streetscape"];
            }

            [self.mapView setCenterCoordinate:location.coordinate
                                     animated:YES];
            [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, 100, 100)
                           animated:NO];

            [_mapView addAnnotation:self.annotation];
            [_mapView selectAnnotation:self.annotation animated:YES];
        } break;
        default:
            break;
    }
}

#pragma mark - 四个按钮点击事件
- (void)recordBtnDidClicked:(UIButton *)sender {
    [self selectOnlyoneButtonWithIndex:sender.tag];
    
    // 按钮变了，清除地图上面已经显示的图标
    // 并且当前记录的选择状态也要清除
    if (self.currentSelectBtn != sender.tag) {
//        if (self.annotation) {
//            [self.mapView removeAnnotation:self.annotation];
//        }
        
        switch (self.currentSelectBtn) {
            case kButtonTagCard:
                [self deSelectAllCardCellBtn];
                [_cardTableView reloadData];
                break;
            case kButtonTagHis:
                [self deSelectAllHisCell];
                [_hisTableView reloadData];
                break;
            case kButtonTagSos:
                [self deSelectAllEmgCell];
                [_sosTableView reloadData];
                break;
//            case kButtonTagFalldown:
//                [self deSelectAllFallCell];
//                [_falldownTableView reloadData];
//                break;
            default:
                break;
        }
    }

    self.currentSelectBtn = sender.tag;
    switch (sender.tag) {
        case kButtonTagCard:        // 打卡记录
            [self.tableScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*2, 0) animated:YES];
            break;
        case kButtonTagHis:         // 历史记录
            [self.tableScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
            break;
        case kButtonTagSos:         // 救援记录
            [self.tableScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            break;
//        case kButtonTagFalldown:    // 跌倒记录
//            [self.tableScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*2, 0) animated:YES];
            break;
        default:
            break;
    }
}

#pragma mark - 隐藏或者显示底部的View
- (void)handTap {
    if (self.userView.frame.origin.y > SCREEN_HEIGHT - kUserViewHeight + 1) {   // 当前在底部，弹出
        [UIView animateWithDuration:0.2 animations:^{
            self.stateImage.image = [UIImage imageNamed:@"down"];
            CGRect frame = _userView.frame;
            frame.origin.y = SCREEN_HEIGHT - kUserViewHeight;
            _userView.frame = frame;
        }];
    } else {        // 已经弹出, 隐藏
        [UIView animateWithDuration:0.2 animations:^{
            self.stateImage.image = [UIImage imageNamed:@"up"];
            CGRect frame = _userView.frame;
            frame.origin.y = SCREEN_HEIGHT - kTopLabelHeight;
            _userView.frame = frame;
        }];
    }
}

- (void)showUserView {
    [UIView animateWithDuration:0.2 animations:^{
        self.stateImage.image = [UIImage imageNamed:@"down"];
        CGRect frame = _userView.frame;
        frame.origin.y = SCREEN_HEIGHT - kUserViewHeight;
        _userView.frame = frame;
    }];
}

- (void)hideUserView {
    [UIView animateWithDuration:0.2 animations:^{
        self.stateImage.image = [UIImage imageNamed:@"up"];
        CGRect frame = _userView.frame;
        frame.origin.y = SCREEN_HEIGHT - kTopLabelHeight;
        _userView.frame = frame;
    }];
}

#pragma mark - 拖动手势
- (void)handlePan:(UIPanGestureRecognizer *)rec {
    CGPoint point = [rec translationInView:self.userView];
    static BOOL flag = YES;
    if (rec.state != UIGestureRecognizerStateEnded) {
        flag = point.y > 0 ? YES : NO;
    }
    CGRect frame = self.userView.frame;
    CGFloat y = frame.origin.y + point.y;
    if (y >= SCREEN_HEIGHT - kUserViewHeight &&
        y <= SCREEN_HEIGHT - (kRecordBtnHeight + 50)) {
        frame.origin.y = y;
        self.userView.frame = frame;
    }

    [rec setTranslation:CGPointMake(0, 0) inView:self.userView];
    if (rec.state == UIGestureRecognizerStateEnded && flag) {
        [self hideUserView];
    } else if (rec.state == UIGestureRecognizerStateEnded && !flag) {
        [self showUserView];
    }
}

- (void)selectOnlyoneButtonWithIndex:(NSInteger)index {
    switch (index) {
        case kButtonTagCard:
            self.cardBtn.selected = YES;
            self.hisBtn.selected = NO;
            self.sosBtn.selected = NO;
//            self.falldownBtn.selected = NO;
            break;
        case kButtonTagHis:
            self.cardBtn.selected = NO;
            self.hisBtn.selected = YES;
            self.sosBtn.selected = NO;
//            self.falldownBtn.selected = NO;
            break;
        case kButtonTagSos:
            self.cardBtn.selected = NO;
            self.hisBtn.selected = NO;
            self.sosBtn.selected = YES;
//            self.falldownBtn.selected = NO;
            break;
//        case kButtonTagFalldown:
//            self.cardBtn.selected = NO;
//            self.hisBtn.selected = NO;
//            self.sosBtn.selected = NO;
//            self.falldownBtn.selected = YES;
            break;
        default:
            break;
    }
}

#pragma mark - 切换设备
- (void)rightBarButtonDidClicked:(UIBarButtonItem *)sender
{
    KMBindDeviceListVC *vc = [[KMBindDeviceListVC alloc] init];
    vc.detailModel = _deviceDetailModel;
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 返回
- (void)backBarButtonDidClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KMBindDeviceListVCDelegate
- (void)didSelectBindDeviceWithModel:(KMBundleDevicesDetailModel *)deviceListDetailModel {

    if ([KMMemberManager sharedInstance].netStatus < 1 ) {
        
        [SVProgressHUD showErrorWithStatus:kNetError];
        return;
    }
    // fix BUG: 切换设备时重新选择历史记录
    _historyShowFirstRecordTime = 1;
    _deviceDetailModel = deviceListDetailModel;
    _userName.text = _deviceDetailModel.realName;
    [_userImageView sdImageWithIMEI:_deviceDetailModel.imei];
    self.currentType = deviceListDetailModel.type;
    [self updateAllRecordsFromServer];
}

#pragma mark - scrollView事件

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableScrollView) {
        CGFloat scrollviewW =  scrollView.frame.size.width;
        CGFloat x = scrollView.contentOffset.x;
        int page = (x + scrollviewW / 2) / scrollviewW;
        
        switch (page) {
            case 0:
                self.currentSelectBtn = kButtonTagSos;
                break;
            case 1:
                self.currentSelectBtn = kButtonTagHis;
                break;
            case 2:
                self.currentSelectBtn = kButtonTagCard;
                break;
            default:
                break;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.tableScrollView) {
        switch (self.currentSelectBtn) {
            case kButtonTagCard:
                [self selectOnlyoneButtonWithIndex:kButtonTagCard];
//                [self.scrollView setContentOffset:CGPointMake(kRecordBtnWidth, 0) animated:YES];
                break;
            case kButtonTagHis:
                [self selectOnlyoneButtonWithIndex:kButtonTagHis];
                break;
            case kButtonTagSos:
                [self selectOnlyoneButtonWithIndex:kButtonTagSos];
//                [self.scrollView setContentOffset:CGPointZero animated:YES];
                break;
//            case kButtonTagFalldown:
//                [self selectOnlyoneButtonWithIndex:kButtonTagFalldown];
                break;
            default:
                break;
        }
    }
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retCount = 0;
    
    if (tableView == self.cardTableView) {
        retCount = _checkRecordsModel.list.count;
    } else if (tableView == self.hisTableView) {
        retCount =  _hisRecordsModel.list.count;
    } else if (tableView == self.sosTableView) {
        retCount = _emgRecordsModel.list.count;
    }

    return retCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (tableView == self.cardTableView) {
        KMLocationCardCell *cardCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        KMCheckRecordsDetailModel *m = _checkRecordsModel.list[indexPath.row];
        cardCell.delegate = self;
        cardCell.checkinDate = [NSString stringWholeWithDateAndMinute:m.checkInDate];
        if (m.checkOutDate == 0) {
            cardCell.checkOutDate = kLoadStringWithKey(@"Location_VC_not_checkout");
        } else {
            cardCell.checkOutDate = [NSString stringWholeWithDateAndMinute:m.checkOutDate];
        }
        cardCell.selectBtnIndex = m.btnSelectState;
        cell = cardCell;
    } else if (tableView == self.hisTableView) {
        KMHisRecordsDetailModel *m = _hisRecordsModel.list[indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        cell.textLabel.text = [NSString stringWholeWithDateAndMinute:m.prDate];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        // 去掉cell的选择效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (m.cellSelected) {
            cell.textLabel.textColor = kMainColor;
            cell.imageView.image = [UIImage imageNamed:@"position_circle_orange_sel"];
        } else {
            cell.textLabel.textColor = kGrayContextColor;
            cell.imageView.image = [UIImage imageNamed:@"position_circle_orange_normal"];
        }
    } else if (tableView == self.sosTableView) {
        KMEmgRecordsDetailModel *m = _emgRecordsModel.list[indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        cell.textLabel.text = [NSString stringWholeWithDateAndMinute:m.emgDate];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        // 去掉cell的选择效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (m.cellSelected) {
            cell.textLabel.textColor = kMainColor;
            cell.imageView.image = [UIImage imageNamed:@"position_circle_orange_sel"];
        } else {
            cell.textLabel.textColor = kGrayContextColor;
            cell.imageView.image = [UIImage imageNamed:@"position_circle_orange_normal"];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.hisTableView) {           // 历史记录
        [self deSelectAllHisCell];
        KMHisRecordsDetailModel *m = _hisRecordsModel.list[indexPath.row];
        m.cellSelected = YES;
        [_hisTableView reloadData];
        
        self.currentLocation = CLLocationCoordinate2DMake(m.gpsLat, m.gpsLng);
        CLLocation *location = [[CLLocation alloc] initWithLatitude:m.gpsLat longitude:m.gpsLng];
        [self addUserLocationAnnotationWithName:kLoadStringWithKey(@"Location_VC_his_records")
                                       location:location
                                        Address:m.address
                                            Out:NO];
    } else if (tableView == self.sosTableView) {    // 救援记录
        [self deSelectAllEmgCell];
        KMEmgRecordsDetailModel *m = _emgRecordsModel.list[indexPath.row];
        m.cellSelected = YES;
        [_sosTableView reloadData];
        
        self.currentLocation = CLLocationCoordinate2DMake(m.gpsLat, m.gpsLng);
        CLLocation *location = [[CLLocation alloc] initWithLatitude:m.gpsLat longitude:m.gpsLng];
        [self addUserLocationAnnotationWithName:kLoadStringWithKey(@"Location_VC_emg_records")
                                       location:location
                                        Address:m.address
                                            Out:NO];
    }
}

/**
 *  若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }

    return  YES;
}

#pragma mark - KMLocationCardCellDelegate
- (void)cellBtnDidClickWithCell:(KMLocationCardCell *)cell btnIndex:(NSInteger)index {
    [self deSelectAllCardCellBtn];
    NSIndexPath *currentIndexPath = [_cardTableView indexPathForCell:cell];
    KMCheckRecordsDetailModel *m = _checkRecordsModel.list[currentIndexPath.row];
    m.btnSelectState = index;
    
    [_cardTableView reloadData];
    
    NSString *name = index == 0 ? kLoadStringWithKey(@"Location_VC_checkin") : kLoadStringWithKey(@"Location_VC_checkout");
    CLLocation *location;
    NSString *address;
    if (index == 0) {
        location = [[CLLocation alloc] initWithLatitude:m.inGpsLat longitude:m.inGpsLng];
        address = m.inAddress;
    } else {
        location = [[CLLocation alloc] initWithLatitude:m.outGpsLat longitude:m.outGpsLng];
        address = m.outAddress;
    }
    
    self.currentLocation = location.coordinate;
    
    [self addUserLocationAnnotationWithName:name location:location Address:address Out:index];
}

/**
 *  取消选中所有打卡记录
 */
- (void)deSelectAllCardCellBtn {
    for (KMCheckRecordsDetailModel *m in _checkRecordsModel.list) {
        m.btnSelectState = -1;
    }
}

- (void)deSelectAllHisCell {
    for (KMHisRecordsDetailModel *m in _hisRecordsModel.list) {
        m.cellSelected = NO;
    }
}

- (void)deSelectAllEmgCell {
    for (KMEmgRecordsDetailModel *m in _emgRecordsModel.list) {
        m.cellSelected = NO;
    }
}

//- (void)deSelectAllFallCell {
//    for (KMFallDetailModel *m in _fallRecordsModel.list) {
//        m.cellSelected = NO;
//    }
//}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    CLLocationCoordinate2D temp = self.currentLocation;

    // 为了不被遮挡，需要向下偏移一点
    if (temp.latitude >= 0.0003) {
        temp.latitude -= 0.0003;
    }
    
    mapView.centerCoordinate = temp;
}

#pragma mark - 根据anntation生成对应的View
- (UIView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation
{
    if ([annotation isKindOfClass:[KMAnnotation class]]) {                  // iOS自带地图
        static NSString *key1 = @"AnnotationKey";
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:key1];
            annotationView.canShowCallout = YES;
        }

        annotationView.annotation = annotation;
        annotationView.selected = YES;
        annotationView.image = ((KMAnnotation *)annotation).image;
        return annotationView;
    }

    return nil;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    NSLog(@"mapViewDidFinishLoadingMap");
}

#pragma mark - 从服务器拉取数据

- (void)updateAllRecordsFromServer {
    [self updateValFromServer];
    [self updateCheckRecordsFromServer];
    [self updateHisRecordsFromServer];
    [self updateEmgRecordsFromServer];
    //新增 根据手表类型隐藏部分功能
    [self setUserViewForType];
}
- (void)setUserViewForType{
    if (self.currentType == nil) {
        self.currentType = _deviceDetailModel.type;
    }
    
    /*if ([self.currentType isEqualToString:@"100"]){
        //隐藏多余btn
        self.sosBtn.hidden = YES;
        self.cardBtn.hidden = YES;
        
        _hisBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, kRecordBtnHeight);
        
        _tableScrollView.bounces = YES;
        _tableScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*1, 0);
        
        [self recordBtnDidClicked:self.hisBtn];
    }else*/ if ([self.currentType isEqualToString:@"20"]||[self.currentType isEqualToString:@"1"]){
        //隐藏多余btn
        self.cardBtn.hidden = YES;
        self.sosBtn.hidden = NO;
        //隐藏打卡点数
        self.userVal.hidden = YES;
        
        _sosBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH * 0.5, kRecordBtnHeight);
        _hisBtn.frame = CGRectMake(SCREEN_WIDTH * 0.5, 0, SCREEN_WIDTH * 0.5, kRecordBtnHeight);
        
        _tableScrollView.bounces = NO;
        _tableScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*2, 0);
        [self recordBtnDidClicked:self.sosBtn];
    }else{
        //取消隐藏
        _cardBtn.frame = CGRectMake(kRecordBtnWidth*2, 0, kRecordBtnWidth, kRecordBtnHeight);
        _hisBtn.frame = CGRectMake(kRecordBtnWidth, 0, kRecordBtnWidth, kRecordBtnHeight);
        _sosBtn.frame = CGRectMake(0, 0, kRecordBtnWidth, kRecordBtnHeight);
        
        
        self.sosBtn.hidden = NO;
        self.cardBtn.hidden = NO;
        self.userVal.hidden = NO;
        _tableScrollView.bounces = YES;
        _tableScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*3, 0);
        [self recordBtnDidClicked:self.sosBtn];
    }
}

/**
 *  依次获取设备列表 -> 打卡点数 -> 打卡记录 -> 历史记录 -> 救援记录 -> 跌倒记录
 */
- (void)updateDeviceListFromServer {
    @weakify(self)
    [SVProgressHUD show];
    [[KMNetAPI manager] getDevicesListWithAccount:member.loginAccount
                                            Block:^(int code, NSString *res) {
        @strongify(self)
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
            [SVProgressHUD dismiss];
            _deviceListModel = [KMBundleDevicesModel mj_objectWithKeyValues:resModel.content];
            // 还没有绑定任何设置，跳到绑定页面
            if (_deviceListModel.list.count == 0) {
                [self jumpToBundleDeviceVC];
                return;
            }
            // 处理推送消息：如果传了imei则默认显示这个imei
            if (_pushModel.content.imei.length > 0) {
                for (int i = 0; i < _deviceListModel.list.count; i++) {
                    KMBundleDevicesDetailModel *m = [_deviceListModel.list objectAtIndex:i];
                    if ([_pushModel.content.imei isEqualToString:m.imei]) {
                        _deviceDetailModel = m;
                        break;
                    }
                }
                
                if (_deviceDetailModel == nil) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"*** 模型传入错误，IMEI(%@)未找到", _pushModel.content.imei]];
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        // 使用推送的信息显示定位信息
                        CLLocation *location = [[CLLocation alloc] initWithLatitude:_pushModel.content.lat longitude:_pushModel.content.lon];
                        _currentLocation = CLLocationCoordinate2DMake(_pushModel.content.lat, _pushModel.content.lon);
                        NSString *title;
                        if ([_pushModel.content.type isEqualToString:@"SOS"]) {
                            title = kLoadStringWithKey(@"Location_VC_push_emg_records");
                        } else {
                            title = kLoadStringWithKey(@"Location_VC_push_fall_records");
                        }
                        
                        [self addUserLocationAnnotationWithName:title
                                                     location:location
                                                      Address:_pushModel.content.address
                                                          Out:NO];
                        
                        _pushModel = nil;
                    });
                }
            } else {
                // 使用当前使用的设备
                _deviceDetailModel = nil;
                for (int i = 0; i < _deviceListModel.list.count; i++) {
                    KMBundleDevicesDetailModel *detail = _deviceListModel.list[i];
                    if (detail.myWear == 1) {
                        _deviceDetailModel = detail;
                        break;
                    }
                }
                
                // 如果没有正在使用的设备，选择第一个设备作为当前使用设备
                if (_deviceDetailModel == nil) {
                    _deviceDetailModel = _deviceListModel.list[0];
                }
            }
            
            _userName.text = _deviceDetailModel.realName;
            [_userImageView sdImageWithIMEI:_deviceDetailModel.imei];
            
            [self updateAllRecordsFromServer];
        } else {
            [SVProgressHUD showErrorWithStatus:kNetReqFailWithCode(resModel.errorCode)];
            DMLog(@"*** DeviceList: %@", resModel.msg);
        }
    }];
}

- (void)jumpToBundleDeviceVC {
    self.addNewDeviceAlertView = [[CustomIOSAlertView alloc] init];
    KMCommonAlertView *view = [[KMCommonAlertView alloc] initWithFrame:CGRectMake(0, 0,300, 200)];
    view.titleLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_select");
    view.titleLabel.backgroundColor = kRedColor;
    view.msgLabel.text = kLoadStringWithKey(@"DeviceSetting_VC_no_device_bind");
    view.buttonsArray = @[kLoadStringWithKey(@"DeviceSetting_VC_YES")];
    
    UIButton *cancelButton = view.realButtons[0];
    cancelButton.tag = 100;
    [cancelButton addTarget:self action:@selector(jumpToRealBundleDeviceVC:) forControlEvents:UIControlEventTouchUpInside];
    
    self.addNewDeviceAlertView.containerView = view;
    self.addNewDeviceAlertView.buttonTitles = nil;
    [self.addNewDeviceAlertView setUseMotionEffects:NO];
    
    [self.addNewDeviceAlertView show];
}

- (void)jumpToRealBundleDeviceVC:(UIButton *)sender {
    [self.addNewDeviceAlertView close];
    KMDeviceSettingVC *vc = [KMDeviceSettingVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  从服务器获取打卡点数
 */
- (void)updateValFromServer {
//    [[KMNetAPI manager] getValWithIMEI:_deviceDetailModel.imei Block:^(int code, NSString *res) {
//        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
//        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
//            KMValModel *valModel = [KMValModel mj_objectWithKeyValues:resModel.content];
//            if (valModel.list.count > 0) {
//                _valDetailModel = [valModel.list objectAtIndex:0];
//                _userVal.text = [NSString stringWithFormat:@" (%@%d)",
//                                 kLoadStringWithKey(@"Location_VC_check_val"),
//                                 _valDetailModel.currentVal];
//            } else {
//                _userVal.text = @"";
//            }
//        } else {
//            DMLog(@"*** Val: %@", resModel.msg);
//        }
//    }];
    [[KMLocationService sharedInstance] getValWithIMEI:_deviceDetailModel.imei successHandler:^(id data) {
        
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:data];
        
        KMValModel *valModel = [KMValModel mj_objectWithKeyValues:resModel.content];
        if (valModel.list.count > 0) {
            _valDetailModel = [valModel.list objectAtIndex:0];
            _userVal.text = [NSString stringWithFormat:@" (%@%d)",
                             kLoadStringWithKey(@"Location_VC_check_val"),
                             _valDetailModel.currentVal];
        } else {
            _userVal.text = @"";
        }
    } failureHandler:^(NSError *error) {
        DMLog(@"*** Val: %@", error.localizedDescription);
    }];
}

/**
 *  从服务器获取打卡记录
 */
- (void)updateCheckRecordsFromServer {
    //WS(ws);
//    self.checkRecordManager = [KMNetAPI manager];
//    NSLog(@"打开记录 %@",self.checkRecordManager);
//    [self.checkRecordManager getCheckRecordsWithIMEI:_deviceDetailModel.imei Block:^(int code, NSString *res) {
//        //if (ws.annotation) [ws.mapView removeAnnotation:ws.annotation];
//        [_cardTableView.mj_header endRefreshing];
//        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
//        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
//            _checkRecordsModel = [KMCheckRecordsModel mj_objectWithKeyValues:resModel.content];
//            if (_checkRecordsModel.list.count == 0) {
//                _cardTableView.hidden = YES;
//            } else {
//                _cardTableView.hidden = NO;
//            }
//            [_cardTableView reloadData];
//        } else {
//            DMLog(@"*** CheckRecords: %@", resModel.msg);
//        }
//    }];
    [[KMLocationService sharedInstance] getCheckRecordsWithIMEI:_deviceDetailModel.imei successHandler:^(id data) {
        
        //if (ws.annotation) [ws.mapView removeAnnotation:ws.annotation];
        [_cardTableView.mj_header endRefreshing];
        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:data];
        _checkRecordsModel = [KMCheckRecordsModel mj_objectWithKeyValues:resModel.content];
        if (_checkRecordsModel.list.count == 0) {
            _cardTableView.hidden = YES;
        } else {
            _cardTableView.hidden = NO;
        }
        [_cardTableView reloadData];
    } failureHandler:^(NSError *error) {
        DMLog(@"*** Val: %@", error.localizedDescription);
    }];
    
}

/**
 *  获取历史记录
 */
- (void)updateHisRecordsFromServer {
    //WS(ws);
//    self.recordsRecordManager = [KMNetAPI manager];
//    NSLog(@"获取历史记录 %@",self.recordsRecordManager);
//    [self.recordsRecordManager getHisRecordsWithIMEI:_deviceDetailModel.imei Block:^(int code, NSString *res) {
//        //if (ws.annotation) [ws.mapView removeAnnotation:ws.annotation];
//        [_hisTableView.mj_header endRefreshing];
//        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
//        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
//            _hisRecordsModel = [KMHisRecordsModel mj_objectWithKeyValues:resModel.content];
//            [_hisTableView reloadData];
//            if (_hisRecordsModel.list.count == 0) {
//                _hisTableView.hidden = YES;
//            } else {
//                _hisTableView.hidden = NO;
//            }
//            
//            // 进入定位页面显示历史记录第一笔数据, 如果是推送信息弹出的提示则直接返回
//            // 地图未完全加载完，可能会出问题
//            if (_historyShowFirstRecordTime != 0) {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_historyShowFirstRecordTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    _historyShowFirstRecordTime = 0;
//                    if (_hisRecordsModel.list.count > 0) {
//                        KMHisRecordsDetailModel *m = _hisRecordsModel.list[0];
//                        
//                        self.currentLocation = CLLocationCoordinate2DMake(m.gpsLat, m.gpsLng);
//                        CLLocation *location = [[CLLocation alloc] initWithLatitude:m.gpsLat longitude:m.gpsLng];
//                        [self addUserLocationAnnotationWithName:kLoadStringWithKey(@"Location_VC_his_records")
//                                                       location:location
//                                                        Address:m.address
//                                                            Out:NO];
//                    }
//                });
//            }
//        } else {
//            DMLog(@"*** HisRecords: %@", resModel.msg);
//        }
//    }];
    [[KMLocationService sharedInstance] getHisRecordsWithIMEI:_deviceDetailModel.imei successHandler:^(id data) {
        //if (ws.annotation) [ws.mapView removeAnnotation:ws.annotation];
                [_hisTableView.mj_header endRefreshing];
                KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:data];
                                    _hisRecordsModel = [KMHisRecordsModel mj_objectWithKeyValues:resModel.content];
                    [_hisTableView reloadData];
                    if (_hisRecordsModel.list.count == 0) {
                        _hisTableView.hidden = YES;
                    } else {
                        _hisTableView.hidden = NO;
                    }
        
                    // 进入定位页面显示历史记录第一笔数据, 如果是推送信息弹出的提示则直接返回
                    // 地图未完全加载完，可能会出问题
                    if (_historyShowFirstRecordTime != 0) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_historyShowFirstRecordTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            _historyShowFirstRecordTime = 0;
                            if (_hisRecordsModel.list.count > 0) {
                                KMHisRecordsDetailModel *m = _hisRecordsModel.list[0];
        
                                self.currentLocation = CLLocationCoordinate2DMake(m.gpsLat, m.gpsLng);
                                CLLocation *location = [[CLLocation alloc] initWithLatitude:m.gpsLat longitude:m.gpsLng];
                                [self addUserLocationAnnotationWithName:kLoadStringWithKey(@"Location_VC_his_records")
                                                               location:location
                                                                Address:m.address
                                                                    Out:NO];
                            }
                        });
                    }

    } failureHandler:^(NSError *error) {
         DMLog(@"*** HisRecords: %@", error.localizedDescription);
    }];
}

/**
 *  获取求救记录
 */
- (void)updateEmgRecordsFromServer {
    //WS(ws);
//     self.emgRecordsManager = [KMNetAPI manager];
//    [self.emgRecordsManager getEmgRecordsWithIMEI:_deviceDetailModel.imei Block:^(int code, NSString *res) {
//        //if (ws.annotation) [ws.mapView removeAnnotation:ws.annotation];
//        [_sosTableView.mj_header endRefreshing];
//        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
//        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
//            _emgRecordsModel = [KMEmgRecordsModel mj_objectWithKeyValues:resModel.content];
//            if (_emgRecordsModel.list.count == 0) {
//                _sosTableView.hidden = YES;
//            } else {
//                _sosTableView.hidden = NO;
//            }
//            [_sosTableView reloadData];
//        } else {
//            DMLog(@"*** EmgRecords: %@", resModel.msg);
//        }
//    }];
    [[KMLocationService sharedInstance] getEmgRecordsWithIMEI:_deviceDetailModel.imei successHandler:^(id data) {
                //if (ws.annotation) [ws.mapView removeAnnotation:ws.annotation];
                [_sosTableView.mj_header endRefreshing];
                KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:data];
                    _emgRecordsModel = [KMEmgRecordsModel mj_objectWithKeyValues:resModel.content];
                    if (_emgRecordsModel.list.count == 0) {
                        _sosTableView.hidden = YES;
                    } else {
                        _sosTableView.hidden = NO;
                    }
                    [_sosTableView reloadData];
                
    } failureHandler:^(NSError *error) {
        DMLog(@"*** EmgRecords: %@", error.localizedDescription);
    }];
}

///**
// *  获取跌倒记录
// */
//- (void)updateFallRecordsFromServer {
//    //WS(ws);
//    [[KMNetAPI manager] getFallRecordsWithIMEI:_deviceDetailModel.imei Block:^(int code, NSString *res) {
//        //if (ws.annotation) [ws.mapView removeAnnotation:ws.annotation];
//        [_falldownTableView.mj_header endRefreshing];
//        KMNetworkResModel *resModel = [KMNetworkResModel mj_objectWithKeyValues:res];
//        if (code == 0 && resModel.errorCode <= kNetReqSuccess) {
//            _fallRecordsModel = [KMFallModel mj_objectWithKeyValues:resModel.content];
//            if (_fallRecordsModel.list.count == 0) {
//                _falldownTableView.hidden = YES;
//            } else {
//                _falldownTableView.hidden = NO;
//            }
//            [_falldownTableView reloadData];
//        } else {
//            kNetReqFailWithCode(resModel.errorCode);
//            DMLog(@"*** FallRecords: %@", resModel.msg);
//        }
//    }];
//}

#pragma mark - 8010立即定位发送短信 Delegate
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            //信息传送成功
            
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            
            break;
        default:
            break;
    }
}

-(void)showMessageView:(NSArray *)phones title:(NSString *)title body:(NSString *)body
{
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = phones;
        controller.navigationBar.tintColor = [UIColor redColor];
        controller.body = body;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
//        [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kLoadStringWithKey(@"Location_VC_message_Prompt_information") message:kLoadStringWithKey(@"Location_VC_message_description") delegate:nil cancelButtonTitle:kLoadStringWithKey(@"Location_VC_message_confirm") otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)dealloc
{
    if (self.mapView) {
        self.mapView.delegate = nil;
        [self.mapView removeFromSuperview];
        self.mapView = nil;
    }
    [self.userName removeObserver:self forKeyPath:@"text"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kmIMADDNotification" object:nil];
}


@end
