local this = {}

local tileTable = {}

local animateTime = 0

function this.Init()
    tileTable = require("dictionaries/tiles")
end

function this.UpdateAnimationTime(dt)
    animateTime = animateTime + dt
end

function this.GetTileDictionary()
    return tileTable
end

function this.DrawTile(name, x, y, overlay)
    local tile = tileTable[name:upper()]
    if tile.overlay == nil then tile.overlay = false end
    if tile.overlay ~= overlay then return end

    if tile.images == nil then
        love.graphics.draw(tile.image, x, y)

        -- Draw bloom
        if tile.bloomImage ~= nil then
            Util.DrawBloomImage(tile.bloomImage, x, y, false)
        end
    else
        local animateMult = tile.animateMult or 1
        local imageIndex = (math.floor(animateTime * animateMult) % #tile.images) + 1
        love.graphics.draw(tile.images[imageIndex], x, y)

        -- Draw bloom
        if tile.bloomImages ~= nil then
            Util.DrawBloomImage(tile.bloomImages[imageIndex], x, y, false)
        end
    end
end

return this