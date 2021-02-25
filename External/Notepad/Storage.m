#import "Storage.h"
#import "Simplenote-Swift.h"

@interface Storage ()
@property(nonatomic, strong) NSMutableAttributedString *backingStore;
@property(nonatomic, strong) Theme *theme;
@property(nonatomic, assign) BOOL skipRestyling;
@end

@implementation Storage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backingStore = [[NSMutableAttributedString alloc] init];
        [self configure];
    }
    return self;
}

- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr
{
    self = [super initWithAttributedString:attrStr];
    if (self) {
        self.backingStore = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
        [self configure];
    }
    return self;
}

- (void)configure
{
    self.theme = [[Theme alloc] initWithMarkdownEnabled:NO];
}

- (NSString *)string {
    return self.backingStore.string;
}

- (NSDictionary<NSAttributedStringKey,id> *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [self.backingStore attributesAtIndex:location effectiveRange:range];
}

/// Refreshes the receiver's Attributes. We must always do this since `Markdown` isn't the only variable: FontSize might have been also updated!
///
- (void)refreshStyleWithMarkdownEnabled:(BOOL)markdownEnabled
{
    self.theme = [[Theme alloc] initWithMarkdownEnabled:markdownEnabled];
    [self resetStyles];
}

/// Processes any edits made to the text in the editor.
///
- (void)processEditing
{
    if (self.skipRestyling) {
        [super processEditing];
        return;
    }

    NSRange lineRange = [[self string] lineRangeForRange:NSMakeRange(NSMaxRange(self.editedRange), 0)];
    NSRange extendedRange = NSUnionRange(self.editedRange, lineRange);

    [self applyStyles:extendedRange];

    [super processEditing];
}

- (void)endEditingWithoutRestyling {
    self.skipRestyling = YES;
    [self endEditing];
    self.skipRestyling = NO;
}

@end
