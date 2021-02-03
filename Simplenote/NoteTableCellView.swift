import Foundation
import AppKit


// MARK: - TagTableCellView
//
@objcMembers
class NoteTableCellView: NSTableCellView {

    /// TextField: Title
    ///
    @IBOutlet private var titleTextField: NSTextField!

    /// TextField: Body
    ///
    @IBOutlet private var bodyTextField: NSTextField!

    /// LeftImage: Pinned Indicator
    ///
    @IBOutlet private var pinnedImageView: NSImageView!

    /// RightImage: Shared Indicator
    ///
    @IBOutlet private var sharedImageView: NSImageView!

    /// Workaround: In AppKit, TableView Cell Selection works at the Row level
    ///
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            refreshSelectedState()
        }
    }

    /// Indicates if the receiver's associated NSTableRowView is *selected*
    ///
    private var selected = false {
        didSet {
            guard oldValue != selected else {
                return
            }

            refreshStyle()
        }
    }

    /// Indicates if the receiver displays the pinned indicator
    ///
    var displaysPinnedIndicator: Bool {
        get {
            !pinnedImageView.isHidden
        }
        set {
            pinnedImageView.isHidden = !newValue
        }
    }

    /// Indicates if the receiver displays the shared indicator
    ///
    var displaysSharedIndicator: Bool {
        get {
            !sharedImageView.isHidden
        }
        set {
            sharedImageView.isHidden = !newValue
        }
    }

    /// In condensed mode we simply won't render the bodyTextField
    ///
    var rendersInCondensedMode: Bool {
        get {
            bodyTextField.isHidden
        }
        set {
            bodyTextField.isHidden = newValue
        }
    }

    /// Note's Title
    /// - Note: Once the cell is fully initialized, please remember to run `refreshAttributedStrings`
    ///
    var title: String?

    /// Note's Body
    /// - Note: Once the cell is fully initialized, please remember to run `refreshAttributedStrings`
    ///
    var body: String?

    /// Body's Prefix: Designed to display Dates (with a slightly different style) when appropriate.
    ///
    var bodyPrefix: String?

    /// Keywords to use for higlighting title and body
    ///
    var keywords: [String]?


    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextFields()
        setupImageViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
}


// MARK: - Public API(s)
//
extension NoteTableCellView {

    /// Refreshes the receiver's style
    ///
    func refreshStyle() {
        refreshAttributedStrings()
        refreshAccessoryIcons()
    }

    /// Refreshed the Label(s) Attributed Strings: Keywords, Bullets and the Body Prefix will be taken into consideration
    ///
    private func refreshAttributedStrings() {
        titleTextField.attributedStringValue = titleString
        bodyTextField.attributedStringValue = bodyString
    }

    /// Refreshes the Accessory Icons tint color
    ///
    func refreshAccessoryIcons() {
        // We *don't wanna use* `imageView.contentTintColor` since on highlight it's automatically changing the tintColor!
        let pinnedColor: NSColor = selected ? .simplenoteTextColor : .simplenoteAccessoryTintColor
        let sharedColor: NSColor = selected ? .simplenoteTextColor : .simplenoteSecondaryTextColor

        pinnedImageView.image = pinnedImageView.image?.tinted(with: pinnedColor)
        sharedImageView.image = sharedImageView.image?.tinted(with: sharedColor)
    }
}


// MARK: - String Builders
//
private extension NoteTableCellView {

    var excerptHighlightColor: NSColor {
        selected ? .simplenoteSelectedExcerptHighlightColor : .simplenoteExcerptHighlightColor
    }

    var titleString: NSAttributedString {
        return title.map {
            return NSAttributedString.previewString(text: $0,
                                                    font: Fonts.title,
                                                    color: .simplenoteTextColor,
                                                    highlighting: (keywords: keywords, color: excerptHighlightColor, font: Fonts.title))
        } ?? NSAttributedString()
    }

