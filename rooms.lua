local this = {}

Pathfun = require("libraries/pathfun")

local roomData = nil

local flashTimerColor = 1
local changeRoomFlashTimer = nil
local needsToUpdateTo = nil

local camX, camY = 0, 0

local currentOutsideMod = -1

local bossEnt = nil

function this.GetDTMult()
    if Multiplayer.IsConnected() then return 1 end
    
	-- dt change
	local dtMultChange = 0
	if Player.Get().inventory.isOpened then
		dtMultChange = dtMultChange + 0.8
	end
	if Player.Get().cooldowns.parry.current > 0 and Player.Get().canBeDrawn then
		dtMultChange = dtMultChange + Util.MathLerp(0, 0.8, Player.Get().cooldowns.parry.current/Player.Get().cooldowns.parry.default)
	end
	-- Ensure dt change doesn't break game :)
	if dtMultChange > 0.9 then
		dtMultChange = 0.9
	elseif dtMultChange < 0 then
		dtMultChange = 0
	end
    return 1 - dtMultChange
end

function this.SetBossEntity(entity)
    bossEnt = entity
end

function this.GetBossEntity()
    return bossEnt
end

function this.GetDayNightCycleMod()
    return currentOutsideMod
end

function this.SetDayNightCycleMod(newMod)
    currentOutsideMod = newMod
end

function this.GetCurrentRoomData()
    return roomData
end

local function ClearCurrentRoom(removePlayer)
    bossEnt = nil
    Objects.RemoveAllGameObjects(removePlayer)
    Projectiles.RemoveAllProjectiles()
    Items.RemoveAllDroppedItems()
    FX.RemoveAllFX()
    if roomData == nil then return end
    
    for k, v in pairs(roomData.outsideLights) do
        Lighting.RemoveLight(v.lightID)
    end
end

function this.IsCutsceneRunning()
    return roomData.cutscenes[roomData.cutscenes.stage] ~= nil
end

function this.GetCutsceneStage()
    return roomData.cutscenes.stage
end

