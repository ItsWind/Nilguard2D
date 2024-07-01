local this = {}

local function EntitySearchForBetterWeaponInBag(entity, attackType, conditional)
    if entity.cooldowns.attack.current > 0 then return false end
    local slotToEquipFrom = nil
    for k, v in pairs(entity.inventory.bag) do
        if not v.doNotLetAISwitchTo and v.attackType ~= nil and v.attackType == attackType then
            if conditional == nil then
                slotToEquipFrom = k
                break
            end
            if conditional(v) then
                slotToEquipFrom = k
                break
            end
        end
    end
    if slotToEquipFrom ~= nil then
        local itemToEquip = entity.inventory.bag[slotToEquipFrom]
        entity:EquipFromSlot(slotToEquipFrom)
        -- Equip shield if possible
        if itemToEquip.equipType == "weapon" and itemToEquip.canUseShield and entity.inventory.equipped.shield == nil then
            -- Equip shield
            for i=1, #entity.inventory.bag do
                if entity.inventory.bag[i].equipType == "shield" then
                    entity:EquipFromSlot(i)
                    break
                end
            end
        end
        return true
    end
    return false
end

local aiWeaponType = {}
aiWeaponType.melee = function(dt, thisEnt, x, y, targetEnt, ignoreVisibility)
    local targetX, targetY = targetEnt:GetPosition()
    local distFromTarget = Util.MathDistance(x, y, targetX, targetY)

    if not thisEnt:CanSeeEntity(targetEnt, ignoreVisibility) then
        thisEnt.ai.targetEntID = nil
        thisEnt.ai.movingTo = {targetX, targetY}
        return
    elseif distFromTarget >= 32 then
        if thisEnt.maxMana ~= nil and thisEnt.mana >= thisEnt.maxMana/2 then
            if EntitySearchForBetterWeaponInBag(thisEnt, "ranged", function(item)
                return item.manaCost ~= nil
            end) then return end
        end

        if EntitySearchForBetterWeaponInBag(thisEnt, "ranged", function(item)
            return item.manaCost == nil
        end) then return end
    end
    local angleToLook = Util.MathGetAngleTo(x, y, targetX, targetY)
    thisEnt:ChangeLookAngle(angleToLook)
    thisEnt.ai.movingTo = {targetX, targetY}
    

    local weaponRange = thisEnt.inventory.equipped.weapon.range

    if distFromTarget <= weaponRange + 4 and thisEnt.ai.attackWait <= 0 then
        thisEnt.cooldowns.block.increase = false
        thisEnt:Attack()
    elseif thisEnt.inventory.equipped.shield ~= nil and targetEnt.inventory.equipped.weapon ~= nil then
        if distFromTarget > weaponRange and targetEnt.inventory.equipped.weapon.attackType == "ranged" then
            thisEnt:Block()
        elseif distFromTarget < weaponRange and targetEnt.inventory.equipped.weapon.attackType == "melee" then
            thisEnt:Block()
        end
    else
        thisEnt.cooldowns.block.increase = false
    end
