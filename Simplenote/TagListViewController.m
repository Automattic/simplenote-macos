//
//  TagListViewController.m
//  Simplenote
//
//  Created by Michael Johnston on 7/2/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "TagListViewController.h"
#import "NoteListViewController.h"
#import "SimplenoteAppDelegate.h"
#import "Tag.h"
#import "NSString+Metadata.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"

@import Simperium_OSX;



NSString * const TagListDidBeginViewingTagNotification      = @"TagListDidBeginViewingTagNotification";
NSString * const TagListDidUpdateTagNotification            = @"TagListDidUpdateTagNotification";
NSString * const TagListDidBeginViewingTrashNotification    = @"TagListDidBeginViewingTrashNotification";
NSString * const TagListWillFinishViewingTrashNotification  = @"TagListWillFinishViewingTrashNotification";
NSString * const TagListDidEmptyTrashNotification           = @"TagListDidEmptyTrashNotification";
CGFloat const TagListEstimatedRowHeight                     = 30;

@interface TagListViewController ()
@property (nonatomic, strong) NSMenu            *tagDropdownMenu;
@property (nonatomic, strong) NSMenu            *trashDropdownMenu;
@property (nonatomic, strong) NSString          *tagNameBeingEdited;
@property (nonatomic, strong) NSArray<Tag *>    *tagArray;
@property (nonatomic, assign) BOOL              menuShowing;

@end

@implementation TagListViewController

- (void)deinit
{
    [self stopListeningToNotifications];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.state = [TagListState new];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self buildDropdownMenus];

    self.tableView.rowHeight = TagListEstimatedRowHeight;
    self.tableView.usesAutomaticRowHeights = YES;
    [self.tableView selectRowIndexes:self.state.indexSetForAllNotes byExtendingSelection:NO];
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObject:@"Tag"]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];

    [self refreshExtendedContentInsets];
    [self startListeningToNotifications];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self applyStyle];
}

- (void)startListeningToNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(tagAddedFromEditor:) name:SPTagAddedFromEditorNotificationName object:nil];
    [nc addObserver:self selector:@selector(sortModeWasUpdated:) name:TagSortModeDidChangeNotification object:nil];
}

- (void)stopListeningToNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (Simperium *)simperium
{
    return [[SimplenoteAppDelegate sharedDelegate] simperium];
}

- (void)buildDropdownMenus
{
    self.trashDropdownMenu = [[NSMenu alloc] initWithTitle:@""];
    self.trashDropdownMenu.delegate = self;
    self.trashDropdownMenu.autoenablesItems = YES;

    [self.trashDropdownMenu addItemWithTitle:NSLocalizedString(@"Empty Trash", @"Empty Trash Action")
                                      action:@selector(emptyTrashAction:)
                               keyEquivalent:@""];

    for (NSMenuItem *item in self.trashDropdownMenu.itemArray) {
        [item setTarget:self];
    }
    
    self.tagDropdownMenu = [[NSMenu alloc] initWithTitle:@""];
    self.tagDropdownMenu.delegate = self;
    self.tagDropdownMenu.autoenablesItems = YES;

    [self.tagDropdownMenu addItemWithTitle:NSLocalizedString(@"Rename Tag", @"Rename Tag Action")
                                    action:@selector(renameAction:)
                             keyEquivalent:@""];

    [self.tagDropdownMenu addItemWithTitle:NSLocalizedString(@"Delete Tag", @"Delete Tag Action")
                                    action:@selector(deleteAction:)
                             keyEquivalent:@""];

    for (NSMenuItem *item in self.tagDropdownMenu.itemArray) {
        [item setTarget:self];
    }
}

- (void)sortTags
{
    NSSortDescriptor *sortDescriptor;
    if (Options.shared.alphabeticallySortTags) {
        sortDescriptor = [[NSSortDescriptor alloc]
                          initWithKey:@"name"
                          ascending:YES
                          selector:@selector(localizedCaseInsensitiveCompare:)];
    } else {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    }

    self.tagArray = [self.tagArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

// TODO: Work in Progress. Decouple with a delegate please
//
- (NoteListViewController *)noteListViewController
{
    return [[SimplenoteAppDelegate sharedDelegate] noteListViewController];
}

- (void)reloadDataAndPreserveSelection
{
    // Remember last selections
    NSInteger tagRow = [self.tableView selectedRow];
    NSInteger noteRow = [self.noteListViewController.tableView selectedRow];

    [self refreshState];
    
    // Restore last selections
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:tagRow] byExtendingSelection:NO];
    
    [self.noteListViewController.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:noteRow] byExtendingSelection:NO];

}

