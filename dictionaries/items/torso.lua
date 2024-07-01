local dict = {}

dict.TORSO_METAL = {
    lootTier = 1,
    id = "TORSO_METAL",
    equipType = "torso",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/torso_metal.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/armor/torso/metal.png")
    },
    absorption = 0.6,
    weight = 0.5
}

dict.TORSO_OTHRIAN = {
    doNotIncludeInRandomItems = true,
    doNotIncludeInItemSets = true,
    id = "TORSO_OTHRIAN",
    equipType = "torso",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/torso_othrian.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/armor/torso/othrian.png")
    },
    absorption = 0.3,
    weight = 0.25
}

dict.TORSO_MAGE = {
    lootTier = 2,
    id = "TORSO_MAGE",
    equipType = "torso",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/torso_mage.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/armor/torso/mage.png")
    },
    absorption = 0.05,
    manaRegen = 2
}

return dict