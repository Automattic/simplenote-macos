#import "VersionsViewController.h"
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"


@interface VersionsViewController ()
@property (nonatomic, strong) IBOutlet NSSlider     *versionSlider;
@property (nonatomic, strong) IBOutlet NSTextField  *versionTextField;
@property (nonatomic, strong) IBOutlet NSButton     *restoreButton;
@end

@implementation VersionsViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startListeningToNotifications];
    [self applyStyle];
}

- (void)startListeningToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyStyle)
                                                 name:VSThemeManagerThemeDidChangeNotification
                                               object:nil];
}

- (void)applyStyle
{
    NSParameterAssert(self.versionSlider);
    NSParameterAssert(self.versionTextField);
    NSParameterAssert(self.restoreButton);
    
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    self.versionTextField.textColor = [theme colorForKey:@"popoverTextColor"];
}


#pragma mark - Public API(s)

- (void)updateSliderWithMinimum:(NSInteger)minimum maximum:(NSInteger)maximum
{
    self.versionSlider.maxValue = maximum;
    self.versionSlider.minValue = minimum;
    self.versionSlider.numberOfTickMarks = maximum - minimum + 1;
    [self.versionSlider setObjectValue:@(maximum)];
}


#pragma mark - Properties

- (BOOL)restoreActionEnabled
{
    return self.restoreButton.enabled;
}

- (void)setRestoreActionEnabled:(BOOL)restoreActionEnabled
{
    self.restoreButton.enabled = restoreActionEnabled;
}

- (NSString *)versionText
{
    return self.versionTextField.stringValue;
}

- (void)setVersionText:(NSString *)text
{
    self.versionTextField.stringValue = text;
}

- (NSInteger)maxSliderValue
{
    return self.versionSlider.maxValue;
}


#pragma mark - IBAction(s)

- (IBAction)restoreWasPressed:(id)sender
{
    [self.delegate versionsControllerDidClickRestore:self];
}

- (IBAction)versionSliderChanged:(id)sender
{
    [self.delegate versionsController:self updatedSlider:self.versionSlider.integerValue];
}

@end
