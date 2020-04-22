//
//  SimplenoteAppDelegate.m
//  Simplenote
//
//  Created by Michael Johnston on 11-08-22.
//  Copyright (c) 2011 Simperium. All rights reserved.
//

#import "SimplenoteAppDelegate.h"
#import "TagListViewController.h"
#import "DateTransformer.h"
#import "Note.h"
#import "Tag.h"
#import "LoginWindowController.h"
#import "NoteListViewController.h"
#import "NoteEditorViewController.h"
#import "SPMarkdownParser.h"
#import "SPWindow.h"
#import "SPToolbarView.h"
#import "NSImage+Colorize.h"
#import "StatusChecker.h"
#import "SPConstants.h"
#import "VSThemeManager.h"
#import "SPSplitView.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"
#import "WPAuthHandler.h"

@import Simperium_OSX;

#if USE_HOCKEY
#import <Sparkle/Sparkle.h>
#import <HockeySDK/HockeySDK.h>
#endif



#pragma mark ====================================================================================
#pragma mark Constants
#pragma mark ====================================================================================

#define kFirstLaunchKey					@"SPFirstLaunch"
#define kMinimumNoteListSplit			240
#define kMaximumNoteListSplit			384
#define kDefaultThemeAppearanceTag      2


#pragma mark ====================================================================================
#pragma mark Private
#pragma mark ====================================================================================

#if USE_HOCKEY
@interface SimplenoteAppDelegate () <SimperiumDelegate, SPBucketDelegate, BITHockeyManagerDelegate>
#else
@interface SimplenoteAppDelegate () <SimperiumDelegate, SPBucketDelegate>
#endif

@property (strong, nonatomic) IBOutlet TagListViewController    *tagListViewController;
@property (strong, nonatomic) IBOutlet NoteListViewController   *noteListViewController;
@property (strong, nonatomic) IBOutlet NoteEditorViewController *noteEditorViewController;
@property (strong, nonatomic) IBOutlet NSView                   *textViewParent;
@property (strong, nonatomic) IBOutlet NSScrollView             *textScrollView;
@property (strong, nonatomic) IBOutlet SPSplitView              *splitView;
@property (strong, nonatomic) IBOutlet NSMenuItem               *exportItem;
@property (strong, nonatomic) IBOutlet NSMenuItem               *switchThemeItem;
@property (strong, nonatomic) IBOutlet NSMenuItem               *emptyTrashItem;
@property (strong, nonatomic) IBOutlet NSMenuItem               *mainWindowItem;

@property (strong, nonatomic) NSWindowController                *aboutWindowController;
@property (strong, nonatomic) NSWindowController                *privacyWindowController;

#if USE_HOCKEY
@property (strong, nonatomic) SPUStandardUpdaterController      *updaterController;
#endif

@end


#pragma mark ====================================================================================
#pragma mark SimplenoteAppDelegate
#pragma mark ====================================================================================

@implementation SimplenoteAppDelegate {
    BOOL tagListWasVisibleUponFocusMode;
}

#pragma mark - Startup
// Can be used for bugs that don't show up while debugging from Xcode
- (void)redirectConsoleLogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"console.log"];
    
    NSLog(@"Redirecting Console Logs: %@", logPath);
    freopen([logPath fileSystemRepresentation],"a+",stderr);
}

- (Simperium *)configureSimperium
{
    Simperium *simperium                            = [[Simperium alloc] initWithModel:self.managedObjectModel
                                                                               context:self.managedObjectContext
                                                                           coordinator:self.persistentStoreCoordinator];
    simperium.delegate                              = self;
    simperium.verboseLoggingEnabled                 = NO;
    simperium.authenticationWindowControllerClass   = [LoginWindowController class];
    
    SPAuthenticator *authenticator                  = simperium.authenticator;
    authenticator.providerString                    = @"simplenote.com";
    
    SPAuthenticationConfiguration *config           = [SPAuthenticationConfiguration sharedInstance];
    config.logoImageName                            = SPSimplenoteLogoImageName;
    config.forgotPasswordURL                        = SPSimplenoteForgotPasswordURL;
    
    return simperium;
}

#if USE_HOCKEY
- (void)configureHockeyWithID:(NSString *)hockeyID
{
    NSLog(@"Initializing HockeyApp... ");
    
    BITHockeyManager *hockeyManager = [BITHockeyManager sharedHockeyManager];
    
    [hockeyManager configureWithIdentifier:hockeyID delegate:self];
    [hockeyManager startManager];
}

