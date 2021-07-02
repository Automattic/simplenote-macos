import Foundation

// MARK: - Verification
//
extension SPTracker {

    static func trackSettingsStatusBarDisplayMode(hidden: Bool) {
        trackAutomatticEvent(withName: "settings_sort_bar_display_mode", properties: ["hidden" : hidden])
    }

    static func trackVerificationReviewScreenViewed() {
        trackAutomatticEvent(withName: "verification_review_screen_viewed", properties: nil)
    }

    static func trackVerificationVerifyScreenViewed() {
        trackAutomatticEvent(withName: "verification_verify_screen_viewed", properties: nil)
    }

    static func trackVerificationConfirmButtonTapped() {
        trackAutomatticEvent(withName: "verification_confirm_button_tapped", properties: nil)
    }

    static func trackVerificationChangeEmailButtonTapped() {
        trackAutomatticEvent(withName: "verification_change_email_button_tapped", properties: nil)
    }

    static func trackVerificationResendEmailButtonTapped() {
        trackAutomatticEvent(withName: "verification_resend_email_button_tapped", properties: nil)
    }

    static func trackVerificationDismissed() {
        trackAutomatticEvent(withName: "verification_dismissed", properties: nil)
    }
}


// MARK: - Shortcuts
//
extension SPTracker {
    private static func trackShortcut(_ value: String) {
        trackAutomatticEvent(withName: "shortcut_used", properties: ["shortcut": value])
    }

    @objc
    static func trackToggleFocusMode() {
        trackShortcut("focus_mode")
    }

    static func trackShortcutSearch() {
        trackShortcut("focus_search")
    }

    static func trackShortcutToggleEditorAndTags() {
        trackShortcut("toggle_note_tag_editing")
    }

    static func trackShortcutCreateNote() {
        trackShortcut("create_note")
    }

    static func trackShortcutToggleMarkdownPreview() {
        trackShortcut("markdown")
    }

    @objc
    static func trackShortcutToggleChecklist() {
        trackShortcut("toggle_checklist")
    }

    @objc
    static func trackShortcutToggleSidebar() {
        trackShortcut("cycle_visible_panels")
    }
}
