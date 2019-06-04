on run arg
    set setTo to arg's first item as boolean
    tell application "System Events" to tell appearance preferences to set dark mode to setTo
end run