- (void)reset
{
    self.tagArray = @[];
    [self refreshState];
}

- (void)loadTags
{
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    self.tagArray = [[appDelegate.simperium bucketForName: @"Tag"] allObjects];
    [self sortTags];

    [appDelegate.simperium save];
    
    [self reloadDataAndPreserveSelection];
}

- (Tag *)tagWithName:(NSString *)tagName
{
    for (Tag *tag in self.tagArray) {
        if ([tag.name isEqualToString:tagName]) {
            return tag;
        }
    }
    
    return nil;
}

- (NSString *)selectedTagName
{
    return self.selectedTag.name ?: @"";
}

- (void)selectAllNotesTag
{
    [self.tableView selectRowIndexes:self.state.indexSetForAllNotes byExtendingSelection:NO];

    // Notes:
    //  1.  Programatically selecting the Row Indexes trigger the regular callback chain
    //  2.  Because of the above, NoteListController's predicate is already refreshed
    //  3.  Standard mechanism will refresh the UI in the next runloop cycle
    //
    // Since this API is expected to be synchronous, we'll force a resync.
    //
    [self.noteListViewController reloadSynchronously];
}

- (void)selectTag:(Tag *)tagToSelect
{
    NSIndexSet *index = [self.state indexSetForTagWithName:tagToSelect.name];
    if (!index) {
        return;
    }

    [self.tableView selectRowIndexes:index byExtendingSelection:NO];
}

- (NSArray *)notesWithTag:(Tag *)tag
{
    NSPredicate *compound = [NSCompoundPredicate andPredicateWithSubpredicates:@[
        [NSPredicate predicateForNotesWithDeletedStatus:NO],
        [NSPredicate predicateForNotesWithTag:tag.name]
    ]];
    
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    SPBucket *noteBucket = [appDelegate.simperium bucketForName:@"Note"];
    
    // Note:
    // 'contains' predicate might return Tags that contains our search keyword as a substring.
    // 
    NSArray *notes = [noteBucket objectsForPredicate:compound];
    NSMutableArray *exactMatches = [NSMutableArray array];
    for (Note *note in notes) {
        if ([note.tagsArray containsObject:tag.name]) {
            [exactMatches addObject:note];
        }
    }
    
    return exactMatches;
}

- (Tag *)addTagWithName:(NSString *)tagName
{
    return [self addTagWithName:tagName atIndex:nil];
}

- (Tag *)addTagWithName:(NSString *)tagName atIndex:(NSNumber *)index
{
    // Don't add tags that have email addresses
    if (tagName == nil || tagName.length == 0 || [tagName containsEmailAddress]) {
        return nil;
    }
    
    // Don't add the tag if there is an existing tag with the same name
    if ([self tagWithName:tagName]) {
        return nil;
    }
    
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    SPBucket *tagBucket = [appDelegate.simperium bucketForName:@"Tag"];
    NSString *tagKey = [[tagName lowercaseString] sp_urlEncodeString];
    Tag *newTag = [tagBucket insertNewObjectForKey:tagKey];
    newTag.name = tagName;
    newTag.index = index == nil ? @([tagBucket numObjects]) : index;
    [appDelegate.simperium save];
    
    return newTag;
}

- (void)tagAddedFromEditor:(NSNotification *)notification
{
    [self addTagWithName:[notification.userInfo objectForKey:@"tagName"]];
    [self loadTags];
}

- (void)sortModeWasUpdated:(NSNotification *)notification
{
    [self loadTags];
}

