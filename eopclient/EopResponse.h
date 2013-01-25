//
//  EopResponse.h
//
//  api请求返回的结果
//
//  Created by cenwenchu on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EopResponse : NSObject

@property(copy,nonatomic) NSString *content;//返回的结果，如果失败没有该属性
@property(copy,nonatomic) NSError *error;//返回的错误信息，如果成功没有该属性
@property(copy,nonatomic) NSDictionary *reqParams;//请求时候的入参，不包括附件类型的参数

@end
