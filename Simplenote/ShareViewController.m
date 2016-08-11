//
//  ShareViewController.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 5/1/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "ShareViewController.h"
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"


@interface ShareViewController ()
@property (nonatomic, strong) IBOutlet NSTextField  *shareTextField;
@end

@implementation ShareViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyStyle)
                                                 name:VSThemeManagerThemeDidChangeNotification
                                               object:nil];
    
    [self applyStyle];
}

- (void)applyStyle
{
    NSAssert(self.shareTextField, @"Missing Outlet");
    
    VSTheme *theme                  = [[VSThemeManager sharedManager] theme];
    self.shareTextField.textColor   = [theme colorForKey:@"popoverTextColor"];
}

@end
