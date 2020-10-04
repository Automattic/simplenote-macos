import Foundation


// MARK: - NSStoryboard: Helper API(s)
//
extension NSStoryboard {

    func instantiateViewController<T: NSViewController>(ofType type: T.Type) -> T {
        guard let target = instantiateController(withIdentifier: T.sceneIdentifier) as? T else {
            fatalError()
        }

        return target
    }
}


// MARK: - NSStoryboard.Name
//
extension NSStoryboard.Name {
    static let main = "Main"
}


// MARK: - NSStoryboard.SceneIdentifier + NSViewController
//
extension NSViewController {

    static var sceneIdentifier: NSStoryboard.SceneIdentifier {
        classNameWithoutNamespaces
    }
}
