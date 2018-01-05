//
//  SPTextLinkifier.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 08/27/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Simplenote-Swift.h"


/**
 *  @class      SPTextLinkifier
 *  @brief      The purpose of this class is to handle Text Linkification for a given NSTextView Instance.
 *              We need to do this, by hand, since NSTextView's Data Detectors have an extremely poor performance 
 *              when dealing with huge documents, full of links.
 */

@interface SPTextLinkifier : NSObject

@property (nonatomic, strong,  readonly) NSTextView *textView;
@property (nonatomic, assign, readwrite) BOOL       enabled;

/**
 *  @details    Returns a new Linkifier Instance
 *  @param      textView    The TextView that requires Linkification Services.
 *  @returs                 The new Text Linkifier Instance.
 */
+ (SPTextLinkifier *)linkifierWithTextView:(NSTextView *)textView;

@end
