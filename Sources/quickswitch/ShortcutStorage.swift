import Foundation

@MainActor
final class ShortcutStorage: @unchecked Sendable {
    static let shared = ShortcutStorage()
    private let shortcutsKey = "SavedShortcuts"
    
    private init() {}
    
    func getAllShortcuts() async -> [AppShortcut] {
        if let data = UserDefaults.standard.data(forKey: shortcutsKey),
           let shortcuts = try? JSONDecoder().decode([AppShortcut].self, from: data) {
            return shortcuts
        }
        return []
    }
    
    func saveShortcuts(_ shortcuts: [AppShortcut]) async {
        if let data = try? JSONEncoder().encode(shortcuts) {
            UserDefaults.standard.set(data, forKey: shortcutsKey)
        }
    }
}
