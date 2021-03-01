#import "LoginWindowController.h"
#import "SPConstants.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"


#pragma mark - Constants

static CGFloat const SPAuthenticationWindowWidth        = 380.0f;
static CGFloat const SPAuthenticationWindowHeight       = 580.0f;
static CGFloat const SPAuthenticationRowSize            = 50;

static CGFloat const SPAuthenticationCancelWidth        = 60.0f;

static CGFloat const SPAuthenticationFieldPaddingX      = 30.0f;
static CGFloat const SPAuthenticationFieldWidth         = SPAuthenticationWindowWidth - SPAuthenticationFieldPaddingX * 2;
static CGFloat const SPAuthenticationFieldHeight        = 40.0f;

static CGFloat const SPAuthenticationProgressSize       = 20.0f;

static CGFloat const SPLoginWPButtonWidth               = 270.0f;
static NSString *SPAuthSessionKey                       = @"SPAuthSessionKey";


#pragma mark - Private

@interface LoginWindowController () <NSTextFieldDelegate>
@property (nonatomic, strong) NSImageView               *logoImageView;
@property (nonatomic, strong) NSButton                  *cancelButton;
@property (nonatomic, strong) SPAuthenticationTextField *usernameField;
@property (nonatomic, strong) SPAuthenticationTextField *passwordField;
@property (nonatomic, strong) SPAuthenticationTextField *confirmField;
@property (nonatomic, strong) NSTextField               *changeToSignInField;
@property (nonatomic, strong) NSTextField               *changeToSignUpField;
@property (nonatomic, strong) NSTextField               *errorField;
@property (nonatomic, strong) NSButton                  *signInButton;
@property (nonatomic, strong) NSButton                  *signUpButton;
@property (nonatomic, strong) NSButton                  *forgotPasswordButton;
@property (nonatomic, strong) NSButton                  *changeToSignInButton;
@property (nonatomic, strong) NSButton                  *changeToSignUpButton;
@property (nonatomic, strong) NSProgressIndicator       *signInProgress;
@property (nonatomic, strong) NSProgressIndicator       *signUpProgress;
@property (nonatomic, assign) BOOL                      isAnimatingProgress;
@end


#pragma mark - SPAuthenticationWindowController