function this.SetCutsceneStage(newStage)
    if Save.IsReloading() then return end

    for k, v in pairs(Ents.GetEntities()) do
        v.ai.doNotFindEnemy = false
    end
    
    roomData.cutscenes.stage = newStage
    local cutsceneData = roomData.cutscenes[newStage]
    if cutsceneData ~= nil then
        for k, v in pairs(Ents.GetEntities()) do
            v.ai.doNotFindEnemy = true
        end

        roomData.cutscenes.speed = 1

        if cutsceneData.Start ~= nil then cutsceneData.Start(Objects.GetGameObjects(), roomData.cutscenes.miscData) end
        
        local shouldPauseAI = cutsceneData.pauseAI or true
        if cutsceneData.pauseAI then
            PAUSEAI = true
        end

        roomData.cutscenes.origin = {
            x = camX,
            y = camY
        }
        roomData.cutscenes.cameraTimeLeft = cutsceneData.cam.time
        roomData.cutscenes.displayTimeLeft = cutsceneData.time or 999999

        -- if cutscene is a text display
        if cutsceneData.dialogs == nil then
            roomData.cutscenes.type = "text"

            roomData.cutscenes.characterTime = 1 / (#cutsceneData.text.content / cutsceneData.text.time)
            roomData.cutscenes.currentCharacterTime = 0
            roomData.cutscenes.remainingText = cutsceneData.text.content
            roomData.cutscenes.currentText = ""
        -- if cutscene is a dialog choice
        else
            roomData.cutscenes.type = "dialog"

            local screenWidth, screenHeight = love.window.getMode()
            local currentDialogBox = {
                x1 = 32,
                y1 = screenHeight * 0.66,
                width = screenWidth - 64,
                height = 64
            }
            roomData.cutscenes.dialogs = {}
            for k, v in pairs(cutsceneData.dialogs) do
                local dialogInfo = {
                    hoverMeter = 0,
                    text = v.text,
                    goToIndex = v.goToIndex,
                    x1 = currentDialogBox.x1,
                    y1 = currentDialogBox.y1,
                    x2 = currentDialogBox.x1 + currentDialogBox.width,
                    y2 = currentDialogBox.y1 + currentDialogBox.height
                }
                currentDialogBox.y1 = dialogInfo.y2 + (32 * math.floor(utf8.len(v.text)/(screenWidth/22.22)))
                table.insert(roomData.cutscenes.dialogs, dialogInfo)
            end
        end
    else
        PAUSEAI = false
        Player.Get().hasControl = true
    end
end

function this.AdvanceCutsceneStage()
    if roomData.cutscenes.type == "dialog" then return end

    if roomData.cutscenes.speed == 1 then
        roomData.cutscenes.speed = 4
    else
        local currentCutsceneData = roomData.cutscenes[roomData.cutscenes.stage]
        local currentStage = roomData.cutscenes.stage
        if currentCutsceneData.End ~= nil then currentCutsceneData.End(Objects.GetGameObjects(), roomData.cutscenes.miscData) end
        if roomData.cutscenes.stage == currentStage then
            this.SetCutsceneStage(roomData.cutscenes.stage + 1)
        end
        Player.Get().ai.attackWait = 1
    end
end

function this.ChangeRoom(newRoomName, clearCurrent, removePlayer, shouldSave, flashActive)
    if clearCurrent == nil then clearCurrent = false end
    if removePlayer == nil then removePlayer = true end
    if shouldSave == nil then shouldSave = true end

    if clearCurrent then ClearCurrentRoom(removePlayer) end

    local newRoomData = require("rooms/room_" .. newRoomName).GetRoomData()

    Sounds.PlayBackgroundMusic(newRoomData.musicName .. ".ogg")

    if removePlayer then
        Player.Init(newRoomData.playerX, newRoomData.playerY)
    else
        Player.Get().physicsBody:setPosition(newRoomData.playerX, newRoomData.playerY)
    end

    camX, camY = Player.Get().x, Player.Get().y
    Objects.CreateGameObjectsFromRoomData(newRoomData.gameObjects)

    Luven.setAmbientLightColor(newRoomData.ambientLight)

    newRoomData.currentOutsideLight = 1.0
    if roomData ~= nil then
        newRoomData.currentOutsideLight = roomData.currentOutsideLight
    end

    roomData = newRoomData

    for k, v in pairs(roomData.outsideLights) do
        if v.shadow then
            v.lightID = Lighting.AddShadow(v.x, v.y, v.power)
        else
            v.lightID = Lighting.AddStillLight(v.x, v.y, {newRoomData.currentOutsideLight, newRoomData.currentOutsideLight, newRoomData.currentOutsideLight}, v.power)
        end
    end

    roomData.navigation = Pathfun.Navigation(roomData.navPolygons)
    roomData.navigation:initialize()

	local homeDirectoryString = Util.GetHomeDirectory()
    if pcall(function()
        roomData.cutscenes = require("rooms/cutscenes/cutscenes_" .. newRoomName)
    end) then
    else
        roomData.cutscenes = {}
    end
    roomData.cutscenes.miscData = {}

    this.SetCutsceneStage(0)

    if pcall(function()
        roomData.triggers = require("rooms/triggers/triggers_" .. newRoomName)
    end) then
    else
        roomData.triggers = {}
    end

    if shouldSave then
        Save.Save("testsave")
    end

    if flashActive then
        PAUSEAI = true
        changeRoomFlashTimer = {
            current = 3,
            mod = -1
        }
    end
end

local function CheckForUpdate()
    if needsToUpdateTo ~= nil and changeRoomFlashTimer == nil then
        this.ChangeRoom(needsToUpdateTo.roomName, needsToUpdateTo.clearCurrent, needsToUpdateTo.removePlayer, true, needsToUpdateTo.flashActive)
        needsToUpdateTo = nil
    end
end

local function CheckFlashTimer(dt)
    if changeRoomFlashTimer ~= nil then
        Player.Get().hasControl = false
        changeRoomFlashTimer.current = changeRoomFlashTimer.current + (dt * changeRoomFlashTimer.mod)
        if changeRoomFlashTimer.current >= 3 or changeRoomFlashTimer.current <= 0 then
            PAUSEAI = false
            changeRoomFlashTimer = nil
            Player.Get().hasControl = true
        end
    end
end

function this.DrawFlashTimer(screenWidth, screenHeight)
    local alpha = 0

    if changeRoomFlashTimer ~= nil then
        alpha = Util.MathLerp(0, 1, changeRoomFlashTimer.current/1.5)
    elseif changeRoomFlashTimer == nil and needsToUpdateTo ~= nil then
        alpha = 1
    end

    love.graphics.setColor(flashTimerColor,flashTimerColor,flashTimerColor,alpha)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    love.graphics.setColor(1,1,1)
end

function this.MarkForChangeRoom(newRoomName, clearCurrent, removePlayer, flashScreen, flashSound, flashWhite)
    if needsToUpdateTo ~= nil then return end

    if clearCurrent == nil then clearCurrent = false end
    if removePlayer == nil then removePlayer = true end
    if flashScreen then
        changeRoomFlashTimer = {
            current = 0,
            mod = 1
        }
        if flashWhite then
            flashTimerColor = 1
        else
            flashTimerColor = 0
        end
        if flashSound ~= nil then
            Sounds.PlayUISound(flashSound, Util.MathRandomDecimal(0.95, 1.05))
        end
        Player.Get().physicsBody:setLinearVelocity(0, 0)
    end
    needsToUpdateTo = {
        roomName = newRoomName,
        clearCurrent = clearCurrent,
        removePlayer = removePlayer,
        flashActive = flashScreen
    }
end

function this.RestartCurrentRoom()
    this.MarkForChangeRoom(roomData.name, true, true)
end

local function GetCurrentRoomDataLuaString(roomNameInput)
    local luaStrTop = [[local roomData = {}
roomData.name = "%s"
roomData.nextRoomName = "%s"
roomData.playerX = %f
roomData.playerY = %f
roomData.ambientLight = {%f, %f, %f}
roomData.ambientOutside = %s
roomData.musicName = "%s"
]]
    local plyX, plyY = Player.Get():GetPosition()
    luaStrTop = luaStrTop:format(roomNameInput, roomData.nextRoomName, plyX, plyY, roomData.ambientLight[1], roomData.ambientLight[2], roomData.ambientLight[3], roomData.ambientOutside, roomData.musicName)

    local luaStrOutsideLights = "roomData.outsideLights = {\n\t"
    for k, v in pairs(roomData.outsideLights) do
        local outsideLightStr = "[%d] = {x=%f,y=%f,power=%f,shadow=%s},\n"
        outsideLightStr = outsideLightStr:format(k, v.x, v.y, v.power, v.shadow)
        luaStrOutsideLights = luaStrOutsideLights .. outsideLightStr
    end
    luaStrOutsideLights = luaStrOutsideLights .. "}\n"

    local luaStrNavPolygons = "roomData.navPolygons = {\n\t{\n\t\t"
    for k1, pmap in pairs(roomData.navPolygons) do
        for k2, polygon in pairs(pmap) do
            luaStrNavPolygons = luaStrNavPolygons .. "{"
            for k3, coord in pairs(polygon) do
                luaStrNavPolygons = luaStrNavPolygons .. "{" .. coord[1] .. ", " .. coord[2] .. "},"
            end
            luaStrNavPolygons = luaStrNavPolygons .. "},\n\t\t"
        end
    end

    local luaStrTopMid = [[}
}
roomData.gameObjects = {
    ]]

    local luaStrGameObjects = ""
    for k, v in pairs(Objects.GetGameObjects()) do
        if k ~= Player.Get().uniqueID then
            local gameObjectString = [=[["%s:%d"] = {
        ["x"] = %d,
        ["y"] = %d
    },
]=]
            local gameObjectX, gameObjectY = v:GetPosition()
            gameObjectString = gameObjectString:format(v.gameObjectName, v.uniqueID, gameObjectX, gameObjectY)
            luaStrGameObjects = luaStrGameObjects .. gameObjectString
        end
    end

    local luaStrMiddle = [[}
roomData.tiles = {
    ]]

    local luaStrTiles = ""
    for k, v in pairs(roomData.tiles) do
        local tile = Tiles.GetTileDictionary()[v.image]
        local tileKey = tostring(v.x) .. tostring(v.y)
        if tile.overlay then tileKey = tileKey .. "OVERLAY" end
        local tileString = [=[["%s"] = {
        ["x"] = %d,
        ["y"] = %d,
        ["image"] = "%s"
    },
]=]
        tileString = tileString:format(tileKey, v.x, v.y, v.image)
        luaStrTiles = luaStrTiles .. tileString
    end

    local luaStrBottom = [[}
function GetRoomData()
    return roomData
end
return {GetRoomData = GetRoomData}]]

    return luaStrTop .. luaStrOutsideLights .. luaStrNavPolygons .. luaStrTopMid .. luaStrGameObjects .. luaStrMiddle .. luaStrTiles .. luaStrBottom
