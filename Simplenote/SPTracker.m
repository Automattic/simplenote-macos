//
//  SPTracker.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/17/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import "SPTracker.h"
#import "SPAutomatticTracker.h"


@implementation SPTracker


#pragma mark - Metadata

+ (void)refreshMetadataWithEmail:(NSString *)email
{
    [[SPAutomatticTracker sharedInstance] refreshMetadataWithEmail:email];
}

+ (void)refreshMetadataForAnonymousUser
{
    [[SPAutomatticTracker sharedInstance] refreshMetadataForAnonymousUser];
}



#pragma mark - Lifecycle
+ (void)trackApplicationLaunched
{
    [self trackAutomatticEventWithName:@"application_launched" properties:nil];
}

+ (void)trackApplicationTerminated
{
    [self trackAutomatticEventWithName:@"application_terminated" properties:nil];
}


#pragma mark - Note Editor

+ (void)trackEditorNoteCreated
{
    [self trackAutomatticEventWithName:@"editor_note_created" properties:nil];
}

+ (void)trackEditorNoteDeleted
{
    [self trackAutomatticEventWithName:@"editor_note_deleted" properties:nil];
}

+ (void)trackEditorNoteRestored
{
    [self trackAutomatticEventWithName:@"editor_note_restored" properties:nil];
}

+ (void)trackEditorNotePublished
{
    [self trackAutomatticEventWithName:@"editor_note_published" properties:nil];
}

+ (void)trackEditorNoteUnpublished
{
    [self trackAutomatticEventWithName:@"editor_note_unpublished" properties:nil];
}

+ (void)trackEditorNoteEdited
{
    [self trackAutomatticEventWithName:@"editor_note_edited" properties:nil];
}

+ (void)trackEditorTagAdded:(BOOL)isEmail
{
    NSString *eventName = isEmail ? @"editor_email_tag_added" : @"editor_tag_added";
    [self trackAutomatticEventWithName:eventName properties:nil];
}

+ (void)trackEditorTagRemoved:(BOOL)isEmail
{
    NSString *eventName = isEmail ? @"editor_email_tag_removed" : @"editor_tag_removed";
    [self trackAutomatticEventWithName:eventName properties:nil];
}

+ (void)trackEditorTagsEdited
{
    [self trackAutomatticEventWithName:@"editor_tags_edited" properties:nil];
}

+ (void)trackEditorNotePinningToggled
{
    [self trackAutomatticEventWithName:@"editor_note_pinning_toggled" properties:nil];
}

+ (void)trackEditorCollaboratorsAccessed
{
    [self trackAutomatticEventWithName:@"editor_collaborators_accessed" properties:nil];
}

+ (void)trackEditorVersionsAccessed
{
    [self trackAutomatticEventWithName:@"editor_versions_accessed" properties:nil];
}



#pragma mark - Note List

+ (void)trackListNoteDeleted
{
    [self trackAutomatticEventWithName:@"list_note_deleted" properties:nil];
}

+ (void)trackListNoteOpened
{
    [self trackAutomatticEventWithName:@"list_note_opened" properties:nil];
}

+ (void)trackListTrashEmptied
{
    [self trackAutomatticEventWithName:@"list_trash_emptied" properties:nil];
}

+ (void)trackListNotesSearched
{
    [self trackAutomatticEventWithName:@"list_notes_searched" properties:nil];
}

+ (void)trackListTrashPressed
{
    [self trackAutomatticEventWithName:@"list_trash_viewed" properties:nil];
}



#pragma mark - Preferences

+ (void)trackSettingsFontSizeUpdated
{
    [self trackAutomatticEventWithName:@"settings_font_size_updated" properties:nil];
}

+ (void)trackSettingsAlphabeticalSortEnabled:(BOOL)isOn
{
    [self trackAutomatticEventWithName:@"settings_alphabetical_sort_enabled" properties:@{ @"enabled" : @(isOn) }];
}

+ (void)trackSettingsThemeUpdated:(NSString *)themeName
{
    NSParameterAssert(themeName);
    
    [self trackAutomatticEventWithName:@"settings_theme_updated" properties:@{ @"name" : themeName }];
}

+ (void)trackSettingsListCondensedEnabled
{
    [self trackAutomatticEventWithName:@"settings_list_condensed_enabled" properties:nil];
}



#pragma mark - Sidebar

+ (void)trackSidebarButtonPresed
{
    [self trackAutomatticEventWithName:@"sidebar_button_pressed" properties:nil];
}



#pragma mark - Tag List

+ (void)trackTagRowPressed
{
    [self trackAutomatticEventWithName:@"tag_cell_pressed" properties:nil];
}

+ (void)trackTagRowRenamed
{
    [self trackAutomatticEventWithName:@"tag_menu_renamed" properties:nil];
}

+ (void)trackTagRowDeleted
{
    [self trackAutomatticEventWithName:@"tag_menu_deleted" properties:nil];
}



#pragma mark - User

+ (void)trackUserSignedUp
{
    [self trackAutomatticEventWithName:@"user_account_created" properties:nil];
}

+ (void)trackUserSignedIn
{
    [self trackAutomatticEventWithName:@"user_signed_in" properties:nil];
}

+ (void)trackUserSignedOut
{
    [self trackAutomatticEventWithName:@"user_signed_out" properties:nil];
}



#pragma mark - Google Analytics Helpers

+ (void)trackAutomatticEventWithName:(NSString *)name properties:(NSDictionary *)properties
{
    [[SPAutomatticTracker sharedInstance] trackEventWithName:name properties:properties];
}

@end
