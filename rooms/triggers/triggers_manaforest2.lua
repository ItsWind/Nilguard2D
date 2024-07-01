local this = {
    {
        x1 = 59,
        y1 = 177,
        x2 = 116,
        y2 = 225,
        Triggered = function(gameObjects)
            if Rooms.GetCutsceneStage() == 5 then
                Rooms.SetCutsceneStage(6)
            end
        end
    },
    {
        x1 = 197,
        y1 = 326,
        x2 = 306,
        y2 = 399,
        Triggered = function(gameObjects)
            if Rooms.GetCutsceneStage() == 15 then
                Rooms.SetCutsceneStage(16)
            end
        end
    }
}

return this