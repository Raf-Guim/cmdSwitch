import AppKit

class ShortcutTableCellView: NSTableCellView {
    private let appIconView = NSImageView()
    private let appNameLabel = NSTextField(labelWithString: "")
    private let shortcutLabel = NSTextField(labelWithString: "")
    private let deleteButton = NSButton(image: NSImage(systemSymbolName: "trash", accessibilityDescription: "Excluir")!, target: nil, action: nil)
    
    var onDelete: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Configura o ícone do app
        appIconView.imageScaling = .scaleProportionallyDown
        appIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(appIconView)
        
        // Configura o nome do app
        appNameLabel.lineBreakMode = .byTruncatingTail
        appNameLabel.textColor = .labelColor
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(appNameLabel)
        
        // Configura o label do atalho
        shortcutLabel.textColor = .secondaryLabelColor
        shortcutLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shortcutLabel)
        
        // Configura o botão de excluir
        deleteButton.bezelStyle = .inline
        deleteButton.isBordered = false
        deleteButton.target = self
        deleteButton.action = #selector(deleteClicked)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            appIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            appIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            appIconView.widthAnchor.constraint(equalToConstant: 32),
            appIconView.heightAnchor.constraint(equalToConstant: 32),
            
            appNameLabel.leadingAnchor.constraint(equalTo: appIconView.trailingAnchor, constant: 8),
            appNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            appNameLabel.widthAnchor.constraint(equalToConstant: 150),
            
            shortcutLabel.leadingAnchor.constraint(equalTo: appNameLabel.trailingAnchor, constant: 8),
            shortcutLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with shortcut: AppShortcut) {
        // Configura o ícone do app
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: shortcut.bundleId) {
            appIconView.image = NSWorkspace.shared.icon(forFile: appURL.path)
        }
        
        // Configura o nome do app
        appNameLabel.stringValue = shortcut.name
        
        // Configura o texto do atalho
        let keyDescription = CommandKeyState.shared.getKeyDescription(forKeycode: shortcut.keycode)
        shortcutLabel.stringValue = "⌘ + \(keyDescription)"
    }
    
    @objc private func deleteClicked() {
        onDelete?()
    }
}
