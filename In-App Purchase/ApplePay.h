//
//  ApplePay.h
//  YaoBaFromYF
//
//  Created by llt on 2018/9/7.
//  Copyright © 2018年 LLT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

typedef NS_ENUM(NSInteger) {
    IAP0p20=20,
    IAP1p100,
    IAP4p600,
    IAP9p1000,
    IAP24p6000,
}buyCoinsTag;

@interface ApplePay : NSObject {
    int buyType;
}

@property (nonatomic, copy) NSString *orderNo;

+ (instancetype)shard;

/**
 启动工具
 */
- (void)startManager;

/**
 结束工具
 */
- (void)stopManager;

- (void)ApplePay;

- (void)configWith:(void(^)(void))BlockSucsess Fail:(void(^)(void))Failler;


@end
