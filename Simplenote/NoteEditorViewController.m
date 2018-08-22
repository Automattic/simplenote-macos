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
#import "SPConstants.h"
#import "SPMarkdownParser.h"
#import "SPToolbarView.h"
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"
#import "SPTracker.h"

#import "Simplenote-Swift.h"

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
static NSString * const SPMarkdownPreferencesKey        = @"kMarkdownPreferencesKey";
static NSInteger const SPVersionSliderMaxVersions       = 10;


#pragma mark ====================================================================================
#pragma mark Private
#pragma mark ====================================================================================

@interface NoteEditorViewController() <NSTextDelegate, NSTextViewDelegate, NSPopoverDelegate,
                                       NSTokenFieldDelegate, SPBucketDelegate, NSMenuDelegate>

@property (nonatomic, strong) NSTimer               *saveTimer;
@property (nonatomic, strong) NSMutableDictionary   *noteVersionData;
@property (nonatomic, strong) NSMutableDictionary   *noteScrollPositions;
@property (nonatomic,   copy) NSString              *noteContentBeforeRemoteUpdate;
@property (nonatomic, strong) NSArray               *selectedNotes;
@property (nonatomic, strong) NSPopover             *activePopover;
@property (nonatomic, strong) Storage               *storage;

@property (nonatomic, assign) NSUInteger            cursorLocationBeforeRemoteUpdate;
@property (nonatomic, assign) BOOL                  viewingVersions;
@property (nonatomic, assign) BOOL                  viewingTrash;

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
    
    return self;
}

- (void)awakeFromNib
{
    [self.noteEditor setFrameSize:NSMakeSize(self.noteEditor.frame.size.width-kMinEditorPadding/2, self.noteEditor.frame.size.height-kMinEditorPadding/2)];
    self.storage = [Storage newInstance];
    [self.noteEditor.layoutManager replaceTextStorage:self.storage];
    
    // Set hyperlinks to be the same color as the app's highlight color
    [self.noteEditor setLinkTextAttributes: @{
       NSForegroundColorAttributeName: [self.theme colorForKey:@"tintColor"],
        NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle],
                NSCursorAttributeName: [NSCursor pointingHandCursor]
     }];

	// Restore last session's  preferences
	NSDictionary *preferences = [self loadNoteEditorPreferences];
	for (NSString *key in preferences.allKeys) {
		[self.noteEditor setValue:preferences[key] forKey:key];
	}
    
    int lineLengthPosition = [[NSUserDefaults standardUserDefaults] boolForKey:kEditorWidthPreferencesKey] ? 1 : 0;
    [self updateLineLengthMenuForPosition:lineLengthPosition];
    
    tagTokenField = [self.bottomBar addTagField];
    tagTokenField.delegate = self;
    self.noteScrollPositions = [[NSMutableDictionary alloc] init];
    
    [noNoteText setFont:[NSFont systemFontOfSize:20.0]];

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(trashDidLoad:) name:kDidBeginViewingTrash object:nil];
    [nc addObserver:self selector:@selector(tagsDidLoad:) name:kTagsDidLoad object:nil];
    [nc addObserver:self selector:@selector(tagUpdated:) name:kTagUpdated object:nil];
    [nc addObserver:self selector:@selector(simperiumWillSave:) name:SimperiumWillSaveNotification object:nil];
    
    [self applyStyle];
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
    
    if (!self.markdownView.isHidden) {
        [self toggleMarkdownView:nil];
    }
    
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
    
    // Save the scrollPosition of the current note
    if (self.note != nil) {
        NSValue *positionValue = [NSValue valueWithPoint:[[self.scrollView contentView] bounds].origin];
        self.noteScrollPositions[self.note.simperiumKey] = positionValue;
    }
    
    // Issue #291:
    // Flipping the editable flag effectively "Commits" the last character being edited (Korean Keyboard)
    self.noteEditor.editable    = false;
    self.noteEditor.editable    = !self.viewingTrash;
    
    self.noteEditor.selectable  = !self.viewingTrash;
    
    tagTokenField.editable      = !self.viewingTrash;
    tagTokenField.selectable    = !self.viewingTrash;
    self.bottomBar.enabled      = !self.viewingTrash;

    self.note                   = selectedNote;
    self.selectedNotes          = [NSArray arrayWithObject:self.note];
    
    [self updateTagField];
    [self updateShareButtonVisibility];
    [previewButton setEnabled:YES];
    [historyButton setEnabled:YES];

    if (selectedNote.content != nil) {
        // Force selection to start; not doing this can cause an NSTextStorage exception when
        // switching away from long notes (> 5000 characters)
        [self.noteEditor setSelectedRange:NSMakeRange(0, 0)];
        self.noteEditor.string = self.note.content;
    } else {
        self.noteEditor.string = @"";
    }
    
    [previewButton setHidden:!self.note.markdown || self.viewingTrash];
    [self.storage applyStyleWithMarkdownEnabled:self.note.markdown];
    
    if ([self.noteScrollPositions objectForKey:selectedNote.simperiumKey] != nil) {
        // Restore scroll position for note if it was saved previously in this session
        double scrollDelay = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, scrollDelay * NSEC_PER_SEC);
        // #hack! Scroll after a very slight delay, to give the editor time to load the content
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            NSPoint scrollPoint = [[self.noteScrollPositions objectForKey:selectedNote.simperiumKey] pointValue];
            [[self.scrollView documentView] scrollPoint:scrollPoint];
        });
    } else {
        // Otherwise we'll scroll to the top!
        [[self.scrollView documentView] scrollPoint:NSMakePoint(0, 0)];
    }
    
    [self checkTextInDocument];
    
    if (selectedNote.markdown) {
        // Reset markdown preview content
        NSString *html = [SPMarkdownParser renderHTMLFromMarkdownString:@""];
        [self.markdownView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
    }
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
    [shareButton setEnabled:NO];
    [previewButton setEnabled:NO];
    [historyButton setEnabled:NO];
    
    NSString *status = [NSString stringWithFormat:@"%ld notes selected", [self.selectedNotes count]];
    [self showStatusText:status];
}

