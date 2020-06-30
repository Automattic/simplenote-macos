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
#import "JSONKit+Simplenote.h"
#import "NSString+Metadata.h"
#import "SPConstants.h"
#import "SPMarkdownParser.h"
#import "SPTracker.h"

#import "Simplenote-Swift.h"

@import Simperium_OSX;



#pragma mark ====================================================================================
#pragma mark Notifications
#pragma mark ====================================================================================

NSString * const SPTagAddedFromEditorNotificationName   = @"SPTagAddedFromEditor";
NSString * const SPWillAddNewNoteNotificationName       = @"SPWillAddNewNote";


#pragma mark ====================================================================================
#pragma mark Constants
#pragma mark ====================================================================================

static NSString * const SPTextViewPreferencesKey        = @"kTextViewPreferencesKey";
static NSString * const SPFontSizePreferencesKey        = @"kFontSizePreferencesKey";
static NSString * const SPMarkdownPreferencesKey        = @"kMarkdownPreferencesKey";
static NSInteger const SPVersionSliderMaxVersions       = 30;


#pragma mark ====================================================================================
#pragma mark Private
#pragma mark ====================================================================================

@interface NoteEditorViewController() <NSMenuDelegate,
                                        NSSharingServicePickerDelegate,
                                        NSTextDelegate,
                                        NSTextViewDelegate,
                                        SPBucketDelegate,
                                        VersionsViewControllerDelegate>

@property (nonatomic, strong) MarkdownViewController    *markdownViewController;

@property (nonatomic, strong) NSTimer                   *saveTimer;
@property (nonatomic, strong) NSMutableDictionary       *noteVersionData;
@property (nonatomic, strong) NSMutableDictionary       *noteScrollPositions;
@property (nonatomic,   copy) NSString                  *noteContentBeforeRemoteUpdate;
@property (nonatomic, strong) NSArray                   *selectedNotes;
@property (nonatomic, strong) Storage                   *storage;
@property (nonatomic, strong) TextViewInputHandler      *inputHandler;

@property (nonatomic, assign) NSUInteger                cursorLocationBeforeRemoteUpdate;
@property (nonatomic, assign) BOOL                      viewingVersions;
@property (nonatomic, assign) BOOL                      viewingTrash;

@end


#pragma mark ====================================================================================
#pragma mark NoteEditorViewController
#pragma mark ====================================================================================

@implementation NoteEditorViewController

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
    [super awakeFromNib];

    [self.noteEditor setFrameSize:NSMakeSize(self.noteEditor.frame.size.width-kMinEditorPadding/2, self.noteEditor.frame.size.height-kMinEditorPadding/2)];
    self.storage = [Storage new];
    [self.noteEditor.layoutManager replaceTextStorage:self.storage];
    [self.noteEditor.layoutManager setDefaultAttachmentScaling:NSImageScaleProportionallyDown];
    
    // Set hyperlinks to be the same color as the app's highlight color
    [self.noteEditor setLinkTextAttributes: @{
       NSForegroundColorAttributeName: [NSColor simplenoteLinkColor],
        NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle],
                NSCursorAttributeName: [NSCursor pointingHandCursor]
     }];

	// Restore last session's  preferences
	NSDictionary *preferences = [self loadNoteEditorPreferences];
	for (NSString *key in preferences.allKeys) {
		[self.noteEditor setValue:preferences[key] forKey:key];
	}

    // Interface Initialization
    [self setupScrollView];
    [self setupTopDivider];
    [self setupStatusImageView];
    [self setupTagsField];

    // Preload Markdown Preview
    self.markdownViewController = [MarkdownViewController new];
    [self.markdownViewController preloadView];

    // Realtime Markdown Support
    self.inputHandler = [TextViewInputHandler new];
    
    int lineLengthPosition = [[NSUserDefaults standardUserDefaults] boolForKey:kEditorWidthPreferencesKey] ? 1 : 0;
    [self updateLineLengthMenuForPosition:lineLengthPosition];

    self.noteScrollPositions = [[NSMutableDictionary alloc] init];
    
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(trashDidLoad:) name:TagListDidBeginViewingTrashNotification object:nil];
    [nc addObserver:self selector:@selector(tagsDidLoad:) name:TagListDidBeginViewingTagNotification object:nil];
    [nc addObserver:self selector:@selector(tagUpdated:) name:TagListDidUpdateTagNotification object:nil];
    [nc addObserver:self selector:@selector(simperiumWillSave:) name:SimperiumWillSaveNotification object:nil];

    [self startListeningToScrollNotifications];

    [self applyStyle];
}

