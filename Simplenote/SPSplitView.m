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
        [self listenNotifications];
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
    // Slight hack to make left divider the background color
    if (rect.origin.x < 200) {
        [[[[VSThemeManager sharedManager] theme] colorForKey:@"tableViewBackgroundColor"] set];
        NSRectFill(rect);
    } else {
        [[[[VSThemeManager sharedManager] theme] colorForKey:@"dividerColor"] set];
        NSRectFill(rect);
    }
}


#pragma mark - NSNotification Helpers

- (void)listenNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppWillTerminateNote:)
                                                 name:NSApplicationWillTerminateNotification
                                               object:nil];
}


- (void)handleAppWillTerminateNote:(NSNotification *)note
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
        
        NSRect frame        = subview.frame;
        frame.size.width    = [params[SPSplitViewWidthKey] floatValue];
        subview.frame       = frame;
        
        subview.hidden      = [params[SPSplitViewVisibleKey] boolValue];
    }
}

- (void)applyStyle
{
    [self setNeedsDisplay:YES];
}

@end
