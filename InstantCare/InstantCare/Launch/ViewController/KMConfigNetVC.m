//
//  KMConfigNetVC.m
//  InstantCare
//
//  Created by Omichael on 2017/3/27.
//  Copyright © 2017年 kangmei. All rights reserved.
//


//项目基色
#define BaseColor [UIColor colorWithRed:255.0/255.f green:110.0/255.f blue:127.0/255.f alpha:1.0]

#import "KMConfigNetVC.h"

@interface KMConfigNetVC ()

@end

@implementation KMConfigNetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.title = @"域名配置";
    [self initView];
}

-(void)initView{
    for (int i = 0; i <=5 ; i++) {
        UIButton *button = [[UIButton alloc]init];
        button.tag = i+100;
        [button setTitle:[self setButtonTitle:button] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changeHost:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(20, 64+50*i, [UIScreen mainScreen].bounds.size.width - 20*2, 50);
        [self.view addSubview:button];
    }
    NSLog(@"%ld",(long)[[NSUserDefaults standardUserDefaults]integerForKey:@"HOST"]);
    UIButton *button = [self.view viewWithTag:[[NSUserDefaults standardUserDefaults]integerForKey:@"HOST"]];
    [self setButtonBackColor:button];
}

-(NSString *)setButtonTitle:(UIButton *)sender{
    NSInteger tag = sender.tag;
    NSString *string = [[NSString alloc]init];
    switch (tag-100) {
        case 0:
            string = @"生产";
            break;
        case 1:
            string = @"演示";
            break;
        case 2:
            string = @"测试";
            break;
        case 3:
            string = @"Azure";
            break;
        case 4:
            string = @"外网";
            break;
        case 5:
            string = @"灰度";
            break;
        default:
            break;
    }
    
  
    return string;
}

-(void)setButtonBackColor:(UIButton *)sender{
    for (int i = 0; i <=4 ; i++) {
        UIButton *button = [self.view viewWithTag:i+100];
        [button setBackgroundColor:[UIColor lightGrayColor]];
    }
    [sender setBackgroundColor:kBuleColor];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)changeHost:(UIButton *)sender{
    [[NSUserDefaults standardUserDefaults]setInteger:sender.tag forKey:@"HOST"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"%ld",(long)[[NSUserDefaults standardUserDefaults]integerForKey:@"HOST"]);
    [self setButtonBackColor:sender];
}


@end
