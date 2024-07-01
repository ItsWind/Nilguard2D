local this = {}

this[1] = {
    anchor = "c",
    offsetX = 0,
    offsetY = -200,
    content = {
        {
            text = "Enter an IP address, then press connect below.\n\nTo host, press host. You may need to forward port 22122 and/or let the game through your firewall.",
            alignText = "center",
            width = 1200,
            padding = 48,
            fontSize = 42
        },
    }
}

this[2] = {
    anchor = "c",
    offsetX = 0,
    offsetY = 200,
    content = {
        {
            inputText = "localhost",
            textKey = "ipinput",
            height = 60,
            width = 400,
            padding = 24,
            fontSize = 24
        },
        {
            text = "Connect",
            alignText = "center",
            width = 400,
            padding = 24,
            fontSize = 32,
            Click = function(x, y, miscData)
                -- Connect to multiplayer IP
                print("CONNECTING " .. miscData.textKeys["ipinput"])
                Menus.SetMenu(nil)
                Multiplayer.ConnectFromMenu(miscData.textKeys["ipinput"])
            end
        },
        {
            text = "Host",
            alignText = "center",
            width = 400,
            padding = 24,
            fontSize = 32,
            Click = function()
                -- Host multiplayer
                Menus.SetMenu(nil)
                Multiplayer.HostFromMenu()
            end
        },
        {
            text = "Back",
            alignText = "center",
            width = 400,
            padding = 24,
            fontSize = 32,
            Click = function(x, y, miscData)
                Menus.SetMenu(miscData.lastMenuName)
            end
        },
    }
}

return this