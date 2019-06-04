tell application "System Events"
    set processList to get the name of every process whose background only is false
    repeat with processName in processList
        do shell script "Killall " & quoted form of processName
    end repeat
end tell
