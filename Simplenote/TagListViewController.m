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
#import "SPTableView.h"
#import "Tag.h"
#import "NSString+Metadata.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"

@import Simperium_OSX;


#define kPaddingRow 0
#define kAllNotesRow 1
#define kTrashRow 2
#define kTagHeaderRow 3
#define kStartOfTagListRow 4


NSString * const kTagsDidLoad = @"SPTagsDidLoad";
NSString * const kTagUpdated = @"SPTagUpdated";
NSString * const kDidBeginViewingTrash = @"SPDidBeginViewingTrash";
NSString * const kWillFinishViewingTrash = @"SPWillFinishViewingTrash";
NSString * const kDidEmptyTrash = @"SPDidEmptyTrash";
CGFloat const SPListEstimatedRowHeight = 30;

@interface TagListViewController ()

@property (nonatomic, strong) NSMenu    *tagDropdownMenu;
@property (nonatomic, strong) NSMenu    *trashDropdownMenu;
@property (nonatomic, strong) NSString  *tagNameBeingEdited;
@property (nonatomic, assign) BOOL      menuShowing;

@end

@implementation TagListViewController

- (void)deinit
{
    [self stopListeningToNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self buildDropdownMenus];

    self.tableView.rowHeight = SPListEstimatedRowHeight;
    self.tableView.usesAutomaticRowHeights = YES;
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:kAllNotesRow] byExtendingSelection:NO];    
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObject:@"Tag"]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];

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
    
    [self.tableView reloadData];
    
    // Restore last selections
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:tagRow] byExtendingSelection:NO];
    
    [self.noteListViewController.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:noteRow] byExtendingSelection:NO];

}

- (void)reset
{
    self.tagArray = [NSArray array];
    [self.tableView reloadData];
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
    NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow < kStartOfTagListRow) {
        return @"";
    }
    
    Tag *tag = [self.tagArray objectAtIndex:selectedRow - kStartOfTagListRow];
    return tag.name;
}

- (void)selectAllNotesTag
{
    NSIndexSet *allNotesIndex = [NSIndexSet indexSetWithIndex:kAllNotesRow];
    [self.tableView selectRowIndexes:allNotesIndex byExtendingSelection:NO];

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
    int row=0;
    for (Tag *tag in self.tagArray) {
        if ([tag.name isEqualToString:tagToSelect.name])
            break;
        row++;
    }
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row+kStartOfTagListRow] byExtendingSelection:NO];
}

- (NSArray *)notesWithTag:(Tag *)tag
{
    NSArray *predicateList = @[
        [NSPredicate predicateWithFormat: @"deleted == %@", @(NO)],
        [NSPredicate predicateWithFormat: @"tags CONTAINS[c] %@", tag.name]
    ];
    
    NSPredicate *compound = [NSCompoundPredicate andPredicateWithSubpredicates:predicateList];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagUpdated object:self userInfo:userInfo];
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
		[self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:kAllNotesRow] byExtendingSelection:NO];
	} else {
		[self selectTag:selectedTag];
	}
	
    NSDictionary *userInfo = @{@"tagName": tagName};
    [[NSNotificationCenter defaultCenter] postNotificationName:kTagUpdated object:self userInfo:userInfo];
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

- (Tag *)tagAtIndex:(NSInteger)tagIndex
{
	return (tagIndex >= 0 && tagIndex < self.tagArray.count) ? self.tagArray[tagIndex] : nil;
}

- (Tag *)selectedTag
{
	NSInteger tagIndex = self.tableView.selectedRow - kStartOfTagListRow;
	return [self tagAtIndex:tagIndex];
}

- (Tag *)highlightedTag
{
	NSInteger tagIndex = [self highlightedTagRowIndex] - kStartOfTagListRow;
	return [self tagAtIndex:tagIndex];
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
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"deleted == YES"]];
    
    NSError *error;
    NSArray *items = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Note *note in items) {
        [appDelegate.managedObjectContext deleteObject:note];
    }
    [appDelegate.simperium save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidEmptyTrash object:self];
}


#pragma mark - NSTableView delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return kStartOfTagListRow + self.tagArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    switch (row) {
        case kAllNotesRow:
            return NSLocalizedString(@"All Notes", @"Title of the view that displays all your notes");

        case kTrashRow:
            return NSLocalizedString(@"Trash", @"Title of the view that displays all your deleted notes");

        case kTagHeaderRow:
        case kPaddingRow:
            return @"";

        default: {
            Tag *tag = [self.tagArray objectAtIndex:row-kStartOfTagListRow];
            return tag.name;
        }
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (row == kAllNotesRow) {
        return [self allNotesTableViewCell];
    }

    if (row == kTrashRow) {
        return [self trashTableViewCell];
    }

    if (row == kTagHeaderRow) {
        return [self tagHeaderTableViewCell];
    }

    if (row == kPaddingRow) {
        return [self paddingTableViewCell];
    }

    Tag *tag = [self.tagArray objectAtIndex:row-kStartOfTagListRow];
    return [self tagTableViewCellForTag:tag];
}

- (NSMenu *)tableView:(NSTableView *)tableView menuForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    switch (row) {
        case kAllNotesRow:
        case kTagHeaderRow:
        case kPaddingRow:
            return nil;
        case kTrashRow:
            return self.trashDropdownMenu;
        default:
            return self.tagDropdownMenu;
    }
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    TableRowView *rowView = [TableRowView new];
    rowView.selectedBackgroundColor = [NSColor simplenoteSelectedBackgroundColor];
    return rowView;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    if (row == kTagHeaderRow || row == kPaddingRow) {
        return NO;
    }
    
    if ([self.tableView selectedRow] == kTrashRow) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kWillFinishViewingTrash object:self];
    }

    return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    BOOL isViewingTrash = [self.tableView selectedRow] == kTrashRow;
    NSString *notificationName = isViewingTrash ? kDidBeginViewingTrash : kTagsDidLoad;
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];

    [self.noteListViewController filterNotes:nil];
    [self.noteListViewController selectRow:0];
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
    return [self.tableView selectedRow] >= kStartOfTagListRow && self.tagNameBeingEdited == nil;
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
    BOOL isAlphaSort = Options.shared.alphabeticallySortTags;
    if (isAlphaSort || [rowIndexes firstIndex] < kStartOfTagListRow) {
        // Alphabetical tag sorting should not allow drag and drop
        return NO;
    }
    
    [pboard declareTypes:[NSArray arrayWithObject:@"Tag"] owner:self];
    
    // Collect URI representation of managed objects
    NSMutableArray *objectURIs = [NSMutableArray array];
    NSUInteger row = [rowIndexes firstIndex] - kStartOfTagListRow;
    id objProxy = [self.tagArray objectAtIndex:row];
    [objectURIs addObject: [[objProxy objectID] URIRepresentation]];
    
    // Set them to paste board
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:objectURIs] forType:@"Tag"];
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tableView
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    if (row < kStartOfTagListRow) {
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
    row = row - kStartOfTagListRow;
        
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
