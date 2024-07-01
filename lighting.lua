local this = {}

Luven = require("libraries/luven/luven")

function this.Init()
    Luven.init()
    Luven.camera:init(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    Luven.camera:setScale(4)
end

function this.Update(dt)
    Luven.update(dt)
end

function this.Draw()
    Luven.camera:draw()
end

function this.AddLight(x, y, colorRange, powerRange, speedRange)
	return Luven.addFlickeringLight(x, y, colorRange, powerRange, speedRange)
end

function this.AddStillLight(x, y, color, power)
    return Luven.addNormalLight(x, y, color, power)
end

function this.AddShadow(x, y, power)
    local lightID = Luven.addNormalLight(x, y, {0.25, 0.25, 0.25}, power)
    local light = Luven.getAllLights()[lightID]
    light.blendingMode = "subtract"
    return lightID
end

function this.RemoveLight(lightID)
    Luven.removeLight(lightID)
end

function this.GetVisibilityAt(x, y)
    local visibility = 0

    local ambientColor = Luven.getAmbientLightColor()
    local ambientTable = {ambientColor[1], ambientColor[2], ambientColor[3]}
    table.sort(ambientTable)
    local ambientLightColorMax = ambientTable[#ambientTable]
    if ambientLightColorMax >= 1 then return 100 end

    visibility = visibility + ambientLightColorMax * 100

    for lightID, light in pairs(Luven.getAllLights()) do
        if light.enabled then
            local distanceToLight = Util.MathDistance(x, y, light.x, light.y)
            -- power is used for distance/light reach
            local power = light.power
            local maxDist = power*100

            if distanceToLight <= maxDist then
                local colorTable = {light.color[1], light.color[2], light.color[3]}
                table.sort(colorTable)
                local colorMax = colorTable[#colorTable]
                local colorIntensity = Util.MathLerp(colorMax, 0, distanceToLight/maxDist)

                visibility = visibility + colorIntensity * 100
            end
        end
    end

    return visibility
end

return this