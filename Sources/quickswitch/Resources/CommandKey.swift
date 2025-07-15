import AppKit

// Cria um ícone para o aplicativo usando SF Symbols
let image = NSImage(systemSymbolName: "command.square.fill", accessibilityDescription: "QuickSwitch")!
let tinted = image.copy() as! NSImage
tinted.lockFocus()
NSColor.systemBlue.set()
NSRect(origin: .zero, size: tinted.size).fill(using: .sourceAtop)
tinted.unlockFocus()

// Salva o ícone
if let tiffData = tinted.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let iconData = bitmap.representation(using: .icns, properties: [:]) {
    try? iconData.write(to: URL(fileURLWithPath: "CommandKey.icns"))
}
