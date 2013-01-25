//
//  EopViewController.m
//  eopclient
//
//  Created by bingoohuang on 13-1-21.
//  Copyright (c) 2013年 bingoohuang. All rights reserved.
//

#import "EopViewController.h"
#import "EopClient.h"
#import "EopResponse.h"

@interface EopViewController ()

@end

@implementation EopViewController

// @synthesize rspLabel = _rspLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exec:(id)sender {
    EopClient* eopClient = [[[EopClient alloc]init] autorelease];
    // 初始化EopClient, 
    // [eopClient init:@"app" pubKey:@"signKey" url:@"http://127.0.0.1:8080/eop"];
    [eopClient init:self.app.text
             pubKey:self.pubkey.text
                url:@"http://127.0.0.1:8080/eop"];
    // 设置业务参数
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:@"bingoo" forKey:@"name"];
    // 使用业务参数，调用eop api
    [eopClient exec:@"Get" api:self.api.text params:params target:self cb:@selector(updateResponse:) needMainThreadCallBack:TRUE];
}

- (void) updateResponse: (EopResponse*)eopResponse {
    NSString* content = eopResponse.content;
    self.rspLabel.text = content;
}
@end
