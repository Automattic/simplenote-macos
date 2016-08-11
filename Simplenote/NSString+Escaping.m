//
//  NSString+Escaping.m
//  Simplenote
//
//  Copyright © 2016 Simperium. All rights reserved.
//

#import "NSString+Escaping.h"

@implementation NSString (Escaping)

- (NSString *)stringByUrlEncoding
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8
                                                                                 )
                                         );
}

@end
