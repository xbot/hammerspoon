tell application "Arc"
    set tabURL to URL of active tab of window 1
    set tabTitle to title of active tab of window 1
    tell front document of application "OmniFocus"
        tell quick entry
            make new inbox task with properties {name:("Review: " & tabTitle), note:tabURL as text}
            open
        end tell
    end tell
    display notification "Successfully exported tab '" & tabTitle & "' to OmniFocus" with title "Send tab to OmniFocus"
end tell
