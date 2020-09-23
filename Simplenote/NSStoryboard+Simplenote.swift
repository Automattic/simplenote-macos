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

    func instantiateWindowController<T: NSWindowController>(ofType type: T.Type) -> T {
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
    static let suggestions = "Suggestions"
}


// MARK: - NSStoryboard.SceneIdentifier + NSViewController
//
extension NSViewController {

    static var sceneIdentifier: NSStoryboard.SceneIdentifier {
        classNameWithoutNamespaces
    }
}


// MARK: - NSStoryboard.SceneIdentifier + NSWindowController
//
extension NSWindowController {

    static var sceneIdentifier: NSStoryboard.SceneIdentifier {
        classNameWithoutNamespaces
    }
}

