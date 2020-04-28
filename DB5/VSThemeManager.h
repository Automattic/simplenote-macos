//
//  VSThemeManager.h
//  Simplenote
//
//  Created by Tom Witkin on 7/6/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSTheme.h"
#import "VSThemeLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface VSThemeManager : NSObject

+ (VSThemeManager *)sharedManager;
- (VSTheme *)theme;

- (void)swapTheme:(nullable NSString *)theme;

@end

NS_ASSUME_NONNULL_END
