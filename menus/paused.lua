local this = {}

-- buttons on side
this[1] = {
    anchor = "c",
    offsetX = 0,
    offsetY = 0,
    content = {
        {
            text = "Options",
            alignText = "center",
            width = 200,
            padding = 24,
            fontSize = 32,
            Click = function()
                Menus.SetMenu("options")
            end
        },
        {
            text = "Unpause",
            alignText = "center",
            width = 200,
            padding = 24,
            fontSize = 32,
            Click = function()
                Player.Get().ai.attackWait = 1
                Menus.SetMenu(nil)
            end
        },
        {
            text = "Exit",
            alignText = "center",
            width = 200,
            padding = 24,
            fontSize = 32,
            Click = function()
                Menus.SetMenu("ensurequit")
            end
        },
    }
}

return this