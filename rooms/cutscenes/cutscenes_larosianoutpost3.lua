local this = {}

this[1] = {
    pauseAI = false,
    time = 8,
    text = {
        content = "\"Thanks for your help! Wait.. ____you're the one from the prison!\"",
        time = 6,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    Start = function(gameObjects)
        local chadrion = gameObjects[278292764]
        local plyX, plyY = Player.Get():GetPosition()
        local randX, randY = Util.GetNavValidRandomPointNear(plyX, plyY, 16)

        chadrion.ai.movingTo = {randX, randY}
        chadrion.ai.doNotWander = true
        chadrion.ai.doNotFindEnemy = true
    end
}
this[2] = {
    pauseAI = false,
    time = 7,
    text = {
        content = "\"I'm glad that thing didn't hurt you, __but __where did you go?\"",
        time = 5,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    Start = function(gameObjects, miscData)
        miscData.enemiesSpawned = {}
        for i=1, 4 do
            local plyX, plyY = Player.Get():GetPosition()
            local entity = Ents.NewEntity(true, "ENEMY_OTHRIAN_GUARD", math.random(340, 360), 404)
            miscData.enemiesSpawned[#miscData.enemiesSpawned+1] = entity
            local entX, entY = entity:GetPosition()
            local angleToEnt = Util.MathGetAngleTo(plyX, plyY, entX, entY)
            entity.ai.movingTo = {plyX + math.cos(angleToEnt) * 64, plyY + math.sin(angleToEnt) * 64}
            entity.cooldowns.aggro.current = 99
            entity.ai.doNotWander = true
            entity.ai.doNotFindEnemy = true
        end
    end,
    End = function(gameObjects, miscData)
        miscData.enemiesSpawned[math.random(1,#miscData.enemiesSpawned)]:Say("CHADRION! SUBMIT OR DIE!")
    end
}
this[3] = {
    pauseAI = false,
    time = 8,
    text = {
        content = "\"I guess there's no time for questions... ____Help me send these dogs to the Creator!\"",
        time = 5,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    End = function(gameObjects, miscData)
        miscData.enemiesSpawned[math.random(1,#miscData.enemiesSpawned)]:Say("VERY WELL! YOUR REBELLION DIES HERE!")
        for k, v in pairs(miscData.enemiesSpawned) do
            if v.ai ~= nil then
                v.ai.doNotWander = false
                v.ai.doNotFindEnemy = false
            end
        end
        
        local chadrion = gameObjects[278292764]
        chadrion.ai.doNotWander = false
        chadrion.ai.doNotFindEnemy = false

        -- Remove falling fireball fx
        Objects.RemoveGameObject(367375)
        Objects.RemoveGameObject(457457)
    end
}

this[5] = {
    pauseAI = false,
    time = 3,
    text = {
        content = "\"Nice work!\"",
        time = 1,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    Start = function(gameObjects, miscData)
        miscData.enemiesSpawned = nil
        local chadrion = gameObjects[278292764]
        local plyX, plyY = Player.Get():GetPosition()
        local randX, randY = Util.GetNavValidRandomPointNear(plyX, plyY, 16)

        chadrion.ai.movingTo = {randX, randY}
        chadrion.ai.doNotWander = true
        chadrion.ai.doNotFindEnemy = true
    end,
    End = function(gameObjects)
        local chadrion = gameObjects[278292764]
        if Player.Get().health <= Player.Get().maxHealth / 2 then
            Rooms.SetCutsceneStage(7)
        elseif chadrion.health <= chadrion.maxHealth / 2 then
            Rooms.SetCutsceneStage(6)
        else
            Rooms.SetCutsceneStage(8)
        end
    end
}
this[6] = {
    pauseAI = false,
    time = 8,
    text = {
        content = "\"I'm hurt pretty bad. ____I don't suppose you know of a way to heal me up a bit? ____I would appreciate it greatly.\"",
        time = 6,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    End = function(gameObjects)
        Rooms.SetCutsceneStage(9)
    end
}
this[7] = {
    pauseAI = false,
    time = 8,
    text = {
        content = "\"You don't look so good. ____I don't know of a way to make that better, __but I _will _protect you as best I can.\"",
        time = 6,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    End = function(gameObjects)
        Rooms.SetCutsceneStage(9)
    end
}
this[8] = {
    pauseAI = false,
    time = 5,
    text = {
        content = "\"And not much of a scratch on us, huh?\"",
        time = 3,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    }
}
this[9] = {
    pauseAI = false,
    time = 8,
    text = {
        content = "\"We'll likely run into a few more. ____Come on, __the way out is down this path! __I got your back.\"",
        time = 6,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    End = function(gameObjects)
        local chadrion = gameObjects[278292764]
        chadrion.ai.doNotWander = false
        chadrion.ai.doNotFindEnemy = false
    end
}

this[11] = {
    pauseAI = false,
    time = 8,
    text = {
        content = "\"Seems like we cleared them out! ____Haha!\"",
        time = 6,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    Start = function(gameObjects)
        local chadrion = gameObjects[278292764]
        chadrion.ai.doNotWander = true
        chadrion.ai.doNotFindEnemy = true
    end
}
this[12] = {
    pauseAI = false,
    time = 8,
    text = {
        content = "\"C H A D R I O N ! ! !\"",
        time = 6,
        color = {0.65, 0, 0},
        pitch = 2
    },
    cam = {
        x = 801,
        y = 701,
        time = 3
    },
    Start = function()
        Sounds.PlayBackgroundMusic("Prophet.ogg")
    end,
    Update = function(dt, gameObjects)
        local randX, randY = math.random(793, 809), math.random(693, 709)
        FX.CreateFX("SMOKE", randX, randY, 5)
    end,
    End = function(gameObjects, miscData)
        local chadrion = gameObjects[278292764]
        chadrion:Say("oh boy...", {0.8, 1, 0.5})

        for i=1, 100 do
            FX.CreateFX("SMOKE", 801, 701, 0, 50)
        end
        local ydetRelik = Ents.NewEntity(true, "YDET_RELIK_NORMAL", 801, 701)
        ydetRelik.canBeKilled = false
        ydetRelik:ChangeLookAngle(math.pi)
        ydetRelik.ai.doNotFindEnemy = true
        ydetRelik.ai.doNotWander = true
        miscData.ydetRelik = ydetRelik
        ydetRelik.ai.movingTo = {720, 701}
    end
}
this[13] = {
    pauseAI = false,
    time = 10,
    text = {
        content = "\"You think that you can just RUN AWAY and ___HIDE ___in Larosia forever?\"",
        time = 8,
        color = {0.65, 0, 0},
        pitch = 2
    },
    cam = {
        x = "ydetRelik",
        y = "ydetRelik",
        time = 3
    }
}
this[14] = {
    pauseAI = false,
    time = 11,
    text = {
        content = "\"No no, ____it doesn't __WORK __like that.\"",
        time = 9,
        color = {0.65, 0, 0},
        pitch = 2
    },
    cam = {
        x = "ydetRelik",
        y = "ydetRelik",
        time = 3
    },
    Start = function(gameObjects, miscData)
        miscData.mageSpawnPoints = {}
        for i=1, 12 do
            local randX, randY = Util.GetNavValidRandomPointNear(720, 701, 32)
            miscData.mageSpawnPoints[i] = {
                x = randX,
                y = randY
            }
        end
    end,
    Update = function(dt, gameObjects, miscData)
        for k, v in pairs(miscData.mageSpawnPoints) do
            local randX, randY = math.random(v.x - 8, v.x + 8), math.random(v.y - 8, v.y + 8)
            FX.CreateFX("SMOKE", randX, randY, 0, 5)
        end
    end
}
this[15] = {
    pauseAI = false,
    time = 8,
    text = {
        content = "\"My mages will remind you of this.\"",
        time = 5,
        color = {0.65, 0, 0},
        pitch = 2
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    Start = function(gameObjects, miscData)
        miscData.mages = {}
        miscData.larosians = {}
        for k, v in pairs(miscData.mageSpawnPoints) do
            local mage = Ents.NewEntity(true, "ENEMY_BASIC_HUMAN_MAGE", v.x, v.y)
            mage:ChangeLookAngle(math.pi)
            mage.ai.doNotFindEnemy = true
            mage.ai.doNotWander = true
            miscData.mages[#miscData.mages+1] = mage
            for i=1, 100 do
                FX.CreateFX("SMOKE", v.x, v.y, 0, 50)
            end
        end
        miscData.mageSpawnPoints = nil
    end,
    End = function(gameObjects, miscData)
        for i=1, 12 do
            local toSpawn = "BASIC_HUMAN_MELEE"
            if i % 4 == 0 then toSpawn = "BASIC_HUMAN_RANGED" end
            local randX, randY = Util.GetNavValidRandomPointNear(874, 696, 32)
            local larosian = Ents.NewEntity(true, toSpawn, randX, randY)
            larosian:ChangeLookAngle(math.pi)
            larosian.ai.doNotFindEnemy = true
            larosian.ai.doNotWander = true
            larosian.ai.doNotFollow = true
            miscData.larosians[i] = larosian
        end
    end
}
this[16] = {
    pauseAI = false,
    time = 10,
    text = {
        content = "\"FOR LAROSIA! ________AND FOR A __FREE __OTHRIAN __PEOPLE!\"",
        time = 7,
    },
    cam = {
        x = 801,
        y = 701,
        time = 3
    },
    End = function(gameObjects, miscData)
        Rooms.SetCutsceneStage(161)
    end
}
this[161] = {
    pauseAI = false,
    time = 2,
    text = {
        content = "\"WHAT IN THE\"",
        time = 2,
        color = {0.65, 0, 0},
        pitch = 2
    },
    cam = {
        x = 801,
        y = 701,
        time = 3
    },
    Start = function(gameObjects, miscData)
        miscData.ydetRelik:ChangeLookAngle(0)
    end,
    End = function(gameObjects, miscData)
        local chadrion = gameObjects[278292764]
        chadrion.ai.doNotWander = false
        chadrion.ai.doNotFindEnemy = false
        chadrion.ai.doNotFollow = false

        miscData.ydetRelik.ai.doNotWander = false
        miscData.ydetRelik.ai.doNotFindEnemy = false
        Rooms.SetBossEntity(miscData.ydetRelik)

        for k, v in pairs(miscData.larosians) do
            v:Say("FOR LAROSIA!")
            v.ai.doNotFindEnemy = false
            v.ai.doNotWander = false
            v.ai.doNotFollow = false
        end

        for k, v in pairs(miscData.mages) do
            v.ai.doNotFindEnemy = false
            v.ai.doNotWander = false
        end

        Rooms.SetCutsceneStage(17)
    end
}

this[18] = {
    pauseAI = false,
    time = 10,
    text = {
        content = "\"ENOUGH OF THIS ____NONSENSE!\"",
        time = 5,
        color = {0.65, 0, 0},
        pitch = 2
    },
    cam = {
        x = "ydetRelik",
        y = "ydetRelik",
        time = 3
    },
    Start = function(gameObjects, miscData)
        for k, v in pairs(gameObjects) do
            if v.ai ~= nil then
                v.ai.doNotFindEnemy = true
                v.ai.doNotWander = true
                v.ai.doNotFollow = true
            end
        end
    end,
    Update = function(dt, gameObjects, miscData)
        local ydetX, ydetY = miscData.ydetRelik:GetPosition()
        local randX, randY = math.random(ydetX - 16, ydetX + 16), math.random(ydetY - 16, ydetY + 16)
        FX.CreateFX("SMOKE", randX, randY, 0, 5)
        for k, v in pairs(gameObjects) do
            if v.ai ~= nil then
                if v.uniqueID ~= miscData.ydetRelik.uniqueID then
                    local ydetX, ydetY = miscData.ydetRelik:GetPosition()
                    local thisEntX, thisEntY = v:GetPosition()
                    local dist = Util.MathDistance(ydetX, ydetY, thisEntX, thisEntY)
                    if dist <= 64 then
                        local ydetAngleToThisEnt = Util.MathGetAngleTo(ydetX, ydetY, thisEntX, thisEntY)
                        local xMod = math.cos(ydetAngleToThisEnt)
                        local yMod = math.sin(ydetAngleToThisEnt)
                        v:Flick(xMod, yMod, Util.MathLerp(8, 1, dist/64))
                    end
                end
            end
        end
    end,
    End = function(gameObjects, miscData)
        local ydetX, ydetY = miscData.ydetRelik:GetPosition()
        for i=1, 200 do
            FX.CreateFX("SMOKE", ydetX, ydetY, 0, 50)
        end
        Rooms.SetBossEntity(nil)
        Objects.RemoveGameObject(miscData.ydetRelik.uniqueID)
        miscData.ydetRelik = nil
        miscData.mages = nil
        miscData.larosians = nil

        Sounds.PlayBackgroundMusic("FFXAttack.ogg")
    end
}

this[19] = {
    pauseAI = false,
    time = 6,
    text = {
        content = "\"I can't believe we ran him off!\"",
        time = 3,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    Start = function(gameObjects)
        local plyX, plyY = Player.Get():GetPosition()
        local randX, randY = Util.GetNavValidRandomPointNear(plyX, plyY, 16)
        local chadrion = gameObjects[278292764]
        chadrion.ai.movingTo = {randX, randY}
    end
}
this[20] = {
    pauseAI = false,
    time = 7,
    text = {
        content = "\"I wouldn't have made it to my people without your help.\"",
        time = 5,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    }
}
this[21] = {
    pauseAI = false,
    time = 12,
    text = {
        content = "\"Please, ____come with me to Larosia. ____You are free to refuse, __but you might be safer there anyway considering you just made an enemy of Othria.\"",
        time = 10,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "278292764",
        y = "278292764",
        time = 3
    },
    End = function(gameObjects)
        for k, v in pairs(gameObjects) do
            if v.ai ~= nil then
                v.ai.doNotFindEnemy = false
                v.ai.doNotWander = false
            end
        end

        local chadrion = gameObjects[278292764]
        chadrion.ai.doNotWander = true
        chadrion.ai.doNotFindEnemy = true
        chadrion.ai.doNotFollow = true
        chadrion.ai.targetEntID = nil
        chadrion.ai.movingTo = {801, 701}
    end
}

return this