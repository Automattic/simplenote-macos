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

- (BOOL)restoreActionEnabled
{
    return self.restoreButton.enabled;
}

- (void)setRestoreActionEnabled:(BOOL)restoreActionEnabled
{
    self.restoreButton.enabled = restoreActionEnabled;
}
}

@end
