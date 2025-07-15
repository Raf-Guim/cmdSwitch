# CMD Switch

CMD Switch is a macOS utility that enhances your workflow by allowing you to assign custom keyboard shortcuts to launch applications using the right Command key. This tool is perfect for users who want quick access to their frequently used applications without cluttering their keyboard shortcuts.

## Features

- Use the right Command key + any key to launch applications
- Modern, native macOS interface with blur effects
- Launch at login option
- Easy-to-use preferences window to manage shortcuts
- Runs in the menu bar for easy access
- Supports macOS 12.0 and later

## Installation

1. Download the latest release of CMD Switch
2. Move `CMD Switch.app` to your Applications folder
3. When launching for the first time, right-click the app and select "Open" (this is required because the app is not signed)
4. The app will appear in your menu bar with a command key icon

## Configuration

1. Click the command key icon in the menu bar
2. Select "Preferences" to open the configuration window
3. Add new shortcuts:
   - The list shows all your configured shortcuts
   - Each shortcut consists of a key and the associated application
   - Click the "+" button to add a new shortcut
   - Select an application and assign a key to it
4. Optional: Enable "Launch at Login" to start CMD Switch automatically when you log in

## Usage

1. Hold the right Command key (⌘)
2. Press the key you assigned to an application
3. The application will launch or bring to front if it's already running

## Building from Source

### Prerequisites

- Xcode 14.0 or later
- Swift 5.7 or later
- macOS 12.0 or later

### Build Steps

1. Clone the repository:

```bash
git clone https://github.com/raf-guim/cmdSwitch.git
cd cmdSwitch
```

2. Build the project:

```bash
swift build
```

3. Create the application bundle:

```bash
./build_app.sh
```

4. The built application will be in the `build` directory as `CMD Switch.app`

## Permissions

CMD Switch needs the following permissions to function:

- Accessibility permissions (to monitor keyboard events)
- Launch at login (optional, if you enable this feature)

When you first run the app, macOS will prompt you to grant these permissions.

## Troubleshooting

1. If keyboard shortcuts don't work:

   - Check System Preferences > Security & Privacy > Privacy > Accessibility
   - Make sure CMD Switch is allowed to control your computer

2. If the app doesn't launch at login:
   - Check System Preferences > Users & Groups > Login Items
   - Add CMD Switch manually if it's not listed

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
