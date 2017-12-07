//
//  SPSplitView.h
//  Simplenote
//
//  Created by Michael Johnston on 8/6/13.
//  Copyright (c) 2013 Simperium. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern const CGFloat SPSplitViewDefaultWidth;

typedef NS_ENUM(NSInteger, SPSplitViewSection) {
    SPSplitViewSectionTags      = 0,
    SPSplitViewSectionList      = 1
};


@interface SPSplitView : NSSplitView

@property (nonatomic, strong) NSString *simplenoteAutosaveName;

- (void)applyStyle;

@end
