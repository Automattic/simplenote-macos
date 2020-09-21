import Foundation


// MARK: - Simperium + Simplenote API(s)
//
extension SPBucket {

    /// Returns all of the Bucket's objects of the specified type.
    /// - Note: This method should become irrelevant when Simperium's API is Swifted (OR) enhanced to support generics
    ///
    func allObjects<T: SPManagedObject>(ofType: T.Type) -> [T] {
        guard let results = allObjects() as? [T] else {
            return []
        }

        return results
    }

    /// Returns all of the Bucket's objects of the specified type, matching a given Predicate
    /// - Note: This method should become irrelevant when Simperium's API is Swifted (OR) enhanced to support generics
    ///
    func objects<T: SPManagedObject>(ofType: T.Type, for predicate: NSPredicate) -> [T] {
        guard let results = objects(for: predicate) as? [T] else {
            return []
        }

        return results
    }
}
