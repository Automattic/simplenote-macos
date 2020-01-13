//
//  SPConstants.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/23/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "SPConstants.h"



#pragma mark ====================================================================================
#pragma mark Constants
#pragma mark ====================================================================================

NSString * const SPWelcomeNoteID                    = @"welcomeNote-Mac";

NSString * const SPSimperiumPreferencesObjectKey    = @"preferences-key";
NSString * const SPAutomatticAnalyticCookiesURL     = @"https://automattic.com/cookies";
NSString * const SPAutomatticAnalyticPrivacyURL     = @"https://automattic.com/privacy";

NSString * const SPSimplenotePublishURL             = @"http://simp.ly/publish/";
NSString * const SPSimplenoteForgotPasswordURL      = @"https://app.simplenote.com/forgot/";
NSString * const SPSimplenoteLogoImageName          = @"logo";
NSString * const SPWPServiceName                    = @"simplenote-wpcom";
NSString * const SPSignInErrorNotificationName      = @"SPSignInErrorNotificationName";
NSString * const SPWPSignInAuthURL                  = @"https://public-api.wordpress.com/oauth2/authorize?response_type=code&scope=global&client_id=%@&redirect_uri=%@&state=%@";
NSString * const SPHelpURL                          = @"https://simplenote.com/help";
NSString * const SPContactUsURL                     = @"https://simplenote.com/contact-us";
NSString * const SPTwitterURL                       = @"https://twitter.com/simplenoteapp";

#if APP_STORE_BUILD
NSString * const SPBuildType                       = @"app-store";
#elif PUBLIC_BUILD
NSString * const SPBuildType                       = @"public";
#else
NSString * const SPBuildType                       = @"developer-internal";
#endif
