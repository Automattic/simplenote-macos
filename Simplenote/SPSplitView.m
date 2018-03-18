//
//  SPSplitView.m
//  Simplenote
//
//  Created by Michael Johnston on 8/6/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "SPSplitView.h"
#import "VSThemeManager.h"

#pragma mark ====================================================================================
#pragma mark Constants
#pragma mark ====================================================================================

static NSString * const SPSplitViewWidthKey     = @"width";
static NSString * const SPSplitViewVisibleKey   = @"visible";
const CGFloat SPSplitViewDefaultWidth = 135.0;



#pragma mark ====================================================================================
#pragma mark SPSplitView
#pragma mark ====================================================================================

@implementation SPSplitView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self startListeningToNotifications];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self loadStateWithKey:self.simplenoteAutosaveName];
}

- (CGFloat)dividerThickness
{
    return 1.0;
}

- (void)drawDividerInRect:(NSRect)rect
{
    // Slight hack to make left divider the background color when tags view is collapsed
    if (rect.origin.x == 0) {
        [[[[VSThemeManager sharedManager] theme] colorForKey:@"tableViewBackgroundColor"] set];
        NSRectFill(rect);
    } else {
        [[[[VSThemeManager sharedManager] theme] colorForKey:@"dividerColor"] set];
        NSRectFill(rect);
    }
}


#pragma mark - NSNotification Helpers

- (void)startListeningToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWindowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
}


- (void)handleWindowWillClose:(NSNotification *)note
{
    [self saveStateWithName:self.simplenoteAutosaveName];
}


#pragma mark - Simplenote State Restoration


/**
    Note:
    WHY do we implement manual state restoration?. Because of Issue #297: under (unknown) circumstances,
    Split View's section might get an invalid width!
 
 **/

- (void)saveStateWithName:(NSString *)name
{
    if (!name) {
        return;
    }
    
    // Persist: Width + Visibility
    NSMutableArray *state = [NSMutableArray array];
    
    for (NSView *subview in self.subviews) {
        NSDictionary *parameters = @{
            SPSplitViewWidthKey     : @(subview.frame.size.width),
            SPSplitViewVisibleKey   : @(subview.isHidden)
        };
        [state addObject:parameters];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:state forKey:name];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadStateWithKey:(NSString *)key
{
    if (!key) {
        return;
    }
    
    // Failsafe: State Elements should equal the number of subviews
    NSArray *state = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (state.count != self.subviews.count) {
        return;
    }
    
    NSInteger i = -1;
    for (NSView *subview in self.subviews) {
        NSDictionary *params = state[++i];
        if (![params isKindOfClass:[NSDictionary class]]) {
            continue;
        }

        /// NOTE:
        /// The TagList's width is fixed, and should not be restored! (Unless it is zero)
        ///
        CGFloat targetWidth = [params[SPSplitViewWidthKey] floatValue];
        if (i == SPSplitViewSectionTags && targetWidth > 0) {
            targetWidth = SPSplitViewDefaultWidth;
        }
        NSRect frame        = subview.frame;
        frame.size.width    = targetWidth;
        subview.frame       = frame;

        subview.hidden      = [params[SPSplitViewVisibleKey] boolValue];
    }
}

- (void)applyStyle
{
    [self setNeedsDisplay:YES];
}

//-(void)mouseMoved:(NSEvent *)event {
//    if (self.toolbar == NULL) {
//        return;
//    }
//    
//    NSWindow *plotWindow = [self window];
//    NSPoint mousePosition = [plotWindow mouseLocationOutsideOfEventStream];
//    
//    //convert to View
//    mousePosition = [self convertPoint:mousePosition fromView:nil];
//    float mX = mousePosition.x;
//    float mY = mousePosition.y;
//    if (self.toolbar.isHidden && mY < 30 && mX > 0 && mX < self.frame.size.width) {
//        [self.toolbar setHidden:NO];
//        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
//            context.duration = 0.5;
//            self.toolbar.animator.alphaValue = 0.7;
//        } completionHandler:^{
//            
//        }];
//    }
//    else if (!self.toolbar.isHidden && (mY > self.toolbar.frame.size.height || mY < 0 || mX < 0 || mX > self.frame.size.width))  {
//        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
//            context.duration = 0.5;
//            self.toolbar.animator.alphaValue = 0.0;
//        } completionHandler:^{
//            [self.toolbar setHidden:YES];
//        }];
//    }
//}


@end
