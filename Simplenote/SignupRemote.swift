import Foundation


// MARK: - SignupRemote
//
class SignupRemote {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send signup request for specified email address
    ///
    func requestSignup(email: String, completion: @escaping (_ success: Bool, _ statusCode: Int) -> Void) {
        guard let requestURL = request(with: email) else {
            completion(false, .zero)
            return
        }

        let dataTask = urlSession.dataTask(with: requestURL) { (data, response, error) in
            DispatchQueue.main.async {
                guard let response = response as? HTTPURLResponse else {
                    // This should never, ever happen
                    completion(false, .zero)
                    return
                }

                // Check for 2xx status code
                let success = response.statusCode / 100 == 2
                completion(success, response.statusCode)
            }
        }

        dataTask.resume()
    }

    private func request(with email: String) -> URLRequest? {
        guard let url = URL(string: SimplenoteConstants.simplenoteRequestSignupURL) else {
            return nil
        }

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: RemoteConstants.timeout)
        request.httpMethod = RemoteConstants.Method.POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["username": email.lowercased()])

        return request
    }
}
