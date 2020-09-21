//
//  SPTableView.h
//  Simplenote
//
//  Created by Michael Johnston on 7/26/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SPTextView.h"

@protocol SPTableViewDelegate <NSTableViewDelegate>

- (nullable NSMenu *)tableView:(nonnull NSTableView *)tableView menuForTableColumn:(NSInteger)column row:(NSInteger)row;

@end



IB_DESIGNABLE
@interface SPTableView : NSTableView<SPTextViewDelegate, NSTextFieldDelegate>

/// AppKit will always ensure that the clicked row is visble. However, the SDK considers a row as being "not visible"
/// whenever the clicked row falls within the `contentInsets` area.
///
/// Meaning that even when a given row is fully visible, NSTableView might perform a scroll anyways, leading to a jumpy UX.
/// We're implementing a (opt-in) mechanism that disables Scrolling, during a mouseDown operation.
///
@property (nonatomic, assign) IBInspectable BOOL disableAutoscrollOnMouseDown;

@end
