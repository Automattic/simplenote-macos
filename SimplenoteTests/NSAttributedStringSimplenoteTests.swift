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

        waitForExpectations(timeout: TestConstants.defaultTimeout, handler: nil)
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
}
