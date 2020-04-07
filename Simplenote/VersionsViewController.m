#import "VersionsViewController.h"
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"


@interface VersionsViewController ()
@property (nonatomic, strong) IBOutlet NSTextField  *versionsTextField;
@property (nonatomic, strong) IBOutlet NSButton     *restoreButton;
@end

@implementation VersionsViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyStyle)
                                                 name:VSThemeManagerThemeDidChangeNotification
                                               object:nil];
    
    [self applyStyle];
}

- (void)applyStyle
{
    NSAssert(self.versionsTextField, @"Missing Outlet");
    NSAssert(self.restoreButton, @"Missing Outlet");
    
    VSTheme *theme                      = [[VSThemeManager sharedManager] theme];
    self.versionsTextField.textColor    = [theme colorForKey:@"popoverTextColor"];
}

@end
