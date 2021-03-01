#import "LoginWindowController.h"
#import "SPConstants.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"


#pragma mark - Constants

static NSString *SPAuthSessionKey = @"SPAuthSessionKey";


#pragma mark - Private

@interface LoginWindowController () <NSTextFieldDelegate>
@property (nonatomic, strong) IBOutlet NSImageView                  *logoImageView;
@property (nonatomic, strong) IBOutlet NSTextField                  *errorField;
@property (nonatomic, strong) IBOutlet SPAuthenticationTextField    *usernameField;
@property (nonatomic, strong) IBOutlet SPAuthenticationTextField    *passwordField;
@property (nonatomic, strong) IBOutlet NSButton                     *actionButton;
@property (nonatomic, strong) IBOutlet NSProgressIndicator          *actionProgress;
@property (nonatomic, strong) IBOutlet NSButton                     *forgotPasswordButton;
@property (nonatomic, strong) IBOutlet NSTextField                  *switchTipField;
@property (nonatomic, strong) IBOutlet NSButton                     *switchActionButton;
@property (nonatomic, strong) IBOutlet NSButton                     *wordPressSSOButton;
@end


#pragma mark - SPAuthenticationWindowController

@implementation LoginWindowController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (instancetype)init
{
    NSString *nibName = NSStringFromClass([self class]);
    if (self = [super initWithWindowNibName:nibName]) {
        self.validator = [SPAuthenticationValidator new];
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.errorField.stringValue = @"";
    self.errorField.textColor = [NSColor redColor];

    [self.usernameField setPlaceholderString:NSLocalizedString(@"Email", @"Placeholder text for login field")];
    self.usernameField.delegate = self;

    [self.passwordField setPlaceholderString:NSLocalizedString(@"Password", @"Placeholder text for password field")];
    self.passwordField.delegate = self;

    // Forgot Password!
    NSString *forgotText = NSLocalizedString(@"Forgot your Password?", @"Forgot Password Button");
    self.forgotPasswordButton.title = [forgotText uppercaseString];
    self.forgotPasswordButton.contentTintColor = [NSColor simplenoteBrandColor];

    // Toggle Signup: Tip
    self.switchTipField.textColor = [NSColor colorWithCalibratedWhite:153.f/255.f alpha:1.0];

    // Toggle Signup: Action
    self.switchActionButton.contentTintColor = [NSColor simplenoteBrandColor];

    // WordPress SSO
    NSImage *wpIcon = [[NSImage imageNamed:@"icon_wp"] tintedWithColor:[NSColor simplenoteBrandColor]];
    self.wordPressSSOButton.image = wpIcon;
    self.wordPressSSOButton.title = NSLocalizedString(@"Log in with WordPress.com", @"button title for wp.com sign in button");
    self.wordPressSSOButton.contentTintColor = [NSColor colorWithCalibratedWhite:120.0/255.0 alpha:1.0];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(signInErrorAction:) name:SPSignInErrorNotificationName object:nil];
}


#pragma mark - Action Handlers

- (IBAction)forgotPassword:(id)sender {
    NSString *forgotPasswordURL = [[SPAuthenticationConfiguration sharedInstance] forgotPasswordURL];

    // Post the email already entered in the Username Field. This allows us to prefill the Forgot Password Form
    NSString *username = self.usernameText;
    if (username.length) {
        NSString *parameters = [NSString stringWithFormat:@"?email=%@", username];
        forgotPasswordURL = [forgotPasswordURL stringByAppendingString:parameters];
    }

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:forgotPasswordURL]];
}

- (IBAction)toggleAuthenticationMode:(id)sender {
    self.signingIn = !self.signingIn;
    NSRect windowFrame = [window frame];
    windowFrame.size.height -= delta;
    windowFrame.origin.y += delta;
    [window setFrame:windowFrame display:YES animate:YES];
}


#pragma mark - Dynamic Properties

- (NSString *)usernameText {
    return self.usernameField.stringValue.sp_trim ?: @"";
}

- (NSString *)passwordText {
    return self.passwordField.stringValue ?: @"";
}

- (void)setSigningIn:(BOOL)signingIn {
    _signingIn = signingIn;
    [self refreshFields];
}


#pragma mark - Interface Helpers

- (void)refreshFields {
    [self ensureWindowIsLoaded];

    [self clearAuthenticationError];
    [self refreshButtonTitles];
    [self refreshVisibleComponents];

    // Refresh the entire View
    [self.window.contentView setNeedsDisplay:YES];
}