- (void)changeTagName:(NSString *)oldTagName toName:(NSString *)newTagName
{
    [SPTracker trackTagRowRenamed];
    
    Tag *renamedTag = [self tagWithName:oldTagName];
    
    // No spaces allowed (currently)
    newTagName = [newTagName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Brute force updating of all notes with this tag
    NSArray *notes = [self notesWithTag:renamedTag];
	for (Note *note in notes) {
        [note stripTag:oldTagName];
        [note addTag:newTagName];
        [note createPreview];
	}
    
    renamedTag.name = newTagName;
    [self.simperium save];
    
    NSDictionary *userInfo = @{@"tagName": newTagName};
    [[NSNotificationCenter defaultCenter] postNotificationName:TagListDidUpdateTagNotification object:self userInfo:userInfo];
}

- (void)deleteTag:(Tag *)tag
{
    [SPTracker trackTagRowDeleted];
    
	// Failsafes FTW
	if (!tag) {
		return;
	}
	
	Tag* selectedTag = [self selectedTag];
    NSString *tagName = [tag.name copy];
    
    NSArray *notes = [self notesWithTag:tag];
	
    // Strip this tag from all notes
	for (Note *note in notes) {
		[note stripTag: tag.name];
		[note createPreview];
	}
    
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    SPBucket *tagBucket = [appDelegate.simperium bucketForName:@"Tag"];
    [tagBucket deleteObject:tag];
    [appDelegate.simperium save];
    
    [self loadTags];
    
	if(tag == selectedTag) {
        [self.tableView selectRowIndexes:self.state.indexSetForAllNotes byExtendingSelection:NO];
	} else {
        [self selectTag:selectedTag];
	}
	
    NSDictionary *userInfo = @{@"tagName": tagName};
    [[NSNotificationCenter defaultCenter] postNotificationName:TagListDidUpdateTagNotification object:self userInfo:userInfo];
}


#pragma mark - Helpers

- (NSInteger)highlightedTagRowIndex
{
	__block NSInteger tagIndex = NSNotFound;
	
	[self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row)
	 {
		 NSInteger columnIndex = -1;
		 while(++columnIndex < rowView.numberOfColumns) {
			 
			 TagTableCellView* tagCellView = (TagTableCellView*)[rowView viewAtColumn:columnIndex];
			 
			 if([tagCellView isKindOfClass:[TagTableCellView class]] && tagCellView.mouseInside) {
				 tagIndex = row;
				 break;
			 }
		 }
	 }];
	
	return tagIndex;
}

- (Tag *)selectedTag
{
    return [self.state tagAtIndex:self.tableView.selectedRow];
}

- (Tag *)highlightedTag
{
    return [self.state tagAtIndex:self.highlightedTagRowIndex];
}


#pragma mark - Actions

- (IBAction)deleteAction:(id)sender
{
	Tag *tag = nil;

	// If the sender is the table itself: we're resonding to a backspace event
	if (sender == self.tableView) {
		tag = [self selectedTag];
	// Otherwise, let's figure out what's the highlighted row
	} else {
		tag = [self highlightedTag];
	}
	
	// Proceed!
    if (tag) {
		[self deleteTag:tag];
	}
}

- (IBAction)renameAction:(id)sender
{
	NSInteger row = NSNotFound;
	
	if(sender == self.tableView) {
		row = [self.tableView selectedRow];
	} else {
		row = [self highlightedTagRowIndex];
	}
	
	if(row != NSNotFound) {
		TagTableCellView *tagView = [self.tableView viewAtColumn:0 row:row makeIfNecessary:NO];
		[tagView.nameTextField becomeFirstResponder];
	}
}

- (IBAction)emptyTrashAction:(id)sender
{
    [SPTracker trackListTrashEmptied];
    
    // Empty it
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:appDelegate.managedObjectContext];
    fetchRequest.entity = entity;
    fetchRequest.predicate = [NSPredicate predicateForNotesWithDeletedStatus:YES];
    
    NSError *error;
    NSArray *items = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Note *note in items) {
        [appDelegate.managedObjectContext deleteObject:note];
    }
    [appDelegate.simperium save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TagListDidEmptyTrashNotification object:self];
}


#pragma mark - NSMenuValidation delegate

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    // Tag dropdowns are always valid
    if (menuItem.menu == self.tagDropdownMenu) {
        return YES;
    }
    
    // For trash dropdown, check if there are deleted notes
    if (menuItem.menu == self.trashDropdownMenu) {
		SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
        return [appDelegate numDeletedNotes] > 0;
    }
    
    // Disable menu items for All Notes, Trash, or if you're editing a tag (uses the NSMenuValidation informal protocol)
    BOOL isTagSelected = [self selectedTag] != nil;
    return isTagSelected && self.tagNameBeingEdited == nil;
}

- (void)menuWillOpen:(NSMenu *)menu
{
    self.menuShowing = YES;
}

- (void)menuDidClose:(NSMenu *)menu
{
    self.menuShowing = NO;
}


#pragma mark - NSTextField delegate

