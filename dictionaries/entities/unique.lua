local dict = {}

dict.NAM_OLAH = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/nam/body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/nam/head.png"),
        face = love.graphics.newImage("sprites/entities/humanoid/nam/face.png")
    },
    factionName = "PLAYER",
    health = 1000000,
    speed = 2,
    sightRange = 512,
    itemDropChance = 0,
    sayingSet = "NAM_OLAH",
    inventory = {
        itemSet = "NAM_OLAH"
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
        AI.AIIdleChatter(dt, thisEnt)
    end
}

dict.CHADRION = {
    objectID = "HUMAN",
    images = {
        shadow = love.graphics.newImage("sprites/entities/humanoid/humanoid_shadow.png"),
        body = love.graphics.newImage("sprites/entities/humanoid/chadrion/body.png"),
        head = love.graphics.newImage("sprites/entities/humanoid/humanoid_head.png"),
        face = love.graphics.newImage("sprites/entities/humanoid/chadrion/face.png")
    },
    factionName = "PLAYER",
    health = 500,
    speed = 4,
    sightRange = 128,
    itemDropChance = 0,
    sayingSet = "CHADRION",
    inventory = {
        itemSet = "CHADRION"
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

        if not Save.HasGameFlag("ChadrionPlayerMagic") then
            if Player.Get().cooldowns.attack.current > 0 and Player.Get().inventory.equipped.weapon.manaCost ~= nil then
                thisEnt:Say("You can use magic!? Are you a runaway mage or something?", {0.8, 1, 0.5})
                Save.AddGameFlag("ChadrionPlayerMagic")
            end
        end
    end,
    DeathAction = function(isRemoval)
        if isRemoval then return end
		Save.MarkForReload("Chadrion has died!")
    end
}

return dict