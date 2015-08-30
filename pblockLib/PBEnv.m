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
  char	*val = getenv([name cStringUsingEncoding:NSUTF8StringEncoding]);
  if (NULL == val) {
    return nil;
  } else {
    return [NSString stringWithCString:val encoding:NSUTF8StringEncoding];
  }
}

@end