// TODO: Work in Progress. Decouple with a delegate please
//
- (NoteListViewController *)noteListViewController
{
    return [[SimplenoteAppDelegate sharedDelegate] noteListViewController];
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
    [self.note createPreview];
    
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

- (void)displayNote:(Note *)selectedNote
{
    [self save];
    [self showStatusText:nil];
    [self.statusImageView setHidden: selectedNote != nil];
    
    if (self.isDisplayingMarkdown) {
        [self toggleMarkdownView:nil];
    }

    if (selectedNote == nil) {
        self.note = nil;
        self.selectedNotes = @[];
        [self refreshToolbarActions];
        [self refreshEditorActions];
        [self refreshTagsField];
        [self.noteEditor displayNoteWithContent:@""];

        return;
    }

    if ([self.note.simperiumKey isEqualToString:selectedNote.simperiumKey]) {
        return;
    }

    // Issue #393: `self.note` might be populated, but it's simperiumKey inaccessible
    NSString *simperiumKey = self.note.simperiumKey;
    if (simperiumKey != nil) {
        // Save the scrollPosition of the current note
        NSValue *positionValue = [NSValue valueWithPoint:self.scrollView.contentView.bounds.origin];
        self.noteScrollPositions[simperiumKey] = positionValue;
    }
    
    // Issue #291:
    // Flipping the editable flag effectively "Commits" the last character being edited (Korean Keyboard)
    self.noteEditor.editable = false;
    self.noteEditor.editable = !self.viewingTrash;
    
    self.noteEditor.selectable = !self.viewingTrash;

    self.note = selectedNote;
    self.selectedNotes = [NSArray arrayWithObject:self.note];
    
    [self refreshToolbarActions];
    [self refreshTagsField];

    if (selectedNote.content != nil) {
        // Force selection to start; not doing this can cause an NSTextStorage exception when
        // switching away from long notes (> 5000 characters)
        [self.noteEditor setSelectedRange:NSMakeRange(0, 0)];
        [self.noteEditor displayNoteWithContent:self.note.content];
    } else {
        [self.noteEditor displayNoteWithContent:@""];
    }

    [self.storage refreshStyleWithMarkdownEnabled:self.note.markdown];
    
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
}

- (void)displayNotes:(NSArray *)notes
{
    self.note = nil;
    self.selectedNotes = notes;
    [self.noteEditor displayNoteWithContent:@""];

    [self refreshToolbarActions];
    [self refreshEditorActions];
    [self refreshTagsField];

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

        // Issue #472: Linkification should not be undoable
        [self.noteEditor.undoManager disableUndoRegistration];
        [self.noteEditor checkTextInDocument:nil];
        [self.noteEditor.undoManager enableUndoRegistration];

        [self.noteEditor setNeedsDisplay:YES];
        [self.noteEditor setDelegate:self];
    });
}

- (void)showStatusText:(NSString *)text
{
    BOOL shouldHideImage = text == nil || text.length == 0;

    self.statusTextField.stringValue = text ?: @"";
    self.statusImageView.hidden = shouldHideImage;
}

- (void)trashDidLoad:(NSNotification *)notification
{
    self.viewingTrash = YES;
    [self refreshEditorActions];
    [self refreshToolbarActions];
    [self refreshTagsFieldActions];
}

- (void)tagsDidLoad:(NSNotification *)notification
{
    self.viewingTrash = NO;
    [self refreshEditorActions];
    [self refreshToolbarActions];
    [self refreshTagsFieldActions];
}

- (void)tagUpdated:(NSNotification *)notification
{
    [self refreshTagsField];
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

- (void)updateVersionLabel:(NSDate *)versionDate
{
    NSString *text = [NSString stringWithFormat:@"  %@: %@",
                      NSLocalizedString(@"Version", @"Label for the current version of a note"),
                      [self.note getDateString:versionDate brief:NO]];

    self.versionsViewController.versionText = text;
}

- (void)updateVersionSlider
{
    NSInteger maximum = [self.note.version integerValue];
    NSInteger minimum = [self minimumNoteVersion];

    [self.versionsViewController refreshSliderWithMax:maximum min:minimum];
}



#pragma mark - Text Delegates

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)selector
{
    if (selector == @selector(insertNewline:)) {
        return [self.noteEditor processNewlineInsertion];
    }

    if (selector == @selector(insertTab:)) {
        return [self.noteEditor processTabInsertion];
    }
    
    return NO;
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    return [self.inputHandler textView:textView shouldChangeTextInRange:affectedCharRange string:replacementString];
}

- (void)textDidChange:(NSNotification *)notification
{
    self.note.content = [self.noteEditor plainTextContent];
    [self.note createPreview];
    
    [self refreshToolbarActions];
    
    [self.saveTimer invalidate];
    self.saveTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(saveAndSync:) userInfo:nil repeats:NO];
    
    // Update the note list preview
    [self.noteListViewController reloadRowForNoteKey:self.note.simperiumKey];
}


#pragma mark - Simperium

