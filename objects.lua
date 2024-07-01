local this = {}

local gameObjectDictionary = {}

local physicsWorld = nil
local gameObjects = {}

local playerObjectProxOverlayShader = love.graphics.newShader("shaders/playerObjectProxOverlay.shader")

function this.Init()
	love.physics.setMeter(32)
	physicsWorld = love.physics.newWorld(0, 0, true)

    gameObjectDictionary = require("dictionaries/objects")
end

function this.Update(dt)
    physicsWorld:update(dt)

    for k, v in pairs(gameObjects) do
        v:Update(dt)
    end
end

function this.AddToYSort()
    for k, v in pairs(gameObjects) do
        local x, y = v:GetPosition()
        YSort.Add(v:GetYDrawLevel(), v.Draw)
    end
end

function this.GetPhysicsWorld()
    return physicsWorld
end

function this.GetGameObjectDictionary()
    return gameObjectDictionary
end

function this.GetGameObjects()
    return gameObjects
end

function this.GetGameObjectCount()
    local count = 0
    for k, v in pairs(gameObjects) do count = count + 1 end
    return count
end

function this.RemoveGameObject(gameObjectID, performDeathActionForEntity)
    local gameObject = gameObjects[gameObjectID]
    if gameObject == nil then return end

    if performDeathActionForEntity == nil then performDeathActionForEntity = true end
    if performDeathActionForEntity and gameObject.DeathAction ~= nil then gameObject.DeathAction(true) end

    gameObject.physicsBody:destroy()

    if gameObject.lightID ~= nil then Lighting.RemoveLight(gameObject.lightID) end
    
    gameObjects[gameObjectID] = nil
    Ents.RemoveEntity(gameObjectID)
end

function this.RemoveAllGameObjects(removePlayer)
    if removePlayer == nil then removePlayer = true end
    for k, v in pairs(gameObjects) do
        if not removePlayer and v.uniqueID == Player.Get().uniqueID then goto continue end
        this.RemoveGameObject(v.uniqueID)
        ::continue::
    end
end

function this.StoreGameObject(gameObject, withKey)
    -- Assign gameObject ID
    local newID = withKey or math.random(0, 1000000000)
    while gameObjects[newID] ~= nil do
        newID = math.random(0, 1000000000)
    end
    gameObject.uniqueID = newID
    gameObjects[newID] = gameObject
end

