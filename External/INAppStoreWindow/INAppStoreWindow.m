//
//  INAppStoreWindow.m
//
//  Copyright 2011 Indragie Karunaratne. All rights reserved.
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "INAppStoreWindow.h"

#define IN_RUNNING_LION (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
#define IN_COMPILING_LION __MAC_OS_X_VERSION_MAX_ALLOWED >= 1070

/** -----------------------------------------
 - There are 2 sets of colors, one for an active (key) state and one for an inactivate state
 - Each set contains 3 colors. 2 colors for the start and end of the title gradient, and another color to draw the separator line on the bottom
 - These colors are meant to mimic the color of the default titlebar (taken from OS X 10.6), but are subject
 to change at any time
 ----------------------------------------- **/

#define IN_COLOR_MAIN_START [NSColor colorWithDeviceWhite:0.659 alpha:1.0]
#define IN_COLOR_MAIN_END [NSColor colorWithDeviceWhite:0.812 alpha:1.0]
#define IN_COLOR_MAIN_BOTTOM [NSColor colorWithDeviceWhite:0.318 alpha:1.0]

#define IN_COLOR_NOTMAIN_START [NSColor colorWithDeviceWhite:0.851 alpha:1.0]
#define IN_COLOR_NOTMAIN_END [NSColor colorWithDeviceWhite:0.929 alpha:1.0]
#define IN_COLOR_NOTMAIN_BOTTOM [NSColor colorWithDeviceWhite:0.600 alpha:1.0]

#define IN_COLOR_MAIN_TITLE_TEXT [NSColor colorWithDeviceWhite:56.0/255.0 alpha:1.0]
#define IN_COLOR_NOTMAIN_TITLE_TEXT [NSColor colorWithDeviceWhite:56.0/255.0 alpha:0.5]

/** Lion */

#define IN_COLOR_MAIN_START_L [NSColor colorWithDeviceWhite:0.66 alpha:1.0]
#define IN_COLOR_MAIN_END_L [NSColor colorWithDeviceWhite:0.9 alpha:1.0]
#define IN_COLOR_MAIN_BOTTOM_L [NSColor colorWithDeviceWhite:0.408 alpha:1.0]

#define IN_COLOR_NOTMAIN_START_L [NSColor colorWithDeviceWhite:0.878 alpha:1.0]
#define IN_COLOR_NOTMAIN_END_L [NSColor colorWithDeviceWhite:0.976 alpha:1.0]
#define IN_COLOR_NOTMAIN_BOTTOM_L [NSColor colorWithDeviceWhite:0.655 alpha:1.0]


/** Corner clipping radius **/
const CGFloat INCornerClipRadius = 4.0;

NS_INLINE CGFloat INMidHeight(NSRect aRect){
    return (aRect.size.height * (CGFloat)0.5);
}

CF_RETURNS_RETAINED
NS_INLINE CGPathRef INCreateClippingPathWithRectAndRadius(NSRect rect, CGFloat radius)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, NSMinX(rect), NSMinY(rect));
    CGPathAddLineToPoint(path, NULL, NSMinX(rect), NSMaxY(rect)-radius);
    CGPathAddArcToPoint(path, NULL, NSMinX(rect), NSMaxY(rect), NSMinX(rect)+radius, NSMaxY(rect), radius);
    CGPathAddLineToPoint(path, NULL, NSMaxX(rect)-radius, NSMaxY(rect));
    CGPathAddArcToPoint(path, NULL,  NSMaxX(rect), NSMaxY(rect), NSMaxX(rect), NSMaxY(rect)-radius, radius);
    CGPathAddLineToPoint(path, NULL, NSMaxX(rect), NSMinY(rect));
    CGPathCloseSubpath(path);
    return path;
}

CF_RETURNS_RETAINED
NS_INLINE CGColorRef INCreateCGColorFromNSColor(NSColor *color)
{
    NSColor *rgbColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat components[4];
    [rgbColor getComponents:components];
    
    CGColorSpaceRef theColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGColorRef theColor = CGColorCreate(theColorSpace, components);
    CGColorSpaceRelease(theColorSpace);
	return theColor;
}

CF_RETURNS_RETAINED
NS_INLINE CGGradientRef INCreateGradientWithColors(NSColor *startingColor, NSColor *endingColor)
{
    CGFloat locations[2] = {0.0f, 1.0f, };
	CGColorRef cgStartingColor = INCreateCGColorFromNSColor(startingColor);
	CGColorRef cgEndingColor = INCreateCGColorFromNSColor(endingColor);
    #if __has_feature(objc_arc)
    CFArrayRef colors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)cgStartingColor, (__bridge id)cgEndingColor, nil];
    #else
    CFArrayRef colors = (CFArrayRef)[NSArray arrayWithObjects:(id)cgStartingColor, (id)cgEndingColor, nil];
    #endif
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
    CGColorSpaceRelease(colorSpace);
	CGColorRelease(cgStartingColor);
	CGColorRelease(cgEndingColor);
    return gradient;
}

@interface INAppStoreWindowDelegateProxy : NSProxy <NSWindowDelegate>
@property (nonatomic, assign) id<NSWindowDelegate> secondaryDelegate;
@end

@implementation INAppStoreWindowDelegateProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [[self.secondaryDelegate class] instanceMethodSignatureForSelector:selector];
    if (!signature) {
        signature = [super methodSignatureForSelector:selector];
    }
    return signature;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([self.secondaryDelegate respondsToSelector:aSelector]) {
        return YES;
    } else if (aSelector == @selector(window:willPositionSheet:usingRect:)) {
        return YES;
    }
    return NO;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([self.secondaryDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.secondaryDelegate];
    }
}

- (NSRect)window:(INAppStoreWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect
{
    // Somehow the forwarding machinery doesn't handle this.
    if ([self.secondaryDelegate respondsToSelector:_cmd]) {
        return [self.secondaryDelegate window:window willPositionSheet:sheet usingRect:rect];
    }
    rect.origin.y = NSHeight(window.frame) - window.titleBarHeight;
    return rect;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    if (self.secondaryDelegate) {
        return [self.secondaryDelegate isKindOfClass:aClass];
    }
    return NO;
}

@end

@interface INAppStoreWindow ()
- (void)_doInitialWindowSetup;
- (void)_createTitlebarView;
- (void)_setupTrafficLightsTrackingArea;
- (void)_recalculateFrameForTitleBarContainer;
- (void)_repositionContentView;
- (void)_layoutTrafficLightsAndContent;
- (CGFloat)_minimumTitlebarHeight;
- (void)_displayWindowAndTitlebar;
- (void)_hideTitleBarView:(BOOL)hidden;
- (CGFloat)_defaultTrafficLightLeftMargin;
- (CGFloat)_defaultTrafficLightSeparation;
@end

@implementation INTitlebarView

- (void)drawNoiseWithOpacity:(CGFloat)opacity
{
    static CGImageRef noiseImageRef = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        NSUInteger width = 124, height = width;
        NSUInteger size = width*height;
        char *rgba = (char *)malloc(size); srand(120);
        for(NSUInteger i=0; i < size; ++i){rgba[i] = (char)arc4random()%256;}
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef bitmapContext =
        CGBitmapContextCreate(rgba, width, height, 8, width, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
        CFRelease(colorSpace);
        noiseImageRef = CGBitmapContextCreateImage(bitmapContext);
        CFRelease(bitmapContext);
        free(rgba);
    });
	
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(context);
    CGContextSetAlpha(context, opacity);
    CGContextSetBlendMode(context, kCGBlendModeScreen);
	
    if ( [[self window] respondsToSelector:@selector(backingScaleFactor)] ) {
        CGFloat scaleFactor = [[self window] backingScaleFactor];
        CGContextScaleCTM(context, 1/scaleFactor, 1/scaleFactor);
    }
	
    CGRect imageRect = (CGRect){CGPointZero, (CGSize){CGImageGetWidth(noiseImageRef), CGImageGetHeight(noiseImageRef)}};
    CGContextDrawTiledImage(context, imageRect, noiseImageRef);
    CGContextRestoreGState(context);
}

