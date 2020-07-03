//
//  AboutViewController.swift
//  Simplenote
//

import Cocoa
import AutomatticTracks

class AboutViewController: NSViewController {
    struct Constants {
        static let blogUrl =       "https://simplenote.com/blog"
        static let twitterUrl =    "https://twitter.com/simplenoteapp"
        static let githubUrl =     "https://github.com/automattic/simplenote-macos"
        static let hiringUrl =     "https://automattic.com/work-with-us"
        static let privacyUrl =    "https://simplenote.com/privacy/"
        static let termsUrl =      "https://simplenote.com/terms/"
        static let californiaUrl = "https://wp.me/Pe4R-d/#california-consumer-privacy-act-ccpa"
    }

    @IBOutlet var logoImageView:    NSImageView!
    @IBOutlet var backgroundBox:    NSBox!
    @IBOutlet var blogLabel:        SPAboutTextField!
    @IBOutlet var twitterLabel:     SPAboutTextField!
    @IBOutlet var githubLabel:      SPAboutTextField!
    @IBOutlet var hiringLabel:      SPAboutTextField!
    @IBOutlet var privacyLabel:     SPAboutTextField!
    @IBOutlet var tosLabel:         SPAboutTextField!
    @IBOutlet var californiaLabel:  SPAboutTextField!
    @IBOutlet var versionLabel:     NSTextField!
    @IBOutlet var copyrightLabel:   NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logoImageView.image = NSImage(named: .simplenoteLogo)
        backgroundBox.fillColor = .simplenoteBrandColor

        let blogClick = NSClickGestureRecognizer(target: self, action: #selector(blogLabelClick))
        blogLabel.addGestureRecognizer(blogClick)
        
        let twitterClick = NSClickGestureRecognizer(target: self, action: #selector(twitterLabelClick))
        twitterLabel.addGestureRecognizer(twitterClick)

        let githubClick = NSClickGestureRecognizer(target: self, action: #selector(githubLabelClick))
        githubLabel.addGestureRecognizer(githubClick)
        
        let hiringClick = NSClickGestureRecognizer(target: self, action: #selector(hiringLabelClick))
        hiringLabel.addGestureRecognizer(hiringClick)
        
        let privacyClick = NSClickGestureRecognizer(target: self, action: #selector(privacyLabelClick))
        privacyLabel.addGestureRecognizer(privacyClick)
        
        let termsClick = NSClickGestureRecognizer(target: self, action: #selector(termsLabelClick))
        tosLabel.addGestureRecognizer(termsClick)

        let californiaClick = NSClickGestureRecognizer(target: self, action: #selector(californiaLabelClick))
        californiaLabel.addGestureRecognizer(californiaClick)
        
        // Display app version in the header
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let versionString = NSLocalizedString("Version %@", comment: "Version displayed in the about screen")
        versionLabel.stringValue = String(format: versionString, version)
        
        // Display the current year in the copyright footer
        let date = Date()
        let calendar = Calendar.current
        let thisYear = calendar.component(.year, from: date)
        let copyrightText = String(format: "© %d Automattic", thisYear) // No need for translation
        copyrightLabel.stringValue = copyrightText
    }
    
    @objc func blogLabelClick() {
        NSWorkspace.shared.open(URL(string: Constants.blogUrl)!)
    }
    
    @objc func twitterLabelClick() {
        NSWorkspace.shared.open(URL(string: Constants.twitterUrl)!)
    }

    @objc func githubLabelClick() {
        NSWorkspace.shared.open(URL(string: Constants.githubUrl)!)
    }
    
    @objc func hiringLabelClick() {
        NSWorkspace.shared.open(URL(string: Constants.hiringUrl)!)
    }
    
    @objc func privacyLabelClick() {
        NSWorkspace.shared.open(URL(string: Constants.privacyUrl)!)
    }
    
    @objc func termsLabelClick() {
        NSWorkspace.shared.open(URL(string: Constants.termsUrl)!)
    }

    @objc func californiaLabelClick() {
        NSWorkspace.shared.open(URL(string: Constants.californiaUrl)!)
    }
}
