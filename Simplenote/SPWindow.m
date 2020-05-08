#import "SPWindow.h"
#import "Simplenote-Swift.h"


#pragma mark - SPWindow

@implementation SPWindow

- (void)dealloc
{
    [self stopListeningToNotifications];
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if (self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:flag]) {
        [self startListeningToNotifications];
        [self reloadAppearance];
    }

    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    if ((self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:flag screen:screen])) {
        [self startListeningToNotifications];
        [self reloadAppearance];
    }

    return self;
}


#pragma mark - Initialization Helpers

- (void)startListeningToNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(reloadAppearance) name:ThemeDidChangeNotification object:nil];
}

- (void)stopListeningToNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadAppearance
{
    if (@available(macOS 10.14, *)) {
        if ([SPUserInterface isSystemThemeSelected]) {
            self.appearance = nil;
            return;
        }

        NSAppearanceName name = [SPUserInterface isDark] ? NSAppearanceNameVibrantDark : NSAppearanceNameVibrantLight;
        self.appearance = [NSAppearance appearanceNamed:name];
    }
}

@end
