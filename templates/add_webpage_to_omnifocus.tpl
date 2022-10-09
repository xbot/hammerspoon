set tabTitle to "${title}"
set tabURL to "${url}"
tell front document of application "OmniFocus"
    tell quick entry
        make new inbox task with properties {name:("Review: " & tabTitle), note:tabURL as text}
        open
    end tell
end tell
display notification "Successfully exported tab '" & tabTitle & "' to OmniFocus" with title "Send tab to OmniFocus"
