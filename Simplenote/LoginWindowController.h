//
//  LoginWindowController.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/26/15.
//  Copyright © 2015 Simperium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Simplenote-Swift.h"
@import Simperium_OSX;



/**
 *  @class      LoginWindowController
 *  @brief      The purpose of this class is to extend Simperium's Authentication screen, and provide
 *              extra functionality, Simplenote-Y.
 */

@interface LoginWindowController : SPAuthenticationWindowController <NSWindowDelegate>
    @property (nonatomic, strong) WPAuthWindowController *wpAuthWindowController;
@end
