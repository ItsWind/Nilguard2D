local this = {
    {
        x1 = 0,
        y1 = 0,
        x2 = 2000,
        y2 = 2000,
        Triggered = function(gameObjects)
            if Rooms.GetCutsceneStage() == 0 then
                local enemy1 = gameObjects[776233228]
                local enemy2 = gameObjects[711300929]
                local enemy3 = gameObjects[747819628]

                if enemy1 == nil and enemy2 == nil and enemy3 == nil then
                    Rooms.SetCutsceneStage(1)
                end
            end
        end
    },
    {
        x1 = 0,
        y1 = 0,
        x2 = 2000,
        y2 = 2000,
        Triggered = function(gameObjects, miscData)
            if Rooms.GetCutsceneStage() == 4 then
                local enemiesDead = true
                for k, v in pairs(miscData.enemiesSpawned) do
                    if gameObjects[v.uniqueID] ~= nil then
                        enemiesDead = false
                        break
                    end
                end

                if enemiesDead then
                    Rooms.SetCutsceneStage(5)
                end
            end
        end
    },
    {
        x1 = 633,
        y1 = 628,
        x2 = 770,
        y2 = 819,
        Triggered = function(gameObjects)
            if Rooms.GetCutsceneStage() == 10 then
                if Ents.ArePlayerEnemiesNearby(1000, 1000, 2000) then return end

                Rooms.SetCutsceneStage(11)
            end
        end
    },
    {
        x1 = 0,
        y1 = 0,
        x2 = 2000,
        y2 = 2000,
        Triggered = function(gameObjects, miscData)
            if Rooms.GetCutsceneStage() == 17 then
                for k, v in pairs(miscData.mages) do
                    if gameObjects[v.uniqueID] ~= nil then return end
                end

                if miscData.ydetRelik.health <= 5 then
                    Rooms.SetCutsceneStage(18)
                end
            end
        end
    },
    {
        x1 = 781,
        y1 = 661,
        x2 = 959,
        y2 = 742,
        Triggered = function(gameObjects, miscData)
            if Rooms.GetCutsceneStage() == 22 then
                Rooms.MarkForChangeRoom(Rooms.GetCurrentRoomData().nextRoomName, true, false, true, nil, false)
            end
        end
    },
}

return this