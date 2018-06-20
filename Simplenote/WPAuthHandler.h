//
//  WPAuthHandler.h
//  Simplenote
//  Handles oauth authentication with WordPress.com
//

@import Simperium_OSX;

@interface WPAuthHandler : NSObject
+ (BOOL)isWPAuthenticationUrl:(NSURL*)url;
+ (SPUser *)authorizeSimplenoteUserFromUrl:(NSURL*)url forAppId:(NSString *)appId;
@end