- (void)configureSparkle
{
    self.updaterController = [[SPUStandardUpdaterController alloc] initWithUpdaterDelegate:nil
                                                                        userDriverDelegate:nil];

    _updaterController.updater.sendsSystemProfile = YES;
    _updaterController.updater.automaticallyChecksForUpdates = YES;

    [_updaterController.updater checkForUpdatesInBackground];
}
#endif

- (VSTheme *)theme
{
    return [[VSThemeManager sharedManager] theme];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    NSAppleEventManager *eventManager = [NSAppleEventManager sharedAppleEventManager];
    [eventManager setEventHandler:self
                      andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                    forEventClass:kInternetEventClass
                       andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [SPTracker trackApplicationLaunched];
    
    [self configureWindow];
    [self hookWindowNotifications];

    VSThemeManager *themeManager = [VSThemeManager sharedManager];
    if ([themeManager isMojaveWithNoThemeSet]) {
        [self updateThemeMenuForPosition:kDefaultThemeAppearanceTag];
    } else {
        [self updateThemeMenuForPosition:[[VSThemeManager sharedManager] isDarkMode] ? 1 : 0];
    }
    [self applyStyle];
    
	self.simperium = [self configureSimperium];

    [self.tagListViewController loadTags];
    [self.noteListViewController loadNotes];
    
    [self.simperium setAllBucketDelegates:self];
    [self.simperium bucketForName:@"Note"].notifyWhileIndexing = YES;
    [self.simperium bucketForName:@"Tag"].notifyWhileIndexing = YES;

#if USE_HOCKEY
    [self configureHockeyWithID:SPCredentials.bitHockeyIdentifier];
    [self configureSparkle];
#endif

    [self setupCrashLogging];

#if VERBOSE_LOGGING
    [self.simperium setVerboseLoggingEnabled:YES];
    [self redirectConsoleLogToDocumentFolder];
#endif

	[self.simperium authenticateWithAppID:SPCredentials.simperiumAppID APIKey:SPCredentials.simperiumApiKey window:self.window];

    [self cleanupTags];
    [self configureWelcomeNoteIfNeeded];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(applyStyle) name:VSThemeManagerThemeDidChangeNotification object:nil];
}

- (void)configureWindow
{
    // Restore collapsed state of tag list based on autosaved width
    BOOL collapsed                              = self.tagListViewController.view.frame.size.width <= 1;
    self.tagListViewController.view.hidden      = collapsed;
    self.noteListViewController.view.hidden     = NO;
    self.window.releasedWhenClosed              = NO;
    
    [self.splitView adjustSubviews];
    [self notifySplitDidChange];
    
    // Add the markdown view (you can't add a WKWebView in a .xib until macOS 10.12)
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    WKPreferences *prefs = [[WKPreferences alloc] init];
    prefs.javaScriptEnabled = NO;
    webConfig.preferences = prefs;
    CGRect frame = CGRectMake(0, 43.0f, self.textViewParent.frame.size.width, self.textViewParent.frame.size.height - 43.0f);
    WKWebView *markdownView = [[WKWebView alloc] initWithFrame:frame configuration:webConfig];
    [markdownView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [markdownView setHidden:YES];
    
    // Preload CSS in webview, prevents 'flashing' when first loading the markdown view
    NSString *html = [SPMarkdownParser renderHTMLFromMarkdownString:@""];
    [markdownView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
    
    [self.textViewParent addSubview:markdownView];
    self.noteEditorViewController.markdownView = markdownView;
    [markdownView setNavigationDelegate:self.noteEditorViewController];
    
    // Add the System Appearance menu item to the 'Theme' menu on Mojave or later
    if (@available(macOS 10.14, *)) {
        NSMenuItem *separatorItem = [NSMenuItem separatorItem];
        [themeMenu addItem:separatorItem];
        
        NSMenuItem *systemDefaultItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"System Appearance", @"Menu item for using default macOS theme appearance.") action:@selector(changeThemeAction:) keyEquivalent:@""];
        systemDefaultItem.tag = kDefaultThemeAppearanceTag;
        [themeMenu addItem:systemDefaultItem];
    }

    [self configureToolbar];
}