end
function this.SaveCurrentRoomData(roomNameInput)
	local homeDirectoryString = Util.GetHomeDirectory()
    local file, err = io.open(homeDirectoryString .. "\\rooms\\room_" .. roomNameInput .. ".lua", "w")
    if file then
        file:write(GetCurrentRoomDataLuaString(roomNameInput))
        file:close()
    else
        print(err)
    end
end

function this.AddTile(tileName, x, y, overlay)
    local tileX, tileY = Util.GetCorrectedTilePosition(16, x, y)
    local tileKey = tostring(tileX) .. tostring(tileY)
    if overlay then tileKey = tileKey .. "OVERLAY" end
    roomData.tiles[tileKey] = {
        ["x"] = tileX,
        ["y"] = tileY,
        ["image"] = tileName:upper()
    }
end

function this.AddPolygon(polygon)
    table.insert(roomData.navPolygons[1], polygon)
end

function this.ChangePolygonCoordIndex(polygonIndex, coordIndex, newX, newY)
    if newX == nil or newY == nil then
        local polygonIndices = #roomData.navPolygons[1][polygonIndex]
        if polygonIndices <= 3 then
            table.remove(roomData.navPolygons[1], polygonIndex)
        else
            table.remove(roomData.navPolygons[1][polygonIndex], coordIndex)
        end
    else
        roomData.navPolygons[1][polygonIndex][coordIndex] = {newX, newY}
    end
