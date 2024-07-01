local dict = {}

dict.YDET_RELIK = {
    objectID = "YDET_RELIK",
    images = {
        shadow = love.graphics.newImage("sprites/entities/bosses/ydet_relik/shadow.png"),
        body = love.graphics.newImage("sprites/entities/bosses/ydet_relik/body.png"),
        head = love.graphics.newImage("sprites/entities/bosses/ydet_relik/head.png"),
        face = love.graphics.newImage("sprites/entities/bosses/ydet_relik/face.png")
    },
    factionName = "PLAYER_ENEMY",
    health = 5000,
    speed = 4,
    sightRange = 512,
    itemDropChance = 100,
    sayingSet = "YDET_RELIK",
    inventory = {
        itemSet = "YDET_RELIK",
        bag = {
            specificWeapons = {
                "PISTOL"
            }
        }
    },
    sounds = {
        hurt = "sound/ents/humanoid/hurt.ogg",
        death = "sound/ents/humanoid/death.ogg"
    },
    seeThruWalls = true,
    aiUpdate = function(dt, thisEnt)
        AI.AIBreathe(dt, thisEnt)
        AI.YdetRelik(dt, thisEnt)
    end,
    DeathAction = function(isRemoval)
        if isRemoval then return end
        Sounds.PlayBackgroundMusic("Gladiator.ogg")
        Rooms.SetBossEntity(nil)
        Rooms.SetCutsceneStage(2)
    end
}
dict.YDET_RELIK_NORMAL = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/firstone_body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/firstone_head.png"),
        face = love.graphics.newImage("sprites/entities/bosses/ydet_relik/face_normal.png")
    },
    factionName = "PLAYER_ENEMY",
    health = 2000,
    mana = 500,
    speed = 4,
    sightRange = 512,
    itemDropChance = 0,
    sayingSet = "YDET_RELIK_NORMAL",
    inventory = {
        itemSet = "YDET_RELIK_NORMAL"
    },
    sounds = {
        hurt = "sound/ents/humanoid/hurt.ogg",
        death = "sound/ents/humanoid/death.ogg"
    },
    seeThruWalls = true,
    aiUpdate = function(dt, thisEnt)
        AI.AIBreathe(dt, thisEnt)
        AI.YdetRelikNormal(dt, thisEnt)
    end
}

return dict