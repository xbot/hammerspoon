hs.loadSpoon('SendToOmniFocus')

spoon.SendToOmniFocus:bindHotkeys({
    send_to_omnifocus = {{'ctrl', 'alt', 'cmd'}, 'O'}
})

spoon.SendToOmniFocus:registerApplication('Brave Browser', {
    apptype = "chromeapp",
    itemname = "tab"
})

local hotkey = require "hs.hotkey"

-- Press ctrl+opt+O to format Jira ticket title
hotkey.bind(hyperCtrl, "O", function()
    local selectedText = hs.uielement.focusedElement():selectedText()

    if selectedText == nil then
        hs.alert.show("No text selected")
        return
    end

    local formattedText = nil

    if string.match(selectedText, '^Review:%s%[DEV%-%d+%]%s.*%s%-%sJira$') then
        local ticketNumber = string.match(selectedText, '^Review:%s%[(DEV%-%d+)%]%s.*%s%-%sJira$')
        local ticketTitle = string.match(selectedText, '^Review:%s%[DEV%-%d+%]%s(.*)%s%-%sJira$')

        formattedText = ticketNumber .. ' ' .. ticketTitle;
    elseif string.match(selectedText, '^Review:%s.*$') then
        formattedText = string.gsub(selectedText, '^Review:%s', '')
    else
        hs.alert.show('Not an expected string, nothing happened.')
        return
    end

    hs.pasteboard.setContents(formattedText)
    hs.eventtap.keyStroke({"cmd"}, "v")
end)