- (void)drawRect:(NSRect)dirtyRect
{
    INAppStoreWindow *window = (INAppStoreWindow *)[self window];
    BOOL drawsAsMainWindow = ([window isMainWindow] && [[NSApplication sharedApplication] isActive]);
    
    NSRect drawingRect = [self bounds];
    if ( window.titleBarDrawingBlock ) {
        CGPathRef clippingPath = INCreateClippingPathWithRectAndRadius(drawingRect, INCornerClipRadius);
        window.titleBarDrawingBlock(drawsAsMainWindow, NSRectToCGRect(drawingRect), clippingPath);
        CGPathRelease(clippingPath);
    } else {
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        
        NSColor *startColor = drawsAsMainWindow ? window.titleBarStartColor : window.inactiveTitleBarStartColor;
        NSColor *endColor = drawsAsMainWindow ? window.titleBarEndColor : window.inactiveTitleBarEndColor;
        
        if (IN_RUNNING_LION) {
            startColor = startColor ?: (drawsAsMainWindow ? IN_COLOR_MAIN_START_L : IN_COLOR_NOTMAIN_START_L);
            endColor = endColor ?: (drawsAsMainWindow ? IN_COLOR_MAIN_END_L : IN_COLOR_NOTMAIN_END_L);
        } else {
            startColor = startColor ?: (drawsAsMainWindow ? IN_COLOR_MAIN_START : IN_COLOR_NOTMAIN_START);
            endColor = endColor ?: (drawsAsMainWindow ? IN_COLOR_MAIN_END : IN_COLOR_NOTMAIN_END);
        }
        
        NSRect clippingRect = drawingRect;
        #if IN_COMPILING_LION
        if((([window styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask)){
            [[NSColor blackColor] setFill];
            [[NSBezierPath bezierPathWithRect:self.bounds] fill];
        }
        #endif
        clippingRect.size.height -= 1;
        CGPathRef clippingPath = INCreateClippingPathWithRectAndRadius(clippingRect, INCornerClipRadius);
        CGContextAddPath(context, clippingPath);
        CGContextClip(context);
        CGPathRelease(clippingPath);
        
        CGGradientRef gradient = INCreateGradientWithColors(startColor, endColor);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(NSMidX(drawingRect), NSMinY(drawingRect)),
                                    CGPointMake(NSMidX(drawingRect), NSMaxY(drawingRect)), 0);
        CGGradientRelease(gradient);
		
        if ([window showsBaselineSeparator]) {
            NSColor *bottomColor = drawsAsMainWindow ? window.baselineSeparatorColor : window.inactiveBaselineSeparatorColor;
            
            if (IN_RUNNING_LION) {
                bottomColor = bottomColor ? bottomColor : drawsAsMainWindow ? IN_COLOR_MAIN_BOTTOM_L : IN_COLOR_NOTMAIN_BOTTOM_L;
            } else {
                bottomColor = bottomColor ? bottomColor : drawsAsMainWindow ? IN_COLOR_MAIN_BOTTOM : IN_COLOR_NOTMAIN_BOTTOM;
            }
            
            NSRect bottomRect = NSMakeRect(0.0, NSMinY(drawingRect), NSWidth(drawingRect), window.baselineSeparatorHeight);
            [bottomColor set];
            NSRectFill(bottomRect);
            
            if (IN_RUNNING_LION) {
                bottomRect.origin.y += 1.0;
                [[NSColor colorWithDeviceWhite:1.0 alpha:0.12] setFill];
                [[NSBezierPath bezierPathWithRect:bottomRect] fill];
            }
        }
        
        if (IN_RUNNING_LION && drawsAsMainWindow) {
            CGRect noiseRect = NSInsetRect(drawingRect, 1.0, 1.0);
            
            if (![window showsBaselineSeparator]) {
                noiseRect.origin.y    -= 1.0;
                noiseRect.size.height += 1.0;
            }
            
            CGPathRef noiseClippingPath =
            INCreateClippingPathWithRectAndRadius(noiseRect, INCornerClipRadius);
            CGContextAddPath(context, noiseClippingPath);
            CGContextClip(context);
            CGPathRelease(noiseClippingPath);
            
            [self drawNoiseWithOpacity:0.1];
        }
    }
    
    if ([window showsTitle] && (([window styleMask] & NSFullScreenWindowMask) == 0 || window.showsTitleInFullscreen)) {
        NSRect titleTextRect;
        NSDictionary *titleTextStyles = nil;
        [self getTitleFrame:&titleTextRect textAttributes:&titleTextStyles forWindow:window];
		
        if (window.verticallyCenterTitle) {
            titleTextRect.origin.y = floor(NSMidY(drawingRect) - (NSHeight(titleTextRect) / 2.f));
        }
		
        [window.title drawInRect:titleTextRect withAttributes:titleTextStyles];
    }
}

- (void)getTitleFrame:(out NSRect *)frame textAttributes:(out NSDictionary **)attributes forWindow:(in INAppStoreWindow *)window
{
    BOOL drawsAsMainWindow = ([window isMainWindow] && [[NSApplication sharedApplication] isActive]);
    
    NSShadow *titleTextShadow = drawsAsMainWindow ? window.titleTextShadow : window.inactiveTitleTextShadow;
    if (titleTextShadow == nil) {
        #if __has_feature(objc_arc)
        titleTextShadow = [[NSShadow alloc] init];
        #else
        titleTextShadow = [[[NSShadow alloc] init] autorelease];
        #endif
        titleTextShadow.shadowBlurRadius = 0.0;
        titleTextShadow.shadowOffset = NSMakeSize(0, -1);
        titleTextShadow.shadowColor = [NSColor colorWithDeviceWhite:1.0 alpha:0.5];
    }
    
    NSColor *titleTextColor = drawsAsMainWindow ? window.titleTextColor : window.inactiveTitleTextColor;
    titleTextColor = titleTextColor ? titleTextColor : drawsAsMainWindow ? IN_COLOR_MAIN_TITLE_TEXT : IN_COLOR_NOTMAIN_TITLE_TEXT;
	
    NSFont *titleFont = window.titleFont ?: [NSFont titleBarFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]];
	
    NSDictionary *titleTextStyles = [NSDictionary dictionaryWithObjectsAndKeys:
                                     titleFont, NSFontAttributeName,
                                     titleTextColor, NSForegroundColorAttributeName,
                                     titleTextShadow, NSShadowAttributeName,
                                     nil];
    NSSize titleSize = [window.title sizeWithAttributes:titleTextStyles];
    NSRect titleTextRect;
    titleTextRect.size = titleSize;
    
    NSButton *docIconButton = [window standardWindowButton:NSWindowDocumentIconButton];
    NSButton *versionsButton = [window standardWindowButton:NSWindowDocumentVersionsButton];
    if (docIconButton) {
        NSRect docIconButtonFrame = [self convertRect:docIconButton.frame fromView:docIconButton.superview];
        titleTextRect.origin.x = NSMaxX(docIconButtonFrame) + 4.0;
        titleTextRect.origin.y = NSMidY(docIconButtonFrame) - titleSize.height/2 + 1;
    }
    else if (versionsButton) {
        NSRect versionsButtonFrame = [self convertRect:versionsButton.frame fromView:versionsButton.superview];
        titleTextRect.origin.x = NSMinX(versionsButtonFrame) - titleSize.width - 1;
        
        NSDocument *document = (NSDocument *)[(NSWindowController *)self.window.windowController document];
        if ([document hasUnautosavedChanges] || [document isDocumentEdited]) {
            titleTextRect.origin.x -= 20;
        }
    }
    else {
        titleTextRect.origin.x = NSMidX(self.bounds) - titleSize.width/2;
    }
    titleTextRect.origin.y = NSMaxY(self.bounds) - titleSize.height - 2.0;
    
    if (frame) {
        *frame = titleTextRect;
    }
    if (attributes) {
        *attributes = titleTextStyles;
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 2) {
        // Get settings from "System Preferences" >  "Appearance" > "Double-click on windows title bar to minimize"
        NSString *const MDAppleMiniaturizeOnDoubleClickKey = @"AppleMiniaturizeOnDoubleClick";
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL shouldMiniaturize = [[userDefaults objectForKey:MDAppleMiniaturizeOnDoubleClickKey] boolValue];
        if (shouldMiniaturize) {
            [[self window] miniaturize:self];
        }
    }
}