end
aiWeaponType.ranged = function(dt, thisEnt, x, y, targetEnt, ignoreVisibility)
    local targetX, targetY = targetEnt:GetCenterMassPosition()
    local distFromTarget = Util.MathDistance(x, y, targetX, targetY)

    if not thisEnt:CanSeeEntity(targetEnt, ignoreVisibility) then
        thisEnt.ai.targetEntID = nil
        thisEnt.ai.movingTo = {targetX, targetY}
        return
    elseif distFromTarget < 32 then
        if EntitySearchForBetterWeaponInBag(thisEnt, "melee") then return end
    elseif thisEnt.maxMana ~= nil and thisEnt.mana < thisEnt.maxMana / 8 then
        if EntitySearchForBetterWeaponInBag(thisEnt, "ranged", function(item)
            return item.manaCost == nil
        end) then return
        elseif EntitySearchForBetterWeaponInBag(thisEnt, "melee") then return end
    end

    local angleToLook = 0
    local projectileType = thisEnt.inventory.equipped.weapon.projectileType
    if projectileType ~= nil then
        local projectileSpeed = Projectiles.GetProjectileSpeedFromDict(projectileType)
        local travelTimeTotal = distFromTarget / projectileSpeed
        local targetVelocityX, targetVelocityY = targetEnt.physicsBody:getLinearVelocity()
        local angleX, angleY = targetVelocityX * travelTimeTotal + targetX, targetVelocityY * travelTimeTotal + targetY
    
        angleToLook = Util.MathGetAngleTo(x, y, angleX, angleY)
    else
        angleToLook = Util.MathGetAngleTo(x, y, targetX, targetY)
    end
    thisEnt:ChangeLookAngle(angleToLook)

    if thisEnt.ai.attackWait <= 0 and thisEnt:CanSeeEntity(targetEnt, ignoreVisibility, false) then
        thisEnt:Attack()
    end

    local distance = 80
    local angle = Util.MathGetAngleTo(targetX, targetY, x, y)
    local nearX = targetX + distance * math.cos(angle)
    local nearY = targetY + distance * math.sin(angle)

    local attempts = 0
    local currentDistance = distance
    while not Rooms.GetCurrentRoomData().navigation:is_point_inside(nearX, nearY) do
        attempts = attempts + 1
        if attempts > 1000 then
            nearX, nearY = targetX, targetY
            break
        end

        currentDistance = currentDistance - 5
        if currentDistance <= distance / 4 then
            currentDistance = distance
            angle = math.random(0,math.pi*2)
        end
        nearX = targetX + currentDistance * math.cos(angle)
        nearY = targetY + currentDistance * math.sin(angle)
    end

    thisEnt.ai.movingTo = {nearX, nearY}
end

local function SetupBossEntity(thisEnt, bossName, phases)
    -- Boss setup
    thisEnt.bossData = {}

    thisEnt.bossData.bossName = bossName

    thisEnt.bossData.activePhase = {
        index = nil,
        timer = 0
    }
    thisEnt.bossData.phases = phases

    thisEnt.bossData.currentPhaseTimer = {
        default = 15,
        current = 0
    }

    Rooms.SetBossEntity(thisEnt)
end

