//
//  SPTableView.h
//  Simplenote
//
//  Created by Michael Johnston on 7/26/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SPTableViewDelegate <NSTableViewDelegate>

@optional
- (nullable NSMenu *)tableView:(nonnull NSTableView *)tableView menuForTableColumn:(NSInteger)column row:(NSInteger)row;

/// Invoked whenever the TableView received a KeyDown event.
/// - Note: When this API returns `true`, further Event forwarding will be halted
///
- (BOOL)tableView:(nonnull NSTableView *)tableView didReceiveKeyDownEvent:(nonnull NSEvent *)event;

@end



IB_DESIGNABLE
@interface SPTableView : NSTableView<NSTextFieldDelegate>

/// AppKit will always ensure that the clicked row is visble. However, the SDK considers a row as being "not visible"
/// whenever the clicked row falls within the `contentInsets` area.
///
/// Meaning that even when a given row is fully visible, NSTableView might perform a scroll anyways, leading to a jumpy UX.
/// We're implementing a (opt-in) mechanism that disables Scrolling, during a mouseDown operation.
///
@property (nonatomic, assign, readwrite) IBInspectable BOOL disableAutoscrollOnMouseDown;
@property (nonatomic, assign, nullable) SEL returnAction;

@end