// Linkifies text in the editor
- (void)checkTextInDocument
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        // Temporarily remove the editor delegate because `checkTextInDocument`
        // fires `textDidChange` which will erroneously modify the note's modification
        // date and unintentionally change the sort order of the note in the list as a result
        [self.noteEditor setDelegate:nil];
        [self.noteEditor checkTextInDocument:nil];
        [self.noteEditor setNeedsDisplay:YES];
        [self.noteEditor setDelegate:self];
    });
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
    [previewButton setHidden:YES];
    [self.bottomBar setEnabled:NO];
}

- (void)tagsDidLoad:(NSNotification *)notification
{
    self.viewingTrash = NO;
    [self.bottomBar setEnabled:YES];
}

- (void)tagUpdated:(NSNotification *)notification
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
    // Apply Autobullets if needed
    BOOL appliedAutoBullets = [self.noteEditor applyAutoBulletsWithReplacementText:text replacementRange:range];

    return !appliedAutoBullets;
}

- (void)textDidChange:(NSNotification *)notification
{
    self.note.content = self.noteEditor.string;
    
    [self updateShareButtonVisibility];
    
    [self.saveTimer invalidate];
    self.saveTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(saveAndSync:) userInfo:nil repeats:NO];
    
    // Update the note list preview
    [noteListViewController reloadRowForNoteKey:self.note.simperiumKey];
}

-(void)updateShareButtonVisibility
{
    [shareButton setEnabled:self.note.content.length > 0];
}

#pragma mark - Simperium

