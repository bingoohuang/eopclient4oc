//
//  EopClient.h
//  eopclient
//
//  Created by bingoohuang on 13-1-21.
//  Copyright (c) 2013年 bingoohuang. All rights reserved.
//
@interface EopClient : NSObject

@property(copy,atomic) NSString *app;
@property(copy,atomic) NSString *pubKey;
@property(copy,atomic) NSString *url;

// 初始化eop平台参数
// app: 应用表示；
// pubkey: 签名密钥
- (void)init:(NSString *)app pubKey:(NSString *)pubKey url:(NSString *)url;

// 调用api入口(异步)
// method请求的方法(GET,POST);
// params具体的业务和系统参数(可以不传，内部会有默认设置，如果要修改比如返回格式，可以设置);
// target和cb用于请求后传递结果回调（NSString或者NSError两种返回）
// needMainThreadCallBack表明是否回调的时候采用主线程的方式回调（如果为true就采用主线程，主线程回调的作用是当回调函数需要操作ui界面的时候，必须是主线程，如果只是后台保存数据，这个值可以是false）
-(void)exec:(NSString *)method api:(NSString *)api params:(NSDictionary *)params target:(id)target cb:(SEL)cb needMainThreadCallBack:(Boolean) needMainThreadCallBack;

@end
