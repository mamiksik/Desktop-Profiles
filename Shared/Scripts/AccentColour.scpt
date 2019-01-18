on run arg
    set setTo to arg's first item
    tell application "System Preferences"
        activate
        reveal pane "com.apple.preference.general"
        delay 1
    end tell

    tell application "System Events" to tell process "System Preferences"
        click checkbox setTo of window "General"
    end tell
end run
