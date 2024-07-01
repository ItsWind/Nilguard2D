local this = {}

local function SetSliderPercentValue(contentBox, mouseX)
    local padding = contentBox.padding or {}
    local leftPadding = padding.left or 0
    local rightPadding = padding.right or 0
    local x1 = contentBox.x1 + leftPadding
    local x2 = contentBox.x2 - rightPadding
    local valueSet = mouseX - x1
    local maxValue = x2 - x1
    local percentValue = valueSet/maxValue
    if percentValue > 0.975 then
        percentValue = 1
    elseif percentValue < 0.025 then
        percentValue = 0
    end
    contentBox.sliderValue = percentValue
end

-- buttons on side
this[1] = {
    anchor = "t",
    offsetX = 0,
    offsetY = 128,
    content = {
        {
            text = "Volume",
            alignText = "center",
            width = 300,
            fontSize = 32
        },
        {
            slider = true,
            width = 300,
            height = 50,
            topPadding = 8,
            bottomPadding = 32,
            Start = function(miscData, contentBox)
                contentBox.sliderValue = Sounds.GetMasterVolume()
            end,
            ClickHeld = function(x, y, miscData)
                SetSliderPercentValue(miscData.currentContentBox, x)
                Sounds.SetMasterVolume(miscData.currentContentBox.sliderValue)
            end
        },
    }
}

-- buttons on side
this[2] = {
    anchor = "b",
    offsetX = 0,
    offsetY = -160,
    content = {
        {
            text = "Exit",
            alignText = "center",
            width = 150,
            padding = 16,
            fontSize = 32,
            Click = function(x, y, miscData)
                Options.SaveCurrentOptions()
                Menus.SetMenu(miscData.lastMenuName)
            end
        }
    }
}

return this