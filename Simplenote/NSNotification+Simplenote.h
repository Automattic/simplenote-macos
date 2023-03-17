#import <Foundation/Foundation.h>


// MARK: - AAPL's Theme Notifications
//
extern NSString * const AppleInterfaceThemeChangedNotification;


// MARK: - Simplenote Notifications: Someone forgot to bridge NSNotification.Name over to ObjC. =(
//
extern NSString * const EditorDisplayModeDidChangeNotification;
extern NSString * const NoteListDisplayModeDidChangeNotification;
extern NSString * const NoteListSortModeDidChangeNotification;
extern NSString * const StatusBarDisplayModeDidChangeNotification;
extern NSString * const TagSortModeDidChangeNotification;
extern NSString * const ThemeDidChangeNotification;
extern NSString * const FontSizeDidChangeNotification;
extern NSString * const SplitViewStateDidChangeNotification;
