import Foundation

struct AppShortcut: Codable {
    let name: String
    let bundleId: String
    let keycode: Int64
    let requiresRightCommand: Bool
}
