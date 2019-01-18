on run arg
    set setTo to arg's first item as boolean
    tell application "System Events"
        tell dock preferences to set autohide to setTo
    end tell
end run
