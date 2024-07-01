local this = {}

local projectileDictionary = {}

local projectiles = {}

local function RemoveProjectile(projectileID)
    local projectile = projectiles[projectileID]
    if projectile == nil then return end

    projectile.physicsBody:destroy()

    if projectile.lightID ~= nil then Lighting.RemoveLight(projectile.lightID) end
    
    projectiles[projectileID] = nil
end

function this.DoProjectileHit(projectileID, x, y, hitID)
    local projectile = projectiles[projectileID]

    -- In multiplayer, projectiles can be nil when this is called from server which crashes game
    -- IMPLEMENT CHECKER LATER TO GET RID OF FAKE PROJECTILES ON NON-HOST CLIENTS
    if projectile == nil then return end

    if projectile.sounds ~= nil and projectile.sounds.hit ~= nil then
        local detectionRadii = projectile.sounds.detectionRadii or {}
        Sounds.PlaySound(projectile.sounds.hit, x, y, 128, math.random(0.8, 1.5), detectionRadii.hit)
    end

    projectile:HitEffect(x, y, hitID, projectile.ownerID)
    RemoveProjectile(projectileID)

    if Multiplayer.IsHost() then
        local data = {
            projectileID = projectileID,
            x = x,
            y = y,
            hitID = hitID
        }
        Multiplayer.HostSendToAll("projectileHit", data)
    end
end

function this.Init()
    projectileDictionary = require("dictionaries/projectiles")

    Objects.GetPhysicsWorld():setCallbacks(function(a, b, coll)
        if Multiplayer.IsConnected() and not Multiplayer.IsHost() then return end

        local x, y = coll:getPositions()
        if x == nil or y == nil then return end

        local projectileA = this.GetProjectileIDFromFixture(a)
        if projectileA ~= nil then
            local projectileB = this.GetProjectileIDFromFixture(b)
            if projectileB ~= nil then
                this.DoProjectileHit(projectileA, x, y)
                this.DoProjectileHit(projectileB, x, y)
                return
            else
                local gameObjectB = Ents.GetEntityIDFromFixture(b)
                this.DoProjectileHit(projectileA, x, y, gameObjectB)
                return
            end
        end

        local projectileB = this.GetProjectileIDFromFixture(b)
        if projectileB ~= nil then
            local gameObjectA = Ents.GetEntityIDFromFixture(a)
            this.DoProjectileHit(projectileB, x, y, gameObjectA)
            return
        end
    end)
end

function this.StoreProjectile(projectile, withKey)
    -- Assign projectile ID
    local newID = withKey
    if newID == nil then
        newID = math.random(0, 1000000000)
        while projectiles[newID] ~= nil do
            newID = math.random(0, 1000000000)
        end
        projectile.uniqueID = newID
    end
    projectiles[newID] = projectile
end

function this.GetProjectileIDFromFixture(fixture)
    for k, v in pairs(projectiles) do
        if v.physicsFixture == fixture then
            return k
        end
    end
    return nil
end

function this.RemoveAllProjectiles()
    for k, v in pairs(projectiles) do
        RemoveProjectile(k)
    end
end

function this.GetProjectileSpeedFromDict(projectileName)
    return projectileDictionary[projectileName].speed
end

function this.NewProjectile(name, ownerID, x, y, direction, distanceFromOrigin, withKey)
    if distanceFromOrigin == nil then distanceFromOrigin = 0 end

    -- ownerID can be nil
    local projectileTemplate = projectileDictionary[name]

    local startX = x + math.cos(direction) * distanceFromOrigin
    local startY = y + math.sin(direction) * distanceFromOrigin

    local projectile = {}

    projectile.image = projectileTemplate.image
    projectile.bloomImage = projectileTemplate.bloomImage
    projectile.speed = projectileTemplate.speed
    projectile.sounds = projectileTemplate.sounds
    projectile.Update = projectileTemplate.Update
    projectile.HitEffect = projectileTemplate.HitEffect

    local lightToUse = projectileTemplate.light
    if lightToUse ~= nil then
        projectile.lightID = Lighting.AddLight(startX, startY, lightToUse.colorRange, lightToUse.powerRange, lightToUse.speedRange)
    end

    projectile.travelTime = projectileTemplate.travelMaxTime

    projectile.direction = direction

    projectile.physicsBody = love.physics.newBody(Objects.GetPhysicsWorld(), startX, startY)
    projectile.physicsBody:setAngularDamping(0)
    projectile.physicsBody:setLinearDamping(0)
    projectile.physicsBody:setType("dynamic")
    projectile.physicsBody:setBullet(true)

    projectile.physicsShape = love.physics.newCircleShape(2)

    projectile.physicsFixture = love.physics.newFixture(projectile.physicsBody, projectile.physicsShape, 0)

    local maskCategoryDecimal = Util.GetMaskCategoryBinaryDecimal(1)
    projectile.physicsFixture:setFilterData(maskCategoryDecimal, maskCategoryDecimal, 0)

    projectile.ownerID = ownerID

    projectile.GetPosition = function(self)
        return self.physicsBody:getPosition()
    end

    this.StoreProjectile(projectile, withKey)

    return projectile
end

function this.Update(dt)
    for k, v in pairs(projectiles) do
        local moveDirection = v.direction
        local xMod = math.cos(moveDirection) * v.speed
        local yMod = math.sin(moveDirection) * v.speed
        --v.physicsBody:applyLinearImpulse(xMod, yMod)
        v.physicsBody:setLinearVelocity(xMod, yMod)

        local x, y = v:GetPosition()

        if v.lightID ~= nil then
            Luven.setLightPosition(v.lightID, x, y)
        end

        if v.Update ~= nil then v:Update() end
        
        if Multiplayer.IsConnected() and not Multiplayer.IsHost() then goto continue end

        v.travelTime = v.travelTime - dt
        if v.travelTime <= 0 then
            local x, y = v:GetPosition()
            this.DoProjectileHit(k, x, y)
        end

        ::continue::
    end
end

function this.AddToYSort()
    for k, v in pairs(projectiles) do
        local x, y = v:GetPosition()
        YSort.Add(y, function()
            love.graphics.draw(v.image, x, y, v.direction, 1, 1, v.image:getWidth()/2, v.image:getHeight()/2)

            -- Draw bloom
            if v.bloomImage ~= nil then
                Util.DrawBloomImage(v.bloomImage, x, y, true, v.direction)
            end
        end)
    end
end

return this