- (void)configureToolbar
{
    NSRect splitFrame                           = self.splitView.frame;
    NSRect toolbarFrame                         = self.toolbar.frame;
    
    splitFrame.size.height                      -= toolbarFrame.size.height;
    self.splitView.frame                        = splitFrame;
    
    toolbarFrame.origin.y                       = splitFrame.size.height;
    toolbarFrame.size.width                     = splitFrame.size.width;
    
    self.toolbar.autoresizingMask               = NSViewWidthSizable | NSViewMinXMargin | NSViewMinYMargin;
    self.toolbar.drawsSeparator                 = true;
    self.toolbar.drawsBackground                = true;
    self.toolbar.frame                          = toolbarFrame;
    
    [self.splitView.superview addSubview:self.toolbar];
}

- (void)hookWindowNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleWindowDidResignMainNote:)         name:NSApplicationDidResignActiveNotification   object:self.window];
    [nc addObserver:self selector:@selector(handleWindowDidResizeNote:)             name:NSWindowDidResizeNotification              object:self.window];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *url = [NSURL URLWithString:urlString];

    if ([WPAuthHandler isWPAuthenticationUrl:url]) {
        if (self.simperium.user.authenticated) {
            // We're already signed in
            [[NSNotificationCenter defaultCenter] postNotificationName:SPSignInErrorNotificationName
                                                                object:nil];
            return;
        }

        SPUser *newUser = [WPAuthHandler authorizeSimplenoteUserFromUrl:url forAppId:SPCredentials.simperiumAppID];
        if (newUser != nil) {
            self.simperium.user = newUser;
            [self.simperium authenticationDidSucceedForUsername:newUser.email token:newUser.authToken];
        }
        
        [SPTracker trackWPCCLoginSucceeded];
        return;
    }

    if ([SPExporter mustEnableExportAction:url]) {
        [self.exportItem setHidden:NO];
    }
}


#pragma mark - Other

- (void)setupCrashLogging
{
    [CrashLogging startWithSimperium: self.simperium];
}

- (IBAction)ensureMainWindowIsVisible:(id)sender
{
    if ([self.window isVisible]) {
        return;
    }

    [self.window makeKeyAndOrderFront:nil];
}

- (IBAction)selectAllNotesTag
{
    [self.tagListViewController selectAllNotesTag];
}

- (NSString *)selectedTagName
{
    return [self.tagListViewController selectedTagName];
}

- (void)selectNoteWithKey:(NSString *)simperiumKey
{
    [self.noteListViewController selectRowForNoteKey:simperiumKey];
}

- (void)cleanupTags
{
    // Some previous versions of Simplenote created blank tags that cause problems; clean them up
    SPBucket *tagBucket = [_simperium bucketForName:@"Tag"];
    NSArray *tags = [tagBucket allObjects];
    for (Tag *tag in tags) {
        if (tag.name == nil || tag.name.length == 0) {
            [tagBucket deleteObject:tag];
		}
    }
    [_simperium save];
}

- (void)configureWelcomeNoteIfNeeded
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *firstLaunchKey = [userDefaults objectForKey:kFirstLaunchKey];
    if (firstLaunchKey != nil) {
        return;
    }
    
    [self performSelector:@selector(createWelcomeNote) withObject:nil afterDelay:0.5];
    
    [userDefaults setObject:@(1) forKey:kFirstLaunchKey];
    [userDefaults synchronize];
    
    [self.noteListViewController setWaitingForIndex:YES];
}

- (NSInteger)numDeletedNotes
{
    SPBucket *notesBucket = [self.simperium bucketForName:@"Note"];
    NSInteger numDeletedNotes = [notesBucket numObjectsForPredicate:[NSPredicate predicateWithFormat:@"deleted == 1"]];
    
    return numDeletedNotes;
}

- (BOOL)isMainWindowVisible
{
    return self.window.isVisible;
}

- (void)createWelcomeNote
{
    SPBucket *noteBucket = [_simperium bucketForName:@"Note"];
    Note *welcomeNote = [noteBucket objectForKey:SPWelcomeNoteID];
    
    if (welcomeNote) {
        return;
	}
    
    welcomeNote = [noteBucket insertNewObjectForKey:SPWelcomeNoteID];
    welcomeNote.modificationDate = [NSDate date];
    welcomeNote.creationDate = [NSDate date];
    welcomeNote.content = NSLocalizedString(@"welcomeNote-Mac", @"A welcome note for new Mac users");
    [welcomeNote createPreviews:welcomeNote.content];
	
    [_simperium save];
}

- (IBAction)exportAcction:(id)sender
{
    [[SPExporter new] presentExporterFrom:self.window simperium:self.simperium];
}

