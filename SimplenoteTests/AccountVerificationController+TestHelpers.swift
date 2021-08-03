import Foundation
@testable import Simplenote

extension AccountVerificationController {
    func randomResult() -> Result<Data?, RemoteError> {
        return Bool.random() ? .success(nil) : .failure(RemoteError.requestError(0, nil))
    }
}
