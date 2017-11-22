//
//  NoteEditorViewController.m
//  Simplenote
//
//  Created by Rainieri Ventura on 2/2/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "NoteEditorViewController.h"
#import "SimplenoteAppDelegate.h"
#import "Note.h"
#import "Tag.h"
#import "NoteListViewController.h"
#import "TagListViewController.h"
#import "NoteEditorBottomBar.h"
#import "JSONKit+Simplenote.h"
#import "NSString+Escaping.h"
#import "NSString+Metadata.h"
#import "NSString+Bullets.h"
#import "NSTextView+Simplenote.h"
#import "NSApplication+Helpers.h"
#import "SPConstants.h"
#import "SPToolbarView.h"
#import "SPTextLinkifier.h"
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"
#import "SPTracker.h"

@import Simperium_OSX;



#pragma mark ====================================================================================
#pragma mark Notifications
#pragma mark ====================================================================================

NSString * const SPNoNoteLoadedNotificationName         = @"SPNoNoteLoaded";
NSString * const SPNoteLoadedNotificationName           = @"SPNoteLoaded";
NSString * const SPTagAddedFromEditorNotificationName   = @"SPTagAddedFromEditor";
NSString * const SPWillAddNewNoteNotificationName       = @"SPWillAddNewNote";


#pragma mark ====================================================================================
#pragma mark Constants
#pragma mark ====================================================================================

static NSString * const SPTextViewPreferencesKey        = @"kTextViewPreferencesKey";
static NSString * const SPFontSizePreferencesKey        = @"kFontSizePreferencesKey";
static NSInteger const SPVersionSliderMaxVersions       = 10;


#pragma mark ====================================================================================
#pragma mark Private
#pragma mark ====================================================================================

@interface NoteEditorViewController() <NSTextDelegate, NSTextViewDelegate, NSPopoverDelegate,
                                       NSTokenFieldDelegate, SPBucketDelegate, NSMenuDelegate>

@property (nonatomic, strong) NSTimer               *saveTimer;
@property (nonatomic, strong) NSMutableDictionary   *noteVersionData;
@property (nonatomic,   copy) NSString              *noteContentBeforeRemoteUpdate;
@property (nonatomic, strong) NSFont                *noteBodyFont;
@property (nonatomic, strong) NSFont                *noteTitleFont;
@property (nonatomic, strong) NSArray               *selectedNotes;
@property (nonatomic, strong) NSPopover             *activePopover;
@property (nonatomic, strong) SPTextLinkifier       *textLinkifier;

@property (nonatomic, assign) NSUInteger            cursorLocationBeforeRemoteUpdate;
@property (nonatomic, assign) BOOL                  viewingVersions;
@property (nonatomic, assign) BOOL                  viewingTrash;
@property (nonatomic, assign) BOOL                  needsFontUpdate;

@end


#pragma mark ====================================================================================
#pragma mark NoteEditorViewController
#pragma mark ====================================================================================

@implementation NoteEditorViewController

- (VSTheme *)theme {

    return [[VSThemeManager sharedManager] theme];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// KVO Cleanup!
	self.noteEditor = nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    CGFloat insetX = 20;
    CGFloat insetY = 20;
    [self.noteEditor setFont:self.noteTitleFont];
    [self.noteEditor setTextContainerInset: NSMakeSize(insetX, insetY)];
    [self.noteEditor setFrameSize:NSMakeSize(self.noteEditor.frame.size.width-insetX/2, self.noteEditor.frame.size.height-insetY/2)];
    [self applyStyle];
	
    // Optimized Linkifier
    self.textLinkifier = [SPTextLinkifier linkifierWithTextView:self.noteEditor];
    
    // Set hyperlinks to be the same color as the app's highlight color
    [self.noteEditor setLinkTextAttributes: @{
       NSForegroundColorAttributeName: [self.theme colorForKey:@"tintColor"],
        NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSSingleUnderlineStyle],
                NSCursorAttributeName: [NSCursor pointingHandCursor]
     }];

	// Restore last session's  preferences
	NSDictionary *preferences = [self loadNoteEditorPreferences];
	for (NSString *key in preferences.allKeys) {
		[self.noteEditor setValue:preferences[key] forKey:key];
	}
    
    tagTokenField = [self.bottomBar addTagField];
    tagTokenField.delegate = self;    
    
    [noNoteText setFont:[NSFont systemFontOfSize:20.0]];

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(trashDidLoad:) name:kDidBeginViewingTrash object:nil];
    [nc addObserver:self selector:@selector(tagsDidLoad:) name:kTagsDidLoad object:nil];
    [nc addObserver:self selector:@selector(tagDeleted:) name:kTagDeleted object:nil];
    [nc addObserver:self selector:@selector(simperiumWillSave:) name:SimperiumWillSaveNotification object:nil];
}

