//
//  SPTracker.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/17/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  @class      SPTracker
 *  @brief      This class is meant to aid in the app's event tracking. We'll relay the appropriate events to
 *              either Automattic Tracks, or Google Analytics.
 */

NS_ASSUME_NONNULL_BEGIN

@interface SPTracker : NSObject

#pragma mark - Metadata
+ (void)refreshMetadataWithEmail:(NSString *)email;
+ (void)refreshMetadataForAnonymousUser;

#pragma mark - Lifecycle
+ (void)trackApplicationLaunched;
+ (void)trackApplicationTerminated;

#pragma mark - Note Editor
+ (void)trackEditorCopiedInternalLink;
+ (void)trackEditorChecklistInserted;
+ (void)trackEditorNoteCreated;
+ (void)trackEditorNoteDeleted;
+ (void)trackEditorNoteRestored;
+ (void)trackEditorNotePublished;
+ (void)trackEditorNoteUnpublished;
+ (void)trackEditorNoteEdited;
+ (void)trackEditorTagAdded:(BOOL)isEmail;
+ (void)trackEditorTagRemoved:(BOOL)isEmail;
+ (void)trackEditorNotePinningToggled;
+ (void)trackEditorVersionsAccessed;
+ (void)trackEditorCollaboratorsAccessed;

#pragma mark - Note List
+ (void)trackListCopiedInternalLink;
+ (void)trackListNoteDeleted;
+ (void)trackListNoteDeletedForever;
+ (void)trackListNotePinningToggled;
+ (void)trackListNoteRestored;
+ (void)trackListNoteOpened;
+ (void)trackListTrashEmptied;
+ (void)trackListNotesSearched;
+ (void)trackListTrashPressed;

#pragma mark - Preferences
+ (void)trackSettingsFontSizeUpdated;
+ (void)trackSettingsAlphabeticalSortEnabled:(BOOL)isOn;
+ (void)trackSettingsThemeUpdated:(nullable NSString *)themeName;
+ (void)trackSettingsListCondensedEnabled:(BOOL)isOn;

#pragma mark - Sidebar
+ (void)trackSidebarButtonPresed;

#pragma mark - Tag List
+ (void)trackTagRowPressed;
+ (void)trackTagRowRenamed;
+ (void)trackTagRowDeleted;

#pragma mark - User
+ (void)trackUserSignedUp;
+ (void)trackUserSignedIn;
+ (void)trackUserSignedOut;

#pragma mark - WP.com Sign In
+ (void)trackWPCCButtonPressed;
+ (void)trackWPCCLoginSucceeded;
+ (void)trackWPCCLoginFailed;

@end

NS_ASSUME_NONNULL_END