function this.CreateGameObjectsFromRoomData(newGameObjects)
    for k, v in pairs(newGameObjects) do
        local colonIndex = k:find(":", 1, true)
        local withKey = tonumber(k:sub(colonIndex+1, #k))
        local gameObjectName = k:sub(1, colonIndex-1)
        local entityNameStartIndex, entityNameEndIndex = k:find("ENT_", 1, true)

        local x = v.x
        local y = v.y

        -- If room gameobject is entity
        if entityNameEndIndex ~= nil then
            local entityName = gameObjectName:sub(entityNameEndIndex+1)
            Ents.NewEntity(true, entityName, x, y, withKey)
        -- If room gameobject is not an entity
        else
            this.NewGameObject(true, gameObjectName, x, y, withKey)
        end
    end
end

function this.NewGameObject(toStore, gameObjectName, x, y, withKey)
    local gameObjectToCreate = gameObjectDictionary[gameObjectName]

    x = x or 0
    y = y or 0

    local t = {}
    t.gameObjectName = gameObjectName
    t.editorDrawOnly = gameObjectToCreate.editorDrawOnly
    t.image = gameObjectToCreate.image
    t.bloomImage = gameObjectToCreate.bloomImage
    t.z = {
        current = 0,
        velocity = 0
    }
    t.fallingForDt = 0
    t.canSeeThru = gameObjectToCreate.canSeeThru
    t.proxCullPercent = 0

    t.sideFacing = 1 -- 1 is right, -1 is left

    -- Set colliders if not specified from image
    local collider = gameObjectToCreate.collider or {
        x = t.image:getWidth(),
        y = t.image:getHeight(),
        offsetX = 0,
        offsetY = 0
    }

    t.physicsBody = love.physics.newBody(physicsWorld, x, y)
    t.physicsShape = love.physics.newRectangleShape(collider.offsetX, collider.offsetY, collider.x, collider.y)

    t.physicsFixture = love.physics.newFixture(t.physicsBody, t.physicsShape, 0)
    t.physicsFixture:setUserData(t)

    if collider.noCollide then
        t.physicsFixture:setSensor(true)
    end

    t.GetZLevel = function(self)
        return self.physicsFixture:getFilterData()
    end

    t.SameZLevelAsObject = function(self, otherObject)
        return self:GetZLevel() == otherObject:GetZLevel()
    end

    t.UpdateZAxis = function(self, dt)
        -- Update collisions based on 16px up/down
        local colliderGroupToSet = math.floor(self.z.current / 16) + 1
        if colliderGroupToSet > 16 then colliderGroupToSet = 16 end

        local maskCategoryDecimal = Util.GetMaskCategoryBinaryDecimal(colliderGroupToSet)

        self.physicsFixture:setFilterData(maskCategoryDecimal, maskCategoryDecimal, 0)

        if self.z.velocity ~= 0 then
            self.z.current = self.z.current + (self.z.velocity * dt)
        end

        if self.z.current > 0 then
            self.hasControl = false

            self.z.velocity = self.z.velocity - (313.6 * dt)
            if self.z.velocity < 0 then
                self.fallingForDt = self.fallingForDt + dt
            end
        elseif self.z.current < 0 then
            if self.uniqueID ~= Player.Get().uniqueID or not Player.Get().inventory.isOpened then
                self.hasControl = true
            end

            self.z.current = 0
            self.z.velocity = 0

            if self.fallingForDt >= 0.2 and self.GetDamaged ~= nil then
                local x, y = self:GetPosition()
                local fallDamageWeapon = {
                    damage = self.fallingForDt * 128,
                    knockback = self.fallingForDt
                }
                if not self:GetDamaged(x, y, fallDamageWeapon) then return false end
            end
            self.fallingForDt = 0
        end

        return true
    end

    t.UpdateProxCull = function(self, dt)
        dt = dt * 2
        if self.proxCullActive then
            self.proxCullPercent = self.proxCullPercent + dt
            if self.proxCullPercent > 1 then self.proxCullPercent = 1 end
        else
            self.proxCullPercent = self.proxCullPercent - dt
            if self.proxCullPercent < 0 then self.proxCullPercent = 0 end
        end
    end
    
    --t.Update = gameObjectToCreate.Update or function(self, dt) end
    t.Update = function(self, dt)
        self:UpdateZAxis(dt)
        self:UpdateProxCull(dt)

        if gameObjectToCreate.Update ~= nil then gameObjectToCreate.Update(self, dt) end
    end

    t.GetYDrawLevel = function(self)
        local x, y = self:GetPosition()
        if gameObjectToCreate.yDrawPosOffset ~= nil then y = y + gameObjectToCreate.yDrawPosOffset end
        return y
    end

    t.GetPosition = function(self)
        local x, y = self.physicsBody:getPosition()
        return x, y, self.z.current
    end

    t.Draw = function()
        if t.editorDrawOnly and not Editor.GetInEditMode() then return end
        if gameObjectToCreate.proxCull then
            if t:GetYDrawLevel() > Player.Get():GetYDrawLevel() and Player.Get():CanSeeEntity(t, true) then
                t.proxCullActive = true
            else
                t.proxCullActive = false
            end
            if t.proxCullPercent > 0 then
                local plyX, plyY = Player.Get():GetPosition()
                plyX, plyY = Util.GetPositionOnScreen(plyX, plyY)
                local tmp, objYLevelOnScreen = Util.GetPositionOnScreen(0, t:GetYDrawLevel())
                playerObjectProxOverlayShader:send("plyScreenPos", {plyX, plyY})
                playerObjectProxOverlayShader:send("screenScale", Luven.camera.scaleX)
                playerObjectProxOverlayShader:send("proxCullPercent", t.proxCullPercent)
                playerObjectProxOverlayShader:send("objYDrawLevel", objYLevelOnScreen)
                love.graphics.setShader(playerObjectProxOverlayShader)
            end
        end
        local x, y, z = t:GetPosition()
        love.graphics.draw(t.image, x, y - z*0.75, 0, 1, 1, t.image:getWidth()/2, t.image:getHeight()/2)

        -- Draw bloom
        if t.bloomImage ~= nil then
            Util.DrawBloomImage(t.bloomImage, x, y - z*0.75)
        end

        love.graphics.setShader()
    end

    t.GetCenterMassPosition = function(self)
        local x1, y1, x2, y2 = self.physicsFixture:getBoundingBox()
        local x, y = (x1 + x2) / 2, (y1 + y2) / 2
        return x, y, self.z.current
    end

    if gameObjectToCreate.light ~= nil then
        local centerMassX, centerMassY = t:GetCenterMassPosition()
        t.lightID = Lighting.AddLight(centerMassX, centerMassY, gameObjectToCreate.light.colorRange, gameObjectToCreate.light.powerRange, gameObjectToCreate.light.speedRange)
    end

    if gameObjectToCreate.physicsType == "dynamic" then
        t.physicsBody:setType("dynamic")
        t.physicsBody:setLinearDamping(gameObjectToCreate.physicsDamping)
        t.physicsBody:setAngularDamping(gameObjectToCreate.physicsDamping)

        t.Move = function(self, dt, x, y, speed)
            if x == 0 and y == 0 then return end
            if dt == nil then dt = 0.2 end
            local magnitude = math.sqrt(x * x + y * y)
            self.physicsBody:applyLinearImpulse(x / magnitude * speed * dt * 100, y / magnitude * speed * dt * 100)
        end

        t.Flick = function(self, x, y, speed)
            if x == 0 and y == 0 then return end
            local magnitude = math.sqrt(x * x + y * y)
            self.physicsBody:setLinearVelocity(x / magnitude * speed * 50, y / magnitude * speed * 50)
        end
    end

    if toStore then this.StoreGameObject(t, withKey) end

    if gameObjectToCreate.Start ~= nil then gameObjectToCreate.Start(t) end

    return t
end

return this