- (void)save
{
    if (![self.note hasChanges]) {
        return;
    }
    
    [SPTracker trackEditorNoteEdited];
    
    // Focus can become lost when a note saves; work around that
    BOOL editorHasFocus = [[NSApp keyWindow] firstResponder] == self.noteEditor;
    NSRange range = [self.noteEditor selectedRange];
    
    self.note.modificationDate = [NSDate date];
    [self.note createPreviews:self.note.content];
    
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    [appDelegate.simperium save];
    
	[self.saveTimer invalidate];
	self.saveTimer = nil;
    
    if (editorHasFocus) {
        [[NSApp keyWindow] makeFirstResponder:self.noteEditor];
        
        if (range.location != NSNotFound && range.location < self.noteEditor.string.length) {
            [self.noteEditor setSelectedRange:range];
        }
    }
}

- (void)saveAndSync:(NSTimer *)timer
{
    [self save];
}

- (void)updateTagField
{
    [tagTokenField setObjectValue: [self.note.tagsArray count] > 0 ? self.note.tagsArray : [NSArray array]];
    [tagTokenField setNeedsDisplay:YES];
}

- (void)displayNote:(Note *)selectedNote
{
    [self save];
    [self showStatusText:nil];
    [statusView setHidden: selectedNote != nil];
    
    if (selectedNote == nil) {
        [self.noteEditor setEditable:NO];
        [self.noteEditor setSelectable:NO];
        [self.noteEditor setString:@""];
        [tagTokenField setEditable:NO];
        [self.bottomBar setEnabled:NO];
        
        self.note = nil;
        self.selectedNotes = [NSArray array];
        
        [tagTokenField setObjectValue:[NSArray array]];
        [[NSNotificationCenter defaultCenter] postNotificationName:SPNoNoteLoadedNotificationName object:self];
        
        return;
    }

    if ([self.note.simperiumKey isEqualToString:selectedNote.simperiumKey]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SPNoteLoadedNotificationName object:self];

    // Issue #291:
    // Flipping the editable flag effectively "Commits" the last character being edited (Korean Keyboard)
    self.noteEditor.editable    = false;
    self.noteEditor.editable    = !self.viewingTrash;
    
    self.noteEditor.selectable  = !self.viewingTrash;
    self.noteEditor.font        = self.noteBodyFont;
    
    tagTokenField.editable      = !self.viewingTrash;
    tagTokenField.selectable    = !self.viewingTrash;
    self.bottomBar.enabled      = !self.viewingTrash;

    self.note                   = selectedNote;
    self.selectedNotes          = [NSArray arrayWithObject:self.note];
    
    [self updateTagField];

    if (selectedNote.content != nil) {
        // Force selection to start; not doing this can cause an NSTextStorage exception when
        // switching away from long notes (> 5000 characters)
        [self.noteEditor setSelectedRange:NSMakeRange(0, 0)];
        self.noteEditor.string = self.note.content;
    } else {
        self.noteEditor.string = @"";
    }
    
    [self updateEditorFonts];
}

- (void)displayNotes:(NSArray *)notes
{
    self.note = nil;
    self.selectedNotes = notes;
    [self.noteEditor setString:@""];
    [self.noteEditor setEditable:NO];
    [self.noteEditor setSelectable:NO];
    [tagTokenField setEditable:NO];
    [tagTokenField setSelectable:NO];
    [tagTokenField setObjectValue:[NSArray array]];
    [self.bottomBar setEnabled:NO];
    
    NSString *status = [NSString stringWithFormat:@"%ld notes selected", [self.selectedNotes count]];
    [self showStatusText:status];
}

- (void)showStatusText:(NSString *)text
{
    // Quick and dirty status text for now
    NSTextField *statusField = [statusView viewWithTag:1];

    if (text == nil || [text length] == 0) {
        [statusField setStringValue:@""];
        [statusView setHidden:YES];
        return;
    }
    
    [statusView setHidden:NO];
    [statusField setStringValue:text];
}

- (void)trashDidLoad:(NSNotification *)notification
{
    self.viewingTrash = YES;
    [self.bottomBar setEnabled:NO];
}

- (void)tagsDidLoad:(NSNotification *)notification
{
    self.viewingTrash = NO;
    [self.bottomBar setEnabled:YES];
}

- (void)tagDeleted:(NSNotification *)notification
{
    [self updateTagField];
}

- (void)simperiumWillSave:(NSNotification *)notification
{
	[self save];
}

