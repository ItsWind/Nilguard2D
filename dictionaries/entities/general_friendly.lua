local dict = {}

dict.PLAYER = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/humanoid_body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/humanoid_head.png"),
    },
    factionName = "PLAYER",
    health = 500,
    mana = 100,
    speed = 4,
    sightRange = 128,
    itemDropChance = 20,
    sounds = {
        hurt = "sound/ents/humanoid/hurt.ogg",
        death = "sound/ents/humanoid/death.ogg",
        detectionRadii = {
            hurt = 64
        }
    }
}

dict.BASIC_HUMAN_MELEE = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/humanoid_body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/humanoid_head.png"),
        face = love.graphics.newImage("sprites/entities/humanoid/humanoid_face_happy.png")
    },
    factionName = "PLAYER",
    health = 100,
    speed = 4,
    sightRange = 128,
    itemDropChance = 20,
    inventory = {
        itemSet = "BASIC_MELEE",
        bag = {
            min = 0,
            max = 2
        }
    },
    sounds = {
        hurt = "sound/ents/humanoid/hurt.ogg",
        death = "sound/ents/humanoid/death.ogg",
        detectionRadii = {
            hurt = 64
        }
    },
    aiUpdate = function(dt, thisEnt)
        AI.AIBreathe(dt, thisEnt)
        AI.AIWander(dt, thisEnt, 64)
        AI.AIFindEnemy(dt, thisEnt)
        AI.AIFollowEntity(dt, thisEnt, Player.Get())
        AI.AIIdleChatter(dt, thisEnt)
    end
}

dict.BASIC_HUMAN_RANGED = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/humanoid_body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/humanoid_head.png"),
        face = love.graphics.newImage("sprites/entities/humanoid/humanoid_face_happy.png")
    },
    factionName = "PLAYER",
    health = 100,
    speed = 4,
    sightRange = 128,
    itemDropChance = 20,
    inventory = {
        itemSet = "BOW",
        bag = {
            min = 0,
            max = 2
        }
    },
    sounds = {
        hurt = "sound/ents/humanoid/hurt.ogg",
        death = "sound/ents/humanoid/death.ogg",
        detectionRadii = {
            hurt = 64
        }
    },
    aiUpdate = function(dt, thisEnt)
        AI.AIBreathe(dt, thisEnt)
        AI.AIWander(dt, thisEnt, 64)
        AI.AIFindEnemy(dt, thisEnt)
        AI.AIFollowEntity(dt, thisEnt, Player.Get())
        AI.AIIdleChatter(dt, thisEnt)
    end
}

dict.PLAYER_MANAFESTATION = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/manifestation_body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/manifestation_head.png")
    },
    factionName = "PLAYER",
    health = 100,
    mana = 100,
    speed = 4,
    sightRange = 128,
    itemDropChance = 20,
    sayingSet = "MANAFESTATION",
    inventory = {
        itemSets = {
            "ELITE_MELEE",
            "BOW",
            "MAGE"
        }
    },
    sounds = {
        hurt = "sound/ents/humanoid/hurt.ogg",
        death = "sound/ents/humanoid/death.ogg"
    },
    BirthAction = function()
        local ply = Player.Get()
        ply.maxMana = ply.maxMana - 25
    end,
    aiUpdate = function(dt, thisEnt)
        AI.AIBreathe(dt, thisEnt)
        AI.AIWander(dt, thisEnt, 64)
        AI.AIFindEnemy(dt, thisEnt)
        AI.AIFollowEntity(dt, thisEnt, Player.Get(), true)
    end,
    DeathAction = function()
        local ply = Player.Get()
        ply.maxMana = ply.maxMana + 25
    end
}

return dict