//
//  KMCloudWebView.h
//  InstantCare
//
//  Created by KM on 2016/12/29.
//  Copyright © 2016年 kangmei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMCloudWebView : UIViewController

@property (nonatomic, copy) NSString *url;


@end


@interface WYWebProgressLayer : CAShapeLayer

- (void)finishedLoad;
- (void)startLoad;

- (void)closeTimer;

@end
