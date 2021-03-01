#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
@import Simperium_OSX;



// MARK: - AuthViewController: Simperium's Authentication UI

@interface AuthViewController : NSViewController <SPAuthenticationInterface>

@property (nonatomic,   strong) SPAuthenticator *authenticator;
@property (nonatomic,   assign) BOOL            signingIn;

@end