- (NSUInteger)newCursorLocation:(NSString *)newText oldText:(NSString *)oldText currentLocation:(NSUInteger)location
{
	NSUInteger newCursorLocation = location;
    
    // Cases:
    // 0. All text after cursor (and possibly more) was removed ==> put cursor at end
    // 1. Text was added after the cursor ==> no change
    // 2. Text was added before the cursor ==> location advances
    // 3. Text was removed after the cursor ==> no change
    // 4. Text was removed before the cursor ==> location retreats
    // 5. Text was added/removed on both sides of the cursor ==> not handled
    
    NSInteger deltaLength = newText.length - oldText.length;
    
    // Case 0
    if (newText.length < location)
        return newText.length;
    
    BOOL beforeCursorMatches = NO;
    BOOL afterCursorMatches = NO;
    @try {
        beforeCursorMatches = [[oldText substringToIndex:location] compare:[newText substringToIndex:location]] == NSOrderedSame;
        afterCursorMatches = [[oldText substringFromIndex:location] compare:[newText substringFromIndex:location+deltaLength]] == NSOrderedSame;
    } @catch (NSException *e) {
        
    }
    
    // Cases 2 and 4
    if (!beforeCursorMatches && afterCursorMatches) {
        newCursorLocation += deltaLength;
    }
    
    // Cases 1, 3 and 5 have no change
    return newCursorLocation;
}

- (NSUInteger)wordCount
{
    NSUInteger numWords = 0;
    for (Note *selectedNote in self.selectedNotes) {
        // countWordsInString returns -1 for a zero length string; handle that
        if (selectedNote.content == nil || [selectedNote.content length] == 0)
            continue;
        
        numWords += [[NSSpellChecker sharedSpellChecker] countWordsInString:selectedNote.content language:nil];
    }
    
    return numWords;
}

- (NSUInteger)charCount
{
    NSUInteger numChars = 0;
    for (Note *selectedNote in self.selectedNotes) {
        if (selectedNote.content == nil)
            continue;
        
        numChars += [selectedNote.content length];
    }
    
    return numChars;
}

- (void)updateCounts
{
    NSString *word = NSLocalizedString(@"Word", @"Text displayed when there is one word in a note (e.g. 1 Word)");
    NSString *words = NSLocalizedString(@"Words", @"Text displayed when there is more than one word in a note (e.g. 5 Words)");
    NSString *character = NSLocalizedString(@"Character", @"Text displayed when there is one character in a note (e.g. 1 Character)");
    NSString *characters = NSLocalizedString(@"Characters", @"Text displayed when there is more than one character in a note (e.g. 130 Characters)");
    NSNumber *numCharacters = @([self charCount]);
    NSNumber *numWords = @([self wordCount]);
    NSString *wordStr = [numWords isEqual: @1] ? word : words;
    NSString *charStr = [numCharacters isEqual: @1] ? character : characters;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    numberFormatter.locale = [NSLocale currentLocale];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.usesGroupingSeparator = YES;
    
    NSString *numCharactersString = [numberFormatter stringForObjectValue:numCharacters];
    NSString *numWordsString = [numberFormatter stringForObjectValue:numWords];

    [characterCountItem setTitle:[NSString stringWithFormat:@"%@ %@", numCharactersString, charStr]];
    [wordCountItem setTitle:[NSString stringWithFormat:@"%@ %@", numWordsString, wordStr]];
}

- (void)updateVersionLabel:(NSDate *)versionDate {
    NSString *versionStr = [@"  " stringByAppendingFormat:@"%@: %@",
							NSLocalizedString(@"Version", @"Label for the current version of a note"),
							[self.note getDateString:versionDate brief:NO]];
    
    versionLabel.stringValue = versionStr;
}



#pragma mark - Text Delegates

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)range replacementString:(NSString *)text
{
    // Need to track whether the user entered a newline in order to prevent scroll jittering
    // when updating the editor's fonts. (If a newline is entered in the title line, fonts
    // need to be adjusted).
    NSUInteger firstNewlineLocation = [self.note.content rangeOfString:@"\n"].location;
    BOOL hasNewline                 = firstNewlineLocation != NSNotFound;
    BOOL editingFirstLine           = range.location <= firstNewlineLocation;

    self.needsFontUpdate            = (hasNewline && editingFirstLine) || !hasNewline || self.noteEditor.string.length == 0;

    // Apply Autobullets if needed
    BOOL appliedAutoBullets = [self.noteEditor applyAutoBulletsWithReplacementText:text replacementRange:range];

    return !appliedAutoBullets;
}