    var bodyString: NSAttributedString {
        let bodyString = NSMutableAttributedString()
        let bodyColor: NSColor = selected ? .simplenoteTextColor : .simplenoteSecondaryTextColor

        if let bodyPrefix = bodyPrefix {
            bodyString += NSAttributedString.previewString(text: bodyPrefix + String.space, font: Fonts.bodyPrefix, color: .simplenoteTextColor)
        }

        if let bodySuffix = body {
            bodyString += NSAttributedString.previewString(text: bodySuffix,
                                                           font: Fonts.body,
                                                           color: bodyColor,
                                                           highlighting: (keywords: keywords, color: excerptHighlightColor, font: Fonts.bodyHighlight))
        }

        return bodyString
    }
}


// MARK: - Selection Workaround
//
private extension NoteTableCellView {

    func refreshSelectedState() {
        guard let row = superview as? NSTableRowView else {
            return
        }

        selected = row.isSelected
    }
}


// MARK: - Interface Initialization
//
private extension NoteTableCellView {

    func setupTextFields() {
        titleTextField.maximumNumberOfLines = Metrics.maximumNumberOfTitleLines
        bodyTextField.maximumNumberOfLines = Metrics.maximumNumberOfBodyLines
    }

    func setupImageViews() {
        pinnedImageView.image = NSImage(named: .pin)
        sharedImageView.image = NSImage(named: .shared)
    }

    func reset() {
        selected = false
    }
}


// MARK: - Interface Initialization
//
extension NoteTableCellView {

    /// Returns the Height that the receiver would require to be rendered, given the current User Settings (number of preview lines).
    ///
    /// Note: Why these calculations? (1) Performance and (2) we need to enforce two body lines
    ///
    @objc
    static var rowHeight: CGFloat {
        let outerInsets = Metrics.outerVerticalStackViewInsets
        let insertTitleHeight = outerInsets.top + Metrics.lineHeightForTitle + outerInsets.bottom

        if Options.shared.notesListCondensed {
            return insertTitleHeight
        }

        let bodyHeight = CGFloat(Metrics.maximumNumberOfBodyLines) * Metrics.lineHeightForBody
        return insertTitleHeight + Metrics.outerVerticalStackViewSpacing + bodyHeight
    }
}


// MARK: - Metrics!
//
private enum Metrics {
    static let lineHeightForTitle = Fonts.title.boundingRectForFont.height.rounded(.up)
    static let lineHeightForBody = Fonts.body.boundingRectForFont.height.rounded(.up)
    static let maximumNumberOfTitleLines = 1
    static let maximumNumberOfBodyLines = 2
    static let outerVerticalStackViewInsets = NSEdgeInsets(top: 9, left: 24, bottom: 9, right: 16)
    static let outerVerticalStackViewSpacing = CGFloat(2)
}


// MARK: - Interface Settings
//
private enum Fonts {
    static let title = NSFont.systemFont(ofSize: 14, weight: .semibold)

    static let body = NSFont.systemFont(ofSize: 12)
    static let bodyHighlight = NSFont.systemFont(ofSize: 12, weight: .semibold)

    static let bodyPrefix = NSFont.systemFont(ofSize: 12, weight: .semibold)
}


// MARK: - AttributedStrings Helpers
//
extension NSAttributedString {

    typealias KeywordHighlight = (keywords: [String]?, color: NSColor, font: NSFont)

    /// Returns a NSAttributedString representation of a given String, with the specified parameters.
    /// List Markers will be replaced by Text Attachments
    ///
    static func previewString(text: String,
                              font: NSFont,
                              color: NSColor,
                              highlighting highlight: KeywordHighlight? = nil) -> NSAttributedString {

        let attrString = NSMutableAttributedString(string: text)
        attrString.processChecklists(with: color, sizingFont: font, allowsMultiplePerLine: true)

        let fullRange = attrString.fullRange
        attrString.addAttribute(.font, value: font, range: fullRange)
        attrString.addAttribute(.foregroundColor, value: color, range: fullRange)

        if let highlight = highlight,
           let keywords = highlight.keywords, !keywords.isEmpty,
           let excerpt = attrString.string.contentSlice(matching: keywords) {

            for range in excerpt.nsMatches {
                attrString.addAttributes([
                    .foregroundColor: highlight.color,
                    .font: highlight.font
                ], range: range)
            }
        }

        return attrString
    }
}

func +=(lhs: NSMutableAttributedString, rhs: NSAttributedString) {
    lhs.append(rhs)
}
