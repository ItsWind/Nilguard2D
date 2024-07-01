local this = {}

this[1] = {
    anchor = "c",
    offsetX = 0,
    offsetY = -150,
    content = {
        {
            text = "Are you sure you'd like to quit? All progress in the current room will be lost.",
            alignText = "center",
            width = 1200,
            padding = 48,
            fontSize = 48
        },
    }
}

this[2] = {
    anchor = "c",
    offsetX = 0,
    offsetY = 100,
    content = {
        {
            text = "Yes",
            alignText = "center",
            width = 100,
            padding = 24,
            fontSize = 32,
            Click = function()
                love.event.quit()
            end
        },
        {
            text = "No",
            alignText = "center",
            width = 100,
            padding = 24,
            fontSize = 32,
            Click = function(x, y, miscData)
                Menus.SetMenu(miscData.lastMenuName)
            end
        },
    }
}

return this