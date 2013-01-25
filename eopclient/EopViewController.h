//
//  EopViewController.h
//  eopclient
//
//  Created by bingoohuang on 13-1-21.
//  Copyright (c) 2013年 bingoohuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EopViewController : UIViewController
@property(assign) IBOutlet UILabel *rspLabel;
@property(assign) IBOutlet UITextField *app;
@property(assign) IBOutlet UITextField *pubkey;
@property(assign) IBOutlet UITextField *api;
- (IBAction)exec:(id)sender;
@end
