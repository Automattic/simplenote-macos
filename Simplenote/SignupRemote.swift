import Foundation

// MARK: - SignupRemote
//
class SignupRemote: Remote {

    /// Send signup request for specified email address
    ///
    func requestSignup(email: String, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let requestURL = request(with: email)!

        performDataTask(with: requestURL, completion: completion)
    }

    private func request(with email: String) -> URLRequest? {
        let url = URL(string: SimplenoteConstants.simplenoteRequestSignupURL)!

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: RemoteConstants.timeout)
        request.httpMethod = RemoteConstants.Method.POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["username": email.lowercased()])

        return request
    }
}