- (void)refreshButtonTitles {
    NSString *signInText    = NSLocalizedString(@"Log In", @"Title of button for logging in");;
    NSString *signUpText    = NSLocalizedString(@"Sign Up", @"Title of button for signing up");
    NSString *signInTip     = NSLocalizedString(@"Already have an account?", @"Link to sign in to an account");
    NSString *signUpTip     = NSLocalizedString(@"Need an account?", @"Link to create an account");

    NSString *actionText    = self.signingIn ? signInText : signUpText;
    NSString *tipText       = self.signingIn ? signUpTip  : signInTip;
    NSString *switchText    = self.signingIn ? signUpText : signInText;

    self.actionButton.title         = actionText;
    self.switchTipField.stringValue = [tipText uppercaseString];
    self.switchActionButton.title   = [switchText uppercaseString];
}

- (void)refreshVisibleComponents {
    self.forgotPasswordButton.hidden = !_signingIn;
    self.wordPressSSOButton.hidden = !_signingIn;
}

- (void)ensureWindowIsLoaded {
    if (self.isWindowLoaded) {
        return;
    }

    [self window];
}

- (void)setInterfaceEnabled:(BOOL)enabled {
    [self.usernameField setEnabled:enabled];
    [self.passwordField setEnabled:enabled];
    [self.actionButton setEnabled:enabled];
    [self.switchActionButton setEnabled:enabled];
    [self.wordPressSSOButton setEnabled:enabled];
}


#pragma mark - WordPress SSO

- (IBAction)wpccSignInAction:(id)sender
{
    NSString *sessionState = [[NSUUID UUID] UUIDString];
    sessionState = [@"app-" stringByAppendingString:sessionState];
    [[NSUserDefaults standardUserDefaults] setObject:sessionState forKey:SPAuthSessionKey];

    NSString *requestUrl = [NSString stringWithFormat:SPWPSignInAuthURL, SPCredentials.wpcomClientID, SPCredentials.wpcomRedirectURL, sessionState];
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


#pragma mark - Actions

- (IBAction)performMainAction:(id)sender {
    if (self.signingIn) {
        [self signInAction:sender];
        return;
    }

    [self signUpAction:sender];
}

- (IBAction)signInAction:(id)sender {
    [SPTracker trackUserSignedIn];
    [self clearAuthenticationError];

    if ([self mustUpgradePasswordStrength]) {
        [self performCredentialsValidation];
        return;
    }

    if (![self validateSignIn]) {
        return;
    }

    [self performAuthentication];
}

- (IBAction)signUpAction:(id)sender {
    [SPTracker trackUserSignedUp];
    [self clearAuthenticationError];

    if (![self validateSignUp]) {
        return;
    }

    [self performSignup];
}

- (IBAction)cancelAction:(id)sender {
    [self.authenticator cancel];
}


#pragma mark - Displaying Porgress

- (void)startLoginAnimation {
    self.actionButton.title = NSLocalizedString(@"Logging In...", @"Displayed temporarily while logging in");
    [self.actionProgress startAnimation:self];
}

- (void)stopLoginAnimation {
    self.actionButton.title = NSLocalizedString(@"Log In", @"Title of button for login");
    [self.actionProgress stopAnimation:self];
}

- (void)startSignupAnimation {
    self.actionButton.title = NSLocalizedString(@"Signing Up...", @"Displayed temoprarily while signing up");
    [self.actionProgress startAnimation:self];
}

- (void)stopSignupAnimation {
    self.actionButton.title = NSLocalizedString(@"Sign Up", @"Title of button for signing up");
    [self.actionProgress stopAnimation:self];
}


#pragma mark - Authentication Wrappers

- (void)performCredentialsValidation {
    [self startLoginAnimation];
    [self setInterfaceEnabled:NO];

    [self.authenticator validateWithUsername:self.usernameText password:self.passwordText success:^{
        [self stopLoginAnimation];
        [self setInterfaceEnabled:YES];
        [self presentPasswordResetAlert];
    } failure:^(NSInteger responseCode, NSString *responseString, NSError *error) {
        [self showAuthenticationErrorForCode:responseCode];
        [self stopLoginAnimation];
        [self setInterfaceEnabled:YES];
    }];
}

- (void)performAuthentication {
    [self startLoginAnimation];
    [self setInterfaceEnabled:NO];

    [self.authenticator authenticateWithUsername:self.usernameText password:self.passwordText success:^{
        // NO-OP
    } failure:^(NSInteger responseCode, NSString *responseString, NSError *error) {
        [self showAuthenticationErrorForCode:responseCode];
        [self stopLoginAnimation];
        [self setInterfaceEnabled:YES];
    }];
}

- (void)performSignup {
    [self startSignupAnimation];
    [self setInterfaceEnabled:NO];

    [self.authenticator signupWithUsername:self.usernameText password:self.passwordText success:^{
        // NO-OP
    } failure:^(NSInteger responseCode, NSString *responseString, NSError *error) {
        [self showAuthenticationErrorForCode:responseCode];
        [self stopSignupAnimation];
        [self setInterfaceEnabled:YES];
    }];
}


#pragma mark - Password Reset Flow

- (void)presentPasswordResetAlert {
    NSAlert *alert = [NSAlert new];
    [alert setMessageText:self.passwordResetMessageText];
    [alert addButtonWithTitle:self.passwordResetProceedText];
    [alert addButtonWithTitle:self.passwordResetCancelText];

    __weak typeof(self) weakSelf = self;
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode != NSAlertFirstButtonReturn) {
            return;
        }

        [weakSelf openResetPasswordURL];
    }];
}