@implementation LoginWindowController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (instancetype)init {
    NSWindowStyleMask styleMask = NSWindowStyleMaskBorderless | NSWindowStyleMaskClosable | NSWindowStyleMaskTitled | NSWindowStyleMaskFullSizeContentView;
    CGRect windowFrame = NSMakeRect(0, 0, SPAuthenticationWindowWidth, SPAuthenticationWindowHeight);
    SPAuthenticationWindow *window = [[SPAuthenticationWindow alloc] initWithContentRect:windowFrame styleMask:styleMask backing:NSBackingStoreBuffered defer:NO];

    // We want the login window to always have the 'light' aqua appearance
    window.appearance                 = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    window.titleVisibility            = NSWindowTitleHidden;
    window.titlebarAppearsTransparent = YES;

    if ((self = [super initWithWindow: window])) {
        self.validator = [[SPAuthenticationValidator alloc] init];

        SPAuthenticationView *authView = [[SPAuthenticationView alloc] initWithFrame:windowFrame];
        [window.contentView addSubview:authView];

        NSString *cancelButtonText = NSLocalizedString(@"Skip", @"Text to display on OSX cancel button");

        self.cancelButton = [self linkButtonWithText:cancelButtonText frame:NSMakeRect(SPAuthenticationWindowWidth-SPAuthenticationCancelWidth, SPAuthenticationWindowHeight-5-20, SPAuthenticationCancelWidth, 20)];
        self.cancelButton.target = self;
        self.cancelButton.action = @selector(cancelAction:);
        [authView addSubview:self.cancelButton];

        NSImage *logoImage = [NSImage imageNamed:[[SPAuthenticationConfiguration sharedInstance] logoImageName]];
        CGFloat markerY = SPAuthenticationWindowHeight-45-logoImage.size.height;
        NSRect logoRect = NSMakeRect(SPAuthenticationWindowWidth * 0.5f - logoImage.size.width * 0.5f, markerY, logoImage.size.width, logoImage.size.height);
        self.logoImageView = [[NSImageView alloc] initWithFrame:logoRect];
        self.logoImageView.image = logoImage;
        [authView addSubview:self.logoImageView];

        self.errorField = [self tipFieldWithText:@"" frame:NSMakeRect(SPAuthenticationFieldPaddingX, markerY - 30, SPAuthenticationFieldWidth, 20)];
        [self.errorField setTextColor:[NSColor redColor]];
        [authView addSubview:self.errorField];

        markerY -= 30;
        self.usernameField = [[SPAuthenticationTextField alloc] initWithFrame:NSMakeRect(SPAuthenticationFieldPaddingX, markerY - SPAuthenticationRowSize, SPAuthenticationFieldWidth, SPAuthenticationFieldHeight) secure:NO];
        [self.usernameField setPlaceholderString:NSLocalizedString(@"Email", @"Placeholder text for login field")];
        self.usernameField.delegate = self;
        [authView addSubview:self.usernameField];

        self.passwordField = [[SPAuthenticationTextField alloc] initWithFrame:NSMakeRect(SPAuthenticationFieldPaddingX, markerY - SPAuthenticationRowSize*2, SPAuthenticationFieldWidth, SPAuthenticationFieldHeight) secure:YES];
        [self.passwordField setPlaceholderString:NSLocalizedString(@"Password", @"Placeholder text for password field")];

        self.passwordField.delegate = self;
        [authView addSubview:self.passwordField];

        self.confirmField = [[SPAuthenticationTextField alloc] initWithFrame:NSMakeRect(SPAuthenticationFieldPaddingX, markerY - SPAuthenticationRowSize*3, SPAuthenticationFieldWidth, SPAuthenticationFieldHeight) secure:YES];
        [self.confirmField setPlaceholderString:NSLocalizedString(@"Confirm Password", @"Placeholder text for confirmation field")];
        self.confirmField.delegate = self;
        [authView addSubview:self.confirmField];

        markerY -= 30;
        self.signInButton = [[SPAuthenticationButton alloc] initWithFrame:NSMakeRect(SPAuthenticationFieldPaddingX, markerY - SPAuthenticationRowSize*3, SPAuthenticationFieldWidth, SPAuthenticationFieldHeight)];
        self.signInButton.title = NSLocalizedString(@"Log In", @"Title of button for logging in");
        self.signInButton.target = self;
        self.signInButton.action = @selector(signInAction:);
        [authView addSubview:self.signInButton];

        self.signInProgress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(self.signInButton.frame.size.width - SPAuthenticationProgressSize - SPAuthenticationFieldPaddingX, (self.signInButton.frame.size.height - SPAuthenticationProgressSize) * 0.5f, SPAuthenticationProgressSize, SPAuthenticationProgressSize)];
        [self.signInProgress setStyle:NSProgressIndicatorStyleSpinning];
        [self.signInProgress setDisplayedWhenStopped:NO];
        [self.signInButton addSubview:self.signInProgress];

        self.signUpButton = [[SPAuthenticationButton alloc] initWithFrame:NSMakeRect(SPAuthenticationFieldPaddingX, markerY - SPAuthenticationRowSize*4, SPAuthenticationFieldWidth, SPAuthenticationFieldHeight)];
        self.signUpButton.title = NSLocalizedString(@"Sign Up", @"Title of button for signing up");
        self.signUpButton.target = self;
        self.signUpButton.action = @selector(signUpAction:);
        [authView addSubview:self.signUpButton];

        self.signUpProgress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(self.signUpButton.frame.size.width - SPAuthenticationProgressSize - SPAuthenticationFieldPaddingX, (self.signUpButton.frame.size.height - SPAuthenticationProgressSize) * 0.5f, SPAuthenticationProgressSize, SPAuthenticationProgressSize)];
        [self.signUpProgress setStyle:NSProgressIndicatorStyleSpinning];
        [self.signUpProgress setDisplayedWhenStopped:NO];
        [self.signUpButton addSubview:self.signUpProgress];

        // Forgot Password!
        NSString *forgotText = NSLocalizedString(@"Forgot your Password?", @"Forgot Password Button");
        self.forgotPasswordButton = [self linkButtonWithText:forgotText frame:NSMakeRect(SPAuthenticationFieldPaddingX, markerY - SPAuthenticationRowSize*3 - 35, SPAuthenticationFieldWidth, 20)];
        self.forgotPasswordButton.target = self;
        self.forgotPasswordButton.action = @selector(forgotPassword:);
        [authView addSubview:self.forgotPasswordButton];

        // Toggle Signup
        NSString *signUpTip = NSLocalizedString(@"Need an account?", @"Link to create an account");
        self.changeToSignUpField = [self tipFieldWithText:signUpTip frame:NSMakeRect(SPAuthenticationFieldPaddingX, markerY - SPAuthenticationRowSize*4 - 35, SPAuthenticationFieldWidth, 20)];
        [authView addSubview:self.changeToSignUpField];

        self.changeToSignUpButton = [self toggleButtonWithText:self.signUpButton.title frame:NSMakeRect(SPAuthenticationFieldPaddingX, self.changeToSignUpField.frame.origin.y - self.changeToSignUpField.frame.size.height - 2, SPAuthenticationFieldWidth, 30)];
        [authView addSubview:self.changeToSignUpButton];

        // Toggle SignIn
        NSString *signInTip = NSLocalizedString(@"Already have an account?", @"Link to sign in to an account");
        self.changeToSignInField = [self tipFieldWithText:signInTip frame:NSMakeRect(SPAuthenticationFieldPaddingX, markerY - SPAuthenticationRowSize*4 - 35, SPAuthenticationFieldWidth, 20)];
        [authView addSubview:self.changeToSignInField];

        self.changeToSignInButton = [self toggleButtonWithText:self.signInButton.title frame:NSMakeRect(SPAuthenticationFieldPaddingX, self.changeToSignInField.frame.origin.y - self.changeToSignInField.frame.size.height - 2, SPAuthenticationFieldWidth, 30)];
        [authView addSubview:self.changeToSignInButton];

        // Enter sign up mode
        [self toggleAuthenticationMode:self.signUpButton];

        // Make the window a bit taller than the default to make room for the wp.com button
        NSImage *wpIcon = [[NSImage imageNamed:@"icon_wp"] tintedWithColor:[NSColor simplenoteBrandColor]];
        NSButton *wpccButton = [[NSButton alloc] init];
        [wpccButton setTitle:NSLocalizedString(@"Sign in with WordPress.com", @"button title for wp.com sign in button")];
        [wpccButton setTarget:self];
        [wpccButton setAction:@selector(wpccSignInAction:)];
        [wpccButton setImage:wpIcon];
        [wpccButton setImagePosition:NSImageLeft];
        [wpccButton setBordered:NO];
        [wpccButton setFont:[NSFont systemFontOfSize:16.0]];

        // A lot of code just to color the button text :|
        NSMutableAttributedString *colorString = [[NSMutableAttributedString alloc] initWithAttributedString:[wpccButton attributedTitle]];
        NSRange titleRange = NSMakeRange(0, [colorString length]);
        NSColor *textColor = [NSColor colorWithCalibratedWhite:120.0/255.0 alpha:1.0];
        [colorString addAttribute:NSForegroundColorAttributeName value:textColor range:titleRange];
        [wpccButton setAttributedTitle:colorString];

        CGFloat centerPosition = (authView.frame.size.width / 2) - (SPLoginWPButtonWidth / 2);
        wpccButton.frame = CGRectMake(centerPosition, SPAuthenticationRowSize, SPLoginWPButtonWidth, SPAuthenticationFieldHeight);
        [authView addSubview:wpccButton];

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(signInErrorAction:) name:SPSignInErrorNotificationName object:nil];
    }

    return self;
}

