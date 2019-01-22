// MARK - Scripts
enum Scripts : String {
    case DarkMode = "DarkMode"
    case AccentColour = "AccentColour"
    case NightShift = "NightShift"
    case AutoHideDock = "AutoHideDock"
    case OpenPreferences = "OpenPreferences"
    case QuitPreferences = "QuitPreferences"
    case KillRunningApplications = "KillAll"
}

//MARK - Apps requiring special treatment
enum AppSpecificBehaviour: String {
    case Chrome = "com.google.Chrome"
    case Finder = "com.apple.finder"
}

//MARK - Queue
enum CustomQueue: String {
    case files = "mamiksik.states"
    case appleScript = "mamiksik.appleScript"
}
