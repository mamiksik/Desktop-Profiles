// MARK: Scripts
enum Scripts : String {
    case darkMode = "DarkMode"
    case accentColour = "AccentColour"
    case nightShift = "NightShift"
    case autoHideDock = "AutoHideDock"
    case openPreferences = "OpenPreferences"
    case quitPreferences = "QuitPreferences"
    case killRunningApplications = "KillAll"
}

// MARK: Apps requiring special treatment
enum AppSpecificBehaviour: String {
    case chrome = "com.google.Chrome"
    case finder = "com.apple.finder"
}

// MARK: Queue
enum CustomQueue: String {
    case files = "mamiksik.states"
    case appleScript = "mamiksik.appleScript"
}