- (void)didReceiveNewContent
{
    NSUInteger newLocation = [self newCursorLocation:self.note.content
                                             oldText:self.noteContentBeforeRemoteUpdate
                                     currentLocation:self.cursorLocationBeforeRemoteUpdate];

    [self.noteEditor displayNoteWithContent:self.note.content];
    self.noteEditor.selectedRange = NSMakeRange(newLocation, 0);
    [self refreshTagsField];
}

- (void)willReceiveNewContent
{
    self.cursorLocationBeforeRemoteUpdate = [self.noteEditor selectedRange].location;
    self.noteContentBeforeRemoteUpdate = self.noteEditor.string;
    
    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
	
    if (self.note != nil && ![self.noteEditor.string isEqualToString:@""]) {
        self.note.content = [self.noteEditor plainTextContent];
        [appDelegate.simperium saveWithoutSyncing];
    }
}

- (void)didReceiveVersion:(NSString *)version data:(NSDictionary *)data
{
    if (self.viewingVersions) {
        if (self.noteVersionData == nil) {
            self.noteVersionData = [NSMutableDictionary dictionaryWithCapacity:SPVersionSliderMaxVersions];
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

    pinnedItem.state = [self selectedNotesPinned] ? NSOnState : NSOffState;
    markdownItem.state = [self selectedNotesMarkdowned] ? NSOnState : NSOffState;
    [collaborateItem setEnabled:numSelectedNotes == 1];
}

- (void)popoverDidShow:(NSNotification *)notification
{
    if (self.activePopover.contentViewController == self.versionsViewController) {
        // Prepare the UI
        self.viewingVersions = YES;
        [self updateVersionSlider];
        [self updateVersionLabel:self.note.modificationDate];
        [self.noteEditor setEditable:NO];

        // Request the version data from Simperium
        Simperium *simperium = [[SimplenoteAppDelegate sharedDelegate] simperium];
        [[simperium bucketForName:@"Note"] requestVersions:SPVersionSliderMaxVersions key:self.note.simperiumKey];   
    }
}

- (void)popoverWillClose:(NSNotification *)notification
{
    if (self.activePopover.contentViewController == self.versionsViewController) {
        self.viewingVersions = NO;
        
        // Unload versions and re-enable editor
        [self.noteEditor setEditable:YES];
        self.noteVersionData = nil;
        
        // Refreshes the note content in the editor, in case the popover was canceled
        [self didReceiveNewContent];
    }
}


#pragma mark - VersionsViewController Delegate

- (void)versionsController:(VersionsViewController *)sender updatedSlider:(NSInteger)newValue
{
    NSDictionary *versionData = [self.noteVersionData objectForKey:@(newValue)];
    NSLog(@"Loading version %ld", (long)newValue);

    self.versionsViewController.restoreActionEnabled = newValue != sender.maxSliderValue && versionData != nil;

	if (versionData != nil) {
        NSString *content = (NSString *)[versionData objectForKey:@"content"];
        [self.noteEditor displayNoteWithContent:content];

		NSDate *versionDate = [NSDate dateWithTimeIntervalSince1970:[(NSString *)[versionData objectForKey:@"modificationDate"] doubleValue]];
		[self updateVersionLabel:versionDate];
	}
}

- (void)versionsControllerDidClickRestore:(VersionsViewController *)sender
{
    [SPTracker trackEditorNoteRestored];
    
    self.note.content = [self.noteEditor plainTextContent];
    [self save];
    [self dismissActivePopover];
}


#pragma mark - Actions

- (IBAction)moreWasPressed:(id)sender
{
    NSButton *infoButton = (NSButton *)sender;
    NSRect infoFrame = infoButton.frame;
    NSPoint origin = NSMakePoint(CGRectGetMidX(infoFrame), CGRectGetMinY(infoFrame));

    [self.moreActionsMenu popUpMenuPositioningItem:nil atLocation:origin inView:infoButton.superview];
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
    [self.noteListViewController selectRowForNoteKey:self.note.simperiumKey];
}

- (IBAction)markdownAction:(id)sender
{
    // Toggle the markdown state
    BOOL isEnabled = markdownItem.state == NSOffState;

    for (Note *selectedNote in self.selectedNotes) {
        selectedNote.markdown = isEnabled;
    }

    // Switch back to the editor if markdown is disabled
    if (!isEnabled && self.isDisplayingMarkdown) {
        [self toggleMarkdownView:nil];
    }

    [self refreshToolbarActions];
    [self save];
    
    // Update editor to apply markdown styles
    [self.storage refreshStyleWithMarkdownEnabled:self.note.markdown];
    [self checkTextInDocument];
    
    [[NSUserDefaults standardUserDefaults] setBool:(BOOL)isEnabled forKey:SPMarkdownPreferencesKey];
}

- (IBAction)addAction:(id)sender
{
    [SPTracker trackEditorNoteCreated];

    [[NSNotificationCenter defaultCenter] postNotificationName:SPWillAddNewNoteNotificationName object:self];
    
    // Save current note first
    self.note.content = [self.noteEditor plainTextContent];
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
    [self.noteListViewController selectRowForNoteKey:newNote.simperiumKey];
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
        [self.noteListViewController deleteNote:noteToDelete];
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



#pragma mark - TagsField Helpers

- (void)updateTagsWithTokens:(NSArray<NSString *> *)tokens
{
    SimplenoteAppDelegate *appDelegate  = [SimplenoteAppDelegate sharedDelegate];
    Simperium *simperium                = appDelegate.simperium;
    Note *note                          = self.note;
    NSString *oldTags                   = note.tags;

    // Create any new tags that don't already exist
    for (NSString *token in tokens) {
        Tag *tag = [simperium searchTagWithName:token];
        if (!tag && ![token containsEmailAddress]) {
            NSDictionary *userInfo = @{@"tagName":token};
            [[NSNotificationCenter defaultCenter] postNotificationName:SPTagAddedFromEditorNotificationName
                                                                object:self
                                                              userInfo:userInfo];
        }
    }

    // Update Tags: Internally they're JSON Encoded!
    [note setTagsFromList:tokens];

    // Ensure the right Tag remains selected
    if ([note hasTag:appDelegate.selectedTagName] == false) {
        [appDelegate selectAllNotesTag];
        [appDelegate selectNoteWithKey:note.simperiumKey];
    }
    
    if ([self.note.tags isEqualToString:oldTags]) {
        return;
    }
    
    [self save];
}


#pragma mark - Fonts

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
        [self.storage refreshStyleWithMarkdownEnabled:self.note.markdown];
    }

    self.backgroundView.fillColor       = [NSColor simplenoteBackgroundColor];
    self.topDividerView.borderColor     = [NSColor simplenoteDividerColor];
    self.bottomDividerView.borderColor  = [NSColor simplenoteDividerColor];
    self.statusTextField.textColor      = [NSColor simplenoteSecondaryTextColor];
    self.noteEditor.insertionPointColor = [NSColor simplenoteTextColor];
    self.noteEditor.textColor           = [NSColor simplenoteTextColor];
    self.tagsField.textColor            = [NSColor simplenoteTextColor];
    self.tagsField.placeholderTextColor = [NSColor simplenoteSecondaryTextColor];
}

// Reprocesses note checklists after switching themes, so they apply the correct color
- (void)fixChecklistColoring
{
    NSString *content = [self.noteEditor plainTextContent];
    [self.noteEditor displayNoteWithContent:content];
}


#pragma mark - NSButton Delegate Methods

- (IBAction)showVersionPopover:(id)sender
{
    // Dismiss the popover if user clicks revisions button when popover is showing already
    if (self.activePopover != nil && [self.activePopover isShown] &&
            self.activePopover.contentViewController == self.versionsViewController) {
        [self dismissActivePopover];
        return;
    }
    
    [SPTracker trackEditorVersionsAccessed];

    VersionsViewController *viewController = [VersionsViewController new];
    viewController.delegate = self;

    [self showViewController:viewController relativeToView:self.toolbarView.historyButton preferredEdge:NSMaxYEdge];
    self.versionsViewController = viewController;
}

- (IBAction)shareNote:(id)sender
{
    if (!self.note.content) {
        return;
    }

    NSButton *sourceButton = self.toolbarView.shareButton;
    NSMutableArray *noteShareItem = [NSMutableArray arrayWithObject:self.note.content];

    NSSharingServicePicker *sharingPicker = [[NSSharingServicePicker alloc] initWithItems:noteShareItem];
    sharingPicker.delegate = self;
    [sharingPicker showRelativeToRect:sourceButton.bounds ofView:sourceButton preferredEdge:NSMinYEdge];
}

- (IBAction)toggleMarkdownView:(id)sender
{
    if (self.isDisplayingMarkdown) {
        [self dismissMarkdownPreview];
    } else {
        [self displayMarkdownPreview:self.note.content];
    }

    [self refreshEditorActions];
    [self refreshToolbarActions];
}

- (IBAction)toggleEditorWidth:(id)sender
{
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

- (void)insertChecklistAction:(id)sender
{
    [self.noteEditor toggleListMarkersAtSelectedRange];
    [SPTracker trackEditorChecklistInserted];
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
        NSImage *image = [NSImage imageNamed:@"icon_simplenote"];
        NSString *title = NSLocalizedString(@"Publish to Web", @"Publish to Web Service");
        NSSharingService *customService = [[NSSharingService alloc] initWithTitle:title image:image alternateImage:nil handler:^{
            [self publishWasPressed];
        }];
        
        services = [services arrayByAddingObject:customService];
    }
    
    return services;
}

@end
