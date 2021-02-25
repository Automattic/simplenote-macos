import Foundation


// MARK: - AuthenticationRemote
//
class AuthenticationRemote {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send verification request for specified email address
    ///
    func requestSignup(email: String, completion: @escaping (_ success: Bool) -> Void) {
        guard let request = requestSignupURLRequest(for: email) else {
            completion(false)
            return
        }

        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                // Check for 2xx status code
                guard let response = response as? HTTPURLResponse, response.statusCode / 100 == 2 else {
                    completion(false)
                    return
                }

                completion(true)
            }
        }

        dataTask.resume()
    }

    private func requestSignupURLRequest(for email: String) -> URLRequest? {
        guard let base64EncodedEmail = email.data(using: .utf8)?.base64EncodedString(),
              let verificationURL = URL(string: SimplenoteConstants.simplenoteRequestSignupURL)
        else {
            return nil
        }

        var request = URLRequest(url: verificationURL.appendingPathComponent(base64EncodedEmail),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: Constants.timeoutInterval)
        request.httpMethod = Constants.httpMethod

        return request
    }
}

// MARK: - Constants
//
private struct Constants {
    static let httpMethod = "POST"
    static let timeoutInterval: TimeInterval = 30
}
