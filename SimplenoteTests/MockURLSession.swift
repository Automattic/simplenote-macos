import Foundation

// MARK: - MockURLSession
//
class MockURLSession: URLSession
{
    var data: (Data?, URLResponse?, Error?)?

    /// URLSession has deprecated its initializers. We must implement our own!
    ///
    override init() {
        // NO-OP
    }

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data?.0, self.data?.1, self.data?.2)
        }
    }
}
