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

- (NSMenu *)tableView:(NSTableView *)tableView menuForTableColumn:(NSInteger)column row:(NSInteger)row;

@end



@interface SPTableView : NSTableView<SPTextViewDelegate, NSTextFieldDelegate>

@end
