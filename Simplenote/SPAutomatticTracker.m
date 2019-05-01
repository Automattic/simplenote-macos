//
//  SPAutomatticTracker.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/9/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "SPAutomatticTracker.h"
#import "TracksService.h"



static NSString *const TracksUserDefaultsAnonymousUserIDKey = @"TracksUserDefaultsAnonymousUserIDKey";
static NSString *const TracksUserDefaultsLoggedInUserIDKey  = @"TracksUserDefaultsLoggedInUserIDKey";
static NSString *const TracksEventNamePrefix                = @"sposx";
static NSString *const TracksAuthenticatedUserTypeKey       = @"simplenote:user_id";


@interface SPAutomatticTracker ()
@property (nonatomic, strong) TracksContextManager  *contextManager;
@property (nonatomic, strong) TracksService         *tracksService;
@property (nonatomic, strong) NSString              *anonymousID;
@property (nonatomic, strong) NSString              *loggedInID;
@end


@implementation SPAutomatticTracker

@synthesize loggedInID = _loggedInID;
@synthesize anonymousID = _anonymousID;

- (instancetype)init
{
    self = [super init];
    if (self) {
        TracksContextManager *contextManager = [TracksContextManager new];
        NSParameterAssert(contextManager);
        
        TracksService *service  = [[TracksService alloc] initWithContextManager:contextManager];
        service.eventNamePrefix = TracksEventNamePrefix;
        service.authenticatedUserTypeKey = TracksAuthenticatedUserTypeKey;
        NSParameterAssert(service);
        
        _tracksService          = service;
        _contextManager         = contextManager;
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static SPAutomatticTracker *_tracker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tracker = [self new];
    });
    
    return _tracker;
}



#pragma mark - Public Methods

- (void)refreshMetadataWithEmail:(NSString *)email
{
    NSParameterAssert(self.tracksService);
    NSMutableDictionary *userProperties = [NSMutableDictionary new];
    userProperties[@"platform"] = @"OSX";

    [self.tracksService.userProperties removeAllObjects];
    [self.tracksService.userProperties addEntriesFromDictionary:userProperties];

    if (self.loggedInID.length == 0) {
        // No previous username logged
        self.loggedInID = email;
        self.anonymousID = nil;
        [self.tracksService switchToAuthenticatedUserWithUsername:@"" userID:email skipAliasEventCreation:NO];
    } else if ([self.loggedInID isEqualToString:email]){
        // Username did not change from last call to this method → just make sure Tracks client has it
        [self.tracksService switchToAuthenticatedUserWithUsername:@"" userID:email skipAliasEventCreation:YES];
    } else {
        // Username changed for some reason → switch back to anonymous first
        [self.tracksService switchToAnonymousUserWithAnonymousID:self.anonymousID];
        [self.tracksService switchToAuthenticatedUserWithUsername:@"" userID:email skipAliasEventCreation:NO];
        self.loggedInID = email;
        self.anonymousID = nil;
    }
}

- (void)refreshMetadataForAnonymousUser
{
    NSParameterAssert(self.tracksService);
    [self.tracksService switchToAnonymousUserWithAnonymousID:self.anonymousID];
    self.loggedInID = nil;
}

- (void)trackEventWithName:(NSString *)name properties:(NSDictionary *)properties
{
    NSParameterAssert(name);
    NSParameterAssert(self.tracksService);
    
    [self.tracksService trackEventName:name withCustomProperties:properties];
    if (properties == nil) {
        NSLog(@"🔵 Tracked: %@", name);
    } else {
        NSLog(@"🔵 Tracked: %@, properties: %@", name, properties);
    }
}

#pragma mark - Private property getter + setters

- (NSString *)anonymousID
{
    if (_anonymousID == nil || _anonymousID.length == 0) {
        NSString *anonymousID = [[NSUserDefaults standardUserDefaults] stringForKey:TracksUserDefaultsAnonymousUserIDKey];
        if (anonymousID == nil) {
            anonymousID = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setObject:anonymousID forKey:TracksUserDefaultsAnonymousUserIDKey];
        }

        _anonymousID = anonymousID;
    }

    return _anonymousID;
}

- (void)setAnonymousID:(NSString *)anonymousID
{
    _anonymousID = anonymousID;

    if (anonymousID == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TracksUserDefaultsAnonymousUserIDKey];
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:anonymousID forKey:TracksUserDefaultsAnonymousUserIDKey];
}

- (NSString *)loggedInID
{
    if (_loggedInID == nil || _loggedInID.length == 0) {
        NSString *loggedInID = [[NSUserDefaults standardUserDefaults] stringForKey:TracksUserDefaultsLoggedInUserIDKey];
        if (loggedInID != nil) {
            _loggedInID = loggedInID;
        }
    }

    return _loggedInID;
}

- (void)setLoggedInID:(NSString *)loggedInID
{
    _loggedInID = loggedInID;

    if (loggedInID == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TracksUserDefaultsLoggedInUserIDKey];
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:loggedInID forKey:TracksUserDefaultsLoggedInUserIDKey];
}

@end
