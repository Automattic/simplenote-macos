//
//  NotesArrayController.m
//  Simplenote
//
//  Created by Michael Johnston on 11-08-26.
//  Copyright (c) 2011 Simperium. All rights reserved.
//

#import "NotesArrayController.h"
#import <Foundation/NSNotificationQueue.h>

@implementation NotesArrayController

- (NSArray *)arrangeObjects:(NSArray *)objects
{
    // Bizarrely fixes a rearrangement bug:
    // http://www.cocoabuilder.com/archive/cocoa/319540-nsarraycontroller-not-rearranging-correctly.html#319595
    NSNotification *notification = [NSNotification notificationWithName: kNotesArrayDidChangeNotification object: self];
    [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle];
    
    return [super arrangeObjects:objects];
}

- (BOOL)setSelectionIndexes:(NSIndexSet *)indexes
{
    NSNotification *notification = [NSNotification notificationWithName: kNotesArraySelectionDidChangeNotification object: self];
    [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle];

    return [super setSelectionIndexes:indexes];
}

@end
