//
//  TagListViewController.m
//  Simplenote
//
//  Created by Michael Johnston on 7/2/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import "TagListViewController.h"
#import "SimplenoteAppDelegate.h"
#import "Tag.h"
#import "NSString+Metadata.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"

@import Simperium_OSX;



NSString * const TagListDidUpdateTagNotification            = @"TagListDidUpdateTagNotification";
NSString * const TagListDidUpdateTagOldNameKey              = @"OldTag";
NSString * const TagListDidUpdateTagNewNameKey              = @"NewTag";
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
    [self.tableView selectRowIndexes:self.state.indexSetForAllNotesRow byExtendingSelection:NO];
    [self.tableView registerForDraggedTypes:[NSArray arrayWithObject:@"Tag"]];
    [self.tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];

    [self setupTableView];
    [self setupHeaderSeparator];

    [self startListeningToSettingsNotifications];
    [self startListeningToScrollNotifications];

    [self loadTags];
    [self applyStyle];
}

- (void)viewWillAppear
{
    [super viewWillAppear];

    // Workaround: Triggering this notification right here helps us avoid timming issues between Storyboard
    // Instantiation and delegate setup.
    [self notifyTagsListFilterDidChange];
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    [self refreshExtendedContentInsets];
}

- (void)startListeningToSettingsNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
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
                                      action:@selector(emptyTrashWasPressed:)
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

- (NSArray<Tag *> *)sortTags:(NSArray<Tag *> *)unsorted
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

    return [unsorted sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)reset
{
    self.tagArray = @[];
    [self refreshState];
}

- (void)loadTags
{
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    NSArray<Tag *> *unsorted = [[appDelegate.simperium bucketForName: @"Tag"] allObjects];
    self.tagArray = [self sortTags:unsorted];

    [appDelegate.simperium save];
    
    [self reloadDataAndPreserveSelection];
}

