//
//  LoginWindowController.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/26/15.
//  Copyright © 2015 Simperium. All rights reserved.
//

#import "LoginWindowController.h"
#import "SPTracker.h"


@implementation LoginWindowController


#pragma mark - Overriden Methods

- (IBAction)signUpAction:(id)sender
{
    [super signUpAction:sender];
    [SPTracker trackUserSignedUp];
}

- (IBAction)signInAction:(id)sender
{
    [super signInAction:sender];
    [SPTracker trackUserSignedIn];
}

@end
