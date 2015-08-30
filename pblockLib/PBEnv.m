//
//  Env.m
//  pblock
//
//  Created by Will Fleming on 8/30/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

#import "PBEnv.h"
#import <stdlib.h>

@implementation PBEnv

+ (NSString*) get:(NSString*)name {
  return [NSString stringWithCString:getenv([name cStringUsingEncoding:NSUTF8StringEncoding])
                            encoding:NSUTF8StringEncoding];
}

@end