local function DoBossPhases(dt, thisEnt, inactiveAction)
    if thisEnt.ai.doNotFindEnemy then return end
    -- Bosses are always aggroed and never take fall damage
    thisEnt.cooldowns.aggro.current = 1
    thisEnt.fallingForDt = 0

    -- Increment phase timer
    thisEnt.bossData.currentPhaseTimer.current = thisEnt.bossData.currentPhaseTimer.current + dt

    -- Phase change
    if thisEnt.bossData.currentPhaseTimer.current >= thisEnt.bossData.currentPhaseTimer.default then
        -- Reset phase timer
        thisEnt.bossData.currentPhaseTimer.current = 0

        -- If boss was doing a phase
        if thisEnt.bossData.activePhase.index ~= nil then
            local phase = thisEnt.bossData.phases[thisEnt.bossData.activePhase.index]
            if phase.done ~= nil then phase.done() end
            thisEnt.bossData.activePhase.index = nil
        -- If boss was not doing a phase, then do a phase
        else
            thisEnt.bossData.activePhase.index = math.random(1, #thisEnt.bossData.phases)
            local phase = thisEnt.bossData.phases[thisEnt.bossData.activePhase.index]
            if phase.init ~= nil then phase.init() end
            phase.action()
            thisEnt.bossData.activePhase.timer = 0
            if phase.phaseTime ~= nil then
                local diff = thisEnt.bossData.currentPhaseTimer.default - phase.phaseTime
                thisEnt.bossData.currentPhaseTimer.current = diff
            end
        end
    end

    -- If has an active phase index
    if thisEnt.bossData.activePhase.index ~= nil then
        local phase = thisEnt.bossData.phases[thisEnt.bossData.activePhase.index]

        thisEnt.bossData.activePhase.timer = thisEnt.bossData.activePhase.timer + dt
        if thisEnt.bossData.activePhase.timer >= phase.delay then
            thisEnt.bossData.activePhase.timer = 0
            phase.action()
        end
    -- If inactive
    else
        inactiveAction()
    end
end

function this.AIIdleChatter(dt, thisEnt)
    if Rooms.IsCutsceneRunning() then return end
    if thisEnt.saying.current ~= nil then return end
    if thisEnt.cooldowns.aggro.current > 0 or thisEnt.ai.targetEntID ~= nil then return end

    if thisEnt.ai.idleChatter == nil then
        thisEnt.ai.idleChatter = {
            lastChatter = 0,
            nextChatterTime = Util.MathRandomDecimal(30, 120)
        }
    end
    thisEnt.ai.idleChatter.lastChatter = thisEnt.ai.idleChatter.lastChatter + dt

    if thisEnt.ai.idleChatter.lastChatter >= thisEnt.ai.idleChatter.nextChatterTime then
        thisEnt.ai.idleChatter.lastChatter = 0
        thisEnt.ai.idleChatter.nextChatterTime = Util.MathRandomDecimal(30, 120)

        local x, y = thisEnt:GetPosition()
        local plyX, plyY = Player.Get():GetPosition()
        local distFromPlayer = Util.MathDistance(x, y, plyX, plyY)
        if distFromPlayer <= 64 and thisEnt:CanSeeEntity(Player.Get()) then
            thisEnt:SayFromSet("idleNearPlayer")
        else
            thisEnt:SayFromSet("idle", 50)
        end
    end
end

function this.AIFollowEntity(dt, thisEnt, followEntity, doNotTurnOff)
    if followEntity == Player.Get() then
        thisEnt.canBeEquipped = true
    end

    if not doNotTurnOff and thisEnt.ai.doNotFollow then return end
    
    if thisEnt.cooldowns.aggro.current > 0 or thisEnt.ai.targetEntID ~= nil then return end

    local x, y = thisEnt:GetPosition()
    local followX, followY = followEntity:GetPosition()

    local followDistance = 48
    local dist = Util.MathDistance(x, y, followX, followY)
    if dist >= followDistance then
        local goToX, goToY = Util.GetNavValidRandomPointNear(followX, followY, followDistance)
        thisEnt.ai.movingTo = {goToX, goToY}
        thisEnt.cooldowns.aggro.current = thisEnt.cooldowns.aggro.default/4
    end
end

function this.AIBreathe(dt, thisEnt)
    if thisEnt.cooldowns.aggro.current > 0 and thisEnt.uniqueID ~= Player.Get().uniqueID then
        dt = dt * 4
    end

    if thisEnt.ai.breathing == nil then
        thisEnt.ai.breathing = {
            currentCycleMod = 1,
            currentCycleTime = 0,
            cycleTimeNeeded = 1.5,
            GetBodyScale = function(maxChange)
                if maxChange == nil then maxChange = 0.075 end
                local change = Util.MathLerp(0, maxChange, thisEnt.ai.breathing.currentCycleTime/thisEnt.ai.breathing.cycleTimeNeeded)
                return 1 + (change * thisEnt.ai.breathing.currentCycleMod)
            end
        }
    end

    thisEnt.ai.breathing.currentCycleTime = thisEnt.ai.breathing.currentCycleTime + dt
    if thisEnt.ai.breathing.currentCycleTime >= thisEnt.ai.breathing.cycleTimeNeeded then
        -- Randomize cycle time needed
        thisEnt.ai.breathing.cycleTimeNeeded = Util.MathRandomDecimal(1.0, 2.0)

        thisEnt.ai.breathing.currentCycleTime = 0
        thisEnt.ai.breathing.currentCycleMod = thisEnt.ai.breathing.currentCycleMod * -1
    end
end

function this.AIWander(dt, thisEnt, range)
    if thisEnt.ai.doNotWander then return end

    if thisEnt.ai.targetEntID ~= nil or thisEnt.cooldowns.aggro.current > 0 then return end

    if thisEnt.ai.sinceLastWander == nil then
        thisEnt.ai.sinceLastWander = 0
    end
    thisEnt.ai.sinceLastWander = thisEnt.ai.sinceLastWander + dt

    if thisEnt.ai.sinceLastWander >= Util.MathRandomDecimal(5, 1500) then
        thisEnt.ai.sinceLastWander = 0

        local x, y = thisEnt:GetPosition()
        local randX, randY = Util.GetNavValidRandomPointNear(x, y, range)

        thisEnt.ai.movingTo = {randX, randY}
    end
end

function this.AIDetectSounds(dt, thisEnt)
    if thisEnt.ai.targetEntID ~= nil then return end

    if thisEnt.cooldowns.aggro.current > 0 then return end

    if thisEnt.ai.targetSoundPos ~= nil then
        thisEnt:SayFromSet("heardSomething", 25)
        thisEnt.cooldowns.aggro.current = thisEnt.cooldowns.aggro.default/2
        local randX, randY = Util.GetNavValidRandomPointNear(thisEnt.ai.targetSoundPos[1], thisEnt.ai.targetSoundPos[2], thisEnt.ai.targetSoundPos[3])
        thisEnt.ai.movingTo = {randX, randY}
        thisEnt.ai.targetSoundPos = nil
    end
end

function this.AIFindEnemy(dt, thisEnt, ignoreVisibility)
    if thisEnt.ai.doNotFindEnemy then return end

    local x, y = thisEnt:GetPosition()

    if thisEnt.ai.attackWait == nil then
        thisEnt.ai.attackWait = 0
    elseif thisEnt.ai.attackWait > 0 then
        thisEnt.ai.attackWait = thisEnt.ai.attackWait - dt
    end

    if thisEnt.ai.findNewEnemyTimer == nil then
        thisEnt.ai.findNewEnemyTimer = 0
    else
        thisEnt.ai.findNewEnemyTimer = thisEnt.ai.findNewEnemyTimer - dt
    end

    if thisEnt.ai.targetEntID == nil and (ignoreVisibility or thisEnt.health >= thisEnt.maxHealth / 6) then
        if thisEnt.ai.findNewEnemyTimer > 0 and thisEnt.cooldowns.aggro.current <= 0 then
            return
        elseif thisEnt.ai.findNewEnemyTimer <= 0 then
            thisEnt.ai.findNewEnemyTimer = Util.MathRandomDecimal(0.5, 2)
        end
        for k, v in pairs(Ents.GetEntities()) do
            if v.uniqueID == thisEnt.uniqueID then goto continue end

            if not v.canBeSeen or v.isBreakable then goto continue end

            local entX, entY = v:GetPosition()
            local distFromEnt = Util.MathDistance(x, y, entX, entY)
            if distFromEnt > thisEnt.sightRange then goto continue end

            if not Factions.IsFactionEnemyOf(thisEnt.faction, v.faction.name) then goto continue end

            if (thisEnt:SameZLevelAsObject(v) and distFromEnt <= thisEnt.sightRange/6) or
            thisEnt:CanSeeEntity(v, ignoreVisibility) then
                thisEnt:SayFromSet("seeEnemy", 25)
                thisEnt.ai.targetEntID = v.uniqueID
                return
            end
            ::continue::
        end
    elseif thisEnt.ai.targetEntID ~= nil then
        thisEnt.cooldowns.aggro.current = thisEnt.cooldowns.aggro.default
        local targetEnt = Objects.GetGameObjects()[thisEnt.ai.targetEntID]
        if targetEnt == nil or not targetEnt.canBeSeen then
            thisEnt:SayFromSet("triumph", 40)
            thisEnt.cooldowns.aggro.current = 0
            thisEnt.ai.targetEntID = nil
            return
        end

        if thisEnt.inventory.equipped.weapon ~= nil then
            aiWeaponType[thisEnt.inventory.equipped.weapon.attackType](dt, thisEnt, x, y, targetEnt, ignoreVisibility)
        end
    end
end

function this.YdetRelik(dt, thisEnt)
    -- Particles
    local numFXParticles = Util.MathLerp(2, 8, thisEnt.z.current/64)
    for i=1, numFXParticles do
        local x, y, z = thisEnt:GetPosition()
        y = thisEnt:GetYDrawLevel()
        local xFx, yFx, zFx = math.random(x-6, x+6), math.random(y-6, y+6), math.random(6, z+18)
    
        local randColorNum = math.random(1,100)
        local color = {0, 0, 0}
        if randColorNum <= 49 then
            color = {0.6, 0, 0.6}
        elseif randColorNum >= 98 then
            color = {0, 1, 0}
        end
        FX.CreateFX("WHITE_SMOKE", xFx, yFx, zFx, 30, nil, color)
    end

    if thisEnt.bossData == nil then
        SetupBossEntity(thisEnt, "Ydet Relik", {
            -- Spawn mobs phase
            {
                init = function()
                    local x, y = thisEnt:GetPosition()
                    Sounds.PlaySound("sound/boss/ydet_relik/evillaugh.ogg", x, y, 256)
                    thisEnt.canBeDamaged = false
                    thisEnt.ai.movingTo = {361, 238, 64}
                end,
                action = function()
                    thisEnt:ChangeLookAngle(-math.pi/2)

                    local plyX, plyY = Player.Get():GetPosition()

                    local spawnX, spawnY = Util.GetNavValidRandomPointNear(plyX, plyY, 64)
                    FX.CreateFX("EMPTY_3", spawnX, spawnY, 0, nil, function(self)
                        Ents.NewEntity(true, "ENEMY_NIL_GUARD", spawnX, spawnY)
                        Sounds.PlaySound("sound/boss/ydet_relik/evillaugh.ogg", spawnX, spawnY, 128, Util.MathRandomDecimal(0.8, 1.2))
                        for i=1, 100 do
                            local randX, randY = Util.MathRandomDecimal(self.x - 8, self.x + 8), Util.MathRandomDecimal(self.y - 8, self.y + 8)
                            local randColor = {0, 0, 0}
                            if math.random(1,2) == 1 then
                                randColor = {0.6, 0, 0.6}
                            end
                            FX.CreateFX("WHITE_SMOKE", randX, randY, 0, 50, nil, randColor)
                        end
                    end, nil, function(self, dt)
                        local randX, randY = Util.MathRandomDecimal(self.x - 8, self.x + 8), Util.MathRandomDecimal(self.y - 8, self.y + 8)
                        local randColor = {0, 0, 0}
                        if math.random(1,2) == 1 then
                            randColor = {0.6, 0, 0.6}
                        end
                        FX.CreateFX("WHITE_SMOKE", randX, randY, 0, 5, nil, randColor)
                    end)
                end,
                done = function()
                    local x, y = thisEnt:GetPosition()
                    Sounds.PlaySound("sound/boss/ydet_relik/evillaugh.ogg", x, y, 256)
                    thisEnt.canBeDamaged = true
                end,
                delay = 3.5,
                phaseTime = 20
            },
            -- Fireball phase
            {
                init = function()
                    local x, y = thisEnt:GetPosition()
                    Sounds.PlaySound("sound/boss/ydet_relik/evillaugh.ogg", x, y, 256)
                    thisEnt.canBeDamaged = false
                    thisEnt.speed = thisEnt.speed*1.25
                    thisEnt.inventory.equipped.weapon = Items.GetWeaponItem("STAFF_FIRE")
                end,
                action = function()
                    local x, y = thisEnt:GetPosition()
                    local plyX, plyY = Player.Get():GetPosition()
                    local randX, randY = Util.GetNavValidRandomPointNear(plyX, plyY, 16)
                    local angleToPly = Util.MathGetAngleTo(x, y, randX, randY)

                    thisEnt:ChangeLookAngle(angleToPly)
                    thisEnt.ai.movingTo = {plyX, plyY}

                    Projectiles.NewProjectile("FIREBALL", thisEnt.uniqueID, x, y, angleToPly, 18)
                end,
                done = function()
                    local x, y = thisEnt:GetPosition()
                    Sounds.PlaySound("sound/boss/ydet_relik/evillaugh.ogg", x, y, 256)
                    thisEnt.canBeDamaged = true
                    thisEnt.speed = thisEnt.speed/1.25
                    thisEnt.inventory.equipped.weapon = Items.GetWeaponItem("YDET_RELIK")
                end,
                delay = 0.35,
                phaseTime = 7
            },
            -- Circle lift phase
            {
                init = function()
                    local x, y = thisEnt:GetPosition()
                    Sounds.PlaySound("sound/boss/ydet_relik/evillaugh.ogg", x, y, 256)
                    thisEnt.canBeDamaged = false
                    thisEnt.ai.movingTo = {361, 238, 64}
                end,
                action = function()
                    thisEnt:ChangeLookAngle(-math.pi/2)

                    local plyX, plyY = Player.Get():GetPosition()

                    local randX, randY = Util.GetNavValidRandomPointNear(plyX, plyY, 128)
                    for i=1, 3 do
                        local centerX, centerY = Util.GetNavValidRandomPointNear(randX, randY, 128)
                        local circleRadius = 64
                        FX.CreateFX("SMOKE", centerX, centerY, 0, 5, function()
                            --local entIDsInArea = Objects.GetEntityIDsInArea(centerX, centerY, circleRadius)

                            for k, v in pairs(Ents.GetEntities()) do
                                local entX, entY = v:GetPosition()
                                if Factions.IsFactionEnemyOf(thisEnt.faction, v.faction.name) and
                                Util.MathDistance(entX, entY, centerX, centerY) <= circleRadius then
                                    v.z.velocity = Util.MathRandomDecimal(200, 300)
                                end
                            end
                        end)
                        for i=-math.pi, math.pi, 0.1 do
                            for j=circleRadius/4, circleRadius, circleRadius/4 do
                                local circleX = centerX + (j * math.cos(i))
                                local circleY = centerY + (j * math.sin(i))
                                FX.CreateFX("WHITE_SMOKE", circleX, circleY, 0, 5)
                            end
                        end
                    end
                    Sounds.PlaySound("sound/boss/ydet_relik/evillaugh.ogg", randX, randY, 128, Util.MathRandomDecimal(0.8, 1.2))
                end,
                done = function()
                    local x, y = thisEnt:GetPosition()
                    Sounds.PlaySound("sound/boss/ydet_relik/evillaugh.ogg", x, y, 256)
                    thisEnt.canBeDamaged = true
                end,
                delay = 3,
                phaseTime = 20
            }
        })
    end

    DoBossPhases(dt, thisEnt, function()
        this.AIFindEnemy(dt, thisEnt, true)
    end)
end

function this.YdetRelikNormal(dt, thisEnt)
    if thisEnt.bossData == nil then
        SetupBossEntity(thisEnt, "Ydet Relik", {
            -- Fireball phase
            {
                init = function()
                    local x, y = thisEnt:GetPosition()
                    Sounds.PlaySound("sound/boss/ydet_relik/evillaugh.ogg", x, y, 256)
                    thisEnt.canBeDamaged = false
                    thisEnt.speed = thisEnt.speed*1.25
                end,
                action = function()
                    local x, y = thisEnt:GetPosition()
                    local plyX, plyY = Player.Get():GetPosition()
                    local randX, randY = Util.GetNavValidRandomPointNear(plyX, plyY, 16)
                    local angleToPly = Util.MathGetAngleTo(x, y, randX, randY)

                    thisEnt:ChangeLookAngle(angleToPly)
                    thisEnt.ai.movingTo = {plyX, plyY}

                    Projectiles.NewProjectile("FIREBALL", thisEnt.uniqueID, x, y, angleToPly, 18)
                end,
                done = function()
                    local x, y = thisEnt:GetPosition()
                    Sounds.PlaySound("sound/boss/ydet_relik/evillaugh.ogg", x, y, 256)
                    thisEnt.canBeDamaged = true
                    thisEnt.speed = thisEnt.speed/1.25
                end,
                delay = 0.6,
                phaseTime = 4
            }
        })
    end

    DoBossPhases(dt, thisEnt, function()
        this.AIFindEnemy(dt, thisEnt, true)
    end)
end

return this