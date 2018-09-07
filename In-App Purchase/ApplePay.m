//
//  ApplePay.m
//  YaoBaFromYF
//
//  Created by llt on 2018/9/7.
//  Copyright © 2018年 LLT. All rights reserved.
//

#import "ApplePay.h"
#import <StoreKit/StoreKit.h>
//在内购项目中创的商品单号

#define ProductID_IAP0p20 @"ceshi001"//App内购买项目的产品ID
#define ProductID_IAP1p100 @"ceshi001" //100
#define ProductID_IAP4p600 @"ceshi001" //600
#define ProductID_IAP9p1000 @"ceshi001" //1000
#define ProductID_IAP24p6000 @"ceshi001" //6000

static ApplePay *_instance;

@interface ApplePay()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property(nonatomic,copy)void(^BlockSucsess)(void);
@property(nonatomic,copy)void(^Failler)(void);

@end

@implementation ApplePay

+ (instancetype)shard {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ApplePay alloc] init];
    });
    return _instance;
}

- (void)startManager {
    //开启监听
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    });
}

- (void)stopManager {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)configWith:(void (^)(void))BlockSucsess Fail:(void (^)(void))Failler {
        self.BlockSucsess = BlockSucsess;
        self.Failler = Failler;
}
- (void)ApplePay {
    buyType =  IAP0p20 ;
   
    if ([SKPaymentQueue canMakePayments]) {
        [self RequestProductData];
        NSLog(@"允许程序内付费购买");
    } else {
        NSLog(@"不允许程序内付费购买");
        
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您的手机没有打开程序内付费购买"
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
        
        [alerView show];
        self.Failler();
    }
}

-(void)RequestProductData {
    NSLog(@"---------请求对应的产品信息------------");
    NSArray *product = nil;
    switch (buyType) {
        case IAP0p20:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP0p20,nil];
            break;
        case IAP1p100:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP1p100,nil];
            break;
        case IAP4p600:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP4p600,nil];
            break;
        case IAP9p1000:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP9p1000,nil];
            break;
        case IAP24p6000:
            product=[[NSArray alloc] initWithObjects:ProductID_IAP24p6000,nil];
            break;
            
        default:
            break;
    }
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
}
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        return;
    }
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %d", (int)[myProduct count]);
    // populate UI
    for(SKProduct *product in myProduct){
        NSLog(@"product info");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"Product id: %@" , product.productIdentifier);
//        NSLog(@"username: %@" , product.applicationUsername);

    }
    SKMutablePayment *payment = nil;
    switch (buyType) {
        case IAP0p20:
            payment = [SKMutablePayment paymentWithProduct:myProduct[0]];
            payment.applicationUsername = self.orderNo;//订单号赋值给applicationUsername属性，并保存到本地（切记要存到本地啊，后续还会用到，请看下面。。）
            [[NSUserDefaults standardUserDefaults] setObject:self.orderNo forKey:@"niegouOrder"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP0p20];    //支付25
            break;
        case IAP1p100:
            payment = [SKMutablePayment paymentWithProduct:myProduct[0]];
            //            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP1p100];    //支付108
            break;
        case IAP4p600:
            //            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP4p600];    //支付618
            break;
        case IAP9p1000:
            //            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP9p1000];    //支付1048
            break;
        case IAP24p6000:
            //            payment  = [SKPayment paymentWithProductIdentifier:ProductID_IAP24p6000];    //支付5898
            break;
        default:
            break;
    }
    NSLog(@"---------发送购买请求------------");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}
//弹出错误信息 请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (self.Failler) {
        self.Failler();
    }
    NSLog(@"-------弹出错误信息----------");
    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",NULL) message:[error localizedDescription]
                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",nil) otherButtonTitles:nil];
    [alerView show];
    
}

-(void)requestDidFinish:(SKRequest *)request {
    NSLog(@"----------反馈信息结束--------------");
//    if (self.Failler) {
//        self.Failler();
//    }
}

-(void)purchasedTransaction: (SKPaymentTransaction *)transaction {
    NSLog(@"-----PurchasedTransaction----");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
}

