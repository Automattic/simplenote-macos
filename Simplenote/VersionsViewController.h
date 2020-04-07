#import <Cocoa/Cocoa.h>

@interface VersionsViewController : NSViewController

@property (nonatomic, copy)     NSString                            *versionText;
@property (nonatomic, assign)   BOOL                                restoreActionEnabled;

@end