end

function this.GetPolygonCoordIndexWithPosition(x, y)
    for k1, pmap in pairs(roomData.navPolygons) do
        for polygonIndex, polygon in ipairs(pmap) do
            for coordIndex, coord in ipairs(polygon) do
                if coord[1] == x and coord[2] == y then
                    return polygonIndex, coordIndex
                end
            end
        end
    end
    return nil
end

function this.GetExistingPolygonCoordNear(x, y, snapDist)
    for k1, pmap in pairs(roomData.navPolygons) do
        for k2, polygon in pairs(pmap) do
            for k3, coord in pairs(polygon) do
                local coordX = coord[1]
                local coordY = coord[2]
                if Util.MathDistance(x, y, coordX, coordY) < snapDist then
                    return coordX, coordY
                end
            end
        end
    end
    return x, y
end

function this.Update(dt)
    -- Check for room update
    CheckForUpdate()
    CheckFlashTimer(dt)

    -- Update tiles animation time
    Tiles.UpdateAnimationTime(dt)

    local plyX, plyY = Player.Get():GetPosition()

    -- Day/night outside light cycle
    if roomData.currentOutsideLight >= 1 then
        currentOutsideMod = -1
    elseif roomData.currentOutsideLight <= 0 then
        currentOutsideMod = 1
    end
    roomData.currentOutsideLight = roomData.currentOutsideLight + (dt / 1000 * currentOutsideMod)
    local correctedOutsideLight = roomData.currentOutsideLight
    if correctedOutsideLight < 0.1 then
        correctedOutsideLight = 0.1
    elseif correctedOutsideLight > 0.9 then
        correctedOutsideLight = 0.9
    end

    for k, v in pairs(roomData.outsideLights) do
        if not v.shadow then
            Luven.setLightColor(v.lightID, {correctedOutsideLight, correctedOutsideLight, correctedOutsideLight})
        end
    end

    if roomData.ambientOutside and not Editor.GetInEditMode() then
        Luven.setAmbientLightColor({correctedOutsideLight, correctedOutsideLight, correctedOutsideLight})
    end

    -- Load cutscene data if available
    local currentCutsceneData = roomData.cutscenes[roomData.cutscenes.stage]

    -- If there is no cutscene, follow player
    if currentCutsceneData == nil then
        local velocityX, velocityY = Player.Get().physicsBody:getLinearVelocity()
        plyX = plyX + velocityX * dt
        plyY = plyY + velocityY * dt

        -- Get midpoint between cursor and player
        local mouseX, mouseY = Util.GetPositionInWorld()
        local midX, midY = (plyX + mouseX)/2, (plyY + mouseY)/2
        -- iterate to find closer point to player
        for i=1, 4 do
            midX, midY = (plyX + midX)/2, (plyY + midY)/2
        end
        camX, camY = midX, midY
    -- if there is a cutscene
    else
        if changeRoomFlashTimer ~= nil then return end
        dt = dt * roomData.cutscenes.speed
        Player.Get().hasControl = false

        if currentCutsceneData.Update ~= nil then currentCutsceneData.Update(dt, Objects.GetGameObjects(), roomData.cutscenes.miscData) end

        -- Cutscene general display time
        roomData.cutscenes.displayTimeLeft = roomData.cutscenes.displayTimeLeft - dt
        if roomData.cutscenes.displayTimeLeft <= 0 then
            local currentStage = roomData.cutscenes.stage
            if currentCutsceneData.End ~= nil then currentCutsceneData.End(Objects.GetGameObjects(), roomData.cutscenes.miscData) end
            if roomData.cutscenes.stage == currentStage then
                this.SetCutsceneStage(roomData.cutscenes.stage + 1)
            end
            return
        end

        -- Cutscene camera move
        roomData.cutscenes.cameraTimeLeft = roomData.cutscenes.cameraTimeLeft - dt
        local cameraTimeLeft = Util.MathLerp(0, 1, roomData.cutscenes.cameraTimeLeft/currentCutsceneData.cam.time)
        if cameraTimeLeft < 0 then cameraTimeLeft = 0 end

        local newCamX = currentCutsceneData.cam.x
        local newCamY = currentCutsceneData.cam.y
        -- if cam pos variable is not a number, then convert the string value to a number to follow a game object
        if type(newCamX) ~= "number" or type(newCamY) ~= "number" then
            if newCamX == "ply" then
                newCamX, newCamY = plyX, plyY
            else
                local objID = tonumber(newCamX)
                if objID ~= nil then
                    local gameObject = Objects.GetGameObjects()[objID]
                    if gameObject ~= nil then
                        local objX, objY = gameObject:GetPosition()
                        newCamX, newCamY = objX, objY
                    else
                        newCamX, newCamY = plyX, plyY
                    end
                else
                    local objectFromMiscData = roomData.cutscenes.miscData[newCamX]
                    if objectFromMiscData ~= nil then
                        local objX, objY = objectFromMiscData:GetPosition()
                        newCamX, newCamY = objX, objY
                    else
                        newCamX, newCamY = plyX, plyY
                    end
                end
            end
        end

        local originX = roomData.cutscenes.origin.x or plyX
        local originY = roomData.cutscenes.origin.y or plyY
        camX = Util.MathLerp(newCamX, originX, cameraTimeLeft)
        camY = Util.MathLerp(newCamY, originY, cameraTimeLeft)

        -- Cutscene add text
        if roomData.cutscenes.type == "text" then
            roomData.cutscenes.currentCharacterTime = roomData.cutscenes.currentCharacterTime + dt
            if #roomData.cutscenes.remainingText > 0 and roomData.cutscenes.currentCharacterTime >= roomData.cutscenes.characterTime then
                roomData.cutscenes.currentCharacterTime = 0

                local characterToAdd = roomData.cutscenes.remainingText:sub(1, 1)
                roomData.cutscenes.remainingText = roomData.cutscenes.remainingText:sub(2, #roomData.cutscenes.remainingText)
                if characterToAdd ~= "_" then
                    roomData.cutscenes.currentText = roomData.cutscenes.currentText .. characterToAdd
                    local pitchToUse = currentCutsceneData.text.pitch or 3.95
                    Sounds.PlayUISound("sound/ui/char_appear.ogg", Util.MathRandomDecimal(pitchToUse - 0.05, pitchToUse + 0.05))
                end
            end
        -- Cutscene get if clicked dialogs
        else
            local mouseX, mouseY = love.mouse.getPosition()
            for k, v in pairs(roomData.cutscenes.dialogs) do
                -- If mouse is hovered over dialog
                if mouseX >= v.x1 and mouseX <= v.x2 and mouseY >= v.y1 and mouseY <= v.y2 then
                    if v.hoverMeter < 1 then
                        v.hoverMeter = v.hoverMeter + dt * 4
                    else
                        v.hoverMeter = 1
                    end

                    if v.hoverMeter >= 1 and love.mouse.isDown(1) then
                        this.SetCutsceneStage(v.goToIndex)
                    end
                else
                    if v.hoverMeter > 0 then
                        v.hoverMeter = v.hoverMeter - dt * 4
                    else
                        v.hoverMeter = 0
                    end
                end
            end
        end
    end

    -- Set camera to follow coords
    Luven.camera:setPosition(camX, camY)

    -- Check if player is in a trigger
    for k, v in pairs(roomData.triggers) do
        -- Check if player inside trigger
        if v.triggered == nil and plyX >= v.x1 and plyX <= v.x2 and plyY >= v.y1 and plyY <= v.y2 then
            -- Check triggerOnce var
            if v.triggerOnce == true then v.triggered = true end

            v.Triggered(Objects.GetGameObjects(), roomData.cutscenes.miscData)
        end
    end
end

function this.DrawTiles(overlay)
    for k, v in pairs(roomData.tiles) do
        Tiles.DrawTile(v.image, v.x, v.y, overlay)
    end
end

function this.DrawNavMesh()
    for k1, pMap in pairs(roomData.navPolygons) do
        for k2, polygon in pairs(pMap) do
            local polygonCoords = {}
            for k3, coord in pairs(polygon) do
                local x = coord[1]
                table.insert(polygonCoords, x)
                local y = coord[2]
                table.insert(polygonCoords, y)
                love.graphics.setColor(1.0, 1.0, 1.0, 0.5)
                love.graphics.circle("fill", x, y, 2)
            end
            love.graphics.setColor(1.0, 1.0, 1.0, 0.25)
            love.graphics.polygon("fill", polygonCoords)
        end
    end
    love.graphics.setColor(1.0, 1.0, 1.0)
end

function this.DrawCutscene(screenWidth, screenHeight)
    local currentCutsceneData = roomData.cutscenes[roomData.cutscenes.stage]
    if currentCutsceneData ~= nil then

        -- Draw cutscene text rectangle
        love.graphics.setColor(0, 0, 0, 0.95)
        local cutsceneTextRectangle = {
            x = 16,
            y = screenHeight * 0.66 - 16,
            width = screenWidth - 32,
            height = screenHeight * 0.33
        }
        love.graphics.rectangle("fill", cutsceneTextRectangle.x, cutsceneTextRectangle.y, cutsceneTextRectangle.width, cutsceneTextRectangle.height,
        cutsceneTextRectangle.width/64, cutsceneTextRectangle.height/8, 8)
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("line", cutsceneTextRectangle.x, cutsceneTextRectangle.y, cutsceneTextRectangle.width, cutsceneTextRectangle.height,
        cutsceneTextRectangle.width/64, cutsceneTextRectangle.height/8, 8)

        -- Draw cutscene text
        if roomData.cutscenes.type == "text" then
            local textColor = currentCutsceneData.text.color or {1, 1, 1}
            love.graphics.setColor(textColor[1], textColor[2], textColor[3])
            love.graphics.printf(roomData.cutscenes.currentText, FONT, 32, screenHeight * 0.66, screenWidth - 64, "left")
        else
            for k, v in pairs(roomData.cutscenes.dialogs) do
                local colorRange = Util.MathLerp(0.25, 1, v.hoverMeter)
                love.graphics.setColor(colorRange, colorRange, colorRange)
                love.graphics.printf(v.text, DIALOG_FONT, v.x1, v.y1, screenWidth - 64, "center")
            end
        end
        love.graphics.setColor(1, 1, 1)
    end
end

function this.DrawBossBar(screenWidth, screenHeight)
    if bossEnt ~= nil then
        local paddingX, paddingY = WIDTH_MULT * 4, 16
        local totalWidth = screenWidth - paddingX * 2
        local totalHeight = BOSSBAR_WIDTH_MULT
        local healthBarWidth = Util.MathLerp(0, totalWidth, bossEnt.health/bossEnt.maxHealth)
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", paddingX, paddingY, totalWidth, totalHeight)
        love.graphics.setColor(0.8, 0, 0)
        love.graphics.rectangle("fill", paddingX, paddingY, healthBarWidth, totalHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(bossEnt.bossData.bossName, BOSSBAR_FONT, paddingX, paddingY, totalWidth, "center")
    end
end

return this