@end

@interface INTitlebarContainer : NSView
@end

@implementation INTitlebarContainer
- (void)mouseDragged:(NSEvent *)theEvent
{
    NSWindow *window = [self window];
    NSPoint where = [self convertPoint:theEvent.locationInWindow fromView:nil];
    
    if ([window isMovableByWindowBackground] || ([window styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask) {
        [super mouseDragged: theEvent];
        return;
    }
    NSPoint origin = [window frame].origin;
    while ((theEvent = [NSApp nextEventMatchingMask:NSLeftMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES]) && ([theEvent type] != NSLeftMouseUp)) {
        @autoreleasepool {
            NSPoint now = [self convertPoint:theEvent.locationInWindow fromView:nil];
            origin.x += now.x - where.x;
            origin.y += now.y - where.y;
            [window setFrameOrigin:origin];
            where = now;
        }
    }
}
@end

@implementation INAppStoreWindow{
    CGFloat _cachedTitleBarHeight;
    BOOL _setFullScreenButtonRightMargin;
	BOOL _preventWindowFrameChange;
    INAppStoreWindowDelegateProxy *_delegateProxy;
    INTitlebarContainer *_titleBarContainer;
}

@synthesize titleBarView = _titleBarView;
@synthesize titleBarHeight = _titleBarHeight;
@synthesize centerFullScreenButton = _centerFullScreenButton;
@synthesize centerTrafficLightButtons = _centerTrafficLightButtons;
@synthesize verticalTrafficLightButtons = _verticalTrafficLightButtons;
@synthesize hideTitleBarInFullScreen = _hideTitleBarInFullScreen;
@synthesize titleBarDrawingBlock = _titleBarDrawingBlock;
@synthesize showsBaselineSeparator = _showsBaselineSeparator;
@synthesize fullScreenButtonRightMargin = _fullScreenButtonRightMargin;
@synthesize trafficLightButtonsLeftMargin = _trafficLightButtonsLeftMargin;
@synthesize titleBarStartColor = _titleBarStartColor;
@synthesize titleBarEndColor = _titleBarEndColor;
@synthesize baselineSeparatorColor = _baselineSeparatorColor;
@synthesize baselineSeparatorHeight = _baselineSeparatorHeight;
@synthesize inactiveTitleBarStartColor = _inactiveTitleBarStartColor;
@synthesize inactiveTitleBarEndColor = _inactiveTitleBarEndColor;
@synthesize inactiveBaselineSeparatorColor = _inactiveBaselineSeparatorColor;

#pragma mark -
#pragma mark Initialization

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
        [self _doInitialWindowSetup];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen])) {
        [self _doInitialWindowSetup];
    }
    return self;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [self setDelegate:nil];
    #if !__has_feature(objc_arc)
//    [_delegateProxy release];
    [_titleBarView release];
    [_closeButton release];
    [_minimizeButton release];
    [_zoomButton release];
    [_fullScreenButton release];
    [super dealloc];
    #endif
}

#pragma mark -
#pragma mark NSWindow Overrides

- (void)becomeKeyWindow
{
    [super becomeKeyWindow];
    if (_specialBehaviorDisabled) {
        return;
    }
    
    [self _updateTitlebarView];
    [self _layoutTrafficLightsAndContent];
    [self _setupTrafficLightsTrackingArea];
}

- (void)resignKeyWindow
{
    [super resignKeyWindow];
    if (_specialBehaviorDisabled) {
        return;
    }
    
    [self _updateTitlebarView];
    [self _layoutTrafficLightsAndContent];
}

- (void)becomeMainWindow
{
    [super becomeMainWindow];
    if (_specialBehaviorDisabled) {
        return;
    }
    
    [self _updateTitlebarView];
}

- (void)resignMainWindow
{
    [super resignMainWindow];
    if (_specialBehaviorDisabled) {
        return;
    }
    
    [self _updateTitlebarView];
}

- (void)setContentView:(NSView *)aView
{
    [super setContentView:aView];
    if (_specialBehaviorDisabled) {
        return;
    }
    
    [self _repositionContentView];
}

- (void)setTitle:(NSString *)aString
{
    [super setTitle:aString];
    if (_specialBehaviorDisabled) {
        return;
    }
    
    [self _layoutTrafficLightsAndContent];
    [self _displayWindowAndTitlebar];
}

