import XCTest
@testable import Simplenote

class SignupRemoteTests: XCTestCase {
    private lazy var urlSession = MockURLSession()
    private lazy var signupRemote = SignupRemote(urlSession: urlSession)

    func testSuccessWhenStatusCodeIs2xx() {
        verifySignupSucceeds(withStatusCode: Int.random(in: 200..<300), email: "email@gmail.com", expectedSuccess: Remote.Result.success)
    }

    func testFailureWhenStatusCodeIs4xxOr5xx() {
        let statusCode = Int.random(in: 400..<600)
        verifySignupSucceeds(withStatusCode: statusCode, email: "email@gmail.com", expectedSuccess: Remote.Result.failure(statusCode, nil))
    }

    func testRequestSetsEmailToCorrectCase() throws {
        signupRemote.requestSignup(email: "EMAIL@gmail.com", completion: { _ in })

        let expecation = "email@gmail.com"
        let body: Dictionary<String, String> = try XCTUnwrap(urlSession.lastRequest?.decodeHtmlBody())
        let decodedEmail = try XCTUnwrap(body["username"])

        XCTAssertEqual(expecation, decodedEmail)
    }

    func testRequestSetsEmailToCorrectCaseWithSpecialCharacters() throws {
        signupRemote.requestSignup(email: "EMAIL123456@#$%^@gmail.com", completion: { _ in })

        let expecation = "email123456@#$%^@gmail.com"
        let body: Dictionary<String, String> = try XCTUnwrap(urlSession.lastRequest?.decodeHtmlBody())
        let decodedEmail = try XCTUnwrap(body["username"])

        XCTAssertEqual(expecation, decodedEmail)
    }

    func testRequestSetsEmailToCorrectCaseWithMixedCase() throws {
        signupRemote.requestSignup(email: "eMaIl@gmail.com", completion: { _ in })

        let expecation = "email@gmail.com"
        let body: Dictionary<String, String> = try XCTUnwrap(urlSession.lastRequest?.decodeHtmlBody())
        let decodedEmail = try XCTUnwrap(body["username"])

        XCTAssertEqual(expecation, decodedEmail)
    }
}

private extension SignupRemoteTests {
    func verifySignupSucceeds(withStatusCode statusCode: Int, email: String, expectedSuccess: Remote.Result) {
        urlSession.data = (nil,
                           mockResponse(with: statusCode),
                           nil)

        let expectation = self.expectation(description: "Verify is called")

        signupRemote.requestSignup(email: email) { (result) in
            XCTAssertEqual(result, expectedSuccess)
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
