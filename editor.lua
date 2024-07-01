local this = {}

local inEditMode = false
local inNavMode = false

local standardTileSize = 16

-- Categories
-- 1 = tiles
-- 2 = objects
-- 3 = entities
local currentEditModeCategory = 1
local currentCategoryIndex = 1

local editorPlaceables = {}
editorPlaceables[1] = {}
editorPlaceables[2] = {}
editorPlaceables[3] = {}

local currentEditPolygon = {}
local navEditPolygons = {}

local currentLightAdding = nil

function this.Init()
    for k, v in pairs(Tiles.GetTileDictionary()) do
        local newTile = v
        newTile.originalKey = k
        table.insert(editorPlaceables[1], newTile)
    end
    for k, v in pairs(Objects.GetGameObjectDictionary()) do
        if k:find("ENT_", 1, true) == nil then
            local newObject = v
            newObject.originalKey = k
            table.insert(editorPlaceables[2], newObject)
        end
    end
    for k, v in pairs(Ents.GetEntityDictionary()) do
        local newEntity = v
        newEntity.originalKey = k
        newEntity.image = Objects.GetGameObjectDictionary()["ENT_" .. v.objectID].image
        table.insert(editorPlaceables[3], newEntity)
    end
end

function this.GetInEditMode()
    return inEditMode
end

function this.GetInNavMode()
    return inNavMode
end

local function SetEditMode(toggle)
    if toggle and inNavMode then inNavMode = false end
    inEditMode = toggle
end

local function SavePolygonsToRoomData()
    for k, v in pairs(navEditPolygons) do
        Rooms.AddPolygon(v)
    end
    navEditPolygons = {}
end

local function SetNavMode(toggle)
    if toggle then
        if inEditMode then inEditMode = false end
    else
        SavePolygonsToRoomData()
    end

    inNavMode = toggle
end

local function CycleEditModeCategory(mod)
    local newCategoryNumber = currentEditModeCategory + mod
    if newCategoryNumber < 1 then
        newCategoryNumber = #editorPlaceables
    elseif newCategoryNumber > #editorPlaceables then
        newCategoryNumber = 1
    end
    currentCategoryIndex = 1
    currentEditModeCategory = newCategoryNumber
end

local function CycleEditModeCategoryIndex(mod)
    local newIndex = currentCategoryIndex + mod
    if newIndex < 1 then
        newIndex = #editorPlaceables[currentEditModeCategory]
    elseif newIndex > #editorPlaceables[currentEditModeCategory] then
        newIndex = 1
    end
    currentCategoryIndex = newIndex
end

local function GetCurrentSelectedPlaceable()
    return editorPlaceables[currentEditModeCategory][currentCategoryIndex]
end

local function SaveCurrentPolygon()
    if #currentEditPolygon < 3 then
        return false
    end

    table.insert(navEditPolygons, currentEditPolygon)
    currentEditPolygon = {}

    return true
end

local function DrawEditNavMesh()
    for k2, polygon in pairs(navEditPolygons) do
        local polygonCoords = {}
        for k3, coord in pairs(polygon) do
            local x = coord[1]
            table.insert(polygonCoords, x)
            local y = coord[2]
            table.insert(polygonCoords, y)
            love.graphics.setColor(0.0, 1.0, 0.0, 0.5)
            love.graphics.circle("fill", x, y, 2)
        end
        love.graphics.setColor(0.0, 1.0, 0.0, 0.25)
        love.graphics.polygon("fill", polygonCoords)
    end
    for k, coord in pairs(currentEditPolygon) do
        love.graphics.setColor(1.0, 1.0, 0.0, 0.5)
        love.graphics.circle("fill", coord[1], coord[2], 2)
    end
    love.graphics.setColor(1.0, 1.0, 1.0)
end

function this.Draw()
    if inEditMode then
        local dummyImage = GetCurrentSelectedPlaceable().image or GetCurrentSelectedPlaceable().images[1]

        local mouseX, mouseY = Util.GetPositionInWorld()

        if currentEditModeCategory == 1 then
            mouseX, mouseY = Util.GetCorrectedTilePosition(standardTileSize, mouseX, mouseY)
        elseif currentEditModeCategory == 2 and love.keyboard.isDown("lshift") then
            mouseX, mouseY = Util.GetCorrectedTilePosition(standardTileSize, mouseX, mouseY)
        else
            mouseX, mouseY = mouseX - (dummyImage:getWidth()/2), mouseY - (dummyImage:getHeight()/2)
        end

        love.graphics.draw(dummyImage, mouseX, mouseY)
        love.graphics.printf(GetCurrentSelectedPlaceable().originalKey, mouseX, mouseY, 128, "center")
    elseif inNavMode then
        local mouseX, mouseY = Util.GetPositionInWorld()

        Rooms.DrawNavMesh()
        DrawEditNavMesh()
    end
end

local editorControls = {}
local fullBrightOn = false
editorControls.f = function()
    local ambientLightToSet = {1,1,1}
    if fullBrightOn then
        ambientLightToSet = Rooms.GetCurrentRoomData().ambientLight
    end
    fullBrightOn = not fullBrightOn
    Luven.setAmbientLightColor(ambientLightToSet)