- (void)setMaxSize:(NSSize)size
{
	[super setMaxSize:size];
    if (_specialBehaviorDisabled) {
        return;
    }
    
	[self _layoutTrafficLightsAndContent];
}

- (void)setMinSize:(NSSize)size
{
	[super setMinSize:size];
    if (_specialBehaviorDisabled) {
        return;
    }
    
	[self _layoutTrafficLightsAndContent];
}

#pragma mark -
#pragma mark Accessors

- (void)setTitleBarView:(NSView *)newTitleBarView
{
    if ((_titleBarView != newTitleBarView) && newTitleBarView) {
        [_titleBarView removeFromSuperview];
        #if __has_feature(objc_arc)
        _titleBarView = newTitleBarView;
        #else
        [_titleBarView release];
        _titleBarView = [newTitleBarView retain];
        #endif
        [_titleBarView setFrame:[_titleBarContainer bounds]];
        [_titleBarView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_titleBarContainer addSubview:_titleBarView];
    }
}

- (NSView *)titleBarView
{
    return _titleBarView;
}

- (void)setTitleBarHeight:(CGFloat)newTitleBarHeight
{
    if (_titleBarHeight != newTitleBarHeight) {
        _cachedTitleBarHeight = newTitleBarHeight;
        _titleBarHeight = _cachedTitleBarHeight;
        
        if (_specialBehaviorDisabled) {
            return;
        }
        [self _layoutTrafficLightsAndContent];
        [self _displayWindowAndTitlebar];
    }
}

- (CGFloat)titleBarHeight
{
    return _titleBarHeight;
}

- (void)setShowsBaselineSeparator:(BOOL)showsBaselineSeparator
{
    if (_showsBaselineSeparator != showsBaselineSeparator) {
        _showsBaselineSeparator = showsBaselineSeparator;
        [self.titleBarView setNeedsDisplay:YES];
    }
}

- (BOOL)showsBaselineSeparator
{
    return _showsBaselineSeparator;
}

- (void)setTrafficLightButtonsLeftMargin:(CGFloat)newTrafficLightButtonsLeftMargin
{
    if (_trafficLightButtonsLeftMargin != newTrafficLightButtonsLeftMargin) {
        _trafficLightButtonsLeftMargin = newTrafficLightButtonsLeftMargin;
        [self _layoutTrafficLightsAndContent];
        [self _displayWindowAndTitlebar];
        [self _setupTrafficLightsTrackingArea];
    }
}

- (CGFloat)trafficLightButtonsLeftMargin
{
    return _trafficLightButtonsLeftMargin;
}


- (void)setFullScreenButtonRightMargin:(CGFloat)newFullScreenButtonRightMargin
{
    if (_specialBehaviorDisabled) {
        return;
    }
    
    if (_fullScreenButtonRightMargin != newFullScreenButtonRightMargin) {
        _setFullScreenButtonRightMargin = YES;
        _fullScreenButtonRightMargin = newFullScreenButtonRightMargin;
        [self _layoutTrafficLightsAndContent];
        [self _displayWindowAndTitlebar];
    }
}

- (CGFloat)fullScreenButtonRightMargin
{
    return _fullScreenButtonRightMargin;
}

- (void)setShowsTitle:(BOOL)showsTitle {
    if (_showsTitle != showsTitle) {
        _showsTitle = showsTitle;
        [self _displayWindowAndTitlebar];
    }
}

- (void)setCenterFullScreenButton:(BOOL)centerFullScreenButton{
    if (_specialBehaviorDisabled) {
        return;
    }
    
    if( _centerFullScreenButton != centerFullScreenButton ) {
        _centerFullScreenButton = centerFullScreenButton;
        [self _layoutTrafficLightsAndContent];
    }
}

- (void)setCenterTrafficLightButtons:(BOOL)centerTrafficLightButtons
{
    if ( _centerTrafficLightButtons != centerTrafficLightButtons ) {
        _centerTrafficLightButtons = centerTrafficLightButtons;
        [self _layoutTrafficLightsAndContent];
        [self _setupTrafficLightsTrackingArea];
    }
}

- (void)setVerticalTrafficLightButtons:(BOOL)verticalTrafficLightButtons
{
    if ( _verticalTrafficLightButtons != verticalTrafficLightButtons ) {
        _verticalTrafficLightButtons = verticalTrafficLightButtons;
        [self _layoutTrafficLightsAndContent];
        [self _setupTrafficLightsTrackingArea];
    }
}

- (void)setVerticallyCenterTitle:(BOOL)verticallyCenterTitle
{
    if ( _verticallyCenterTitle != verticallyCenterTitle ) {
        _verticallyCenterTitle = verticallyCenterTitle;
        [self _displayWindowAndTitlebar];
    }
}

- (void)setTrafficLightSeparation:(CGFloat)trafficLightSeparation
{
    if (_trafficLightSeparation != trafficLightSeparation) {
        _trafficLightSeparation = trafficLightSeparation;
        [self _layoutTrafficLightsAndContent];
        [self _setupTrafficLightsTrackingArea];
    }
}

- (void)setDelegate:(id<NSWindowDelegate>)anObject
{
    [_delegateProxy setSecondaryDelegate:anObject];
    [super setDelegate:nil];
    [super setDelegate:_delegateProxy];
}

