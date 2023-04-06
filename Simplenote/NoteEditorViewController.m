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
#import "TagListViewController.h"
#import "JSONKit+Simplenote.h"
#import "NSString+Metadata.h"
#import "SPConstants.h"
#import "SPMarkdownParser.h"
#import "SPTracker.h"

#import "Simplenote-Swift.h"

@import Simperium_OSX;



#pragma mark - Constants

static NSString * const SPTextViewPreferencesKey        = @"kTextViewPreferencesKey";
static NSString * const SPMarkdownPreferencesKey        = @"kMarkdownPreferencesKey";



#pragma mark - Private

@interface NoteEditorViewController() <NSMenuDelegate,
                                        NSTextDelegate,
                                        NSTextViewDelegate,
                                        SPBucketDelegate>

@property (nonatomic, strong) MarkdownViewController    *markdownViewController;

@property (nonatomic, strong) NSTimer                   *saveTimer;
@property (nonatomic, strong) NSArray                   *selectedNotes;
@property (nonatomic, strong) Storage                   *storage;
@property (nonatomic, strong) TextViewInputHandler      *inputHandler;

@end



#pragma mark - NoteEditorViewController

@implementation NoteEditorViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopObservingEditorProperties:self.noteEditor];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.selectedNotes = @[];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    [self setupStatusImageView];
    [self setupTagsField];
    [self setupTagsView];

    // Interlinks
    [self setupInterlinksProcessor];

    // Preload Markdown Preview
    self.markdownViewController = [MarkdownViewController new];
    [self.markdownViewController preloadView];

    // Realtime Markdown Support
    self.inputHandler = [TextViewInputHandler new];

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(simperiumWillSave:) name:SimperiumWillSaveNotification object:nil];
    [nc addObserver:self selector:@selector(displayModeWasUpdated:) name:EditorDisplayModeDidChangeNotification object:nil];
    [nc addObserver:self selector:@selector(statusbarWasUpdated:) name:StatusBarDisplayModeDidChangeNotification object:nil];
    [nc addObserver:self selector:@selector(refreshStyle) name:FontSizeDidChangeNotification object:nil];

    [self startListeningToScrollNotifications];
    [self startListeningToWindowNotifications];

    [self refreshStyle];
    [self refreshInterface];
    [self refreshBottomInsets];
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    [self refreshScrollInsets];
    [self refreshHeaderState];
    [self refreshTextContainer];
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
        [self toggleMarkdownView:self];
    }

    if (selectedNote == nil) {
        self.note = nil;
        self.selectedNotes = @[];

        [self refreshInterface];

        return;
    }

    if ([self.note.simperiumKey isEqualToString:selectedNote.simperiumKey]) {
        return;
    }

    [self saveScrollPositionAndCursorLocation];

    // Issue #291:
    // Flipping the editable flag effectively "Commits" the last character being edited (Korean Keyboard)
    self.noteEditor.editable = false;
    self.noteEditor.editable = !self.viewingTrash;
    
    self.noteEditor.selectable = !self.viewingTrash;

    self.note = selectedNote;
    self.selectedNotes = [NSArray arrayWithObject:self.note];
    
    [self refreshToolbarActions];
    [self refreshTagsField];
    [self resetTagsFieldScrollOffset];

    if (selectedNote.content != nil) {
        // Force selection to start; not doing this can cause an NSTextStorage exception when
        // switching away from long notes (> 5000 characters)
        [self.noteEditor setSelectedRange:NSMakeRange(0, 0)];
        [self displayContent:self.note.content];
    } else {
        [self displayContent:nil];
    }

    [self.storage refreshStyleWithMarkdownEnabled:self.note.markdown];

    [self restoreScrollPosition];
    [self restoreCursorLocation];
}

- (void)displayNotes:(NSArray *)notes
{
    self.note = nil;
    self.selectedNotes = notes;
    [self displayContent:nil];

    [self refreshToolbarActions];
    [self refreshEditorActions];
    [self refreshTagsField];

    NSString *status = [NSString stringWithFormat:@"%ld notes selected", [self.selectedNotes count]];
    [self showStatusText:status];
}

