//
//  CustomTokenField.h
//  Simplenote
//
//  Created by Rainieri Ventura on 4/8/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "NoteEditorViewController.h"

@interface SPTokenField : NSTokenField <NSTextFieldDelegate, NSControlTextEditingDelegate>{
    IBOutlet NoteEditorViewController *noteEditorViewController;
}

@end