- (void)setOptional:(BOOL)on {
    _optional = on;
    [self.cancelButton setHidden:!_optional];
}

- (NSTextField *)tipFieldWithText:(NSString *)text frame:(CGRect)frame {
    NSTextField *field = [[NSTextField alloc] initWithFrame:frame];
    NSFont *font = [NSFont fontWithName:[SPAuthenticationConfiguration sharedInstance].mediumFontName size:13];
    [field setStringValue:[text uppercaseString]];
    [field setEditable:NO];
    [field setSelectable:NO];
    [field setBordered:NO];
    [field setDrawsBackground:NO];
    [field setAlignment:NSTextAlignmentCenter];
    [field setFont:font];
    [field setTextColor:[NSColor colorWithCalibratedWhite:153.f/255.f alpha:1.0]];

    return field;
}

- (NSButton *)linkButtonWithText:(NSString *)text frame:(CGRect)frame {
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    [button setBordered:NO];
    [button setButtonType:NSButtonTypeMomentaryChange];

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    NSColor *linkColor = [SPAuthenticationConfiguration sharedInstance].controlColor;

    NSFont *font = [NSFont fontWithName:[SPAuthenticationConfiguration sharedInstance].mediumFontName size:13];
    NSDictionary *attributes = @{NSFontAttributeName : font,
                                 NSForegroundColorAttributeName : linkColor,
                                 NSParagraphStyleAttributeName : style};
    [button setAttributedTitle: [[NSAttributedString alloc] initWithString:[text uppercaseString] attributes:attributes]];

    return button;
}