- (void)textDidChange:(NSNotification *)notification
{
    self.note.content = self.noteEditor.string;
    
    [self.saveTimer invalidate];
    self.saveTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(saveAndSync:) userInfo:nil repeats:NO];
    
    // Update the fonts only if there was a newline entered or more than a single character changed
    if (self.needsFontUpdate) {
        [self updateEditorFonts];
    }
    
    self.needsFontUpdate = NO;
    
    // Update the note list preview
    [noteListViewController reloadRowForNoteKey:self.note.simperiumKey];
}


#pragma mark - Simperium

- (void)didReceiveNewContent
{
    NSUInteger newLocation = [self newCursorLocation:self.note.content
                                             oldText:self.noteContentBeforeRemoteUpdate
                                     currentLocation:self.cursorLocationBeforeRemoteUpdate];

    self.noteEditor.string = self.note.content;
    [self updateEditorFonts];
    
    NSRange newRange = NSMakeRange(newLocation, 0);
    [self.noteEditor setSelectedRange:newRange];

    [self updatePublishUI];
}

- (void)willReceiveNewContent
{
    self.cursorLocationBeforeRemoteUpdate = [self.noteEditor selectedRange].location;
    self.noteContentBeforeRemoteUpdate = self.noteEditor.string;
    
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
	
    if (self.note != nil && ![self.noteEditor.string isEqualToString:@""]) {
        self.note.content = self.noteEditor.string;
        [appDelegate.simperium saveWithoutSyncing];
    }
}

- (void)didReceiveVersion:(NSString *)version data:(NSDictionary *)data
{
    if (self.viewingVersions) {
        if (self.noteVersionData == nil) {
            self.noteVersionData = [NSMutableDictionary dictionaryWithCapacity:10];
        }
        
        [self.noteVersionData setObject:data forKey:@(version.integerValue)];
    }
}

- (long)minimumNoteVersion
{
    NSInteger version = [[self.note version] integerValue];
    NSInteger minVersion = MAX(version - SPVersionSliderMaxVersions, 1);
    
    return minVersion;
}


#pragma mark - Publishing

- (void)updatePublishUI
{
    if (self.note.published && self.note.publishURL.length == 0) {
        [publishLabel setStringValue:@"Publishing..."];
        [publishButton setTitle:@"Publish to Web Page"];
        publishButton.enabled = NO;
    } else if (self.note.published && self.note.publishURL.length > 0) {
        [publishLabel setStringValue:[NSString stringWithFormat:@"%@%@", SPSimplenotePublishURL, self.note.publishURL]];
        [publishButton setTitle:@"Unpublish"];
        publishButton.enabled = YES;
        publishButton.state = NSOnState; // clicking the button will toggle the state
    } else if (!self.note.published && self.note.publishURL.length == 0) {
        [publishLabel setStringValue:@""];
        [publishButton setTitle:@"Publish to Web Page"];
        publishButton.enabled = YES;
        publishButton.state = NSOffState;// clicking the button will toggle the state
    } else if (!self.note.published && self.note.publishURL.length > 0) {
        [publishLabel setStringValue:@"Unpublishing..."];
        [publishButton setTitle:@"Unpublish"];
        publishButton.enabled = NO;
    }
}

- (void)publishNote
{
    [SPTracker trackEditorNotePublished];
    
    self.note.published = YES;
    [self save];
    [self updatePublishUI];
}

- (void)unpublishNote
{
    [SPTracker trackEditorNoteUnpublished];
    
    self.note.published = NO;
    [self save];
    [self updatePublishUI];
}



#pragma mark - Action Menu and Popovers

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    BOOL isMainWindowVisible = [[SimplenoteAppDelegate sharedDelegate] isMainWindowVisible];

    // Note menu
    if (menuItem == newItem) {
        return !self.viewingTrash;
    }

    if (menuItem == deleteItem || menuItem == printItem) {
        return !self.viewingTrash && self.note != nil && isMainWindowVisible;
    }
    
    return YES;
}

- (BOOL)selectedNotesPinned
{
    for (Note *selectedNote in self.selectedNotes) {
        if (!selectedNote.pinned)
            return NO;
    }

    return YES;
}

- (void)menuWillOpen:(NSMenu *)menu
{
    // Action menu
    NSUInteger numSelectedNotes = [self.selectedNotes count];

    if (self.viewingTrash || numSelectedNotes == 0) {
        [menu cancelTrackingWithoutAnimation];
        return;
    }
    
    [self updateCounts];
    pinnedItem.state = [self selectedNotesPinned] ? NSOnState : NSOffState;
    [collaborateItem setEnabled:numSelectedNotes == 1];
    [publishItem setEnabled:numSelectedNotes == 1];
    [historyItem setEnabled:numSelectedNotes == 1];

    NSString *statusString;
    
    if (numSelectedNotes == 1)
        statusString = [NSString stringWithFormat:@"Modified: %@", [self.note.modificationDate sp_stringBeforeNow]];
    else
        statusString = [NSString stringWithFormat:@"%ld Notes Selected", [self.selectedNotes count]];
    
    [modifiedItem setTitle:statusString];
}