- (IBAction)aboutAction:(id)sender
{
    // Prevents duplicate windows!
    if (self.aboutWindowController && self.aboutWindowController.window.isVisible) {
        [self.aboutWindowController.window makeKeyAndOrderFront:self];
        return;
    }
    
    NSStoryboard *aboutStoryboard = [NSStoryboard storyboardWithName:@"About" bundle:nil];
    self.aboutWindowController = [aboutStoryboard instantiateControllerWithIdentifier:@"AboutWindowController"];
    [self.aboutWindowController showWindow:self];
}

- (IBAction)privacyAction:(id)sender
{
    [self ensureMainWindowIsVisible:sender];

    if (self.privacyWindowController) {
        [self.privacyWindowController.window makeKeyAndOrderFront:sender];
        return;
    }

    NSStoryboard *aboutStoryboard = [NSStoryboard storyboardWithName:@"Privacy" bundle:nil];
    self.privacyWindowController = [aboutStoryboard instantiateControllerWithIdentifier:@"PrivacyWindowController"];
    [self.window beginSheet:_privacyWindowController.window completionHandler:^(NSModalResponse returnCode) {
        self.privacyWindowController = nil;
    }];
}


#pragma mark - NSWindow Notification Handlers

- (void)handleWindowDidResizeNote:(NSNotification *)notification
{
    [self.splitView adjustSubviews];
    [self notifySplitDidChange];
}

- (void)handleWindowDidResignMainNote:(NSNotification *)notification
{
    // Use this as an opportunity to re-sort by modify date when the user isn't looking
    // (otherwise it can be a little jarring)
    [self.noteListViewController reloadDataAndPreserveSelection];
}


#pragma mark - Split view Handling

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    // Tag List: Don't draw separators
    return (self.noteListViewController.view.isHidden || dividerIndex == SPSplitViewSectionTags);
}

- (NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex
{
    // Tag List: Don't draw separators
    return (dividerIndex == SPSplitViewSectionTags) ? CGRectZero : proposedEffectiveRect;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
    // When resizing the window, only resize the note editor
    return (subview == self.textViewParent);
}
 
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    // Tag: Split should be fixed
    CGFloat minTagListWidth = [self.tagListViewController.view isHidden] ? 0 : SPSplitViewDefaultWidth;
    if (dividerIndex == SPSplitViewSectionTags) {
        return minTagListWidth;
    }
	
    // List: Split should be dynamic
    return minTagListWidth + kMinimumNoteListSplit;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    // Tag: Split should be fixed
    if (dividerIndex == SPSplitViewSectionTags) {
        return SPSplitViewDefaultWidth;
	}

    // List: Split should be dynamic
    return [self tagListWidth] + kMaximumNoteListSplit;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
    [self notifySplitDidChange];
    
    return proposedPosition;
}


#pragma mark - Split view Helpers

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    [self notifySplitDidChange];
}

- (CGFloat)tagListWidth
{
    return [self.tagListViewController.view isHidden] ? 0 : self.tagListViewController.view.bounds.size.width;
}

- (CGFloat)editorSplitPosition
{
    return [self tagListWidth] + self.noteListViewController.view.bounds.size.width;
}

- (CGFloat)tagListSplitPosition
{
    return self.tagListViewController.view.bounds.size.width;
}

- (void)notifySplitDidChange
{
    [self.toolbar setSplitPositionLeft:[self tagListSplitPosition] right:[self editorSplitPosition]];
}


#pragma mark - Simperium Delegates

- (void)simperiumDidLogin:(Simperium *)simperium
{
    [SPTracker refreshMetadataWithEmail:simperium.user.email];
    [CrashLogging cacheUser: simperium.user];
}

- (void)simperiumDidLogout:(Simperium *)simperium
{
    [SPTracker refreshMetadataForAnonymousUser];
    [CrashLogging clearCachedUser];
}

- (void)simperium:(Simperium *)simperium didFailWithError:(NSError *)error
{
    [SPTracker refreshMetadataForAnonymousUser];
}


#pragma mark - Simperium Callbacks

- (void)bucket:(SPBucket *)bucket didChangeObjectForKey:(NSString *)key forChangeType:(SPBucketChangeType)change memberNames:(NSArray *)memberNames
{
    // Ignore acks
    if (change == SPBucketChangeTypeAcknowledge) {
        return;
	}
    
    if ([bucket.name isEqualToString:@"Note"]) {
        // Note change
        switch (change) {                
            case SPBucketChangeTypeUpdate:
                if ([key isEqualToString:self.noteEditorViewController.note.simperiumKey]) {
                    [self.noteEditorViewController didReceiveNewContent];
                    [self.noteEditorViewController updateTagField];
                }
                [self.noteListViewController noteKeyDidChange:key memberNames:memberNames];

                break;
            
            case SPBucketChangeTypeInsert:
                break;

            default:
                break;
        }
    } else {
        // Tag change
        [self.tagListViewController loadTags];
    }
}

