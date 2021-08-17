import Foundation

enum RemoteError: Error {
    case network
    case requestError(Int, Error?, String?)
}

extension RemoteError {
    var statusCode: Int {
        switch self {
        case .requestError(let statusCode, _, _):
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
        case (.requestError(let lhsStatus, let lhsError, let lhsResponse), .requestError(let rhsStatus, let rhsError, let rhsResponse)):
            return lhsStatus == rhsStatus && lhsError?.localizedDescription == rhsError?.localizedDescription && lhsResponse == rhsResponse
        default:
            return false
        }
    }
}
