import Cocoa


class AboutViewController: NSViewController {
    private enum Constants {
        static let blogUrl =       "https://simplenote.com/blog"
        static let twitterUrl =    "https://twitter.com/simplenoteapp"
        static let githubUrl =     "https://github.com/automattic/simplenote-macos"
        static let helpUrl =       "https://simplenote.com/help"
        static let hiringUrl =     "https://automattic.com/work-with-us"
        static let privacyUrl =    "https://simplenote.com/privacy/"
        static let termsUrl =      "https://simplenote.com/terms/"
        static let californiaUrl = "https://wp.me/Pe4R-d/#california-consumer-privacy-act-ccpa"
    }

    /// Background
    ///
    @IBOutlet private var backgroundBox:    NSBox!

    /// Logo
    ///
    @IBOutlet private var logoImageView:    NSImageView!

    /// Blog
    ///
    @IBOutlet private var blogView:         BackgroundView!
    @IBOutlet private var twitterView:      BackgroundView!
    @IBOutlet private var githubView:       BackgroundView!
    @IBOutlet private var hiringView:       BackgroundView!
    @IBOutlet private var contactView:      BackgroundView!

    /// Labels
    ///
    @IBOutlet private var hiringTitleLabel: NSTextField!
    @IBOutlet private var hiringTextLabel:  NSTextField!
    @IBOutlet private var helpLabel:        NSTextField!
    @IBOutlet private var contactLabel:     NSTextField!
    @IBOutlet private var tosLabel:         SPAboutTextField!
    @IBOutlet private var privacyLabel:     SPAboutTextField!
    @IBOutlet private var californiaLabel:  SPAboutTextField!
    @IBOutlet private var versionLabel:     NSTextField!
    @IBOutlet private var copyrightLabel:   NSTextField!


    // MARK: - Overridden API(s)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogoImage()
        setupBlogView()
        setupTwitterView()
        setupGithubView()
        setupHiringView()
        setupContactView()
        setupLegalLabels()
        setupVersionLabel()
        setupCopyrightLabel()
    }

    func setupLogoImage() {
        logoImageView.image = NSImage(named: .simplenoteLogo)
        backgroundBox.fillColor = .simplenoteBrandColor
    }

    func setupBlogView() {
        let blogClick = NSClickGestureRecognizer(target: self, action: #selector(blogLabelClick))
        blogView.addGestureRecognizer(blogClick)
        blogView.cursor = .pointingHand
    }

    func setupTwitterView() {
        let twitterClick = NSClickGestureRecognizer(target: self, action: #selector(twitterLabelClick))
        twitterView.addGestureRecognizer(twitterClick)
        twitterView.cursor = .pointingHand
    }

    func setupGithubView() {
        let githubClick = NSClickGestureRecognizer(target: self, action: #selector(githubLabelClick))
        githubView.addGestureRecognizer(githubClick)
        githubView.cursor = .pointingHand
    }

    func setupHiringView() {
        let hiringClick = NSClickGestureRecognizer(target: self, action: #selector(hiringLabelClick))
        hiringView.addGestureRecognizer(hiringClick)
        hiringView.cursor = .pointingHand

        hiringTitleLabel.stringValue = NSLocalizedString("Work with Us", comment: "Hiring Title")
        hiringTextLabel.stringValue = NSLocalizedString("Are you a developer? Automattic is Hiring.", comment: "Hiring Details")
    }

    func setupContactView() {
        let contactClick = NSClickGestureRecognizer(target: self, action: #selector(helpLabelClick))
        contactView.addGestureRecognizer(contactClick)
        contactView.cursor = .pointingHand

        helpLabel.stringValue = NSLocalizedString("Get Help", comment: "FAQ or contact us")
        contactLabel.stringValue = NSLocalizedString("FAQ or contact us", comment: "Get Help Description Label")
    }

    func setupLegalLabels() {
        let privacyClick = NSClickGestureRecognizer(target: self, action: #selector(privacyLabelClick))
        privacyLabel.addGestureRecognizer(privacyClick)

        let termsClick = NSClickGestureRecognizer(target: self, action: #selector(termsLabelClick))
        tosLabel.addGestureRecognizer(termsClick)

        let californiaClick = NSClickGestureRecognizer(target: self, action: #selector(californiaLabelClick))
        californiaLabel.addGestureRecognizer(californiaClick)
    }

    func setupVersionLabel() {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let versionString = NSLocalizedString("Version %@", comment: "Version displayed in the about screen")
        versionLabel.stringValue = String(format: versionString, version)
    }

    func setupCopyrightLabel() {
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

    @objc func helpLabelClick() {
        NSWorkspace.shared.open(URL(string: Constants.helpUrl)!)
    }
    
    @objc func termsLabelClick() {
        NSWorkspace.shared.open(URL(string: Constants.termsUrl)!)
    }

    @objc func californiaLabelClick() {
        NSWorkspace.shared.open(URL(string: Constants.californiaUrl)!)
    }
}
