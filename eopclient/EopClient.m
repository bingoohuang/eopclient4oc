//
//  EopClient.m
//  eopclient
//
//  Created by bingoohuang on 13-1-21.
//  Copyright (c) 2013年 bingoohuang. All rights reserved.
//

#import "EopClient.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "GTMBase64.h"
#import "EopResponse.h"

//Functions for Encoding Data.
@interface NSData (TOPEncode)
- (NSString *)MD5EncodedString;
@end

//Functions for Encoding String.
@interface NSString (TOPEncode)
- (NSString *)MD5EncodedString;
@end

@implementation NSData (TOPEncode)

- (NSString *)MD5EncodedString {
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], [self length], result);
 
    NSData *data = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];

    data = [GTMBase64 encodeData:data];

    NSString * base64String = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease];

    return base64String;
}


@end

@implementation NSString(TOPEncode)

- (NSString *)MD5EncodedString {
	return [[self dataUsingEncoding:NSUTF8StringEncoding] MD5EncodedString];
}


@end

@interface EopClient()
    @property (copy)NSOperationQueue *eventQueue;
@end

@implementation EopClient

//app config
@synthesize app = _app;
@synthesize pubKey = _pubKey;
@synthesize url = _url;
@synthesize eventQueue;

-(void)init:(NSString *)app pubKey:(NSString *)pubKey  url:(NSString *)url {
    [self setApp:app];
    [self setPubKey:pubKey];
    [self setUrl:url];
    eventQueue = [[NSOperationQueue alloc] init];
}

- (NSMutableString *)compositeBody:(NSMutableDictionary *)reqParams {
    NSMutableString *body = [[[NSMutableString alloc]init] autorelease];
    NSEnumerator *enumerator = [reqParams keyEnumerator];
    id key;
    
    while ((key = [enumerator nextObject])) {
        [body appendString:key];
        [body appendString:@"=" ];
        
        NSString * t = [(NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                            NULL,
                                                                            (CFStringRef)[[reqParams objectForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                                                            NULL,
                                                                            (CFStringRef)@"&=+$/?%#",
                                                                            kCFStringEncodingUTF8) autorelease] ;
        
        [body appendString:t];
        [body appendString:@"&" ];
    }
    return body;
}

- (void)httpCall:(NSMutableString *)body method:(NSString *)method cb:(SEL)cb target:(id)target needMainThreadCallBack:(Boolean)needMainThreadCallBack reqParams:(NSMutableDictionary *)reqParams {
    NSMutableURLRequest *req = nil;
    
    if ([method caseInsensitiveCompare:@"Get"] == NSOrderedSame) {
        NSString *_url1 = [_url stringByAppendingString:@"?"];
        _url1 = [_url1 stringByAppendingString:body];
        
        NSLog(@"%@",_url1);
        
        req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: _url1]
                                      cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
        
    }
    else {
        req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]
                                      cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
        
        
        NSData *d = [body dataUsingEncoding:NSUTF8StringEncoding];
        [req setHTTPBody:d];
    }
    
    [req setHTTPMethod:[method uppercaseString]];
    
    [NSURLConnection sendAsynchronousRequest:req queue:eventQueue
                           completionHandler:^(NSURLResponse *resp,NSData *data,NSError *error){
                               
                               EopResponse *response = [[[EopResponse alloc] init] autorelease];
                               [response setReqParams:reqParams];
                               
                               if (error == nil) {
                                   NSString *content = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                                   
                                   [response setContent:content];
                               }
                               else  {
                                   NSLog(@"Error happened = %@", error);
                                   [response setError:error];
                               }
                               
                               if (needMainThreadCallBack) {
                                   [target performSelectorOnMainThread:cb withObject:response waitUntilDone:[NSThread isMainThread]];
                               }
                               else {
                                   [target performSelectorInBackground:cb withObject:response];
                               }
                               
                           }];
}

-(void)exec:(NSString *)method api:(NSString *)api params:(NSDictionary *)params target:(id)target cb:(SEL)cb needMainThreadCallBack:(Boolean) needMainThreadCallBack {
    
    NSMutableDictionary *reqParams = [[[NSMutableDictionary alloc] init] autorelease];
    NSArray *keys = [params allKeys];

    for(id k in keys) {
        id v = [params objectForKey:k];
        [reqParams setObject:v forKey:k];
    }

    [reqParams setObject:_app forKey:@"app"];
    [reqParams setObject:api forKey:@"api"];
    // 将当前秒数(1970年1月1日开始计数)转换为字符串（整数部分）
    NSString* rts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
    [reqParams setObject:rts forKey:@"rts"];
    [self sign:reqParams];

    NSMutableString *body = [self compositeBody:reqParams];

    [self httpCall:body method:method cb:cb target:target needMainThreadCallBack:needMainThreadCallBack reqParams:reqParams];
}

-(void)dealloc {
    [_app release];
    [_pubKey release];
    [_url release];
    [eventQueue release];
    [super dealloc];
}

-(void)sign:(NSMutableDictionary *)params {
    NSArray *myKeys = [params allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

    NSMutableString *src = [[[NSMutableString alloc]init] autorelease];
    [src appendString:_pubKey];

    for (id key in sortedKeys) {
        [src appendString:@"$"];
        [src appendString:key];
        [src appendString:@"$"];
        id value = [params objectForKey:key];
        [src appendString:[value isMemberOfClass:[NSString class]] ? value : [value description]];
    }

    [src appendString:_pubKey];

    [params setObject:[src MD5EncodedString] forKey:@"sign"];
}

@end