// Returns the Tag with the associated name.
//
// - Note: This API performs `Tag` comparison by checking the `encoded tag hash`,
//         in order to normalize / isolate ourselves from potential mismatches.
//
// - Ref. https://github.com/Automattic/simplenote-macos/pull/617
//
- (Tag *)tagWithName:(NSString *)tagName
{
    NSString *targetTagHash = tagName.byEncodingAsTagHash;

    for (Tag *tag in self.tagArray) {
        if ([tag.name.byEncodingAsTagHash isEqualToString:targetTagHash]) {
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
    [self.tableView selectRowIndexes:self.state.indexSetForAllNotesRow byExtendingSelection:NO];
    [self.tableView scrollRowToVisible:self.state.indexOfAllNotesTagRow];
}

- (void)selectTag:(Tag *)tagToSelect
{
    NSIndexSet *index = [self.state indexSetForTagRowWithName:tagToSelect.name];
    if (!index) {
        return;
    }

    [self.tableView selectRowIndexes:index byExtendingSelection:NO];
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

    SPBucket *tagBucket = [self.simperium bucketForName:@"Tag"];

    Tag *newTag = [tagBucket insertNewObjectForKey:tagName.byEncodingAsTagHash];
    newTag.name = tagName;
    newTag.index = index == nil ? @(tagBucket.numObjects) : index;
    [self.simperium save];
    
    return newTag;
}

- (void)editorController:(NoteEditorViewController *)controller didAddNewTag:(NSString *)tag
{
    [self addTagWithName:tag];
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
    NSArray *notes = [self.simperium searchNotesWithTag:renamedTag];
	for (Note *note in notes) {
        [note stripTag:oldTagName];
        [note addTag:newTagName];
        [note createPreview];
	}
    
    renamedTag.name = newTagName;
    [self.simperium save];


    [[NSNotificationCenter defaultCenter] postNotificationName:TagListDidUpdateTagNotification object:self userInfo:@{
        TagListDidUpdateTagNewNameKey: newTagName,
        TagListDidUpdateTagOldNameKey: oldTagName
    }];
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

    NSArray *notes = [self.simperium searchNotesWithTag:tag];
	
    // Strip this tag from all notes
	for (Note *note in notes) {
		[note stripTag: tag.name];
		[note createPreview];
	}
    
    [self.simperium.tagsBucket deleteObject:tag];
    [self.simperium save];
    
    [self loadTags];
    
	if(tag == selectedTag) {
        [self.tableView selectRowIndexes:self.state.indexSetForAllNotesRow byExtendingSelection:NO];
	} else {
        [self selectTag:selectedTag];
	}

    [[NSNotificationCenter defaultCenter] postNotificationName:TagListDidUpdateTagNotification object:self userInfo: @{
        TagListDidUpdateTagOldNameKey: tagName
    }];
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
    NSInteger index = self.tableView.selectedRow;
    return index != NSNotFound ? [self.state tagAtIndex:index] : nil;
}

- (Tag *)highlightedTag
{
    NSInteger index = self.highlightedTagRowIndex;
    return index != NSNotFound ? [self.state tagAtIndex:index] : nil;
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


#pragma mark - NSMenuValidation delegate

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    // Tag dropdowns are always valid
    if (menuItem.menu == self.tagDropdownMenu) {
        return YES;
    }
    
    // For trash dropdown, check if there are deleted notes
    if (menuItem.menu == self.trashDropdownMenu) {
        return self.simperium.numberOfDeletedNotes > 0;
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
    self.tagNameBeingEdited = [notification.fieldEditor.string copy];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
    // This can get triggered before renaming has started; don't do anything in that case
    if (!self.tagNameBeingEdited) {
        return;
    }

    // Force de-selection of text
    NSTextView *textView = notification.fieldEditor;
    [textView setSelectedRange:NSMakeRange(0, 0)];

    // Send a *COPY* of the string to avoid "NSLayoutManager: Loop / Crash"
    NSString *newTagName    = [textView.string copy];
    Tag *oldTag             = [self tagWithName:self.tagNameBeingEdited];
    Tag *newTag             = [self tagWithName:newTagName];
    BOOL isProperRename     = newTag == nil || newTag == oldTag;
    BOOL oldTagWasChanged   = [self.tagNameBeingEdited isEqualToString:newTagName] == false;

    if (oldTagWasChanged && isProperRename && newTagName.length > 0) {
        [self changeTagName:self.tagNameBeingEdited toName:newTagName];
    } else {
        [self.tableView reloadSelectedRow];
    }

    self.tagNameBeingEdited = nil;
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

    NSData *payload = [NSKeyedArchiver archivedDataWithRootObject:objectURIs
                                            requiringSecureCoding:NO
                                                            error:nil];

    [pboard declareTypes:@[@"Tag"] owner:self];
    [pboard setData:payload forType:@"Tag"];

    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tableView
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    if (info.draggingSource != self.tableView) {
        return NSDragOperationNone;
    }

    // Disallow drop outside the Tags Range
    if (row < self.state.indexOfFirstTagRow || (row > self.state.indexOfLastTagRow + 1)) {
        return NSDragOperationNone;
    }

    if (dropOperation == NSTableViewDropOn) {
        [self.tableView setDropRow:row dropOperation:NSTableViewDropAbove];
    }

    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation
{
    // Account for row offset
    row = row - self.state.indexOfFirstTagRow;

    // Get object URIs from paste board
    NSData *data = [info.draggingPasteboard dataForType:@"Tag"];
    NSSet *supportedClasses = [NSSet setWithObjects:[NSArray class], [NSURL class], nil];
    NSArray *objectURIs = [NSKeyedUnarchiver unarchivedObjectOfClasses:supportedClasses fromData:data error:nil];

    if (objectURIs == nil || [objectURIs isKindOfClass:[NSArray class]] == false) {
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
    self.headerSeparatorView.borderColor = [NSColor simplenoteSidebarDividerColor];
    self.headerVisualEffectsView.appearance = [NSAppearance simplenoteAppearance];
    self.headerVisualEffectsView.material = [NSVisualEffectView simplenoteTaglistMaterial];
    self.backgroundVisualEffectsView.appearance = [NSAppearance simplenoteAppearance];
    self.backgroundVisualEffectsView.material = [NSVisualEffectView simplenoteTaglistMaterial];
    [self reloadDataAndPreserveSelection];
}

- (void)setActive:(BOOL)active
{
    if (active == _active) {
        return;
    }
    _active = active;
    [self refreshTableRowsActiveStatus];
}

@end
