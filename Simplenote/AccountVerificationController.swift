import Foundation


// MARK: - AccountVerificationController
//
struct AccountVerificationController {

    /// User's email
    ///
    let email: String


    /// Send verification request
    ///
    func verify(completion: @escaping (_ success: Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(true)
        }
    }
}
