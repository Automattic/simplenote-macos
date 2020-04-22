#import <Foundation/Foundation.h>

@class SPTextAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Styling)

- (NSArray<SPTextAttachment *> *)processChecklistsWithColor:(NSColor *)color;

@end

NS_ASSUME_NONNULL_END
