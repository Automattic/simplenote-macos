//
//  SPTextView.h
//  Simplenote
//
//  Created by Michael Johnston on 8/7/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kMinEditorPadding 20
#define kEditorWidthPreferencesKey @"kEditorWidthPreferencesKey"
#define kChecklistRegexPattern @"^- (\\[([ |x])\\])"

@protocol SPTextViewDelegate <NSTextViewDelegate>
- (void)didClickTextView:(id)sender;
@end

@interface SPTextView : NSTextView

- (void)processChecklists;
- (NSString *)getPlainTextContent;

@end
