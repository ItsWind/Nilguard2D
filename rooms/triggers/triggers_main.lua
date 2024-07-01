local this = {
    {
        x1 = 323,
        y1 = 208,
        x2 = 465,
        y2 = 355,
        Triggered = function(gameObjects)
            if Rooms.GetCutsceneStage() == 0 and not Ents.ArePlayerEnemiesNearby(390, 275, 2000) then
                Rooms.SetCutsceneStage(1)
                local inactiveTeleporter = gameObjects[630289977]
                local x, y = inactiveTeleporter:GetPosition()
                Objects.RemoveGameObject(inactiveTeleporter.uniqueID)
                Objects.NewGameObject(true, "TELEPORTER_ACTIVE", x, y)
            end
        end
    }
}

return this