- (void)bucket:(SPBucket *)bucket willChangeObjectsForKeys:(NSSet *)keys
{
    if ([bucket.name isEqualToString:@"Note"]) {
        for (NSString *key in keys) {
            if ([key isEqualToString:self.noteEditorViewController.note.simperiumKey])
                [self.noteEditorViewController willReceiveNewContent];
        }
        [self.noteListViewController noteKeysWillChange:keys];
    }
}

- (void)bucket:(SPBucket *)bucket didReceiveObjectForKey:(NSString *)key version:(NSString *)version data:(NSDictionary *)data
{
    if ([bucket.name isEqualToString:@"Note"]) {
        if ([key isEqualToString: self.noteEditorViewController.note.simperiumKey]) {
            [self.noteEditorViewController didReceiveVersion:version data:data];
        }
    }
}

- (void)bucketWillStartIndexing:(SPBucket *)bucket
{
    if ([bucket.name isEqualToString:@"Note"]) {
        [self.noteListViewController setWaitingForIndex:YES];
    }
}

- (void)bucketDidFinishIndexing:(SPBucket *)bucket
{
    if ([bucket.name isEqualToString:@"Note"]) {
        [self.noteListViewController setWaitingForIndex:NO];
    }
}


#pragma mark - Menu delegate

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem == self.emptyTrashItem) {
        return [self numDeletedNotes] > 0;
    }

    return YES;
}


#pragma mark - Static Helpers

+ (SimplenoteAppDelegate *)sharedDelegate
{
	return (SimplenoteAppDelegate *)[[NSApplication sharedApplication] delegate];
}


#pragma mark - Actions

- (IBAction)signOutAction:(id)sender
{
    // Safety first: Check for unsynced notes before they are deleted!
    if ([StatusChecker hasUnsentChanges:self.simperium] == false)  {
        [self signOut];
        return;
    }

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:NSLocalizedString(@"Delete Notes", @"Delete notes and sign out of the app")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel the action")];
    [alert addButtonWithTitle:NSLocalizedString(@"Visit Web App", @"Visit app.simplenote.com in the browser")];
    [alert setMessageText:NSLocalizedString(@"Unsynced Notes Detected", @"Alert title displayed in when an account has unsynced notes")];
    [alert setInformativeText:NSLocalizedString(@"Signing out will delete any unsynced notes. Check your connection and verify your synced notes by signing in to the Web App.", @"Alert message displayed when an account has unsynced notes")];
    [alert setAlertStyle:NSAlertStyleCritical];

    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (result == NSAlertThirdButtonReturn) {
            NSURL *linkUrl = [NSURL URLWithString:@"https://app.simplenote.com"];
            [[NSWorkspace sharedWorkspace] openURL:linkUrl];
        } else if (result == NSAlertFirstButtonReturn) {
            [self signOut];
        }
    }];
}

-(void)signOut
{
    [SPTracker trackUserSignedOut];
    
    // Remove WordPress token
    [SPKeychain deletePasswordForService:SPWPServiceName account:self.simperium.user.email];
    
    [self.noteEditorViewController displayNote:nil];
    [self.tagListViewController reset];
    [self.noteListViewController reset];
    [self.noteListViewController setWaitingForIndex:YES];
    
    [_simperium signOutAndRemoveLocalData:YES completion:^{
        // Auth window won't show up until next run loop, so be careful not to close main window until then
        [self->_window performSelector:@selector(orderOut:) withObject:self afterDelay:0.1f];
        [self->_simperium authenticateIfNecessary];
    }];
}

- (void)emptyTrashAction:(id)sender
{
    [self.tagListViewController emptyTrashAction:sender];
}

- (void)searchAction:(id)sender
{
    // Needs to be here because this class is the window's delegate, and SPApplication uses sendEvent:
    // to override a search keyboard shortcut...which ends up calling searchAction: here
    [self.noteListViewController searchAction:sender];
}

- (BOOL)isInFocusMode {
    return [self.noteListViewController.view isHidden];
}

