import Foundation

@MainActor
class ShortcutManager {
    static let shared = ShortcutManager()
    weak var delegate: ShortcutsUpdateDelegate?
    
    private init() {}
    
    func notifyShortcutsUpdated() {
        delegate?.shortcutsDidUpdate()
    }
}
