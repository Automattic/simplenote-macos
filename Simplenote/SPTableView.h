//
//  SPTableView.h
//  Simplenote
//
//  Created by Michael Johnston on 7/26/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SPTextView.h"

@interface SPTableView : NSTableView<SPTextViewDelegate, NSTextFieldDelegate> {
    NSMutableArray *validFirstResponders;
}

- (void)addValidFirstResponder:(NSResponder *)responder;

@end