- (IBAction)toggleSidebarAction:(id)sender
{
    [SPTracker trackSidebarButtonPresed];
    
    // Stop focus mode when the sidebar button is pressed with focus mode active
    if ([self isInFocusMode]) {
        [self focusModeAction:nil];
        return;
    }

    CGFloat tagListSplitPosition = MAX([self tagListSplitPosition], SPSplitViewDefaultWidth);
    CGFloat editorSplitPosition = [self editorSplitPosition];
    BOOL collapsed = ![self.tagListViewController.view isHidden];
    [self.tagListViewController.view setHidden:collapsed];
    tagListWasVisibleUponFocusMode = NO;
    
    [self.splitView setPosition:collapsed ? 0 : tagListSplitPosition ofDividerAtIndex:0];
    [self.splitView setPosition:collapsed ? editorSplitPosition - tagListSplitPosition : editorSplitPosition + tagListSplitPosition ofDividerAtIndex:1];
    [self.splitView adjustSubviews];
}

- (IBAction)focusModeAction:(id)sender {
    // Check if the tags list is visible, if so close it
    BOOL tagsVisible = ![self.tagListViewController.view isHidden];
    if (tagsVisible) {
        [self toggleSidebarAction:nil];
        tagListWasVisibleUponFocusMode = YES;
    }
    
    [self.noteListViewController.view setHidden:![self.noteListViewController.view isHidden]];
    
    BOOL isEnteringFocusMode = [self.noteListViewController.view isHidden];
    // Enable/disable buttons and search bar in the toolbar
    [self.toolbar configureForFocusMode: isEnteringFocusMode];
    [focusModeMenuItem setState:isEnteringFocusMode ? NSOnState : NSOffState];
    
    if (!isEnteringFocusMode && tagListWasVisibleUponFocusMode) {
        // If ending focus mode and the tag view was previously visible, show it agian
        [self toggleSidebarAction:nil];
    }
    
    [self.splitView adjustSubviews];
}

- (IBAction)helpAction:(id)sender
{
    NSArray *helpLinks = @[SPHelpURL, SPContactUsURL, SPTwitterURL];
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: helpLinks[menuItem.tag]]];
}

- (IBAction)changeThemeAction:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    if (item.state == NSOnState) {
        return;
    }
    
    if ([sender tag] == kDefaultThemeAppearanceTag) {
        // Resetting to default macOS theme appearance
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:VSThemeManagerThemePrefKey];
        if (@available(macOS 10.14, *)) {
            SPWindow *window = (SPWindow *)self.window;
            window.appearance = nil;
            [window applyMojaveThemeOverrideIfNecessary];
        }
    } else {
        NSString *newTheme = ([sender tag] == 0) ? @"default" : @"dark";
        [SPTracker trackSettingsThemeUpdated:newTheme];
        [[VSThemeManager sharedManager] swapTheme:newTheme];
    }
    
    [self updateThemeMenuForPosition:[sender tag]];
}

- (void)updateThemeMenuForPosition:(NSInteger)position
{
    for (NSMenuItem *menuItem in themeMenu.itemArray) {
        if (menuItem.tag == position) {
            [menuItem setState:NSOnState];
        } else {
            [menuItem setState:NSOffState];
        }
    }
}

- (void)applyStyle
{
    if (@available(macOS 10.14, *)) {
        SPWindow *window = (SPWindow *)self.window;
        [window applyMojaveThemeOverrideIfNecessary];
        [self.noteEditorViewController applyStyle];
        [self.noteEditorViewController fixChecklistColoring];
        [self.noteListViewController applyStyle];
        return;
    }
    
    self.textScrollView.backgroundColor = [self.theme colorForKey:@"tableViewBackgroundColor"];
    [backgroundView setNeedsDisplay:YES];

    [self.splitView applyStyle];
    [self.toolbar applyStyle];
    [self.toolbar setNeedsDisplay:YES];
    [self.tagListViewController applyStyle];
    [self.noteListViewController applyStyle];
    [self.noteEditorViewController applyStyle];
}


#pragma mark - Shutdown

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return NO;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)hasVisibleWindows
{
    if (!hasVisibleWindows) {
        [self.window setIsVisible:YES];
        [self.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    [SPTracker trackApplicationTerminated];
    return [_simperium applicationShouldTerminate:sender];
}


#pragma mark - Core Data

- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"Simplenote"];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Simplenote" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }

    NSDictionary *options = @{
      NSMigratePersistentStoresAutomaticallyOption: @(YES),
      NSInferMappingModelAutomaticallyOption: @(YES)
    };

    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Simplenote.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:options error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;

    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

    return _managedObjectContext;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

@end