- (void)controlTextDidBeginEditing:(NSNotification *)notification
{
    NSTextView *textView = [notification.userInfo objectForKey:@"NSFieldEditor"];
    self.tagNameBeingEdited = [textView.string copy];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
    if (self.tagNameBeingEdited) {
        // This can get triggered before renaming has started; don't do anything in that case

        NSTextView *textView = [notification.userInfo objectForKey:@"NSFieldEditor"];
        
        [textView setSelectedRange:NSMakeRange(0, 0)]; // force de-selection of text
        
        // Note:
        // Send a *COPY* of the string. Otherwise the internal string will be exposed, and this may lead to
        // weird side effects.
        NSString *newTagName = [textView.string copy];
        
        BOOL tagAlreadyExists = [self tagWithName:newTagName] != nil;
        if ([newTagName length] > 0 && !tagAlreadyExists && ![self.tagNameBeingEdited isEqualToString:newTagName])
            [self changeTagName:self.tagNameBeingEdited toName:newTagName];
        
        self.tagNameBeingEdited = nil;
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    return YES;
}


#pragma mark - NSTableView dragging

// Drag 'n' drop code adapted from http://stackoverflow.com/a/13017587/1379066
// Much of this code is overly generalized for this use case, but it works
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    // Alphabetical tag sorting should not allow drag and drop
    if (Options.shared.alphabeticallySortTags) {
        return NO;
    }

    Tag *tag = [self.state tagAtIndex:rowIndexes.firstIndex];
    if (tag == nil) {
        return NO;
    }

    NSArray *objectURIs = @[
        tag.objectID.URIRepresentation
    ];

    [pboard declareTypes:[NSArray arrayWithObject:@"Tag"] owner:self];
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:objectURIs] forType:@"Tag"];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tableView
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    // Disallow drop outside the Tags Range
    if (row < self.state.numberOfFirstTagRow || (row > self.state.numberOfLastTagRow + 1)) {
        return NSDragOperationNone;
    }

    if ([info draggingSource] == self.tableView) {
        if (dropOperation == NSTableViewDropOn){
            [self.tableView setDropRow:row dropOperation:NSTableViewDropAbove];
        }
        return NSDragOperationMove;
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation
{
    // Account for row offset
    row = row - self.state.numberOfFirstTagRow;

    // Get object URIs from paste board
    NSData *data        = [info.draggingPasteboard dataForType:@"Tag"];
    NSArray *objectURIs = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (!objectURIs) {
        return NO;
    }
    
    // Get managed object context and persistent store coordinator
    NSManagedObjectContext *context             = [[SimplenoteAppDelegate sharedDelegate] managedObjectContext];
    NSPersistentStoreCoordinator *coordinator   = [context persistentStoreCoordinator];
    
    // Collect manged objects with URIs
    NSMutableArray *draggedObjects = [NSMutableArray array];
    
    for (NSURL* objectURI in objectURIs) {
        // Get managed object
        NSManagedObjectID *objectID = [coordinator managedObjectIDForURIRepresentation:objectURI];
        NSManagedObject *object     = [context objectWithID:objectID];
        if (!object) {
            continue;
        }
        
        [draggedObjects addObject:object];
    }
    
    // Get managed objects
    NSMutableArray *allObjects = [NSMutableArray arrayWithArray:self.tagArray];
    if (allObjects.count == 0) {
        return NO;
    }
    
    // Replace dragged objects with null objects as placeholder to prevent old order
    for (NSManagedObject *obj in draggedObjects) {
        NSUInteger index = [allObjects indexOfObject:obj];
        if (index == NSNotFound) {
            continue;
        }
        [allObjects replaceObjectAtIndex:index withObject:[NSNull null]];
    }
    
    // Insert dragged objects at row
    if (row < [allObjects count]) {
        [allObjects insertObjects:draggedObjects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row, draggedObjects.count)]];
    } else {
        [allObjects addObjectsFromArray:draggedObjects];
    }
    
    // Remove old null objects
    [allObjects removeObject:[NSNull null]];
    
    // Re-order objects
    for (int i=0; i < allObjects.count; i++) {
        Tag *object = allObjects[i];
        object.index = @(i);
    }
    
    // Reload data
    [self loadTags];
    return YES;
}


#pragma mark - Appearance

- (void)applyStyle
{
    self.visualEffectsView.appearance = [NSAppearance appearanceNamed:self.appearanceNameForVisualEffectsView];
    self.visualEffectsView.material = self.materialForVisualEffectsView;
    [self reloadDataAndPreserveSelection];
}

- (NSAppearanceName)appearanceNameForVisualEffectsView
{
    return SPUserInterface.isDark ? NSAppearanceNameVibrantDark: NSAppearanceNameVibrantLight;
}

- (NSVisualEffectMaterial)materialForVisualEffectsView
{
    if (@available(macOS 10.14, *)) {
        return NSVisualEffectMaterialUnderWindowBackground;
    }

    return NSVisualEffectMaterialAppearanceBased;
}

@end
