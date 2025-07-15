@preconcurrency import AppKit
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var menuBarManager: MenuBarManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configura o app para rodar sem ícone no Dock
        NSApp.setActivationPolicy(.accessory)

        // Inicia o menu bar
        menuBarManager = MenuBarManager.shared

        // Inicia o monitoramento de teclado
        setupKeyboardMonitoring()
    }

    func setupKeyboardMonitoring() {
        print("Iniciando monitoramento de teclado...")

        // Configura o monitoramento de teclado
        let eventMask =
            (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)

        guard
            let tap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: CGEventMask(eventMask),
                callback: eventCallback,
                userInfo: nil
            )
        else {
            print("Erro: Não foi possível criar o event tap")
            return
        }

        // Salva referências para limpar depois se necessário
        self.eventTap = tap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let source = self.runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            print("Monitoramento de teclado configurado com sucesso")
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Limpa os recursos ao fechar o app
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }
    }
}

// Função de callback para eventos do teclado
private func eventCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    // Processa o evento
    switch type {
    case .flagsChanged:
        // Verifica se é o Command direito
        let flags = event.flags
        let isCommand = flags.contains(.maskCommand)
        let isRightCommand = flags.rawValue & 0x0010 != 0

        KeyboardState.shared.setRightCommandPressed(isCommand && isRightCommand)
        return Unmanaged.passRetained(event)

    case .keyDown:
        // Se o Command direito estiver pressionado, processa o atalho
        if KeyboardState.shared.isRightCommandPressed {
            let keycode = event.getIntegerValueField(.keyboardEventKeycode)

            // Verifica os atalhos salvos
            Task { @MainActor in
                let shortcuts = await ShortcutStorage.shared.getAllShortcuts()
                if let shortcut = shortcuts.first(where: { $0.keycode == keycode }) {
                    // Tenta ativar o app correspondente
                    if let runningApp = NSWorkspace.shared.runningApplications.first(where: {
                        $0.bundleIdentifier == shortcut.bundleId
                    }) {
                        runningApp.activate(options: [
                            .activateIgnoringOtherApps, .activateAllWindows,
                        ])
                    } else {
                        // Se o app não estiver rodando, tenta abrir
                        if let appURL = NSWorkspace.shared.urlForApplication(
                            withBundleIdentifier: shortcut.bundleId)
                        {
                            do {
                                let config = NSWorkspace.OpenConfiguration()
                                config.activates = true
                                _ = try await NSWorkspace.shared.openApplication(
                                    at: appURL, configuration: config)
                            } catch {
                                print("Erro ao abrir o app: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    // Se não existe atalho para esta tecla, tenta criar um novo
                    if let frontmostApp = NSWorkspace.shared.frontmostApplication,
                        let bundleId = frontmostApp.bundleIdentifier
                    {
                        var shortcuts = await ShortcutStorage.shared.getAllShortcuts()

                        // Verifica se o comando já está atribuído a outro aplicativo
                        if let existingShortcutForKey = shortcuts.first(where: {
                            $0.keycode == keycode
                        }) {
                            // Se o comando já está atribuído para outro app, não faz nada
                            if existingShortcutForKey.bundleId != bundleId {
                                print("Comando já está atribuído para outro aplicativo")
                            }
                        } else {
                            // Cria o novo atalho
                            let newShortcut = AppShortcut(
                                name: frontmostApp.localizedName ?? "Unknown",
                                bundleId: bundleId,
                                keycode: keycode,
                                requiresRightCommand: true
                            )

                            // Remove atalho existente para o mesmo app (se houver)
                            shortcuts.removeAll { $0.bundleId == bundleId }

                            // Adiciona o novo atalho
                            shortcuts.append(newShortcut)
                            await ShortcutStorage.shared.saveShortcuts(shortcuts)
                            ShortcutManager.shared.notifyShortcutsUpdated()
                        }
                    }
                }
            }

            // Se o Command direito está pressionado, sempre consome o evento
            return nil as Unmanaged<CGEvent>?
        }

        // Se não é Command direito, passa o evento adiante
        return Unmanaged.passRetained(event)

    default:
        return Unmanaged.passRetained(event)
    }
}
