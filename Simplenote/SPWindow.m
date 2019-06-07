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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    styleMask = [self yosemiteMaskWithMask:styleMask];
    if (self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:flag]) {
        [self setupTitle];
        [self startListeningToNotifications];
    }
    
    [self applyMojaveThemeOverrideIfNecessary];
    
    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    styleMask = [self yosemiteMaskWithMask:styleMask];
    if ((self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:flag screen:screen])) {
        [self setupTitle];
        [self startListeningToNotifications];
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

- (void)startListeningToNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(sp_layoutButtons) name:NSWindowDidResizeNotification            object:self];
    [nc addObserver:self selector:@selector(sp_layoutButtons) name:NSWindowDidMoveNotification              object:self];
    [nc addObserver:self selector:@selector(sp_layoutButtons) name:NSWindowDidEndSheetNotification          object:self];
    
    [nc addObserver:self selector:@selector(sp_layoutButtons) name:NSApplicationDidBecomeActiveNotification object:nil];
    [nc addObserver:self selector:@selector(sp_layoutButtons) name:NSApplicationDidResignActiveNotification object:nil];
    
    [nc addObserver:self selector:@selector(sp_layoutButtons) name:NSWindowDidExitFullScreenNotification    object:self];
    [nc addObserver:self selector:@selector(sp_layoutButtons) name:NSWindowWillEnterFullScreenNotification  object:self];
    [nc addObserver:self selector:@selector(sp_layoutButtons) name:NSWindowWillExitFullScreenNotification   object:self];
}


#pragma mark - Overriden Methods

- (void)becomeKeyWindow
{
    [super becomeKeyWindow];
    [self sp_layoutButtons];
}

- (void)resignKeyWindow
{
    [super resignKeyWindow];
    [self sp_layoutButtons];
}

- (void)setTitle:(NSString *)aString
{
    [super setTitle:aString];
    [self sp_layoutButtons];
}

- (void)setMaxSize:(NSSize)size
{
    [super setMaxSize:size];
    [self sp_layoutButtons];
}

- (void)setMinSize:(NSSize)size
{
    [super setMinSize:size];
    [self sp_layoutButtons];
}


#pragma mark - Class Methods

+ (void)load
{
    // Neutralize INAppStoreWindow's behavior when running Yosemite (or higher)
    [INAppStoreWindow setSpecialBehaviorDisabled:YES];
}


#pragma mark - Traffic Light Buttons

- (NSView *)sp_themeFrameView
{
    return [[self contentView] superview];
}

- (NSView *)sp_titlebarContainerView
{
    for (NSView *subview in [[self sp_themeFrameView] subviews]) {
        NSString *name = NSStringFromClass([subview class]);
        if ([name rangeOfString:@"NSTitlebar"].location != NSNotFound) {
            return subview;
        }
    }
    
    return nil;
}

- (NSButton *)sp_closeButton
{
    return [self standardWindowButton:NSWindowCloseButton];
}

- (NSButton *)sp_minimizeButton
{
    return [self standardWindowButton:NSWindowMiniaturizeButton];
}

- (NSButton *)sp_zoomButton
{
    return [self standardWindowButton:NSWindowZoomButton];
}

- (void)sp_layoutButtons
{
    if (self.titleBarHeight == 0) {
        return;
    }
    
    NSView *themeFrameView          = [self sp_themeFrameView];
    NSView *titlebarContainerView   = [self sp_titlebarContainerView];
    
    if (titlebarContainerView == nil) {
        return;
    }
    
    // Enhance the titlebarContainerView's height
    NSRect test                 = titlebarContainerView.frame;
    test.size.height            = self.titleBarHeight;
    test.origin.y               = CGRectGetHeight(themeFrameView.frame) - self.titleBarHeight;
    titlebarContainerView.frame = test;
    
    // Center the Traffic Light Buttons
    NSButton *closeButton       = [self sp_closeButton];
    NSButton *minimizeButton    = [self sp_minimizeButton];
    NSButton *zoomButton        = [self sp_zoomButton];
    
    for (NSButton *button in @[ closeButton, minimizeButton, zoomButton ]) {
        NSRect buttonFrame      = button.frame;
        buttonFrame.origin.y    = floor((self.titleBarHeight - buttonFrame.size.height) * 0.9f);
        button.frame            = buttonFrame;
    }
}

- (void)applyMojaveThemeOverrideIfNecessary
{
    // Apply a theme override if necessary for >= 10.14
    if (@available(macOS 10.14, *)) {
        NSString *themeName = [[NSUserDefaults standardUserDefaults] objectForKey:VSThemeManagerThemePrefKey];
        if (themeName) {
            self.appearance = [NSAppearance appearanceNamed:
                              [themeName isEqualToString:@"dark"] ?
                                 NSAppearanceNameVibrantDark : NSAppearanceNameVibrantLight];
        }

        // Delay needed here in order to properly adjust the stoplight buttons after theme changes
        [self performSelector:@selector(sp_layoutButtons) withObject:nil afterDelay:0.1f];
    }
}

@end