- (void)popoverDidShow:(NSNotification *)notification
{
    if (self.activePopover.contentViewController == self.versionsViewController) {
        // Prepare the UI
        self.viewingVersions = YES;
        versionSlider.maxValue = [self.note.version integerValue];
        versionSlider.minValue = [self minimumNoteVersion];
        versionSlider.numberOfTickMarks = versionSlider.maxValue - versionSlider.minValue + 1;
        [versionSlider setObjectValue:[NSNumber numberWithInteger:versionSlider.maxValue]];
        [self updateVersionLabel:self.note.modificationDate];
        [self.noteEditor setEditable:NO];
        [self.noteEditor setTextColor:[self.theme colorForKey:@"tagViewPlaceholderColor"]];

        // Request the version data from Simperium
        Simperium *simperium = [[SimplenoteAppDelegate sharedDelegate] simperium];
        [[simperium bucketForName:@"Note"] requestVersions:10 key:self.note.simperiumKey];
        
    } else if (self.activePopover.contentViewController == self.publishViewController) {
        NSLog(@"popOverDidShow update publish ui");
        [self updatePublishUI];
    }
}

- (void)popoverWillClose:(NSNotification *)notification
{
    if (self.activePopover.contentViewController == self.versionsViewController) {
        self.viewingVersions = NO;
        
        // Unload versions and re-enable editor
        [self.noteEditor setEditable:YES];
        [self.noteEditor setTextColor:[self.theme colorForKey:@"textColor"]];
        self.noteVersionData = nil;
    }
}



#pragma mark - Actions

- (IBAction)versionSliderChanged:(id)sender
{
    NSInteger versionInt = [versionSlider integerValue]; // can be a float, so get the int
	NSDictionary *versionData = [self.noteVersionData objectForKey:[NSNumber numberWithInteger:versionInt]];
    NSLog(@"Loading version %ld", (long)versionInt);
    
    restoreVersionButton.enabled = [versionSlider integerValue] != versionSlider.maxValue && versionData != nil;
	if (versionData != nil) {
		self.noteEditor.string = (NSString *)[versionData objectForKey:@"content"];
        [self updateEditorFonts];
        [self.noteEditor setTextColor:[self.theme colorForKey:@"tagViewPlaceholderColor"]];

		NSDate *versionDate = [NSDate dateWithTimeIntervalSince1970:[(NSString *)[versionData objectForKey:@"modificationDate"] doubleValue]];
		[self updateVersionLabel:versionDate];
	}
}

- (IBAction)restoreVersionAction:(id)sender
{
    [SPTracker trackEditorNoteRestored];
    
    self.note.content = [self.noteEditor string];
    [self save];
    [self dismissActivePopover];
}

- (IBAction)pinAction:(id)sender
{
    [SPTracker trackEditorNotePinningToggled];
    
    // Toggle the selected notes
    BOOL isPinned = pinnedItem.state == NSOffState;
    
    for (Note *selectedNote in self.selectedNotes) {
        selectedNote.pinned = isPinned;
    }
    
	[self save];
    
    // Update the list
    [notesArrayController rearrangeObjects];
    [noteListViewController selectRowForNoteKey:self.note.simperiumKey];
}

- (IBAction)publishAction:(id)sender
{
    // The button state is toggled when user clicks on it
    if (publishButton.state == NSOnState) {
        [self publishNote];
    } else {
        [self unpublishNote];
    }
}

- (IBAction)addAction:(id)sender
{
    [SPTracker trackEditorNoteCreated];

    [[NSNotificationCenter defaultCenter] postNotificationName:SPWillAddNewNoteNotificationName object:self];
    
    // Save current note first
    self.note.content = self.noteEditor.string;
    [self save];
    
    [notesArrayController setSelectsInsertedObjects:YES];
    
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    [appDelegate ensureMainWindowIsVisible:nil];
    
    Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:appDelegate.simperium.managedObjectContext];
    newNote.modificationDate = [NSDate date];
    newNote.creationDate = [NSDate date];
    
    NSString *currentTag = [appDelegate selectedTagName];
    if ([currentTag length] > 0) {
        [newNote addTag:currentTag];
    }

    [self displayNote:newNote];
    [self save];

    [notesArrayController rearrangeObjects];
    [tableView reloadData];

    // Don't perform selection until the list has refreshed in the next run loop
    [self performSelector:@selector(prepareForNewNote:) withObject:newNote afterDelay:0];
}

