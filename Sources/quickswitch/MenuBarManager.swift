import AppKit
import SwiftUI

@MainActor
class MenuBarManager: NSObject {
    static let shared = MenuBarManager()
    private var statusItem: NSStatusItem?
    
    private override init() {
        super.init()
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "command.square.fill", accessibilityDescription: "QuickSwitch")
        }
        
        // Configura o menu
        let menu = NSMenu()
        
        // Adiciona item de preferências
        let prefsItem = NSMenuItem(title: "Preferências...", action: #selector(openPreferences), keyEquivalent: "")
        prefsItem.target = self
        menu.addItem(prefsItem)
        
        // Adiciona opção de sair
        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Sair", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func openPreferences() {
        PreferencesWindowController.shared.showWindow()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
