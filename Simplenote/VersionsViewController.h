#import <Cocoa/Cocoa.h>


@class VersionsViewController;

@protocol VersionsViewControllerDelegate <NSObject>
- (void)versionsController:(VersionsViewController *)sender updatedSlider:(NSInteger)newValue;
- (void)versionsControllerDidClickRestore:(VersionsViewController *)sender;
@end


@interface VersionsViewController : NSViewController

@property (nonatomic, weak)     id<VersionsViewControllerDelegate>  delegate;
@property (nonatomic, copy)     NSString                            *versionText;
@property (nonatomic, readonly) NSInteger                           maxSliderValue;
@property (nonatomic, assign)   BOOL                                restoreActionEnabled;

- (void)updateSliderWithMinimum:(NSInteger)minimum maximum:(NSInteger)maximum;

@end