- (void)showStatusText:(NSString *)text
{
    BOOL shouldHideImage = text == nil || text.length == 0;

    self.statusTextField.stringValue = text ?: @"";
    self.statusImageView.hidden = shouldHideImage;
}

- (void)simperiumWillSave:(NSNotification *)notification
{
	[self save];
}

- (void)displayModeWasUpdated:(NSNotification *)notification
{
    self.view.needsLayout = YES;
}

- (void)statusbarWasUpdated:(NSNotification *)notification
{
    [self refreshBottomInsets];
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
    
    if (selector == @selector(insertBacktab:)) {
        return [self.noteEditor processTabDeletion];
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

    [self.interlinkProcessor processInterlinkLookupExcludingEntityID: self.note.objectID];
    
    [self.saveTimer invalidate];
    self.saveTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(saveAndSync:) userInfo:nil repeats:NO];

    [self.editorDelegate editorController:self updatedNoteContents:self.note];
}

- (void)textViewDidChangeSelection:(NSNotification *)notification
{
    [self.interlinkProcessor dismissInterlinkLookupIfNeeded];
}


#pragma mark - Simperium

- (void)didReceiveNewContent
{
    [self displayContent:self.note.content];
    [self restoreCursorLocation];
    [self refreshTagsField];
}

- (void)willReceiveNewContent
{
    [self saveScrollPositionAndCursorLocation];

    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
	
    if (self.note != nil && ![self.noteEditor.string isEqualToString:@""]) {
        self.note.content = [self.noteEditor plainTextContent];
        [appDelegate.simperium saveWithoutSyncing];
    }
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
    if (![sender isKindOfClass:[NSMenuItem class]]) {
        return;
    }

    [SPTracker trackEditorNotePinningToggled];

    // Toggle the selected notes
    NSMenuItem *pinnedItem = (NSMenuItem *)sender;
    BOOL isPinned = pinnedItem.state == NSControlStateValueOff;
    
    for (Note *selectedNote in self.selectedNotes) {
        selectedNote.pinned = isPinned;
    }
    
	[self save];
    
    // Update the list
    [self.noteActionsDelegate editorController:self pinnedNoteWithSimperiumKey:self.note.simperiumKey];
}

- (IBAction)markdownAction:(id)sender
{
    if (![sender isKindOfClass:[NSMenuItem class]]) {
        return;
    }

    // Toggle the markdown state
    NSMenuItem *markdownItem = (NSMenuItem *)sender;
    BOOL isEnabled = markdownItem.state == NSControlStateValueOff;

    for (Note *selectedNote in self.selectedNotes) {
        selectedNote.markdown = isEnabled;
    }

    // Switch back to the editor if markdown is disabled
    if (!isEnabled && self.isDisplayingMarkdown) {
        [self toggleMarkdownView:self];
    }

    [self refreshToolbarActions];
    [self save];
    
    // Update editor to apply markdown styles
    [self.storage refreshStyleWithMarkdownEnabled:self.note.markdown];

    [[NSUserDefaults standardUserDefaults] setBool:(BOOL)isEnabled forKey:SPMarkdownPreferencesKey];
}

- (IBAction)newNoteWasPressed:(id)sender
{
    [SPTracker trackEditorNoteCreated];
    [self createNoteFromNote:nil];
}

- (IBAction)duplicateNoteWasPressed:(id)sender
{
    [SPTracker trackEditorNoteDuplicated];
    [self duplicateCurrentNote];
}

- (IBAction)deleteAction:(id)sender
{
    for (Note *noteToDelete in self.selectedNotes) {
        if (noteToDelete.deleted) {
            continue;
        }
        
        [SPTracker trackEditorNoteDeleted];
        noteToDelete.deleted = YES;
        [self.noteActionsDelegate editorController:self deletedNoteWithSimperiumKey:noteToDelete.simperiumKey];
    }

    [self save];
}

