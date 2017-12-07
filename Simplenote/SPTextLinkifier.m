//
//  SPTextLinkifier.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 08/27/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import "SPTextLinkifier.h"
#import "NSTextView+Simplenote.h"
#import "NSView+Simplenote.h"



#pragma mark - Constants

static const NSTextCheckingType SPLinkifierSupportedTypes   = NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber;
static const NSString *SPLinkifierTextKeyPath               = @"string";

//#define SPTextLinkifierDebug true


#pragma mark - Notes

/**
                        Linkify       Unlinkify
 
    Linkify Enabled       x
    Linkify Disabled                      x
 
    Did Edit Text         x
 
    Text Replaced         x
    Scrolled              x
 
 */



#pragma mark - Private

@interface SPTextLinkifier ()
@property (nonatomic, strong) NSTextView        *textView;
@property (nonatomic, strong) NSDataDetector    *dataDetector;
@property (nonatomic, strong) NSCharacterSet    *nonDecimalCharacterSet;
@property (nonatomic, assign) NSRect            lastVisibleRect;
@end



#pragma mark - SPTextLinkifier

@implementation SPTextLinkifier

- (void)dealloc
{
    [self stopListeningToNotifications:_textView];
}

- (instancetype)initWithTextView:(NSTextView *)textView
{
    NSParameterAssert(textView);
    
    if (self = [super init]) {
        _textView               = textView;
        _enabled                = YES;
        _dataDetector           = [[NSDataDetector alloc] initWithTypes:SPLinkifierSupportedTypes error:nil];
        _nonDecimalCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        _lastVisibleRect        = NSZeroRect;
        
        [self startListeningToNotifications:textView];
    }
    
    return self;
}


#pragma mark - Static Helpers

+ (SPTextLinkifier *)linkifierWithTextView:(NSTextView *)textView
{
    return [[SPTextLinkifier alloc] initWithTextView:textView];
}



# pragma mark - Notification Helpers

- (void)startListeningToNotifications:(NSTextView *)textView
{
    NSParameterAssert(textView);
    
    // Listen to Scroll Events
    // Note:
    // We're not using 'NSScrollViewDidEndLiveScrollNotification', since it's not triggered by regular mouse
    // wheel events (or Key UP / Down)
    //
    NSScrollView *scrollView = textView.enclosingScrollView;
    NSClipView *contentView = scrollView.contentView;
    
    [contentView setPostsBoundsChangedNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBoundsDidChangeNote:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:contentView];
    
    // Listen to 'Text Updated' events
    for (NSString *keyPath in self.observedKeyPaths) {
        [textView addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)stopListeningToNotifications:(NSTextView *)textView
{
    NSParameterAssert(textView);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for (NSString *keyPath in self.observedKeyPaths) {
        [textView removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observedKeyPaths
{
    return @[ SPLinkifierTextKeyPath ];
}

- (void)handleBoundsDidChangeNote:(NSNotification *)note
{
#ifdef SPTextLinkifierDebug
    NSLog(@"### SPTextLinkifier: %@", NSStringFromSelector(_cmd));
#endif
    if (!self.enabled) {
        return;
    }
    
    // "Group" BoundsDidChange events fired within a 'Linkify Delay' milliseconds window.
    // Only used in Mountain Lion, due to the lack of 'Live Scroll Did End' Notification
    NSTimeInterval const linkifyDelay = 0.15;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(linkifyVisibleTextIfNeeded) object:nil];
    [self performSelector:@selector(linkifyVisibleTextIfNeeded) withObject:nil afterDelay:linkifyDelay];
}


#pragma mark - Properties

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    if (enabled) {
        [self linkifyVisibleText];
    } else {
        [self unlinkifyText];
    }
}



#pragma mark - KVO Handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
#ifdef SPTextLinkifierDebug
    NSLog(@"### SPTextLinkifier: Changed [%@]", keyPath);
#endif
    
    if (!self.enabled) {
        return;
    }
    
    // Issue #370:
    // Apparently, NSTextView is (breaking down miserably) whenever we replace the string, and begins
    // linkify'ing everything. Workaround: just remove and reapplying the NSLinkAttribute, on string
    // replace
    [self unlinkifyText];
    [self linkifyVisibleText];
}


#pragma mark - Optimized Linkifier

- (void)linkifyVisibleTextIfNeeded
{
    if (CGRectEqualToRect(self.textView.visibleRect, self.lastVisibleRect)) {
        return;
    }
    
    self.lastVisibleRect = self.textView.visibleRect;
    [self linkifyVisibleText];
}

- (void)linkifyVisibleText
{
#ifdef SPTextLinkifierDebug
    NSDate *begin = [NSDate date];
#endif
    
    // Helpers
    NSTextStorage *textStorage      = self.textView.textStorage;
    NSRange visibleRange            = [self.textView visibleTextRange];
    
    NSString *visibleString         = [textStorage.string substringWithRange:visibleRange];
    NSRange range                   = NSMakeRange(0, visibleString.length);
    
    // Detect Attributed Ranges
    NSMutableDictionary *linksMap   = [NSMutableDictionary dictionary];
    
    [self.dataDetector enumerateMatchesInString:visibleString
                                        options:0
                                          range:range
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSRange correctedRange = result.range;
         correctedRange.location += visibleRange.location;
         
         NSValue *wrappedRange = [NSValue valueWithRange:correctedRange];
         
         switch (result.resultType) {
             case NSTextCheckingTypeLink:
             {
                 if (result.URL) {
                     linksMap[wrappedRange] = result.URL;
                 }
                 break;
             }
             case NSTextCheckingTypePhoneNumber:
             {
                 NSArray *phoneDigits    = [result.phoneNumber componentsSeparatedByCharactersInSet:self.nonDecimalCharacterSet];
                 NSString *phoneNumber   = [phoneDigits componentsJoinedByString:[NSString string]];
                 NSString *wrappedPhone  = [NSString stringWithFormat:@"tel:%@", phoneNumber];
                 NSURL *phoneURL         = [NSURL URLWithString:wrappedPhone];
                 
                 if (phoneURL != nil) {
                     linksMap[wrappedRange] = phoneURL;
                 }
                 break;
             }
             default:
             {
                 break;
             }
         }
     }];
    
    
#ifdef SPTextLinkifierDebug
    NSLog(@"### SPTextLinkifier: Detectors Delta [%f]", begin.timeIntervalSinceNow);
#endif
    
    // Apply all of the detected Links in a single loop (++performance++)!!
    [textStorage beginEditing];
    
    for (NSValue *rangeValue in linksMap.allKeys) {
        NSURL *targetURL = linksMap[rangeValue];
        [textStorage addAttribute:NSLinkAttributeName value:targetURL range:rangeValue.rangeValue];
    }
    
    [textStorage endEditing];
    
#ifdef SPTextLinkifierDebug
    NSLog(@"### SPTextLinkifier: Link Count [%ld] Styles Delta [%f]", linksMap.count, begin.timeIntervalSinceNow);
#endif
}

- (void)unlinkifyText
{
    NSTextStorage *textStorage  = self.textView.textStorage;
    NSRange range               = NSMakeRange(0, textStorage.string.length);
    
    [textStorage beginEditing];
    [textStorage removeAttribute:NSLinkAttributeName range:range];
    [textStorage endEditing];
}

@end
