#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - SPHorizontalScrollView
//          This NSScrollView subclass remaps Vertical Scroll events into Horizontal Scroll events, in order to
//          support ScrollWheel events performed with a mouse (single axis device!).
//
@interface SPHorizontalScrollView : NSScrollView

@end

NS_ASSUME_NONNULL_END
