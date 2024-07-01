local dict = {}

dict.CRATE_WOOD = {
    objectID = "CRATE_WOOD",
    isBreakable = true,
    images = {
        body = love.graphics.newImage("sprites/entities/breakables/crate_wood.png")
    },
    faction = "PLAYER_ENEMY",
    health = 50,
    itemDropChance = 100,
    inventory = {
        bag = {
            min = 2,
            max = 5,
            lootTier = 2
        }
    },
    sounds = {
        hurt = "sound/ents/wood_crate/hurt.ogg",
        death = "sound/ents/wood_crate/death.ogg",
        detectionRadii = {
            death = 112
        }
    }
}

dict.BASIC_CRATE_WOOD = {
    objectID = "CRATE_WOOD",
    isBreakable = true,
    images = {
        body = love.graphics.newImage("sprites/entities/breakables/crate_wood.png")
    },
    faction = "PLAYER_ENEMY",
    health = 50,
    itemDropChance = 75,
    inventory = {
        bag = {
            min = 0,
            max = 2,
            lootTier = 1
        }
    },
    sounds = {
        hurt = "sound/ents/wood_crate/hurt.ogg",
        death = "sound/ents/wood_crate/death.ogg",
        detectionRadii = {
            death = 112
        }
    }
}

dict.BUSH = {
    objectID = "BUSH",
    isBreakable = true,
    images = {
        body = love.graphics.newImage("sprites/entities/breakables/bush.png")
    },
    faction = "PLAYER_ENEMY",
    health = 20,
    sounds = {
        hurt = "sound/ents/wood_crate/hurt.ogg",
        death = "sound/ents/wood_crate/death.ogg",
        detectionRadii = {
            death = 64
        }
    }
}

dict.IRON_BARS = {
    objectID = "IRON_BARS",
    isBreakable = true,
    images = {
        body = love.graphics.newImage("sprites/objects/iron_bars.png")
    },
    faction = "PLAYER_ENEMY",
    health = 100,
    sounds = {
        hurt = "sound/ents/wood_crate/hurt.ogg",
        death = "sound/ents/wood_crate/death.ogg",
        detectionRadii = {
            death = 112
        }
    }
}

return dict