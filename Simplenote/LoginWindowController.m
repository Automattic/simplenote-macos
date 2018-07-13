//
//  LoginWindowController.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/26/15.
//  Copyright © 2015 Simperium. All rights reserved.
//

#import "LoginWindowController.h"
#import "SPConstants.h"
#import "SPTracker.h"

static CGFloat const SPLoginAdditionalHeight        = 40.0f;
static CGFloat const SPLoginWPButtonWidth           = 270.0f;
static NSString *SPAuthSessionKey                   = @"SPAuthSessionKey";

@implementation LoginWindowController

- (instancetype)init {
    self = [super init];
    
    // Sanity check for accessing the root view
    if (self.window.contentView.subviews.count < 1) {
        return self;
    }
    
    NSView *rootView = self.window.contentView.subviews[0];
    
    // Make the window a bit taller than the default to make room for the wp.com button
    CGRect frame = self.window.frame;
    frame.size.height += SPLoginAdditionalHeight;
    [self.window setFrame:frame display:YES animate:NO];
    [rootView setFrame:frame];
    
    // Move up all subviews (Frame origin.y is at the bottom on macOS?)
    for(NSView *view in rootView.subviews) {
        CGRect frame = view.frame;
        frame.origin.y += SPLoginAdditionalHeight;
        [view setFrame:frame];
    }
    
    NSButton *wpccButton = [[NSButton alloc] init];
    [wpccButton setTitle:NSLocalizedString(@"Sign in with WordPress.com", @"button title for wp.com sign in button")];
    [wpccButton setTarget:self];
    [wpccButton setAction:@selector(wpccSignInAction:)];
    [wpccButton setImage:[NSImage imageNamed:@"icon_wp"]];
    [wpccButton setImagePosition:NSImageLeft];
    [wpccButton setBordered:NO];
    [wpccButton setFont:[NSFont systemFontOfSize:16.0]];
    
    // A lot of code just to color the button text :|
    NSMutableAttributedString *colorString = [[NSMutableAttributedString alloc] initWithAttributedString:[wpccButton attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorString length]);
    NSColor *textColor = [NSColor colorWithCalibratedWhite:120.0/255.0 alpha:1.0];
    [colorString addAttribute:NSForegroundColorAttributeName value:textColor range:titleRange];
    [wpccButton setAttributedTitle:colorString];
    
    int centerPosition = (rootView.frame.size.width / 2) - (SPLoginWPButtonWidth / 2);
    wpccButton.frame = CGRectMake(centerPosition, SPLoginAdditionalHeight, SPLoginWPButtonWidth, SPLoginAdditionalHeight);
    [rootView addSubview:wpccButton];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(signInErrorAction:) name:SPSignInErrorNotificationName object:nil];
    
    return self;
}

- (IBAction)wpccSignInAction:(id)sender
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString *sessionState = [[NSUUID UUID] UUIDString];
    sessionState = [@"app-" stringByAppendingString:sessionState];
    [[NSUserDefaults standardUserDefaults] setObject:sessionState forKey:SPAuthSessionKey];
    
    NSString *requestUrl = [NSString stringWithFormat:SPWPSignInAuthURL, config[@"WPCCClientID"], config[@"WPCCRedirectURL"], sessionState];
    NSString *encodedUrl = [requestUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:encodedUrl]];
    
    [SPTracker trackWPCCButtonPressed];
}

- (IBAction)signInErrorAction:(NSNotification *)notification
{
    NSString *errorMessage = NSLocalizedString(@"An error was encountered while signing in.", @"Sign in error message");
    if (notification.userInfo != nil && notification.userInfo[@"errorString"]) {
        errorMessage = [notification.userInfo valueForKey:@"errorString"];
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSAlertStyleCritical];
    [alert setMessageText: NSLocalizedString(@"Couldn't Sign In", @"Alert dialog title displayed on sign in error")];
    [alert setInformativeText:errorMessage];
    [alert addButtonWithTitle: NSLocalizedString(@"OK", @"OK button in error alert dialog")];
    [alert runModal];
}

#pragma mark - Overriden Methods

- (IBAction)signUpAction:(id)sender
{
    [super signUpAction:sender];
    [SPTracker trackUserSignedUp];
}

- (IBAction)signInAction:(id)sender
{
    [super signInAction:sender];
    [SPTracker trackUserSignedIn];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