- (id<NSWindowDelegate>)delegate
{
    return [_delegateProxy secondaryDelegate];
}

- (void)setCloseButton:(INWindowButton *)closeButton {
    if (_closeButton != closeButton) {
        [_closeButton removeFromSuperview];
        _closeButton = closeButton;
        if (_closeButton) {
            _closeButton.target = self;
            _closeButton.action = @selector(performClose:);
            [_closeButton setFrameOrigin:[[self standardWindowButton:NSWindowCloseButton] frame].origin];
            [[self themeFrameView] addSubview:_closeButton];
        }
    }
}

- (void)setMinimizeButton:(INWindowButton *)minimizeButton {
    if (_minimizeButton != minimizeButton) {
        [_minimizeButton removeFromSuperview];
        _minimizeButton = minimizeButton;
        if (_minimizeButton) {
            _minimizeButton.target = self;
            _minimizeButton.action = @selector(performMiniaturize:);
            [_minimizeButton setFrameOrigin:[[self standardWindowButton:NSWindowMiniaturizeButton] frame].origin];
            [[self themeFrameView] addSubview:_minimizeButton];
        }
    }
}

- (void)setZoomButton:(INWindowButton *)zoomButton {
    if (_zoomButton != zoomButton) {
        [_zoomButton removeFromSuperview];
        _zoomButton = zoomButton;
        if (_zoomButton) {
            _zoomButton.target = self;
            _zoomButton.action = @selector(performZoom:);
            [_zoomButton setFrameOrigin:[[self standardWindowButton:NSWindowZoomButton] frame].origin];
            [[self themeFrameView] addSubview:_zoomButton];
        }
    }
}

- (void)setFullScreenButton:(INWindowButton *)fullScreenButton {
    if (_specialBehaviorDisabled) {
        return;
    }
    
    if (_fullScreenButton != fullScreenButton) {
        [_fullScreenButton removeFromSuperview];
        _fullScreenButton = fullScreenButton;
        if (_fullScreenButton) {
            _fullScreenButton.target = self;
            _fullScreenButton.action = @selector(toggleFullScreen:);
            [_fullScreenButton setFrameOrigin:[[self standardWindowButton:NSWindowFullScreenButton] frame].origin];
            [[self themeFrameView] addSubview:_fullScreenButton];
        }
    }
}

- (void)setStyleMask:(NSUInteger)styleMask
{
    if (_specialBehaviorDisabled) {
        [super setStyleMask:styleMask];
        return;
    }
    
	_preventWindowFrameChange = YES;
	[super setStyleMask:styleMask];
	_preventWindowFrameChange = NO;
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)flag
{
    if (!_preventWindowFrameChange || _specialBehaviorDisabled) {
		[super setFrame:frameRect display:flag];
    }
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animateFlag
{
    if (!_preventWindowFrameChange || _specialBehaviorDisabled) {
		[super setFrame:frameRect display:displayFlag animate:animateFlag];
    }
}

#pragma mark -
#pragma mark Private

- (void)_doInitialWindowSetup
{
    if (_specialBehaviorDisabled) {
        return;
    }
    
    _showsBaselineSeparator = YES;
    _baselineSeparatorHeight = 0.5;
    _centerTrafficLightButtons = YES;
    _titleBarHeight = [self _minimumTitlebarHeight];
    _cachedTitleBarHeight = _titleBarHeight;
    _trafficLightButtonsLeftMargin = [self _defaultTrafficLightLeftMargin];
    _delegateProxy = [INAppStoreWindowDelegateProxy alloc];
    _trafficLightButtonsTopMargin = 3.f;
    _fullScreenButtonTopMargin = 3.f;
    _trafficLightSeparation = [self _defaultTrafficLightSeparation];
    [super setDelegate:_delegateProxy];
    
    /** -----------------------------------------
     - The window automatically does layout every time its moved or resized, which means that the traffic lights and content view get reset at the original positions, so we need to put them back in place
     - NSWindow is hardcoded to redraw the traffic lights in a specific rect, so when they are moved down, only part of the buttons get redrawn, causing graphical artifacts. Therefore, the window must be force redrawn every time it becomes key/resigns key
     ----------------------------------------- **/
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_layoutTrafficLightsAndContent) name:NSWindowDidResizeNotification object:self];
    [nc addObserver:self selector:@selector(_layoutTrafficLightsAndContent) name:NSWindowDidMoveNotification object:self];
    [nc addObserver:self selector:@selector(_layoutTrafficLightsAndContent) name:NSWindowDidEndSheetNotification object:self];
	
    [nc addObserver:self selector:@selector(_updateTitlebarView) name:NSApplicationDidBecomeActiveNotification object:nil];
    [nc addObserver:self selector:@selector(_updateTitlebarView) name:NSApplicationDidResignActiveNotification object:nil];
    #if IN_COMPILING_LION
    if (IN_RUNNING_LION) {
        [nc addObserver:self selector:@selector(windowDidExitFullScreen:) name:NSWindowDidExitFullScreenNotification object:nil];
        [nc addObserver:self selector:@selector(windowWillEnterFullScreen:) name:NSWindowWillEnterFullScreenNotification object:nil];
        [nc addObserver:self selector:@selector(windowWillExitFullScreen:) name:NSWindowWillExitFullScreenNotification object:nil];
    }
    #endif
    [self _createTitlebarView];
    [self _layoutTrafficLightsAndContent];
    [self _setupTrafficLightsTrackingArea];
}

