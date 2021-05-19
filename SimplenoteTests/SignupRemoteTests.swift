import XCTest
@testable import Simplenote

class SignupRemoteTests: XCTestCase {
    private lazy var urlSession = MockURLSession()
    private lazy var signupRemote = SignupRemote(urlSession: urlSession)

    func testSuccessWhenStatusCodeIs2xx() {
        verifySignupSucceeds(withStatusCode: Int.random(in: 200..<300), email: "email@gmail.com", expectedSuccess: true)
    }

    func testFailureWhenStatusCodeIs4xxOr5xx() throws {
        // At some point in May 2021, we started experiencing CircleCI handing on this test case.
        // After some crude experimentation, it seems that this test is the culprit. We're skipping
        // it for the moment, while waiting for time to investigate better.
        //
        // - Failures examples:
        //   https://app.circleci.com/pipelines/github/Automattic/simplenote-macos?branch=merge%2Frelease-2.12-into-develop
        // - CI experimentation:
        //   https://app.circleci.com/pipelines/github/Automattic/simplenote-macos?branch=explore-ci-failures
        let isCI = (ProcessInfo.processInfo.environment["CIRCLECI"] ?? "").isEmpty == false
        try XCTSkipIf(isCI, "Skipped because it seems to be leading to timeous in CI")

        let statusCode = Int.random(in: 400..<600)
        verifySignupSucceeds(withStatusCode: statusCode, email: "email@gmail.com", expectedSuccess: false)
    }

    func testRequestSetsEmailToCorrectCase() throws {
        signupRemote.requestSignup(email: "EMAIL@gmail.com", completion: { _, _ in })

        let expecation = "email@gmail.com"
        let body: Dictionary<String, String> = try XCTUnwrap(urlSession.lastRequest?.decodeHtmlBody())
        let decodedEmail = try XCTUnwrap(body["username"])

        XCTAssertEqual(expecation, decodedEmail)
    }

    func testRequestSetsEmailToCorrectCaseWithSpecialCharacters() throws {
        signupRemote.requestSignup(email: "EMAIL123456@#$%^@gmail.com", completion: { _, _ in })

        let expecation = "email123456@#$%^@gmail.com"
        let body: Dictionary<String, String> = try XCTUnwrap(urlSession.lastRequest?.decodeHtmlBody())
        let decodedEmail = try XCTUnwrap(body["username"])

        XCTAssertEqual(expecation, decodedEmail)
    }

    func testRequestSetsEmailToCorrectCaseWithMixedCase() throws {
        signupRemote.requestSignup(email: "eMaIl@gmail.com", completion: { _, _ in })

        let expecation = "email@gmail.com"
        let body: Dictionary<String, String> = try XCTUnwrap(urlSession.lastRequest?.decodeHtmlBody())
        let decodedEmail = try XCTUnwrap(body["username"])

        XCTAssertEqual(expecation, decodedEmail)
    }
}

private extension SignupRemoteTests {
    func verifySignupSucceeds(withStatusCode statusCode: Int, email: String, expectedSuccess: Bool) {
        urlSession.data = (nil,
                           mockResponse(with: statusCode),
                           nil)

        let expectation = self.expectation(description: "Verify is called")

        signupRemote.requestSignup(email: email) { (success, _) in
            XCTAssertEqual(success, expectedSuccess)
            expectation.fulfill()
        }

        waitForExpectations(timeout: Constants.expectationTimeout, handler: nil)
    }

    func mockResponse(with statusCode: Int) -> HTTPURLResponse? {
        return HTTPURLResponse(url: URL(fileURLWithPath: "/"),
                               statusCode: statusCode,
                               httpVersion: nil,
                               headerFields: nil)
    }
}