end
editorControls.h = function()
    CURRENT_TEXT_INPUT = Rooms.GetCurrentRoomData().name
	Player.Get().hasControl = false
	GET_TEXT_INPUT = function()
		Rooms.SaveCurrentRoomData(CURRENT_TEXT_INPUT)
		CURRENT_TEXT_INPUT = ""
		GET_TEXT_INPUT = nil
		Player.Get().hasControl = true
	end
end
editorControls.g = function()
    CURRENT_TEXT_INPUT = ""
	Player.Get().hasControl = false
	GET_TEXT_INPUT = function()
		Rooms.MarkForChangeRoom(CURRENT_TEXT_INPUT, true)
		CURRENT_TEXT_INPUT = ""
		GET_TEXT_INPUT = nil
		Player.Get().hasControl = true
	end
end
editorControls.o = function()
    local mouseX, mouseY = Util.GetPositionInWorld()

    if currentLightAdding == nil then
        currentLightAdding = {
            x = mouseX,
            y = mouseY,
            power = 1.0,
            shadow = true,
            lightID = Lighting.AddShadow(mouseX, mouseY, 1.0)
        }
    end
end
editorControls.l = function()
    local mouseX, mouseY = Util.GetPositionInWorld()

    if currentLightAdding == nil then
        currentLightAdding = {
            x = mouseX,
            y = mouseY,
            power = 1.0,
            shadow = false,
            lightID = Lighting.AddStillLight(mouseX, mouseY, {1.0, 1.0, 1.0}, 1.0)
        }
    end
end
editorControls["return"] = function()
    if currentLightAdding ~= nil then
        Rooms.GetCurrentRoomData().outsideLights[currentLightAdding.lightID] = currentLightAdding
        currentLightAdding = nil
    end
end
editorControls.j = function()
	PAUSEAI = not PAUSEAI
end
editorControls.e = function()
	CycleEditModeCategoryIndex(1)
end
editorControls.q = function()
	CycleEditModeCategoryIndex(-1)
end
editorControls.z = function()
	CycleEditModeCategory(1)
end
editorControls.c = function()
	CycleEditModeCategory(-1)
end
local navControls = {}
navControls.k = function()
    SaveCurrentPolygon()
end
function this.CheckKeyPress(key, scanCode, isRepeat)
	if not Player.Get().hasControl then return end

    if key == "p" then
        SetEditMode(not inEditMode)
    elseif key == "n" then
        SetNavMode(not inNavMode)
    end

    if inEditMode and editorControls[key] ~= nil then
        editorControls[key]()
    elseif inNavMode and navControls[key] ~= nil then
        navControls[key]()
    end
end

local editModeLeftClick = {}
editModeLeftClick[1] = function(x, y)
    local overlay = GetCurrentSelectedPlaceable().overlay or false
    Rooms.AddTile(GetCurrentSelectedPlaceable().originalKey, x, y, overlay)
end
editModeLeftClick[2] = function(x, y)
    if love.keyboard.isDown("lshift") then
        x, y = Util.GetCorrectedTilePosition(standardTileSize, x, y)
        local imageWidth, imageHeight = GetCurrentSelectedPlaceable().image:getWidth(), GetCurrentSelectedPlaceable().image:getHeight()
        x, y = x+imageWidth/2, y+imageHeight/2
    end
    Objects.NewGameObject(true, GetCurrentSelectedPlaceable().originalKey, x, y)
end
editModeLeftClick[3] = function(x, y)
    Ents.NewEntity(true, GetCurrentSelectedPlaceable().originalKey, x, y)
end
function this.CheckMousePress(x, y, button, istouch, presses)
    x, y = Util.GetPositionInWorld()
    x, y = Util.MathRound(x), Util.MathRound(y)
    if inEditMode then
        if button == 1 then
            editModeLeftClick[currentEditModeCategory](x, y)
        elseif button == 2 then
            local gameObjectID = Player.Get().mousedOverID
            if (gameObjectID ~= nil) then
                Objects.RemoveGameObject(gameObjectID)
            end
        end
    elseif inNavMode then
        x, y = Rooms.GetExistingPolygonCoordNear(x, y, 3)
        if button == 1 then
            table.insert(currentEditPolygon, {x, y})
        elseif button == 2 then
            local polygonIndex, coordIndex = Rooms.GetPolygonCoordIndexWithPosition(x, y)
            if polygonIndex ~= nil then
                Rooms.ChangePolygonCoordIndex(polygonIndex, coordIndex, nil)
            end
        end
    end
end

function this.Update(dt)
    if this.GetInEditMode() and currentEditModeCategory == 1 and love.mouse.isDown(1) then
        local x, y = Util.GetPositionInWorld()
        editModeLeftClick[1](x, y)
    end
end

function this.CheckMouseScroll(x, y)
    if currentLightAdding ~= nil then
        y = y / 100
        currentLightAdding.power = currentLightAdding.power + y
        Luven.setLightPower(currentLightAdding.lightID, currentLightAdding.power)
    end
end

return this