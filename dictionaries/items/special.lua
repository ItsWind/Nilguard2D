local dict = {}

dict.LIFE_CRYSTAL = {
    lootTier = 1,
    id = "LIFE_CRYSTAL",
    equipType = "special",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/life_crystal.png")
    },
    InventoryUse = function(entUsedBy)
        entUsedBy:AddActiveEffect(function()
            local x, y, z = entUsedBy:GetPosition()
            y = entUsedBy:GetYDrawLevel()
            local fxPadding = 8
            local randX, randY, randZ = Util.MathRandomDecimal(x - fxPadding, x + fxPadding), Util.MathRandomDecimal(y - fxPadding, y + fxPadding), Util.MathRandomDecimal(z, z + fxPadding)
            entUsedBy:ModifyHealth(2)
            FX.CreateFX("HP", randX, randY, randZ, 5)
        end, 10, 0.1)
    end
}

dict.MANA_CRYSTAL = {
    lootTier = 1,
    id = "MANA_CRYSTAL",
    equipType = "special",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/mana_crystal.png")
    },
    InventoryUse = function(entUsedBy)
        entUsedBy:AddActiveEffect(function()
            local x, y, z = entUsedBy:GetPosition()
            y = entUsedBy:GetYDrawLevel()
            local fxPadding = 8
            local randX, randY, randZ = Util.MathRandomDecimal(x - fxPadding, x + fxPadding), Util.MathRandomDecimal(y - fxPadding, y + fxPadding), Util.MathRandomDecimal(z, z + fxPadding)
            entUsedBy:ModifyMana(0.25)
            FX.CreateFX("MANA", randX, randY, randZ, {
                x = 0,
                y = 0,
                z = 50
            })
        end, 10, 0.05)
    end
}

return dict