- (NSButton *)toggleButtonWithText:(NSString *)text frame:(CGRect)frame {
    NSButton *button = [self linkButtonWithText:text frame:frame];
    button.target = self;
    button.action = @selector(toggleAuthenticationMode:);

    return button;
}

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
    self.signingIn = (sender == self.changeToSignInButton);
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
    // Refresh Buttons
    [self.signInButton setHidden:!_signingIn];
    [self.signInButton setEnabled:_signingIn];
    [self.signUpButton setHidden:_signingIn];
    [self.signUpButton setEnabled:!_signingIn];
    [self.changeToSignInButton setHidden:_signingIn];
    [self.changeToSignInButton setEnabled:!_signingIn];
    [self.changeToSignUpButton setHidden:!_signingIn];
    [self.changeToSignUpButton setEnabled:_signingIn];
    [self.changeToSignInField setHidden:_signingIn];
    [self.changeToSignUpField setHidden:!_signingIn];
    [self.confirmField setHidden:_signingIn];

    // Remove any pending errors
    [self clearAuthenticationError];

    // Forgot Password
    BOOL shouldDisplayForgotPassword = _signingIn && [[SPAuthenticationConfiguration sharedInstance] forgotPasswordURL];
    [self.forgotPasswordButton setHidden:!shouldDisplayForgotPassword];

    // Refresh the entire View
    [self.window.contentView setNeedsDisplay:YES];
}

- (void)setInterfaceEnabled:(BOOL)enabled {
    [self.signInButton setEnabled:enabled];
    [self.signUpButton setEnabled:enabled];
    [self.changeToSignUpButton setEnabled:enabled];
    [self.changeToSignInButton setEnabled:enabled];
    [self.usernameField setEnabled:enabled];
    [self.passwordField setEnabled:enabled];
    [self.confirmField setEnabled:enabled];
}


#pragma mark - WordPress SSO

- (IBAction)wpccSignInAction:(id)sender
{
    if (self.isAnimatingProgress) {
        return;
    }

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
    self.signInButton.title = NSLocalizedString(@"Logging In...", @"Displayed temporarily while logging in");
    [self.signInProgress startAnimation:self];
    self.isAnimatingProgress = YES;
}

- (void)stopLoginAnimation {
    self.signInButton.title = NSLocalizedString(@"Log In", @"Title of button for login");
    [self.signInProgress stopAnimation:self];
    self.isAnimatingProgress = NO;
}

- (void)startSignupAnimation {
    self.signUpButton.title = NSLocalizedString(@"Signing Up...", @"Displayed temoprarily while signing up");
    [self.signUpProgress startAnimation:self];
    self.isAnimatingProgress = YES;
}

- (void)stopSignupAnimation {
    self.signUpButton.title = NSLocalizedString(@"Sign Up", @"Title of button for signing up");
    [self.signUpProgress stopAnimation:self];
    self.isAnimatingProgress = NO;
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

- (BOOL)validatePasswordsMatch {
    NSError *error = nil;
    if ([self.validator validatePasswordConfirmation:self.confirmField.stringValue password:self.passwordText error:&error]) {
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
           [self validateUsername] &&
           [self validatePasswordsMatch] &&
           [self validatePasswordSecurity];
}

- (void)showAuthenticationError:(NSString *)errorMessage {
    [self.errorField setStringValue:errorMessage];
}

- (void)showAuthenticationErrorForCode:(NSUInteger)responseCode {
    switch (responseCode) {
        case 409:
            // User already exists
            [self showAuthenticationError:NSLocalizedString(@"That email is already being used", @"Error when address is in use")];
            [self.window makeFirstResponder:self.usernameField];
            break;
        case 401:
            // Bad email or password
            [self showAuthenticationError:NSLocalizedString(@"Bad email or password", @"Error for bad email or password")];
            break;

        default:
            // General network problem
            [self showAuthenticationError:NSLocalizedString(@"We're having problems. Please try again soon.", @"Generic error")];
            break;
    }
}

- (void)clearAuthenticationError {
    [self.errorField setStringValue:@""];
}


#pragma mark - NSTextView delegates

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    BOOL retval = NO;

    if (commandSelector == @selector(insertNewline:)) {
        if (_signingIn && [control isEqual:self.passwordField.textField]) {
            [self signInAction:nil];
        } else if (!_signingIn && [control isEqual:self.confirmField.textField]) {
            [self signUpAction:nil];
        }
    }

    return retval;
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    [self.window.contentView setNeedsDisplay:YES];
    return YES;
}

- (void)controlTextDidChange:(NSNotification *)obj {
    // Intercept return and invoke actions
    NSEvent *currentEvent = [NSApp currentEvent];
    if (currentEvent.type == NSEventTypeKeyDown && [currentEvent.charactersIgnoringModifiers isEqualToString:@"\r"]) {
        if (_signingIn && [[obj object] isEqual:self.passwordField.textField]) {
            [self signInAction:nil];
        } else if (!_signingIn && [[obj object] isEqual:self.confirmField.textField]) {
            [self signUpAction:nil];
        }
    }
}

@end
