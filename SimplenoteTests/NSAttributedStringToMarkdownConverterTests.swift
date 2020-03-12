import XCTest
@testable import Simplenote


// MARK: - NSAttributedStringToMarkdownConverter Unit Tests
//
class NSAttributedStringToMarkdownConverterTests: XCTestCase {

    /// Verifies that `NSAttributedStringToMarkdownConverter` properly converts `SPTextAttachment` instances into Markdown markers
    ///
    func testAttributedStringToMarkdownProperlyConvertsTextAttachmentsIntoMarkdownMarkers() {
        let (document, expected) = documentWithAttachments()
        let output = NSAttributedStringToMarkdownConverter.convert(string: document)

        XCTAssertEqual(output, expected)
    }

    /// Verifies that `NSAttributedStringToMarkdownConverter` does not alter NSAttributedStrings that contain no TextAttachments
    ///
    func testAttributedStringToMarkdownDoesNotAlterAttributedStringsWithoutAttachments() {
        let document = documentWithoutAttachments()
        let output = NSAttributedStringToMarkdownConverter.convert(string: document)

        XCTAssertEqual(output, document.string as NSString)
    }
}


// MARK: - Private Methods
//
private extension NSAttributedStringToMarkdownConverterTests {

    func documentWithAttachments(lines: Int = 100) -> (document: NSAttributedString, markdown: NSString) {
        let document = NSMutableAttributedString()
        var markdown = String()

        for index in 0 ..< lines {
            let isChecked = index % 2 == 0
            let prefix = isChecked ? "- [x]" : "- [ ]"
            let payload = " \(index)\n"

            let attachment = SPTextAttachment()
            attachment.isChecked = isChecked

            document.append(attachment: attachment)
            document.append(string: payload)

            markdown += prefix + payload
        }

        return (document, markdown as NSString)
    }

    func documentWithoutAttachments() -> NSAttributedString {
        let sample = """
                     orem ipsum dolor sit amet, consectetur adipiscing elit,
                     sed eiusmod tempor incidunt ut labore et dolore magna aliqua.
                     Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
                     nisi ut aliquid ex ea commodi consequat.
                     Quis aute iure reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
                     Excepteur sint obcaecat cupiditat non proident, sunt in culpa qui officia deserunt.
                     """

        return NSAttributedString(string: sample)
    }
}
