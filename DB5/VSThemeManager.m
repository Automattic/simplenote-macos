//
//  VSThemeManager.m
//  Simplenote
//
//  Created by Tom Witkin on 7/6/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "VSThemeManager.h"

NSString *const VSThemeManagerThemeWillChangeNotification = @"VSThemeManagerThemeWillChangeNotification";
NSString *const VSThemeManagerThemeDidChangeNotification = @"VSThemeManagerThemeDidChangeNotification";
NSString *const VSThemeManagerThemePrefKey = @"VSThemeManagerThemePrefKey";

@interface VSThemeManager ()

@property (nonatomic, strong) VSThemeLoader *themeLoader;
@property (nonatomic, strong) VSTheme *theme;

@end

@implementation VSThemeManager

+ (VSThemeManager *)sharedManager
{
    static VSThemeManager *sharedManager = nil;
    if (!sharedManager) {
        sharedManager = [[VSThemeManager alloc] init];
        
        // load theme
        sharedManager.themeLoader = [VSThemeLoader new];
        
        NSString *themeName = [[NSUserDefaults standardUserDefaults] objectForKey:VSThemeManagerThemePrefKey];
        if (themeName) {
            sharedManager.theme = [sharedManager.themeLoader themeNamed:themeName];
        }
        
        if (!sharedManager.theme)
            sharedManager.theme = sharedManager.themeLoader.defaultTheme;
    }
    
    return sharedManager;
}

- (VSTheme *)theme {
    
    return _theme;
}

- (VSThemeLoader *)themeLoader {
    
    return _themeLoader;
}

- (void)contentSizeCategoryDidChange:(NSNotification *)notification {
    
    for (VSTheme *theme in self.themeLoader.themes) {
        
        [theme clearCaches];
    }
    
    [self swapTheme:self.theme.name];
}

- (void)swapTheme:(NSString *)themeName {
    
    VSTheme *theme = [self.themeLoader themeNamed:themeName];
    
    if (theme) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VSThemeManagerThemeWillChangeNotification
                                                            object:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:themeName
                                                  forKey:VSThemeManagerThemePrefKey];
        
        _theme = theme;
        [[NSNotificationCenter defaultCenter] postNotificationName:VSThemeManagerThemeDidChangeNotification
                                                            object:nil];
    }
}

@end