- (NSString *)passwordResetMessageText {
    return [@[
        NSLocalizedString(@"Your password is insecure and must be reset. The password requirements are:", comment: @"Password Requirements: Title"),
        @"",
        NSLocalizedString(@"- Password cannot match email", comment: @"Password Requirement: Email Match"),
        NSLocalizedString(@"- Minimum of 8 characters", comment: @"Password Requirement: Length"),
        NSLocalizedString(@"- Neither tabs nor newlines are allowed", comment: @"Password Requirement: Special Characters")
    ] componentsJoinedByString:@"\n"];
}

- (NSString *)passwordResetProceedText {
    return NSLocalizedString(@"Reset", @"Password Reset: Proceed");
}

- (NSString *)passwordResetCancelText {
    return NSLocalizedString(@"Cancel", @"Password Reset: Cancel");
}

- (void)openResetPasswordURL {
    NSString *resetPasswordPath = [SPAuthenticationConfiguration.sharedInstance.resetPasswordURL stringByAppendingString:self.usernameText];
    NSURL *targetURL = [NSURL URLWithString:resetPasswordPath];

    if (!targetURL) {
        return;
    }

    [[NSWorkspace sharedWorkspace] openURL:targetURL];
}


#pragma mark - Validation and Error Handling

- (BOOL)validateUsername {
    NSError *error = nil;
    if ([self.validator validateUsername:self.usernameText error:&error]) {
        return YES;
    }

    [self showAuthenticationError:error.localizedDescription];

    return NO;
}

- (BOOL)validatePasswordSecurity {
    NSError *error = nil;
    if ([self.validator validatePasswordWithUsername:self.usernameText password:self.passwordText error:&error]) {
        return YES;
    }

    [self showAuthenticationError:error.localizedDescription];

    return NO;
}

- (BOOL)validateConnection {
    if (!self.authenticator.connected) {
        [self showAuthenticationError:NSLocalizedString(@"You're not connected to the internet", @"Error when you're not connected")];
        return NO;
    }

    return YES;
}

- (BOOL)mustUpgradePasswordStrength {
    BOOL passwordResetEnabled = [[SPAuthenticationConfiguration sharedInstance] passwordUpgradeFlowEnabled];
    BOOL mustResetPassword = [self.validator mustPerformPasswordResetWithUsername:self.usernameText password:self.passwordText];

    return passwordResetEnabled && mustResetPassword;
}

- (BOOL)validateSignIn {
    return [self validateConnection] &&
           [self validateUsername] &&
           [self validatePasswordSecurity];
}

- (BOOL)validateSignUp {
    return [self validateConnection] &&
           [self validateUsername];
}

- (void)showAuthenticationError:(NSString *)errorMessage {
    [self.errorField setStringValue:errorMessage];
}

- (void)showAuthenticationErrorForCode:(NSUInteger)responseCode {
    switch (responseCode) {
        case 409:
            [self showAuthenticationError:NSLocalizedString(@"That email is already being used", @"Error when address is in use")];
            [self.window makeFirstResponder:self.usernameField];
            break;
        case 401:
            [self showAuthenticationError:NSLocalizedString(@"Bad email or password", @"Error for bad email or password")];
            break;

        default:
            [self showAuthenticationError:NSLocalizedString(@"We're having problems. Please try again soon.", @"Generic error")];
            break;
    }
}

- (void)clearAuthenticationError {
    [self.errorField setStringValue:@""];
}


#pragma mark - NSTextView

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [self handleNewlineInField:control];
    }

    return NO;
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    [self.window.contentView setNeedsDisplay:YES];
    return YES;
}

- (void)controlTextDidChange:(NSNotification *)obj {
    NSEvent *currentEvent = [NSApp currentEvent];
    if (currentEvent.type == NSEventTypeKeyDown && [currentEvent.charactersIgnoringModifiers isEqualToString:@"\r"]) {
        [self handleNewlineInField:obj.object];
    }
}

- (void)handleNewlineInField:(NSControl *)field {
    if (_signingIn && [field isEqual:self.passwordField.textField]) {
        [self signInAction:nil];
        return;
    }

    if (!_signingIn && [field isEqual:self.passwordField.textField]) {
        [self signUpAction:nil];
    }
}

@end
