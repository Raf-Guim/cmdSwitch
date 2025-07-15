import AppKit

// Estado global das teclas
final class KeyboardState: @unchecked Sendable {
    static let shared = KeyboardState()
    private var _isRightCommandPressed = false
    let lock = NSLock()

    private init() {}

    var isRightCommandPressed: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isRightCommandPressed
    }

    func setRightCommandPressed(_ value: Bool) {
        lock.lock()
        defer { lock.unlock() }
        _isRightCommandPressed = value
    }
}
