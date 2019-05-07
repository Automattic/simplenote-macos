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
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"]];
}

@end
