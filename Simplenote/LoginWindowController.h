//
//  LoginWindowController.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/26/15.
//  Copyright © 2015 Simperium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
@import Simperium_OSX;



/**
 *  @class      LoginWindowController
 *  @brief      The purpose of this class is to extend Simperium's Authentication screen, and provide
 *              extra functionality, Simplenote-Y.
 */

@interface LoginWindowController : NSWindowController <SPAuthenticationInterface>

@property (nonatomic,   strong) SPAuthenticator             *authenticator;
@property (nonatomic,   strong) SPAuthenticationValidator   *validator;
@property (nonatomic,   assign) BOOL                        optional;
@property (nonatomic,   assign) BOOL                        signingIn;
@property (nonatomic, readonly) BOOL                        isAnimatingProgress;

- (IBAction)signUpAction:(id)sender;
- (IBAction)signInAction:(id)sender;

@end
