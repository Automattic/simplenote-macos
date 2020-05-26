#import <Foundation/Foundation.h>

@class SPTextAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Styling)

/// Replaces List Markers with SPTextAttachment(s). Only one marker will be allowed per line.
///
/// @param color: Tinting Color to be applied over the Image.
///
/// @Discussion
/// This API is used by the Main Editor itself. When the AttributedString is rendered by a NSTextView, the
/// SPTextAttachment(s) can determine, by themselves, the required size.
///
- (void)processChecklistsWithColor:(NSColor *)color;

/// Replaces all of the List Markers in the receiver with SPTextAttachment(s).
///
/// @param color: Tinting Color to be applied over the Image.
/// @param sizingFont: Font that should be used to determine the Attachment Size. Nullable.
/// @param allowsMultiplePerLine: Indicates if multiple List Images can be added in a single line.
///
/// @Discussion
/// When *multiplePerLine* is set to true, we'll prepend a space to any attachment that's not at location Zero.
///
/// @Note
/// AttributedStrings rendered by NSTextField(s) require a Sizing Font to be passed along, since there is no
/// way to programatically access the Font being used.
///
/// This is extremely useful in the Notes List, so that Checklists can match the surrounding text.
///
- (void)processChecklistsWithColor:(NSColor *)color
                        sizingFont:(nullable NSFont *)sizingFont
             allowsMultiplePerLine:(BOOL)allowsMultiplePerLine;

@end

NS_ASSUME_NONNULL_END