- (NSButton *)_windowButtonToLayout:(NSWindowButton)defaultButtonType orUserProvided:(NSButton *)userButton {
    NSButton *defaultButton = [self standardWindowButton:defaultButtonType];
    if (userButton) {
        [defaultButton setHidden:YES];
        defaultButton = userButton;
    } else if ([defaultButton superview] != [self themeFrameView]) {
        [defaultButton setHidden:NO];
    }
    return defaultButton;
}

- (NSButton *)_closeButtonToLayout {
    return [self _windowButtonToLayout:NSWindowCloseButton orUserProvided:self.closeButton];
}

- (NSButton *)_minimizeButtonToLayout {
    return [self _windowButtonToLayout:NSWindowMiniaturizeButton orUserProvided:self.minimizeButton];
}

- (NSButton *)_zoomButtonToLayout {
    return [self _windowButtonToLayout:NSWindowZoomButton orUserProvided:self.zoomButton];
}

- (NSButton *)_fullScreenButtonToLayout {
    return [self _windowButtonToLayout:NSWindowFullScreenButton orUserProvided:self.fullScreenButton];
}

- (void)_layoutTrafficLightsAndContent
{
    // Reposition/resize the title bar view as needed
    [self _recalculateFrameForTitleBarContainer];
    NSButton *close = [self _closeButtonToLayout];
    NSButton *minimize = [self _minimizeButtonToLayout];
    NSButton *zoom = [self _zoomButtonToLayout];
    
    // Set the frame of the window buttons
    NSRect closeFrame = [close frame];
    NSRect minimizeFrame = [minimize frame];
    NSRect zoomFrame = [zoom frame];
    NSRect titleBarFrame = [_titleBarContainer frame];
    CGFloat buttonOrigin = 0.0;
    if (!self.verticalTrafficLightButtons) {
        if (self.centerTrafficLightButtons) {
            buttonOrigin = round(NSMidY(titleBarFrame) - INMidHeight(closeFrame));
        } else {
            buttonOrigin = NSMaxY(titleBarFrame) - NSHeight(closeFrame) - self.trafficLightButtonsTopMargin;
        }
        closeFrame.origin.y = buttonOrigin;
        minimizeFrame.origin.y = buttonOrigin;
        zoomFrame.origin.y = buttonOrigin;
        closeFrame.origin.x = self.trafficLightButtonsLeftMargin;
        minimizeFrame.origin.x = NSMaxX(closeFrame) + self.trafficLightSeparation;
        zoomFrame.origin.x = NSMaxX(minimizeFrame) + self.trafficLightSeparation;
    } else {
        CGFloat groupHeight = NSHeight(closeFrame) + NSHeight(minimizeFrame) + NSHeight(zoomFrame) + 2.f * (self.trafficLightSeparation - 2.f);
        if (self.centerTrafficLightButtons)  {
            buttonOrigin = round(NSMidY(titleBarFrame) - groupHeight / 2.f);
        } else {
            buttonOrigin = NSMaxY(titleBarFrame) - groupHeight - self.trafficLightButtonsTopMargin;
        }
        closeFrame.origin.x = self.trafficLightButtonsLeftMargin;
        minimizeFrame.origin.x = self.trafficLightButtonsLeftMargin;
        zoomFrame.origin.x = self.trafficLightButtonsLeftMargin;
        zoomFrame.origin.y = buttonOrigin;
        minimizeFrame.origin.y = NSMaxY(zoomFrame) + self.trafficLightSeparation - 2.f;
        closeFrame.origin.y = NSMaxY(minimizeFrame) + self.trafficLightSeparation - 2.f;
    }
    [close setFrame:closeFrame];
    [minimize setFrame:minimizeFrame];
    [zoom setFrame:zoomFrame];
    
    #if IN_COMPILING_LION
    // Set the frame of the FullScreen button in Lion if available
    if (IN_RUNNING_LION) {
        NSButton *fullScreen = [self _fullScreenButtonToLayout];
        if (fullScreen) {
            NSRect fullScreenFrame = [fullScreen frame];
            if (!_setFullScreenButtonRightMargin) {
                self.fullScreenButtonRightMargin = NSWidth([_titleBarContainer frame]) - NSMaxX(fullScreen.frame);
            }
            fullScreenFrame.origin.x = NSWidth(titleBarFrame) - NSWidth(fullScreenFrame) - _fullScreenButtonRightMargin;
            if (self.centerFullScreenButton) {
                fullScreenFrame.origin.y = round(NSMidY(titleBarFrame) - INMidHeight(fullScreenFrame));
            } else {
                fullScreenFrame.origin.y = NSMaxY(titleBarFrame) - NSHeight(fullScreenFrame) - self.fullScreenButtonTopMargin;
            }
            [fullScreen setFrame:fullScreenFrame];
        }
    }
    #endif
    [self _repositionContentView];
}

