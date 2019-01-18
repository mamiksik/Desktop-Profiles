on run arg
    set setTo to arg's first item as boolean

    tell application "System Preferences"
        delay 2
        activate
        delay 2
        reveal anchor "displaysNightShiftTab" of pane id "com.apple.preference.displays"
        delay 2
    end tell

    tell application "System Events"
        tell process "System Preferences"
            set theCheckbox to checkbox 1 of tab group 1 of window 1
            tell theCheckbox
                set curr to (its value as boolean)
                if not curr = setTo then click theCheckbox
            end tell
        end tell
    end tell
end run
