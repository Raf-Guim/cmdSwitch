import AppKit
import Foundation

@MainActor
protocol ShortcutsUpdateDelegate: AnyObject {
    func shortcutsDidUpdate()
}

class PreferencesWindow: NSWindow, ShortcutsUpdateDelegate {
    private let launchAtLoginToggle = NSSwitch()
    private let tableView = NSTableView()
    private let scrollView = NSScrollView()
    private var shortcuts: [AppShortcut] = []
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Configurações da janela
        title = "Preferências"
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        
        // Centraliza a janela na tela
        center()
        
        setupUI()
        loadShortcuts()
        
        // Registra para atualizações
        ShortcutManager.shared.delegate = self
    }
    
    private func setupUI() {
        // Cria o visual moderno com blur
        let visualEffect = NSVisualEffectView(frame: contentView?.bounds ?? .zero)
        visualEffect.blendingMode = .behindWindow
        visualEffect.material = .hudWindow
        visualEffect.state = .active
        visualEffect.autoresizingMask = [.width, .height]
        
        // Container principal com padding
        let container = NSView(frame: visualEffect.bounds)
        container.autoresizingMask = [.width, .height]
        
        // Stack view para organizar os controles
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 16
        stackView.edgeInsets = NSEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        
        // Label para a seção de atalhos
        let shortcutsLabel = NSTextField(labelWithString: "Atalhos configurados")
        shortcutsLabel.textColor = .labelColor
        shortcutsLabel.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        
        // Configura a tabela
        setupTableView()
        
        // Adiciona um espaçador após a tabela
        let spacer1 = NSView()
        spacer1.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        // Toggle de inicialização automática
        let launchRow = NSStackView()
        launchRow.orientation = .horizontal
        launchRow.spacing = 8
        
        let launchLabel = NSTextField(labelWithString: "Iniciar ao fazer login")
        launchLabel.textColor = .labelColor
        launchAtLoginToggle.state = LaunchAtLogin.shared.isEnabled ? .on : .off
        launchAtLoginToggle.target = self
        launchAtLoginToggle.action = #selector(toggleLaunchAtLogin)
        
        launchRow.addArrangedSubview(launchAtLoginToggle)
        launchRow.addArrangedSubview(launchLabel)
        
        // Adiciona um espaçador antes do botão de sair
        let spacer2 = NSView()
        spacer2.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        // Botão de sair
        let quitButton = NSButton(title: "Sair do QuickSwitch", target: self, action: #selector(quitApp))
        quitButton.bezelStyle = .rounded
        quitButton.controlSize = .large
        
        // Adiciona os controles ao stack view na nova ordem
        stackView.addArrangedSubview(shortcutsLabel)
        stackView.addArrangedSubview(scrollView)
        stackView.addArrangedSubview(spacer1)
        stackView.addArrangedSubview(launchRow)
        stackView.addArrangedSubview(spacer2)
        stackView.addArrangedSubview(quitButton)
        
        // Configura constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            scrollView.heightAnchor.constraint(equalToConstant: 200),
            scrollView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -48), // Considera o padding
            
            spacer1.heightAnchor.constraint(equalToConstant: 16),
            spacer2.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        visualEffect.addSubview(container)
        contentView = visualEffect
    }
    
    private func setupTableView() {
        // Configura a scroll view
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        
        // Configura a table view
        tableView.style = .fullWidth
        tableView.backgroundColor = .clear
        tableView.headerView = nil
        tableView.rowHeight = 44
        tableView.gridStyleMask = []
        
        // Adiciona a coluna
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("ShortcutColumn"))
        column.resizingMask = .autoresizingMask
        tableView.addTableColumn(column)
        
        // Configura o delegate e data source
        tableView.delegate = self
        tableView.dataSource = self
        
        scrollView.documentView = tableView
    }
    
    private func loadShortcuts() {
        Task { @MainActor in
            shortcuts = await ShortcutStorage.shared.getAllShortcuts()
            tableView.reloadData()
        }
    }
    
    @objc private func toggleLaunchAtLogin() {
        LaunchAtLogin.shared.isEnabled = launchAtLoginToggle.state == .on
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    func shortcutsDidUpdate() {
        loadShortcuts()
    }
}

extension PreferencesWindow: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return shortcuts.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let shortcut = shortcuts[row]
        let cellView = ShortcutTableCellView(frame: .zero)
        cellView.configure(with: shortcut)
        
        cellView.onDelete = {
            Task { @MainActor in
                // Remove o atalho
                var currentShortcuts = await ShortcutStorage.shared.getAllShortcuts()
                currentShortcuts.removeAll { $0.bundleId == shortcut.bundleId }
                await ShortcutStorage.shared.saveShortcuts(currentShortcuts)
            }
        }
        
        return cellView
    }
}

class PreferencesWindowController: NSWindowController {
    static let shared = PreferencesWindowController()
    
    init() {
        super.init(window: PreferencesWindow())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showWindow() {
        if window?.isVisible == true {
            window?.makeKeyAndOrderFront(nil)
        } else {
            window?.center()
            window?.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
}
