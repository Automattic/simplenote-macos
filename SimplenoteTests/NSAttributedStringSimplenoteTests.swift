import XCTest
@testable import Simplenote


// MARK: - NSAttributedString Unit Tests
//
class NSAttributedStringSimplenoteTests: XCTestCase {

    /// Verifies that `enumerateAttachments` calls the received closure with the ranges of the specified attachment kinds *ONLY*
    ///
    func testEnumerateAttachmentsEffectivelyPicksUpAttachmentsOfTheSpecifiedType() {
        let sample = NSMutableAttributedString()

        let attachment0 = SPTextAttachment()
        sample.append(attachment: attachment0)

        let attachment1 = NSTextAttachment()
        sample.append(attachment: attachment1)

        let expectation = self.expectation(description: "Enumeration!")
        sample.enumerateAttachments(of: SPTextAttachment.self) { (enumeratedAttachment, range) in
            XCTAssertEqual(range.location, .zero)
            XCTAssertEqual(enumeratedAttachment, attachment0)

            expectation.fulfill()
        }

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    /// Verifies that `numberOfAttachments` returns zero whenever the receiver has no attachments
    ///
    func testNumberOfAttachmentsReturnsZeroWheneverThereAreNoAttachments() {
        let count = NSAttributedString().numberOfAttachments
        XCTAssertEqual(count, .zero)
    }

    /// Verifies that `numberOfAttachments` returns zero whenever the receiver has no attachments
    ///
    func testNumberOfAttachmentsReturnsTheExpectedNumberOfAttachments() {
        let sample = NSMutableAttributedString()
        let count = 20

        for _ in 0 ..< count {
            sample.append(attachment: NSTextAttachment())
        }

        XCTAssertEqual(sample.numberOfAttachments, count)
    }

    /// Verifies that `rangeOfFirstAttachment(stringValue:)` returns the range of the first NSTextAttachment whose NSCell has the specified stringValue.
    ///
    func testRangeOfFirstAttachmentReturnsTheRangeOfTheFirstAttachmentWhoseCellContainsTheSpecifiedStringValue() {
        let attachmentCell = NSTextAttachmentCell()
        attachmentCell.stringValue = "1234"

        let attachment0 = NSTextAttachment()
        attachment0.attachmentCell = attachmentCell

        let attachment1 = NSTextAttachment()
        attachment1.attachmentCell = attachmentCell

        let text = "Something here "
        let sample = NSMutableAttributedString()
        sample.append(string: text)
        sample.append(attachment: attachment0)
        sample.append(attachment: attachment1)

        let range = sample.rangeOfFirstAttachment(stringValue: "1234")
        XCTAssertEqual(range!.location, text.count)
        XCTAssertEqual(range!.length, 1)
    }

    /// Verifies that `rangeOfFirstAttachment(stringValue:)` returns nil whenever none of the attachments has the specified `attachmentCell.stringValue`
    ///
    func testRangeOfFirstAttachmentReturnsNilWheneverNoneOfTheAttachmentsContainsTheSpecifiedValue() {
        let attachmentCell = NSTextAttachmentCell()
        attachmentCell.stringValue = "1234"

        let attachment0 = NSTextAttachment()
        attachment0.attachmentCell = attachmentCell

        let attachment1 = NSTextAttachment()
        attachment1.attachmentCell = attachmentCell

        let sample = NSMutableAttributedString()
        sample.append(string: "Something here ")
        sample.append(attachment: attachment0)
        sample.append(attachment: attachment1)

        let range = sample.rangeOfFirstAttachment(stringValue: "12345")
        XCTAssertNil(range)
    }
}
