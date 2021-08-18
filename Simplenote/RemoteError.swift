import Foundation

enum RemoteError: Error {
    case network
    case requestError(Int, Error?)
}

extension RemoteError {
    var statusCode: Int {
        switch self {
        case .requestError(let statusCode, _):
            return statusCode
        default:
            return .zero
        }
    }
}

extension RemoteError: Equatable {
    static func == (lhs: RemoteError, rhs: RemoteError) -> Bool {
        switch (lhs, rhs) {
        case (.network, .network):
            return true
        case (.requestError(let lhsStatus, let lhsError), .requestError(let rhsStatus, let rhsError)):
            return lhsStatus == rhsStatus && lhsError?.localizedDescription == rhsError?.localizedDescription
        default:
            return false
        }
    }
}
