//
//  AboutViewController.swift
//  Simplenote
//

import Cocoa

class AboutViewController: NSViewController {
    let blogUrl =       "https://simplenote.com/blog"
    let twitterUrl =    "https://twitter.com/simplenoteapp"
    let appsUrl =       "https://simplenote.com"
    let githubUrl =     "https://github.com/automattic/simplenote-macos"
    let hiringUrl =     "https://automattic.com/work-with-us"
    let privacyUrl =    "https://simplenote.com/privacy/"
    let termsUrl =      "https://simplenote.com/terms/"
    
    @IBOutlet var blogLabel:        SPAboutTextField?
    @IBOutlet var twitterLabel:     SPAboutTextField?
    @IBOutlet var appsLabel:        SPAboutTextField?
    @IBOutlet var githubLabel:      SPAboutTextField?
    @IBOutlet var hiringLabel:      SPAboutTextField?
    @IBOutlet var privacyLabel:     SPAboutTextField?
    @IBOutlet var tosLabel:         SPAboutTextField?
    @IBOutlet var versionLabel:     NSTextField?
    @IBOutlet var copyrightLabel:   NSTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blogClick = NSClickGestureRecognizer(target: self, action: #selector(blogLabelClick))
        blogLabel?.addGestureRecognizer(blogClick)
        
        let twitterClick = NSClickGestureRecognizer(target: self, action: #selector(twitterLabelClick))
        twitterLabel?.addGestureRecognizer(twitterClick)
        
        let appsClick = NSClickGestureRecognizer(target: self, action: #selector(appsLabelClick))
        appsLabel?.addGestureRecognizer(appsClick)
        
        let githubClick = NSClickGestureRecognizer(target: self, action: #selector(githubLabelClick))
        githubLabel?.addGestureRecognizer(githubClick)
        
        let hiringClick = NSClickGestureRecognizer(target: self, action: #selector(hiringLabelClick))
        hiringLabel?.addGestureRecognizer(hiringClick)
        
        let privacyClick = NSClickGestureRecognizer(target: self, action: #selector(privacyLabelClick))
        privacyLabel?.addGestureRecognizer(privacyClick)
        
        let termsClick = NSClickGestureRecognizer(target: self, action: #selector(termsLabelClick))
        tosLabel?.addGestureRecognizer(termsClick)
        
        // Display app version in the header
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let versionString = NSLocalizedString("Version %@", comment: "Version displayed in the about screen")
        versionLabel?.stringValue = String(format: versionString, version)
        
        // Display the current year in the copyright footer
        let date = Date()
        let calendar = Calendar.current
        let thisYear = calendar.component(.year, from: date)
        let copyrightText = String(format: "© %d Automattic", thisYear) // No need for translation
        copyrightLabel?.stringValue = copyrightText
    }
    
    func blogLabelClick() {
        NSWorkspace.shared().open(URL(string: blogUrl)!)
    }
    
    func twitterLabelClick() {
        NSWorkspace.shared().open(URL(string: twitterUrl)!)
    }
    
    func appsLabelClick() {
        NSWorkspace.shared().open(URL(string: appsUrl)!)
    }
    
    func githubLabelClick() {
        NSWorkspace.shared().open(URL(string: githubUrl)!)
    }
    
    func hiringLabelClick() {
        NSWorkspace.shared().open(URL(string: hiringUrl)!)
    }
    
    func privacyLabelClick() {
        NSWorkspace.shared().open(URL(string: privacyUrl)!)
    }
    
    func termsLabelClick() {
        NSWorkspace.shared().open(URL(string: termsUrl)!)
    }
}
