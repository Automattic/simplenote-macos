//
//  SPWindow.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 12/15/14.
//  Copyright (c) 2014 Simperium. All rights reserved.
//

#import "SPWindow.h"
#import "VSThemeManager.h"


#pragma mark ====================================================================================
#pragma mark SPWindow
#pragma mark ====================================================================================

@implementation SPWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    styleMask = [self yosemiteMaskWithMask:styleMask];
    if (self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:flag]) {
        [self setupTitle];
    }
    
    [self applyMojaveThemeOverrideIfNecessary];
    
    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    styleMask = [self yosemiteMaskWithMask:styleMask];
    if ((self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:flag screen:screen])) {
        [self setupTitle];
    }
    
    [self applyMojaveThemeOverrideIfNecessary];
    
    return self;
}


#pragma mark - Initialization Helpers

- (NSUInteger)yosemiteMaskWithMask:(NSUInteger)mask
{
    mask |= NSUnifiedTitleAndToolbarWindowMask | NSFullSizeContentViewWindowMask;
    return mask;
}

- (void)setupTitle
{
    self.titleVisibility            = NSWindowTitleHidden;
    self.titlebarAppearsTransparent = YES;
}

- (void)applyMojaveThemeOverrideIfNecessary
{
    if (@available(macOS 10.14, *)) {
        NSString *themeName = [[NSUserDefaults standardUserDefaults] objectForKey:VSThemeManagerThemePrefKey];
        if (themeName) {
            self.appearance = [NSAppearance appearanceNamed:
                              [themeName isEqualToString:@"dark"] ?
                                 NSAppearanceNameVibrantDark : NSAppearanceNameVibrantLight];
        }
    }
}

@end