- (void)undoManagerDidCloseUndoGroupNotification:(NSNotification *)notification {
    [self _displayWindowAndTitlebar];
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification
{
    if (_hideTitleBarInFullScreen) {
        // Recalculate the views when entering from fullscreen
        _titleBarHeight = 0.0f;
        [self _layoutTrafficLightsAndContent];
        [self _displayWindowAndTitlebar];
        
        [self _hideTitleBarView:YES];
    }
}

- (void)windowWillExitFullScreen:(NSNotification *)notification
{
    if (_hideTitleBarInFullScreen) {
        _titleBarHeight = _cachedTitleBarHeight;
        [self _layoutTrafficLightsAndContent];
        [self _displayWindowAndTitlebar];
        
        [self _hideTitleBarView:NO];
    }
}

- (void)windowDidExitFullScreen:(NSNotification *)notification
{
    [self _layoutTrafficLightsAndContent];
    [self _setupTrafficLightsTrackingArea];
}

- (NSView *)themeFrameView {
    return [[self contentView] superview];
}

- (void)_createTitlebarView
{
    // Create the title bar view
    INTitlebarContainer *container = [[INTitlebarContainer alloc] initWithFrame:NSZeroRect];
    // Configure the view properties and add it as a subview of the theme frame
    NSView *firstSubview = [[[self themeFrameView] subviews] objectAtIndex:0];
    [self _recalculateFrameForTitleBarContainer];
    [[self themeFrameView] addSubview:container positioned:NSWindowBelow relativeTo:firstSubview];
    #if __has_feature(objc_arc)
    _titleBarContainer = container;
    self.titleBarView = [[INTitlebarView alloc] initWithFrame:NSZeroRect];
    #else
    _titleBarContainer = [container autorelease];
    self.titleBarView = [[[INTitlebarView alloc] initWithFrame:NSZeroRect] autorelease];
    #endif
}

- (void)_hideTitleBarView:(BOOL)hidden
{
    [self.titleBarView setHidden:hidden];
}

// Solution for tracking area issue thanks to @Perspx (Alex Rozanski) <https://gist.github.com/972958>
- (void)_setupTrafficLightsTrackingArea
{
    [[self themeFrameView] viewWillStartLiveResize];
    [[self themeFrameView] viewDidEndLiveResize];
}

- (void)_recalculateFrameForTitleBarContainer
{
    NSRect themeFrameRect = [[self themeFrameView] frame];
    NSRect titleFrame = NSMakeRect(0.0, NSMaxY(themeFrameRect) - _titleBarHeight, NSWidth(themeFrameRect), _titleBarHeight);
    [_titleBarContainer setFrame:titleFrame];
}

- (void)_repositionContentView
{
    NSView *contentView = [self contentView];
    NSRect windowFrame = [self frame];
    NSRect currentContentFrame = [contentView frame];
    NSRect newFrame = currentContentFrame;
	
    CGFloat titleHeight = NSHeight(windowFrame) - NSHeight(newFrame);
    CGFloat extraHeight = _titleBarHeight - titleHeight;
    newFrame.size.height -= extraHeight;
	
    if (!NSEqualRects(currentContentFrame, newFrame)) {
        [contentView setFrame:newFrame];
        [contentView setNeedsDisplay:YES];
    }
}

- (CGFloat)_minimumTitlebarHeight
{
    static CGFloat minTitleHeight = 0.0;
    if (!minTitleHeight) {
        NSRect frameRect = [self frame];
        NSRect contentRect = [self contentRectForFrameRect:frameRect];
        minTitleHeight = NSHeight(frameRect) - NSHeight(contentRect);
    }
    return minTitleHeight;
}

- (CGFloat)_defaultTrafficLightLeftMargin
{
    static CGFloat trafficLightLeftMargin = 0.0;
    if (!trafficLightLeftMargin) {
        NSButton *close = [self _closeButtonToLayout];
        trafficLightLeftMargin = NSMinX(close.frame);
    }
    return trafficLightLeftMargin;
}

- (CGFloat)_defaultTrafficLightSeparation
{
    static CGFloat trafficLightSeparation = 0.0;
    if (!trafficLightSeparation) {
        NSButton *close = [self _closeButtonToLayout];
        NSButton *minimize = [self _minimizeButtonToLayout];
        trafficLightSeparation = NSMinX(minimize.frame) - NSMaxX(close.frame);
    }
    return trafficLightSeparation;
}

- (void)_displayWindowAndTitlebar
{
    // Redraw the window and titlebar
    [_titleBarView setNeedsDisplay:YES];
}

- (void)_updateTitlebarView
{
    [_titleBarView setNeedsDisplay:YES];
	
    // "validate" any controls in the titlebar view
    BOOL isMainWindowAndActive = ([self isMainWindow] && [[NSApplication sharedApplication] isActive]);
    for (NSView *childView in [_titleBarView subviews]) {
        if ([childView isKindOfClass:[NSControl class]]) {
            [(NSControl *)childView setEnabled:isMainWindowAndActive];
        }
    }
}


/**
    Simple mechanism to disable INAppStoreWindow custom behavior
 */

static bool _specialBehaviorDisabled = false;

+ (BOOL)isSpecialBehaviorDisabled
{
    return _specialBehaviorDisabled;
}

+ (void)setSpecialBehaviorDisabled:(BOOL)disabled
{
    _specialBehaviorDisabled = disabled;
}

@end
