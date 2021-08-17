import Foundation

class Remote {
    private let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Send  task for remote
    /// Sublcassing Notes: To be able to send a task it is required to first setup the URL request for the task to use
    ///
    func performDataTask(with request: URLRequest, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let responseString = data.flatMap { String(data: $0, encoding: .utf8) }


                // Check for 2xx status code
                guard statusCode / 100 == 2 else {
                    let error = statusCode > 0 ?
                        RemoteError.requestError(statusCode, error, responseString):
                        RemoteError.network
                    completion(.failure(error))
                    return
                }

                completion(.success(data))
            }
        }

        dataTask.resume()
    }
}