- (void)didReceiveNewContent
{
    NSUInteger newLocation = [self newCursorLocation:self.note.content
                                             oldText:self.noteContentBeforeRemoteUpdate
                                     currentLocation:self.cursorLocationBeforeRemoteUpdate];

    self.noteEditor.string = self.note.content;
    
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

- (BOOL)selectedNotesMarkdowned
{
    for (Note *selectedNote in self.selectedNotes) {
        if (!selectedNote.markdown)
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
    markdownItem.state = [self selectedNotesMarkdowned] ? NSOnState : NSOffState;
    [collaborateItem setEnabled:numSelectedNotes == 1];

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

- (IBAction)markdownAction:(id)sender
{
    // Toggle the markdown state
    BOOL isEnabled = markdownItem.state == NSOffState;
    [previewButton setHidden:!isEnabled];
    
    for (Note *selectedNote in self.selectedNotes) {
        selectedNote.markdown = isEnabled;
    }
    
    // Switch back to the editor if markdown is disabled
    if (!isEnabled && ![self.markdownView isHidden]) {
        [self toggleMarkdownView:nil];
    }
    
    [self save];
    
    // Update editor to apply markdown styles
    [self.storage applyStyleWithMarkdownEnabled:self.note.markdown];
    [self checkTextInDocument];
    
    [[NSUserDefaults standardUserDefaults] setBool:(BOOL)isEnabled forKey:SPMarkdownPreferencesKey];
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
    newNote.markdown = [[NSUserDefaults standardUserDefaults] boolForKey:SPMarkdownPreferencesKey];
    
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
    NSTextView *printView = [[NSTextView alloc] init];
    [printView.textStorage appendAttributedString:self.noteEditor.attributedString];
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
- (NSColor *)noteBodyColor
{
    return [self.theme colorForKey:@"textColor"];
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
    [self applyStyle];
    [self checkTextInDocument];
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
    if (self.note != nil) {
        [self.storage applyStyleWithMarkdownEnabled:self.note.markdown];
        if (!self.markdownView.hidden) {
            [self loadMarkdownContent];
        }
    }
    [self.noteEditor setInsertionPointColor:[self.theme colorForKey:@"textColor"]];
    [self.noteEditor setTextColor:[self.theme colorForKey:@"textColor"]];

    [self.bottomBar applyStyle];
    [self.bottomBar setNeedsDisplay:YES];
    [self.bottomBar setEnabled:[self.bottomBar isEnabled]];

    [self dismissActivePopover];
}

- (void)showPublishPopover
{
    [self showViewController:self.publishViewController relativeToView:shareButton preferredEdge:NSMaxYEdge];
}

#pragma mark - NSButton Delegate Methods

- (IBAction)showSharePopover:(id)sender
{
    [SPTracker trackEditorCollaboratorsAccessed];
    [self showViewController:self.shareViewController relativeToView:self.bottomBar preferredEdge:NSMaxYEdge];
    [self.bottomBar.tokenField becomeFirstResponder];
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

- (IBAction)shareNote:(id)sender
{
    if (!self.note.content) {
        return;
    }
    NSMutableArray *noteShareItem = [NSMutableArray arrayWithObject:self.note.content];
    NSSharingServicePicker *sharingPicker = [[NSSharingServicePicker alloc] initWithItems:noteShareItem];
    sharingPicker.delegate = self;
    [sharingPicker showRelativeToRect:shareButton.bounds ofView:shareButton preferredEdge:NSMinYEdge];
}

- (IBAction)toggleMarkdownView:(id)sender
{
    if (self.markdownView == nil) {
        return;
    }
    
    BOOL markdownVisible = self.markdownView.hidden;
    
    [self.editorScrollView setHidden:markdownVisible];
    [self.noteEditor setSelectable:!markdownVisible];
    [self.noteEditor setEditable:!markdownVisible];
    [self.noteEditor setHidden:markdownVisible];
    [self.markdownView setHidden:!markdownVisible];
    
    [previewButton setImage:[NSImage imageNamed:markdownVisible ? @"icon_preview_stop" : @"icon_preview"]];
    [historyButton setEnabled:!markdownVisible];
    
    if (markdownVisible) {
        [self loadMarkdownContent];
    }
}

- (IBAction)toggleEditorWidth:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    if (item.state == NSOnState) {
        return;
    }
    
    [self updateLineLengthMenuForPosition:item.tag];
    [self.noteEditor setNeedsDisplay:YES];
}

- (void)updateLineLengthMenuForPosition:(NSInteger)position
{
    for (NSMenuItem *menuItem in lineLengthMenu.itemArray) {
        if (menuItem.tag == position) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:position == 1 forKey:kEditorWidthPreferencesKey];
}

- (void)loadMarkdownContent {
    NSString *html = [SPMarkdownParser renderHTMLFromMarkdownString:self.note.content];
    [self.markdownView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
}

#pragma mark - NSSharingServicePicker delegate

- (NSArray *)sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker sharingServicesForItems:(NSArray *)items proposedSharingServices:(NSArray *)proposedServices
{
    // Add Simplenote publish to web option to the sharing services drop down
    NSArray *services = proposedServices;
    NSString *firstString;
    for (id item in items) {
        if ([item isKindOfClass:[NSString class]]) {
            firstString = item;
            break;
        }
        if ([item isKindOfClass:[NSAttributedString class]]) {
            firstString = [(NSAttributedString *)item string];
            break;
        }
    }
    
    if (firstString) {
        NSSharingService *customService = [[NSSharingService alloc] initWithTitle:@"Publish to Web" image:[NSImage imageNamed:@"share_icon"] alternateImage:nil handler:^{
            [self showPublishPopover];
        }];
        
        services = [services arrayByAddingObject:customService];
    }
    
    return services;
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
    NSAppearanceName appearanceName = isDarkTheme ? NSAppearanceNameVibrantLight : NSAppearanceNameVibrantDark;

    NSPopover *popover              = [[NSPopover alloc] init];
    popover.contentViewController   = viewController;
    popover.delegate                = self;
    popover.appearance              = [NSAppearance appearanceNamed:appearanceName];
    popover.behavior                = NSPopoverBehaviorTransient;
    
    return popover;
}

- (BOOL)urlSchemeIsAllowed: (NSString *) scheme {
    return [scheme isEqualToString:@"http"] ||
        [scheme isEqualToString:@"https"] ||
        [scheme isEqualToString:@"mailto"];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSURL *linkUrl = navigationAction.request.URL;
        if ([self urlSchemeIsAllowed:linkUrl.scheme]) {
            [[NSWorkspace sharedWorkspace] openURL:linkUrl];
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
