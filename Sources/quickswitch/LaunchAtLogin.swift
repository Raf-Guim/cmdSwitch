import Foundation
import ServiceManagement

@MainActor
class LaunchAtLogin {
    static let shared = LaunchAtLogin()
    
    private init() {}
    
    var isEnabled: Bool {
        get {
            SMAppService.mainApp.status == .enabled
        }
        set {
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Erro ao configurar inicialização automática: \(error.localizedDescription)")
            }
        }
    }
}
