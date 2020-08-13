//
//  SPTableView.m
//  Simplenote
//
//  Created by Michael Johnston on 7/26/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "SPTableView.h"


@interface SPTableView ()
@property (nonatomic, assign) BOOL disablesScrollToRow;
@end

@implementation SPTableView

- (void)keyDown:(NSEvent *)theEvent
{
    // Intercept the delete key and make it delete the currently selected note
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if (key == NSDeleteCharacter) {
        if ([self.delegate respondsToSelector:@selector(deleteAction:)]) {
            [self.delegate performSelector:@selector(deleteAction:) withObject:self];
            return;
        }
    }
    
    [super keyDown:theEvent];
}

- (NSInteger)rowForEvent:(NSEvent *)event
{
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    return [self rowAtPoint:location];
}

- (NSInteger)columnForEvent:(NSEvent *)event
{
    NSPoint mousePoint = [self convertPoint:event.locationInWindow fromView:nil];
    return [self columnAtPoint:mousePoint];
}

- (void)mouseDown:(NSEvent *)event
{
    self.disablesScrollToRow = self.disableAutoscrollOnMouseDown;

    [super mouseDown:event];

    self.disablesScrollToRow = NO;
}

- (BOOL)autoscroll:(NSEvent *)event
{
    if (self.disablesScrollToRow) {
        return NO;
    }

    return [super autoscroll:event];
}

- (void)scrollRowToVisible:(NSInteger)row
{
    if (self.disablesScrollToRow) {
        return;
    }

    [super scrollRowToVisible:row];
}

- (void)didClickTextView:(id)sender
{
    // User clicked a text view. Select its underlying row.
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:[self rowForView:sender]] byExtendingSelection:NO];
}

- (NSMenu *)menuForEvent:(NSEvent*)event
{
    NSInteger row = [self rowForEvent:event];
    NSInteger column = [self columnForEvent:event];

    if ([self.delegate tableView:self shouldSelectRow:row]) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    }

    if ([self.delegate respondsToSelector:@selector(tableView:menuForTableColumn:row:)] == false) {
        return [super menuForEvent:event];
    }

    return [(id<SPTableViewDelegate>)self.delegate tableView:self menuForTableColumn:column row:row];
}

@end
