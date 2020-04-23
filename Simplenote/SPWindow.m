#import "SPWindow.h"
#import "Simplenote-Swift.h"


#pragma mark - SPWindow

@implementation SPWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if (self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:flag]) {
        [self setupTitle];
        [self applyMojaveThemeOverrideIfNecessary];
    }

    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    if ((self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:flag screen:screen])) {
        [self setupTitle];
        [self applyMojaveThemeOverrideIfNecessary];
    }

    return self;
}


#pragma mark - Initialization Helpers

- (void)setupTitle
{
    self.titleVisibility            = NSWindowTitleHidden;
    self.titlebarAppearsTransparent = YES;
}

- (void)applyMojaveThemeOverrideIfNecessary
{
    if (@available(macOS 10.14, *)) {
        NSAppearanceName name = [SPUserInterface isDark] ? NSAppearanceNameVibrantDark : NSAppearanceNameVibrantLight;
        self.appearance = [NSAppearance appearanceNamed:name];
    }
}

@end
