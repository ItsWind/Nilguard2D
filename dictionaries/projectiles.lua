local projectileDictionary = {}

local function DamageEntityCheckForBlock(x, y, entityID, damage, knockback, attackerID)
    local hitEntity = Ents.GetEntities()[entityID]
    if hitEntity == nil then return end

    if hitEntity:FacingPoint(x, y) and hitEntity.cooldowns.block.current > 0 then
        hitEntity.cooldowns.parry.current = hitEntity.cooldowns.parry.default
        return
    end

    Util.DamageEntity(x, y, entityID, damage, knockback, attackerID)
end

projectileDictionary.FIREBALL = {
    image = love.graphics.newImage("sprites/projectiles/fireball.png"),
    bloomImage = love.graphics.newImage("sprites/projectiles/fireball.png"),
    speed = 128,
    travelMaxTime = 3,
    light = {
        colorRange = { min = { 0.95, 0.95, 0.0, 1.0 }, max = { 1.0, 1.0, 0.0, 1.0 } },
        powerRange = { min = 0.35, max = 0.40 },
        speedRange = { min = 0.5, max = 0.75 }
    },
    sounds = {
        hit = "sound/projectiles/fireball_hit.ogg",
        detectionRadii = {
            hit = 192
        }
    },
    Update = function(self)
        local x, y = self:GetPosition()
        local randX, randY = math.random(x-2, x+2), math.random(y-2, y+2)
        FX.CreateFX("SMOKE", randX, randY, 0, 5)
    end,
    HitEffect = function(self, x, y, hitID, attackerID)
        Util.DamageEntitiesInArea(x, y, 32, 150, 2, attackerID)
        
        for i=1, 200 do
            FX.CreateFX("SMOKE", x, y, 0, {
                x = Util.MathRandomDecimal(-35, 35),
                y = Util.MathRandomDecimal(-25, 25),
                z = Util.MathRandomDecimal(-15, 15),
            })
        end
    end
}
projectileDictionary.ICE_SPIKE = {
    image = love.graphics.newImage("sprites/projectiles/ice_spike.png"),
    bloomImage = love.graphics.newImage("sprites/projectiles/ice_spike.png"),
    speed = 128,
    travelMaxTime = 3,
    Update = function(self)
        local x, y = self:GetPosition()
        local randX, randY = math.random(x-2, x+2), math.random(y-2, y+2)
        local r = Util.MathRandomDecimal(0.2, 0.5)
        FX.CreateFX("WHITE_SMOKE", randX, randY, 0, 5, nil, {r, 0.5, 1})
    end,
    HitEffect = function(self, x, y, hitID, attackerID)
        if hitID ~= nil then
            DamageEntityCheckForBlock(x, y, hitID, 25, 0, attackerID)
        end
    end
}
projectileDictionary.ARROW = {
    image = love.graphics.newImage("sprites/projectiles/arrow.png"),
    speed = 256,
    travelMaxTime = 8,
    HitEffect = function(self, x, y, hitID, attackerID)
        if hitID ~= nil then
            DamageEntityCheckForBlock(x, y, hitID, 75, 2, attackerID)
        end
    end
}
projectileDictionary.BULLET = {
    image = love.graphics.newImage("sprites/projectiles/bullet.png"),
    speed = 4096,
    travelMaxTime = 99,
    HitEffect = function(self, x, y, hitID, attackerID)
        if hitID ~= nil then
            Util.DamageEntity(x, y, hitID, 100, 1, attackerID)
        end
    end
}

return projectileDictionary