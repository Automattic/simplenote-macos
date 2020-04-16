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
#import "SPTagCellView.h"
#import "SPTableRowView.h"
#import "SPTableView.h"
#import "Tag.h"
#import "NSString+Metadata.h"
#import "VSThemeManager.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"

@import Simperium_OSX;


#define kAllNotesRow 0
#define kTrashRow 1
#define kTagHeaderRow 2
#define kStartOfTagListRow 3
#define kTagSortPreferencesKey @"kTagSortPreferencesKey"


NSString * const kTagsDidLoad = @"SPTagsDidLoad";
NSString * const kTagUpdated = @"SPTagUpdated";
NSString * const kDidBeginViewingTrash = @"SPDidBeginViewingTrash";
NSString * const kWillFinishViewingTrash = @"SPWillFinishViewingTrash";
NSString * const kDidEmptyTrash = @"SPDidEmptyTrash";
CGFloat const SPListEstimatedRowHeight = 30;

@interface TagListViewController ()

@property (nonatomic, assign) BOOL      menuShowing;
@property (nonatomic, strong) NSString  *tagNameBeingEdited;

@end

@implementation TagListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self buildDropdownMenus];

    self.tableView.rowHeight = SPListEstimatedRowHeight;
    self.tableView.usesAutomaticRowHeights = YES;
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:kAllNotesRow] byExtendingSelection:NO];    
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObject:@"Tag"]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagAddedFromEditor:) name:SPTagAddedFromEditorNotificationName object:nil];
    
    BOOL alphaTagSort = [[NSUserDefaults standardUserDefaults] boolForKey:kTagSortPreferencesKey];
    [tagSortMenuItem setState:alphaTagSort ? NSOnState : NSOffState];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self applyStyle];
}

- (Simperium *)simperium
{
    return [[SimplenoteAppDelegate sharedDelegate] simperium];
}

- (void)buildDropdownMenus
{
    trashDropdownMenu = [[NSMenu alloc] initWithTitle:@""];
    trashDropdownMenu.delegate = self;
    trashDropdownMenu.autoenablesItems = YES;

    [trashDropdownMenu addItemWithTitle:NSLocalizedString(@"Empty Trash", @"Empty Trash Action")
                                 action:@selector(emptyTrashAction:)
                          keyEquivalent:@""];

    for (NSMenuItem *item in trashDropdownMenu.itemArray) {
        [item setTarget:self];
    }
    
    tagDropdownMenu = [[NSMenu alloc] initWithTitle:@""];
    tagDropdownMenu.delegate = self;
    tagDropdownMenu.autoenablesItems = YES;

    [tagDropdownMenu addItemWithTitle:NSLocalizedString(@"Rename Tag", @"Rename Tag Action")
                               action:@selector(renameAction:)
                        keyEquivalent:@""];

    [tagDropdownMenu addItemWithTitle:NSLocalizedString(@"Delete Tag", @"Delete Tag Action")
                               action:@selector(deleteAction:)
                        keyEquivalent:@""];

    for (NSMenuItem *item in tagDropdownMenu.itemArray) {
        [item setTarget:self];
    }
}

- (void)sortTags
{
    BOOL sortAlphabetically = [[NSUserDefaults standardUserDefaults] boolForKey:kTagSortPreferencesKey];
    NSSortDescriptor *sortDescriptor;
    if (sortAlphabetically) {
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
    
    // Force Resync!
    [notesArrayController fetchWithRequest:nil merge:NO error:nil];
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
        [note createPreviews:note.content];
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
		[note createPreviews:note.content];
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
			 
			 SPTagCellView* tagCellView = (SPTagCellView*)[rowView viewAtColumn:columnIndex];
			 
			 if([tagCellView isKindOfClass:[SPTagCellView class]] && tagCellView.mouseInside) {
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
		SPTagCellView *tagView = [self.tableView viewAtColumn:0 row:row makeIfNecessary:NO];
		[tagView.textField becomeFirstResponder];
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

- (IBAction)sortAction:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    [item setState:item.state == NSOnState ? NSOffState : NSOnState];
    [[NSUserDefaults standardUserDefaults] setBool:item.state == NSOnState forKey:kTagSortPreferencesKey];
    
    [self loadTags];
}


#pragma mark - NSTableView delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return kStartOfTagListRow + self.tagArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (row == kAllNotesRow) {
        return NSLocalizedString(@"All Notes", @"Title of the view that displays all your notes");
    } else if(row == kTrashRow) {
        return NSLocalizedString(@"Trash", @"Title of the view that displays all your deleted notes");
    } else if(row == kTagHeaderRow) {
        return @"";
    } else {
        Tag *tag = [self.tagArray objectAtIndex:row-kStartOfTagListRow];
        return tag.name;
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *cellId = @"TagCell";
    
    if (row == kAllNotesRow) {
        cellId = @"AllNotesCell";
    } else if (row == kTrashRow) {
        cellId = @"TrashCell";
    } else if (row == kTagHeaderRow) {
        return [self tagHeaderTableViewCell];
    }
    
    SPTagCellView *tagView = [self.tableView makeViewWithIdentifier:cellId owner:self];
    [tagView.textField setDelegate:self];

    if (row == kAllNotesRow) {
        tagView.textField.stringValue = NSLocalizedString(@"All Notes", @"Title of the view that displays all your notes");
    } else if (row == kTrashRow) {
        tagView.textField.stringValue = NSLocalizedString(@"Trash", @"Title of the view that displays all your deleted notes");
    } else if (row == kTagHeaderRow) {
        tagView.textField.stringValue = @"";
    } else {
        Tag *tag = [self.tagArray objectAtIndex:row-kStartOfTagListRow];
        tagView.textField.stringValue = tag.name;
    }
    
    return tagView;
}

- (NSMenu *)tableView:(NSTableView *)tableView menuForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    switch (row) {
        case kAllNotesRow:
        case kTagHeaderRow:
            return nil;
        case kTrashRow:
            return trashDropdownMenu;
        default:
            return tagDropdownMenu;
    }
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    SPTableRowView *rowView = [[SPTableRowView alloc] initWithFrame:NSZeroRect];
    rowView.drawBorder = NO;
    rowView.grayBackground = YES;
    
    return rowView;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    if (row == kTagHeaderRow) {
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


#pragma mark - NSTableViewDelegate Helpers

- (HeaderTableCellView *)tagHeaderTableViewCell
{
    HeaderTableCellView *headerView = [self.tableView makeViewWithIdentifier:HeaderTableCellView.reuseIdentifier owner:self];
    headerView.textField.stringValue = [NSLocalizedString(@"Tags", @"Tags Section Name") uppercaseString];
    return headerView;
}


#pragma mark - NSMenuValidation delegate

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    // Tag dropdowns are always valid
    if (menuItem.menu == tagDropdownMenu) {
        return YES;
    }
    
    // For trash dropdown, check if there are deleted notes
    if (menuItem.menu == trashDropdownMenu) {
		SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
        return [appDelegate numDeletedNotes] > 0;
    }
    
    if (menuItem.menu == findMenu) {
        return YES;
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

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    return !self.menuShowing;
}

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
    BOOL isAlphaSort = [[NSUserDefaults standardUserDefaults] boolForKey:kTagSortPreferencesKey];
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
    [self.tableView setBackgroundColor:[[[VSThemeManager sharedManager] theme] colorForKey:@"tableViewBackgroundColor"]];
    [tagBox setFillColor:[[[VSThemeManager sharedManager] theme] colorForKey:@"tableViewBackgroundColor"]];
    [self reloadDataAndPreserveSelection];
}

@end
