local dict = {}

dict.ENEMY_OTHRIAN_GUARD = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/humanoid_body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/humanoid_head.png"),
        face = love.graphics.newImage("sprites/entities/humanoid/humanoid_face_happy.png")
    },
    factionName = "PLAYER_ENEMY",
    health = 100,
    speed = 4,
    sightRange = 128,
    itemDropChance = 20,
    inventory = {
        itemSet = "OTHRIAN_GUARD",
        bag = {
            min = 0,
            max = 1
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
        AI.AIDetectSounds(dt, thisEnt)
        AI.AIFindEnemy(dt, thisEnt)
        AI.AIIdleChatter(dt, thisEnt)
    end
}

dict.ENEMY_BASIC_HUMAN_MELEE = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/humanoid_body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/humanoid_head.png"),
        face = love.graphics.newImage("sprites/entities/humanoid/humanoid_face_happy.png")
    },
    factionName = "PLAYER_ENEMY",
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
        AI.AIDetectSounds(dt, thisEnt)
        AI.AIFindEnemy(dt, thisEnt)
        AI.AIIdleChatter(dt, thisEnt)
    end
}

dict.ENEMY_BASIC_HUMAN_BOW = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/humanoid_body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/humanoid_head.png"),
        face = love.graphics.newImage("sprites/entities/humanoid/humanoid_face_happy.png")
    },
    factionName = "PLAYER_ENEMY",
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
        AI.AIDetectSounds(dt, thisEnt)
        AI.AIFindEnemy(dt, thisEnt)
        AI.AIIdleChatter(dt, thisEnt)
    end
}

dict.ENEMY_BASIC_HUMAN_MAGE = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/humanoid_body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/humanoid_head.png"),
        face = love.graphics.newImage("sprites/entities/humanoid/humanoid_face_happy.png")
    },
    factionName = "PLAYER_ENEMY",
    health = 100,
    mana = 75,
    speed = 4,
    sightRange = 128,
    itemDropChance = 20,
    inventory = {
        itemSet = "MAGE",
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
        AI.AIDetectSounds(dt, thisEnt)
        AI.AIFindEnemy(dt, thisEnt)
        AI.AIIdleChatter(dt, thisEnt)
    end
}

dict.ENEMY_NIL_GUARD = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/nil_body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/nil_head.png")
    },
    factionName = "PLAYER_ENEMY",
    health = 65,
    mana = 100,
    speed = 4,
    sightRange = 256,
    itemDropChance = 20,
    sayingSet = "YDET_RELIK",
    inventory = {
        itemSets = {
            "RANDOM_MELEE",
            "BOW",
            "MAGE"
        },
        bag = {
            min = 0,
            max = 3
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
        AI.AIDetectSounds(dt, thisEnt)
        AI.AIFindEnemy(dt, thisEnt)
    end
}

return dict