#pragma mark -- 监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    NSLog(@"-----paymentQueue--------");
    if (transactions.count == 0) {
        return;
    }
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:{//交易完成
                [self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
                if (self.BlockSucsess) {
                    self.BlockSucsess();
                }
                
            } break;
            case SKPaymentTransactionStateFailed://交易失败
            {
                if (self.Failler) {
                    self.Failler();
                }
                [self failedTransaction:transaction];
                NSLog(@"-----交易失败 --------");
                for (SKPaymentTransaction *payTransation in transactions) {
                    NSLog(@"错误原因 %@",payTransation.error.userInfo[@"NSLocalizedDescription"]);
                }
                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                                     message:@"购买失败，请重新尝试购买"
                                                                    delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
                [alerView2 show];
            }break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                NSLog(@"-----已经购买过该商品 --------");
                break;
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"-----商品添加进列表 --------");
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"--------延期-----------");
                break;
            default:
                break;
        }
    }
}
//交易结束
- (void)completeTransaction: (SKPaymentTransaction *)transaction {
    
    NSLog(@"-----交易结束--------");
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
        /*
        // 发送网络POST请求，对购买凭据进行验证
        //测试验证地址:https://sandbox.itunes.apple.com/verifyReceipt
        //正式验证地址:https://buy.itunes.apple.com/verifyReceipt
        NSURL *url = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
        NSMutableURLRequest *urlRequest =
        [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
        urlRequest.HTTPMethod = @"POST";
        NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
        NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
        urlRequest.HTTPBody = payloadData;
        // 提交验证请求，并获得官方的验证JSON结果 iOS9后更改了另外的一个方法
        NSData *result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
        // 官方验证结果为空
        if (result == nil) {
            NSLog(@"验证失败");
            return;
        }
//        [result mj_JSONString]
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:nil];
        if (dict != nil) {
            // 比对字典中以下信息基本上可以保证数据安全
            // bundle_id , application_version , product_id , transaction_id
            //        NSLog(@"验证成功！购买的商品是：%@", @"_productName");
            
            NSLog(@"验证成功%@",dict);
        }
         */
        
        // 验证凭据，获取到苹果返回的交易凭据
        /*调取后台接口，让后台根据receiptData调取苹果接口验证凭据  然后把苹果接口返回的数据根据订单号存到数据库，以备后续对账使用*/
        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        // 从沙盒中获取到购买凭据
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
        NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        NSMutableDictionary *par = [[NSMutableDictionary alloc]init];
        
        NSString *orderString = @"";
        //重要！！！！！！！当用户从来没有用内购支付过时，它会让你绑定支付宝等，会跳到支付宝页面，当再回到APP页面时transaction.payment.applicationUsername 为nil；当用户以前支付过，直接用支付宝支付时则就为你传给它的订单号；所以applicationUsername这个属性不稳定，因此要判断transaction.payment.applicationUsername是否为nil，否则当用户第一次支付成功后，咱们调取后台接口验证凭据时会失败，导致后台不知道该用户已经支付了，会造成掉单的问题；
        if (transaction.payment.applicationUsername.length) {
            orderString = transaction.payment.applicationUsername;
        } else {
            orderString = [[NSUserDefaults standardUserDefaults] objectForKey:@"niegouOrder"];
        }
        par[@"order"] = transaction.payment.applicationUsername;
        par[@"encodeStr"] = encodeStr;
        /*
        [HWHttpTool postWithHUD:nil WithUrl:@"url" params:par success:^(id json) {
            if ([json[@"Status"]isEqualToString:@"success"]) {

         }else{
                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:[json mj_JSONString]
                                                                   delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                [alerView show];
            }
        } failure:^(NSError *error) {
            UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"调取后台接口失败，请联系客服！"
                                                               delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alerView show];
        }];

        [MBProgressHUD hideHUD];
         */
    }
}

//记录交易
//-(void)recordTransaction:(NSString *)product{
//    NSLog(@"-----记录交易--------");
//}

//处理下载内容
-(void)provideContent:(NSString *)product{
    NSLog(@"-----下载--------");
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"失败");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"user cancelled the request, etc.");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    for (SKPaymentTransaction *paymentTransaction in queue.transactions) {
        NSLog(@"%ld  --  %@",queue.transactions.count,paymentTransaction.transactionIdentifier);
        if (paymentTransaction.transactionIdentifier) {
            [self restoreTransaction:paymentTransaction];
        } else {
            [self completeTransaction:paymentTransaction];
        }
    }
}

- (void)restoreTransaction: (SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

    NSLog(@" 交易恢复处理");
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"-------paymentQueue----");
    if (self.Failler) {
        self.Failler();
    }
}


@end
