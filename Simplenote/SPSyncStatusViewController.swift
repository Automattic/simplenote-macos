//
//  SPSyncStatusViewController.swift
//  Simplenote
//
//  Created by Dan Roundhill on 2/7/19.
//  Copyright © 2019 Simperium. All rights reserved.
//

import Cocoa

class SPSyncStatusViewController: NSViewController {
    
    @IBOutlet var resolveSyncView:      NSView!
    @IBOutlet var allGoodSyncView:      NSView!
    @IBOutlet var iconImageView:        NSImageView!
    @IBOutlet var notesTextView:        NSTextView!
    @IBOutlet var lastSyncTextField:    NSTextField!
    @IBOutlet var syncTitleTextField:   NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = NSApplication.shared.delegate as! SimplenoteAppDelegate
        let simperium = delegate.simperium
        
        //let isOffline = simperium!.reachability.currentReachabilityStatus() == NotReachable
        
        let unsyncedNotes = StatusChecker.getUnsyncedNoteTitles(simperium)
        
        // 2 UI States: Sync Complete, and Resolve
        if (unsyncedNotes != "") {
            allGoodSyncView.isHidden = true
            resolveSyncView.isHidden = false
            notesTextView.string = unsyncedNotes!
        } else {
            resolveSyncView.isHidden = true
            allGoodSyncView.isHidden = false
            
            let lastSyncDate = UserDefaults.standard.object(forKey: SPLastSyncDateKey) as! NSDate
            let lastSyncString = String(format: "Last sync: %@", lastSyncDate.timeAgoSinceDate(numericDates: false))
            lastSyncTextField.stringValue = lastSyncString
            
            syncTitleTextField.stringValue = "All Changes Synced"
            
            let theme = VSThemeManager.shared()?.theme()
            iconImageView.image = NSImage(named: "icon_sync_checkmark", colorizeWith: theme?.color(forKey: "tintColor"))
        }
        
    }
    
}
