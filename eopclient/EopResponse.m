//
//  TopApiResponse.m
//  TOPIOSSdk
//
//  Created by cenwenchu on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "EopResponse.h"

@implementation EopResponse

@synthesize content;
@synthesize error;
@synthesize reqParams;

-(void)dealloc
{
    [content release];
    [error release];
    [reqParams release];
    
    [super dealloc];
}

@end
