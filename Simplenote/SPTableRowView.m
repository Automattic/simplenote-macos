//
//  CustomRowView.m
//  Simplenote
//
//  Created by Rainieri Ventura on 1/27/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "SPTableRowView.h"
#import "NSColor+Simplenote.h"
#import "VSThemeManager.h"

@implementation SPTableRowView
@synthesize drawBorder;

- (BOOL)isEmphasized
{
    // Ensures the strong blue selection appears even without focus
    return YES;
}

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        if (_grayBackground) {
            return;
        }

        [[[[VSThemeManager sharedManager] theme] colorForKey:@"tableViewBackgroundColor"] setFill];
        [[NSColor colorForCellSelection] setStroke];

        NSRect rect = NSMakeRect(self.bounds.origin.x-1, self.bounds.origin.y, self.bounds.size.width+2, self.bounds.size.height);
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:rect];
        
        [selectionPath fill];
        
        if (drawBorder) {
            [selectionPath stroke];
        }
    }
}

@end
