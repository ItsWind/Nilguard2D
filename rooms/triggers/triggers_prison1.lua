local this = {
    -- The guy stops waiting for player in first room
    {
        x1 = 281,
        y1 = 304,
        x2 = 310,
        y2 = 367,
        triggerOnce = true,
        Triggered = function(gameObjects)
            local theGuy = gameObjects[444225576]
            local otherGuys = {
                gameObjects[760206978],
                gameObjects[924708822]
            }

            theGuy.ai.movingTo = {562, 163}
            theGuy.ai.moveToWaitForEntID = Player.Get().uniqueID
            
            for k, v in pairs(otherGuys) do
                v.ai.movingTo = {562, 163}
                v.ai.moveToWaitForEntID = Player.Get().uniqueID
            end
        end
    },
    -- Seems like we got trouble
    {
        x1 = 528,
        y1 = 99,
        x2 = 586,
        y2 = 175,
        triggerOnce = true,
        Triggered = function(gameObjects)
            Rooms.SetCutsceneStage(10)
        end
    },
    -- Check if enemies cleared
    {
        x1 = 416,
        y1 = 32,
        x2 = 703,
        y2 = 111,
        --triggerOnce = true,
        Triggered = function(gameObjects)
            if Rooms.GetCutsceneStage() == 11 and not Ents.ArePlayerEnemiesNearby(562, 74, 500) then
                Rooms.SetCutsceneStage(12)
            end
        end
    },
    -- Teleporter trigger
    {
        x1 = 634,
        y1 = 50,
        x2 = 703,
        y2 = 109,
        --triggerOnce = true,
        Triggered = function(gameObjects)
            if Rooms.GetCutsceneStage() == 14 then
                local inactiveTeleporterID = 722130553
                local inactiveTeleporter = gameObjects[inactiveTeleporterID]
                if inactiveTeleporter == nil then return end

                local x, y = inactiveTeleporter:GetPosition()
                Objects.RemoveGameObject(inactiveTeleporter.uniqueID)
                Objects.NewGameObject(true, "TELEPORTER_ACTIVE", x, y)

                Rooms.SetCutsceneStage(15)
            end
            --Rooms.SetCutsceneStage(69)
        end
    }
}

return this