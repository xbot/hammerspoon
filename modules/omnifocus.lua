hs.loadSpoon('SendToOmniFocus')

spoon.SendToOmniFocus:bindHotkeys({send_to_omnifocus = {{'ctrl', 'alt', 'cmd'}, 'J'}})

spoon.SendToOmniFocus:registerApplication('Brave Browser', { apptype = "chromeapp", itemname = "tab" })