- (IBAction)restoreAction:(id)sender
{
    self.note.deleted = NO;
    [self save];
    [self.noteActionsDelegate editorController:self restoredNoteWithSimperiumKey:self.note.simperiumKey];
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


#pragma mark - Fonts

- (IBAction)adjustFontSizeAction:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    NSInteger currentFontSize = [Options.shared fontSize];

    if (item.tag == 0) {
        // Increase font size
        currentFontSize += FontSettings.step;
        currentFontSize = MIN(FontSettings.maximum, currentFontSize);
    } else if (item.tag == 2) {
        // Reset to normal size
        currentFontSize = FontSettings.normal;
    } else {
        // Decrease font size
        currentFontSize -= FontSettings.step;
        currentFontSize = MAX(FontSettings.minimum, currentFontSize);
    }

    currentFontSize = [FontSettings nearestValidFontSizeFrom:currentFontSize];
    // Update font size preference and reset fonts
    [Options.shared setFontSize:currentFontSize];
}

#pragma mark - NoteEditor Preferences Helpers

- (NSArray<NSString *> *)observedEditorProperties
{
    return @[
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
}

- (void)startObservingEditorProperties:(SPTextView *)editor
{
    for (NSString *property in self.self.observedEditorProperties) {
        [editor addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)stopObservingEditorProperties:(SPTextView *)editor
{
    for (NSString *property in self.observedEditorProperties) {
        [editor removeObserver:self forKeyPath:property];
    }
}

- (void)setNoteEditor:(SPTextView *)editor
{
    [self stopObservingEditorProperties:self.noteEditor];
    [self startObservingEditorProperties:editor];

    _noteEditor = editor;

    [self observeEditorIsFirstResponder];
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

// Reprocesses note checklists after switching themes, so they apply the correct color
- (void)fixChecklistColoring
{
    NSString *content = [self.noteEditor plainTextContent];
    [self displayContent:content];
}


#pragma mark - NSButton Delegate Methods

- (IBAction)toggleMarkdownView:(id)sender
{
    if (self.isDisplayingMarkdown || !self.isMarkdownEnabled) {
        [self dismissMarkdownPreview];
        [self.view.window makeFirstResponder:self.noteEditor];

    } else {
        [self displayMarkdownPreview:self.note];
        [self.view.window makeFirstResponder:nil];
    }

    [self refreshEditorActions];
    [self refreshToolbarActions];
}

- (void)insertChecklistAction:(id)sender
{
    [self.noteEditor toggleListMarkersAtSelectedRange];
    [SPTracker trackEditorChecklistInserted];

    if ([sender isKindOfClass:[NSMenuItem class]]) {
        [SPTracker trackShortcutToggleChecklist];
    }
}

#pragma mark - New Note

- (void)duplicateCurrentNote
{
    [self createNoteFromNote:self.note];
}

- (void)createNoteFromNote:(nullable Note *)oldNote {

    // Save current note first
    self.note.content = [self.noteEditor plainTextContent];
    [self save];

    SimplenoteAppDelegate *appDelegate = [SimplenoteAppDelegate sharedDelegate];
    [appDelegate ensureMainWindowIsVisible:nil];

    Simperium *simperium = appDelegate.simperium;
    Note *newNote = [simperium.notesBucket insertNewObject];
    newNote.modificationDate = [NSDate date];
    newNote.creationDate = [NSDate date];

    if (oldNote != nil) {
        newNote.content = oldNote.content;
        newNote.tags = oldNote.tags;
        newNote.tagsArray = oldNote.tagsArray;
        newNote.markdown = oldNote.markdown;
    } else {
        newNote.markdown = [[NSUserDefaults standardUserDefaults] boolForKey:SPMarkdownPreferencesKey];
    }

    NSString *currentTag = [appDelegate selectedTagName];
    if ([currentTag length] > 0) {
        [newNote addTag:currentTag];
    }

    [simperium save];

    [self displayNote:newNote];
    [self.noteActionsDelegate editorController:self addedNoteWithSimperiumKey:newNote.simperiumKey];

    [self.view.window makeFirstResponder:self.noteEditor];
}


@end
