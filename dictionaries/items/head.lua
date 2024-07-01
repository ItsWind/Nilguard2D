local dict = {}

dict.HEAD_MAGE = {
    lootTier = 2,
    id = "HEAD_MAGE",
    equipType = "head",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/head_mage.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/armor/head/mage.png")
    },
    absorption = 0.025,
    manaRegen = 1
}

dict.HEAD_METAL = {
    lootTier = 1,
    id = "HEAD_METAL",
    equipType = "head",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/head_metal.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/armor/head/metal.png")
    },
    absorption = 0.3,
    weight = 0.25
}

dict.HEAD_CHAIN = {
    lootTier = 1,
    id = "HEAD_CHAIN",
    equipType = "head",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/head_chain.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/armor/head/chain.png")
    },
    absorption = 0.15,
    weight = 0.125
}

dict.HEAD_RELIK_CROWN = {
    doNotIncludeInItemSets = true,
    doNotIncludeInRandomItems = true,
    id = "HEAD_RELIK_CROWN",
    equipType = "head",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/relik_crown.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/armor/head/relik_crown.png")
    },
    absorption = 0.15,
    weight = 0.125,
    manaRegen = 1
}

return dict