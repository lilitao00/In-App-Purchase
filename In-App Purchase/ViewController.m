//
//  ViewController.m
//  In-App Purchase
//
//  Created by llt on 2018/9/7.
//  Copyright © 2018年 LLT. All rights reserved.
//

#import "ViewController.h"
#import "ApplePay.h"

@interface ViewController ()

@property(nonatomic,strong)ApplePay *applepay;//苹果支付


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _applepay = [ApplePay shard];

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 150, 100)];
    [btn setTitle:@"我要付款" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn addTarget:self action:@selector(creatOrderNo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

//创建订单号
- (void)creatOrderNo {
    //内购
    [[ApplePay shard] startManager];//程序打开，开始监听
    /*
     后台创建一个接口，每次调取接口返回不同的订单号，并将订单号传给ApplePay
     */
    
    /*
    NSMutableDictionary *par = [[NSMutableDictionary alloc]init];
    [HWHttpTool postWithHUD:nil WithUrl:@"url" params:par success:^(id json) {
        if ([json[@"Status"]isEqualToString:@"success"]) {
            weakSelf.applepay.orderNo = json[@"Data"];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [weakSelf.applepay configWith:^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            } Fail:^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }];
            [weakSelf.applepay ApplePay];
        }else{
            [SMGlobalMethod showMessage:json[@"Message"]];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"创建订单失败");
    }];
     */
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    
    self.applepay.orderNo = timeString;
    [self.applepay ApplePay];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
