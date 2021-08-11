#import "AuthViewController.h"
#import "SPConstants.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"


#pragma mark - Constants

static NSString *SPAuthSessionKey = @"SPAuthSessionKey";


#pragma mark - Private

@interface AuthViewController ()
@property (nonatomic, strong) SPAuthenticationValidator *validator;
@end


#pragma mark - LoginViewController

@implementation AuthViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (instancetype)init
{
    if (self = [super init]) {
        self.validator = [SPAuthenticationValidator new];
        self.signingIn = NO;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupInterface];
    [self refreshInterfaceWithAnimation:NO];
    [self startListeningToNotifications];
}

- (void)startListeningToNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(signInErrorAction:) name:SPSignInErrorNotificationName object:nil];
}


#pragma mark - Action Handlers

- (IBAction)forgotPassword:(id)sender {
    NSString *forgotPasswordURL = [SPCredentials simperiumForgotPasswordURL];
    NSString *username = self.usernameText;

    if (username.length) {
        NSString *parameters = [NSString stringWithFormat:@"?email=%@", username];
        forgotPasswordURL = [forgotPasswordURL stringByAppendingString:parameters];
    }

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:forgotPasswordURL]];
}

- (IBAction)toggleAuthenticationMode:(id)sender {
    self.signingIn = !self.signingIn;
}


#pragma mark - Dynamic Properties

- (void)setSigningIn:(BOOL)signingIn {
    _signingIn = signingIn;
    [self didUpdateAuthenticationMode];
}


#pragma mark - Interface Helpers

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

    [self performSignupRequest];
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
        [self showAuthenticationErrorForCode:responseCode responseString:responseString];
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
        [self showAuthenticationErrorForCode:responseCode responseString: responseString];
        [self stopLoginAnimation];
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
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
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
    NSString *resetPasswordPath = [SPCredentials.simperiumResetPasswordURL stringByAppendingString:self.usernameText];
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
    return [self.validator mustPerformPasswordResetWithUsername:self.usernameText password:self.passwordText];
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

- (void)showAuthenticationErrorForCode:(NSInteger)responseCode responseString:(NSString *)responseString {
    switch (responseCode) {
        case 409:
            [self showAuthenticationError:NSLocalizedString(@"That email is already being used", @"Error when address is in use")];
            [self.view.window makeFirstResponder:self.usernameField];
            break;
        case 401:
            [self process401FromResponseString:responseString];
            break;

        default:
            [self showAuthenticationError:NSLocalizedString(@"We're having problems. Please try again soon.", @"Generic error")];
            break;
    }
}

-(void)process401FromResponseString:(NSString *)responseString
{
    if ([responseString  isEqual:@"compromised password"]) {
        __weak typeof(self) weakSelf = self;
        [self showCompromisedPasswordAlertFor:NSApplication.sharedApplication.windows.lastObject
                                   completion:^(NSModalResponse response)  {
            if (response == NSAlertFirstButtonReturn) {
                [weakSelf openResetPasswordURL];
            }
        }];
        return;
    }

    [self showAuthenticationError:NSLocalizedString(@"Bad email or password", @"Error for bad email or password")];
}

#pragma mark - NSTextView

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        [self handleNewlineInField:control];
    }

    return NO;
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    [self.view setNeedsDisplay:YES];
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

    if (!_signingIn && [field isEqual:self.usernameField.textField]) {
        [self signUpAction:nil];
    }
}

@end