- (void)prepareForNewNote:(Note *)newNote
{
    [noteListViewController selectRowForNoteKey:newNote.simperiumKey];
    [tableView scrollRowToVisible:[tableView selectedRow]];
    
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    [appDelegate.window makeFirstResponder:self.noteEditor];
}

- (IBAction)deleteAction:(id)sender
{
    for (Note *noteToDelete in self.selectedNotes) {
        if (noteToDelete.deleted) {
            continue;
        }
        
        [SPTracker trackEditorNoteDeleted];
        [noteListViewController deleteNote:noteToDelete];
    }
}

- (IBAction)restoreAction:(id)sender
{
    self.note.deleted = NO;
    [self save];
    [notesArrayController rearrangeObjects];
    [tableView reloadData];
    [self displayNote:nil];
}

- (IBAction)printAction:(id)sender
{
    // Create a copy of the editor view to be used as the print source
    NSData *archivedView = [NSKeyedArchiver archivedDataWithRootObject:self.noteEditor];
    NSTextView *printView = [NSKeyedUnarchiver unarchiveObjectWithData:archivedView];
    [printView setTextColor:[NSColor blackColor]];

    // Configure wrapping and alignment
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    [printInfo setHorizontalPagination:NSFitPagination];
    [printInfo setVerticallyCentered:NO];

    // Set the view's frame to the size of the page
    printView.frame = CGRectMake(0, 0, printInfo.paperSize.width, printInfo.paperSize.height);

    // Print the sucker
    NSPrintOperation *operation = [NSPrintOperation printOperationWithView:printView];
    [operation setPrintInfo:printInfo];
    [operation runOperation];
}



#pragma mark - Token delegate

- (void)parseTagTokens:(NSArray *)tokens
{
    SimplenoteAppDelegate *appDelegate  = [SimplenoteAppDelegate sharedDelegate];
    SPBucket *tagBucket                 = [appDelegate.simperium bucketForName:@"Tag"];
    Note *note                          = self.note;
    NSString *oldTags                   = note.tags;
    NSArray *oldTagArray                = note.tagsArray;
    
    NSMutableSet *deletedTags           = [NSMutableSet setWithArray:oldTagArray];
    [deletedTags minusSet:[NSSet setWithArray:tokens]];
    
    NSMutableSet *addedTags             = [NSMutableSet setWithArray:tokens];
    [addedTags minusSet:[NSSet setWithArray:oldTagArray]];
    
    // Create any new tags that don't already exist
    for (NSString *token in tokens) {
        NSString *tagKey = [[token lowercaseString] sp_urlEncodeString];
        Tag *tag = [tagBucket objectForKey:tagKey];
        if (!tag && ![token containsEmailAddress]) {
            NSDictionary *userInfo = @{@"tagName":token};
            [[NSNotificationCenter defaultCenter] postNotificationName:SPTagAddedFromEditorNotificationName
                                                                object:self
                                                              userInfo:userInfo];
        }
    }
    
    // Note:
    // If the currently selected tag was removed from the note, switch to 'All Notes', and preserve the current
    // note selection
    if ([deletedTags containsObject:appDelegate.selectedTagName]) {
        [appDelegate selectAllNotesTag];
        [appDelegate selectNoteWithKey:note.simperiumKey];
    }
    
    // Resolve tokens to tags
    [note setTagsFromList:tokens];
    
    if ([self.note.tags isEqualToString:oldTags]) {
        return;
    }
    
    [self save];
    
    // Tracker
    for (NSString *tag in deletedTags) {
        [SPTracker trackEditorTagRemoved:tag.containsEmailAddress];
    }
    
    for (NSString *tag in addedTags) {
        [SPTracker trackEditorTagAdded:tag.containsEmailAddress];
    }
}

- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring
           indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex
{
    // Don't show auto-complete in fullscreen mode
    BOOL fullscreen = ([self.view.window styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask;
    if (fullscreen)
        return [NSArray array];
    
    // Supply an auto-complete list based on substrings
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    SPBucket *tagBucket = [appDelegate.simperium bucketForName:@"Tag"];
    NSArray *tags = [tagBucket allObjects];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:3];

    for (Tag *tag in tags) {
        BOOL tagFound = [tag.name rangeOfString:substring options:NSCaseInsensitiveSearch].location == 0;
        BOOL tagAlreadyAdded = [self.note.tags rangeOfString:substring options:NSCaseInsensitiveSearch].location != NSNotFound;
        if (tagFound && !tagAlreadyAdded) {
            [results addObject:tag.name];
        }
    }
    
    return results;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index
{
    NSString *tagNameToAdd = [tokens objectAtIndex:0];
    if (![self.note hasTag:tagNameToAdd]) {
        [self parseTagTokens:[tokenField objectValue]];
        return tokens;
    }

    return [NSArray array];
}

- (void)tokenFieldDidChange:(NSTokenField *)tokenField
{
    [self parseTagTokens:[tokenField objectValue]];
}


#pragma mark - Fonts

- (NSFont *)noteBodyFont
{
    if (!_noteBodyFont) {
        _noteBodyFont =  [NSFont systemFontOfSize:[self getFontSize]];
    }
    
    return _noteBodyFont;
}

- (NSColor *)noteBodyColor
{
    return [self.theme colorForKey:@"textColor"];
}

- (NSFont *)noteTitleFont
{
    if (!_noteTitleFont) {
        _noteTitleFont =  [NSFont systemFontOfSize:[self getFontSize] + [self getFontSize] * 0.214f];
    }
    
    return _noteTitleFont;
}

- (NSColor *)noteTitleColor
{
    return [self.theme colorForKey:@"noteHeadlineFontColor"];
}

- (NSInteger)getFontSize
{
    NSInteger fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:SPFontSizePreferencesKey];
    if (!fontSize) {
        fontSize = NoteFontSizeNormal;
        [[NSUserDefaults standardUserDefaults] setInteger:fontSize forKey:SPFontSizePreferencesKey];
    }

    return fontSize;
}

- (IBAction)adjustFontSizeAction:(id)sender
{
    [SPTracker trackSettingsFontSizeUpdated];
    
    NSMenuItem *item = (NSMenuItem *)sender;
    NSInteger currentFontSize = [self getFontSize];

    if (item.tag == 0) {
        // Increase font size
        currentFontSize++;
        currentFontSize = MIN(NoteFontSizeMaximum, currentFontSize);
    } else if (item.tag == 2) {
        // Reset to normal size
        currentFontSize = NoteFontSizeNormal;
    } else {
        // Decrease font size
        currentFontSize--;
        currentFontSize = MAX(NoteFontSizeMinimum, currentFontSize);
    }

    // Update font size preference and reset fonts
    [[NSUserDefaults standardUserDefaults] setInteger:currentFontSize forKey:SPFontSizePreferencesKey];
    self.noteBodyFont = nil;
    self.noteTitleFont = nil;
    [self.noteEditor setFont:self.noteBodyFont];
    [self updateEditorFonts];
}

- (void)updateEditorFonts
{
    NSRange firstLineRange = [self.noteEditor.string rangeOfString:@"\n"];
    NSInteger titleLength = (firstLineRange.location != NSNotFound) ? firstLineRange.location : self.noteEditor.string.length;
    
    NSRange titleRange = NSMakeRange(0, titleLength);
    NSRange bodyRange = NSMakeRange(titleRange.length, self.noteEditor.string.length - titleRange.length);

    NSTextStorage *textStorage = self.noteEditor.textStorage;
    
    [textStorage beginEditing];
    
    [textStorage addAttribute:NSForegroundColorAttributeName value:self.noteTitleColor range:titleRange];
    [textStorage addAttribute:NSFontAttributeName value:self.noteTitleFont range:titleRange];
    
    // Restore body font in case newline was entered inside the title
    if (bodyRange.length > 0) {
        [textStorage addAttribute:NSForegroundColorAttributeName value:self.noteBodyColor range:bodyRange];
        [textStorage addAttribute:NSFontAttributeName value:self.noteBodyFont range:bodyRange];
    }

    [textStorage endEditing];
}



#pragma mark - NoteEditor Preferences Helpers

- (void)setNoteEditor:(SPTextView *)theNoteEditor
{
	NSArray *properties =  @[
		// Spelling + Grammar
		NSStringFromSelector(@selector(continuousSpellCheckingEnabled)),
		NSStringFromSelector(@selector(grammarCheckingEnabled)),
		NSStringFromSelector(@selector(automaticSpellingCorrectionEnabled)),
		// Substitutions
		NSStringFromSelector(@selector(smartInsertDeleteEnabled)),
		NSStringFromSelector(@selector(automaticQuoteSubstitutionEnabled)),
		NSStringFromSelector(@selector(automaticLinkDetectionEnabled)),
		NSStringFromSelector(@selector(automaticDashSubstitutionEnabled)),
		NSStringFromSelector(@selector(automaticTextReplacementEnabled))
	];

	for (NSString *property in properties) {
		[self.noteEditor removeObserver:self forKeyPath:property];
	}
	
	for (NSString *property in properties) {
		[theNoteEditor addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew context:nil];
	}
	
	_noteEditor = theNoteEditor;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object != self.noteEditor) {
		return;
	}

	if (keyPath == nil || change[NSKeyValueChangeNewKey] == nil) {
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *preferences = [[defaults objectForKey:SPTextViewPreferencesKey] mutableCopy];
	if (!preferences) {
		preferences = [NSMutableDictionary dictionary];
	}
	
	preferences[keyPath] = change[NSKeyValueChangeNewKey];
	
	[defaults setObject:preferences forKey:SPTextViewPreferencesKey];
	[defaults synchronize];
    
    // Toggle the 'Optimized Linkifier', as needed
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(automaticLinkDetectionEnabled))]) {
        self.textLinkifier.enabled = [change[NSKeyValueChangeNewKey] boolValue];
    }
}

