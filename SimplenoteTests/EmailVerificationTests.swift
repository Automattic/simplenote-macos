import XCTest
@testable import Simplenote


// MARK: - EmailVerificationTests
//
class EmailVerificationTests: XCTestCase {

    func testEmailVerificationCorrectlyParsesRemotePayload() {
        let payload: [String: Any] = [
            "token": "{ \"username\": \"test@test.com\", \"verified_at\": 1611171132 }",
            "token_signature": "token_signature"
        ]

        let verification = EmailVerification(payload: payload)!
        XCTAssertEqual(verification.username, "test@test.com")
        XCTAssertEqual(verification.timestamp, 1611171132)
        XCTAssertEqual(verification.signature, "token_signature")
    }
}
