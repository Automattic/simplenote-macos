import Foundation

// MARK: - Helpers
//
extension Note {

    /// Given a collection of Tag Names, this API will return the subset that's not already associated with the receiver.
    ///
    func filterUnassociatedTagNames(from names: [String]) -> [String] {
        return names.filter { name in
            self.hasTag(name) == false
        }
    }
}

// MARK: - Previews
//
extension Note {

    /// Create title and body previews from content
    @objc
    func createPreview() {
        let (titleRange, bodyRange) = NoteContentHelper.structure(of: content)

        titlePreview = titlePreview(with: titleRange)
        bodyPreview = bodyPreview(with: bodyRange)
    }

    private func titlePreview(with range: Range<String.Index>?) -> String {
        guard let range = range, let content = content else {
            return NSLocalizedString("New note...", comment: "Empty Note Placeholder")
        }

        let result = String(content[range])
        return result.droppingPrefix(Constants.titleMarkdownPrefix)
    }

    private func bodyPreview(with range: Range<String.Index>?) -> String? {
        guard let range = range, let content = content else {
            return nil
        }

        let upperBound = content.index(range.lowerBound, offsetBy: Constants.bodyPreviewCap, limitedBy: range.upperBound) ?? range.upperBound
        let cappedRange = range.lowerBound..<upperBound

        return String(content[cappedRange]).replacingNewlinesWithSpaces()
    }
}

// MARK: - Excerpt
//
extension Note {

    /// Returns excerpt of the content around the first match of one of the keywords
    ///
    func bodyExcerpt(keywords: [String]?) -> String? {
        guard let keywords = keywords, !keywords.isEmpty, let content = content?.precomposedStringWithCanonicalMapping else {
            return bodyPreview
        }

        guard let bodyRange = NoteContentHelper.structure(of: content).body else {
            return nil
        }

        guard let excerpt = content.contentSlice(matching: keywords,
                                                 in: bodyRange,
                                                 leadingLimit: Constants.excerptLeadingLimit,
                                                 trailingLimit: Constants.excerptTrailingLimit) else {
            return bodyPreview
        }

        let shouldAddEllipsis = excerpt.range.lowerBound > bodyRange.lowerBound
        let excerptString = (shouldAddEllipsis ? "…" : "") + excerpt.slicedContent

        return excerptString.replacingNewlinesWithSpaces()
    }
}

// MARK: - Constants
//
private struct Constants {
    /// Markdown prefix to be removed from title preview
    ///
    static let titleMarkdownPrefix = "# "

    /// Limit for body preview
    ///
    static let bodyPreviewCap = 500

    /// Leading limit for body excerpt
    ///
    static let excerptLeadingLimit = 30

    /// Trailing limit for body excerpt
    static let excerptTrailingLimit = 300
}