- (NSDictionary *)loadNoteEditorPreferences
{
	NSDictionary *preferences = [[NSUserDefaults standardUserDefaults] objectForKey:SPTextViewPreferencesKey];
	if (!preferences) {
		preferences = @{
			NSStringFromSelector(@selector(automaticQuoteSubstitutionEnabled))	: @(false),
			NSStringFromSelector(@selector(automaticDashSubstitutionEnabled))	: @(false)
		};
		[[NSUserDefaults standardUserDefaults] setObject:preferences forKey:SPTextViewPreferencesKey];
	}
	
	return preferences;
}



#pragma mark - Style Helpers

- (void)applyStyle
{
    [self.noteEditor setInsertionPointColor:[self.theme colorForKey:@"textColor"]];
    [self.noteEditor setTextColor:[self.theme colorForKey:@"textColor"]];

    [self.bottomBar applyStyle];
    [self.bottomBar setNeedsDisplay:YES];
    [self.bottomBar setEnabled:[self.bottomBar isEnabled]];

    [self dismissActivePopover];
}



#pragma mark - NSButton Delegate Methods

- (IBAction)showSharePopover:(id)sender
{
    [SPTracker trackEditorCollaboratorsAccessed];
    [self showViewController:self.shareViewController relativeToView:self.bottomBar preferredEdge:NSMaxYEdge];
    [self.bottomBar.tokenField becomeFirstResponder];
}

- (IBAction)showPublishPopover:(id)sender
{
    NSPopUpButton *actionButton = [[[SimplenoteAppDelegate sharedDelegate] toolbar] actionButton];
    [self showViewController:self.publishViewController relativeToView:actionButton preferredEdge:NSMaxYEdge];
}

- (IBAction)emailNote:(id)sender
{
    if (!self.note || [self.note.content length] == 0) {
        return;
    }

    // Send via mailto: url scheme
    NSString *subject = [self.note.titlePreview stringByUrlEncoding];
    NSString *body = [self.note.content stringByUrlEncoding];
    NSString *mailToUrl = [NSString stringWithFormat:@"mailto:?Subject=%@&body=%@",
                           subject,
                           body];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mailToUrl]];
}

- (IBAction)showVersionPopover:(id)sender
{
    // Dismiss the popover if user clicks revisions button when popover is showing already
    if (self.activePopover != nil && [self.activePopover isShown] &&
            self.activePopover.contentViewController == self.versionsViewController) {
        [self dismissActivePopover];
        return;
    }
    
    [SPTracker trackEditorVersionsAccessed];
    [self showViewController:self.versionsViewController relativeToView:self.noteEditor preferredEdge:NSMinXEdge];
}



#pragma mark - NSPopover Helpers

- (void)showViewController:(NSViewController *)viewController
            relativeToView:(NSView *)view
             preferredEdge:(NSRectEdge)preferredEdge
{
    // If needed, dismiss any active popovers
    [self dismissActivePopover];
    
    // Create a new Popover + Show it
    self.activePopover = [self newPopoverWithContentViewController:viewController];
    [self.activePopover showRelativeToRect:view.bounds ofView:view preferredEdge:preferredEdge];
}

- (void)dismissActivePopover
{
    [self.activePopover close];
    self.activePopover = nil;
}

- (NSPopover *)newPopoverWithContentViewController:(NSViewController *)viewController
{
    BOOL isDarkTheme                = [[[VSThemeManager sharedManager] theme] isDark];
    NSPopoverAppearance appearance  = isDarkTheme ? NSPopoverAppearanceMinimal : NSPopoverAppearanceHUD;
    
    NSPopover *popover              = [[NSPopover alloc] init];
    popover.contentViewController   = viewController;
    popover.delegate                = self;
    popover.appearance              = appearance;
    popover.behavior                = NSPopoverBehaviorTransient;
    
    return popover;
}

@end
