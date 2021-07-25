import Foundation


// MARK: - SignupRemote
//
class SignupRemote: Remote {

    /// Send signup request for specified email address
    ///
    func requestSignup(email: String, completion: @escaping (_ result: Result) -> Void) {
        guard let requestURL = request(with: email) else {
            completion(.failure(0, nil))
            return
        }

        performDataTask(with: requestURL, completion: completion)
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
