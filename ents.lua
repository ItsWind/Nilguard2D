local this = {}

local entityDictionary = {}

local entities = {}

local itemSets = require("dictionaries/itemsets")
local sayingSets = require("dictionaries/sayingsets")

function this.Init()
    entityDictionary = require("dictionaries/entities")
end

function this.GetEntityIDsInArea(originX, originY, dist)
    local keysToReturn = {}

    for k, v in pairs(entities) do
        if v.health ~= nil then
            local objX, objY = v:GetPosition()

            if Util.MathDistance(originX, originY, objX, objY) <= dist then
                table.insert(keysToReturn, k)
            end
        end
    end

    return keysToReturn
end

function this.ArePlayerEnemiesNearby(originX, originY, dist)
    for k, v in pairs(entities) do
        if v.health ~= nil and v.isBreakable == nil and Factions.IsFactionEnemyOf(v.faction, "PLAYER") then
            local entX, entY = v:GetPosition()
            if Util.MathDistance(originX, originY, entX, entY) <= dist then
                return true
            end
        end
    end
    return false
end

function this.GetEntityIDsInRangeWithDistanceAndAngle(originX, originY, dist, angle, range)
    local keysToReturn = {}

    angle = Util.MathConvertToPositiveRadians(angle)

    local angle1 = angle - range
    local angle2 = angle + range

    for k, v in pairs(entities) do
        local objX, objY = v:GetCenterMassPosition()
        if v.health ~= nil and Util.MathDistance(originX, originY, objX, objY) <= dist then
            local originAngleToObject = Util.MathGetAngleTo(originX, originY, objX, objY)
            originAngleToObject = Util.MathConvertToPositiveRadians(originAngleToObject)
            if angle1 < 0 then
                if originAngleToObject > angle2 then
                    if originAngleToObject >= (math.pi*2) + angle1 then
                        table.insert(keysToReturn, k)
                        goto continue
                    end
                    goto continue
                end
            elseif angle2 > math.pi*2 then
                if originAngleToObject < angle1 then
                    if originAngleToObject <= angle2 - (math.pi*2) then
                        table.insert(keysToReturn, k)
                        goto continue
                    end
                    goto continue
                end
            end

            if originAngleToObject >= angle1 and originAngleToObject <= angle2 then
                table.insert(keysToReturn, k)
            end
        end
        ::continue::
    end

    return keysToReturn
end

function this.DrawUI()
    for k, v in pairs(entities) do
        if v.DrawUI ~= nil then
            v:DrawUI()
        end
    end
end

function this.GetNumberOfEntities()
    local total = 0
    for k in pairs(entities) do
        total = total + 1
    end
    return total
end

function this.GetEntities()
    return entities
end

function this.RemoveEntity(uniqueID)
    entities[uniqueID] = nil
end

function this.StoreEntity(uniqueID, entity)
    entities[uniqueID] = entity
end

function this.GetEntityDictionary()
    return entityDictionary
end

function this.GetEntityIDFromFixture(fixture)
    for k, v in pairs(entities) do
        if v.health ~= nil and v.physicsFixture == fixture then
            return k
        end
    end
    return nil
end

function this.NewEntity(toStore, entName, x, y, withKey)
    entName = entName:upper()
    local ent = entityDictionary[entName]

    local t = Objects.NewGameObject(false, "ENT_" .. ent.objectID, x, y)
    t.gameObjectName = "ENT_" .. entName
    t.objectID = ent.objectID
    t.hasControl = true
    t.sayingSet = ent.sayingSet or "GENERIC"
    t.maxHealth = ent.health
    t.health = ent.health
    t.canBeDamaged = true
    t.canBeKilled = true
    t.canBeDrawn = true
    t.canBeSeen = true
    t.canBeEquipped = false
    t.maxMana = ent.mana
    t.mana = ent.mana
    t.manaLastUsed = 1
    t.saying = {
        current = nil,
        color = nil,
        timePassed = nil,
        showFor = nil
    }
    t.speed = ent.speed
    t.sightRange = ent.sightRange
    t.seeThruWalls = ent.seeThruWalls
    t.itemDropChance = ent.itemDropChance
    t.DeathAction = ent.DeathAction
    t.BirthAction = ent.BirthAction
    t.sounds = {}
    for k, v in pairs(ent.sounds) do
        t.sounds[k] = v
    end
    t.defaultFaceTimer = 0
    t.images = {}
    for k, v in pairs(ent.images) do
        t.images[k] = v
    end

    if ent.isBreakable then
        t.isBreakable = ent.isBreakable
    end

    t.lookAngle = 0

    t.faction = Factions.GetFactionOf("PLAYER_ENEMY")
    if ent.factionName ~= nil then
        t.faction = Factions.GetFactionOf(ent.factionName)
    end

    t.activeEffects = {}

    t.ai = {}

    t.inventory = {}
    t.inventory.bag = {}
    t.inventory.equipped = {}

    if ent.inventory ~= nil then
        if ent.inventory.itemSet ~= nil then
            local itemSet = itemSets[ent.inventory.itemSet]
            t.inventory.equipped.weapon = itemSet:weapon()
            t.inventory.equipped.shield = itemSet:shield()
            t.inventory.equipped.torso = itemSet:torso()
            t.inventory.equipped.head = itemSet:head()
        elseif ent.inventory.itemSets ~= nil then
            local itemSet = itemSets[ent.inventory.itemSets[math.random(1,#ent.inventory.itemSets)]]
            t.inventory.equipped.weapon = itemSet:weapon()
            t.inventory.equipped.shield = itemSet:shield()
            t.inventory.equipped.torso = itemSet:torso()
            t.inventory.equipped.head = itemSet:head()
        end

        if ent.inventory.bag ~= nil then
            local minToAdd = ent.inventory.bag.min or 0
            local maxToAdd = ent.inventory.bag.max or 0
            if minToAdd ~= 0 or maxToAdd ~= 0 and minToAdd <= maxToAdd then
                local itemsToAddToBag = Items.GetRandomItems(minToAdd, maxToAdd, ent.inventory.bag.lootTier)
                for k, v in pairs(itemsToAddToBag) do
                    table.insert(t.inventory.bag, v)
                end
            end

            if ent.inventory.bag.specificWeapons ~= nil then
                for k, v in pairs(ent.inventory.bag.specificWeapons) do
                    local item = Items.GetWeaponItem(v)
                    table.insert(t.inventory.bag, item)
                end
            end
        end
    end

    t.cooldowns = {}
    -- used for an aggro cooldown
    t.cooldowns.aggro = {
        current = 0,
        default = 5
    }
    -- used for an attacking cooldown
    t.cooldowns.attack = {
        current = 0,
        default = 0
    }
    -- used for a blocking cooldown
    t.cooldowns.block = {
        current = 0,
        default = 0,
        increase = false
    }
    t.cooldowns.parry = {
        current = 0,
        default = 0.5
    }
    t.cooldowns.stunned = {
        current = 0
    }
    -- used for redness on damaged
    t.cooldowns.damaged = {
        current = 0,
        default = 0.25
    }
    -- used for health bar display fade if no changes
    t.cooldowns.showHealth = {
        current = 0,
        default = 7
    }
    -- used for mana bar display fade if no changes
    t.cooldowns.showMana = {
        current = 0,
        default = 7
    }

    t.SetFaceEmotion = function(self, faceEmotionStr, forSeconds, override)
        if self.isBreakable then return end
        -- Player does not have a face canonically
        if not Multiplayer.IsConnected() and self.uniqueID == Player.Get().uniqueID then return end

        if self.images.defaultFace == nil then
            self.images.defaultFace = self.images.face
        end

        if faceEmotionStr == nil then
            self.images.face = self.images.defaultFace
            return
        end

        if override == nil then override = false end

        self.images.face = love.graphics.newImage("sprites/entities/humanoid/humanoid_face_" .. faceEmotionStr .. ".png")
        
        if override then
            self.defaultFaceTimer = forSeconds
        else
            self.defaultFaceTimer = self.defaultFaceTimer + forSeconds
        end
    end

    t.Stun = function(self, forSeconds, override)
        if self.isBreakable then return end
        if override == nil then override = false end

        if self.uniqueID == Player.Get().uniqueID then
            Luven.camera:setShake(forSeconds/2, 1)
        end

        self:AddActiveEffect(function()
            local x, y, z = self:GetCenterMassPosition()
            local randX, randY, randZ = math.random(x-4, x+4), math.random(y+1, y+4), math.random(z+12, z+20)
            FX.CreateFX("STUNNED", randX, randY, randZ, {
                x = Util.MathRandomDecimal(-10, 10),
                y = Util.MathRandomDecimal(-5, 5),
                z = Util.MathRandomDecimal(-5, 5)
            })
        end, forSeconds, 0.05)
        self:SetFaceEmotion("stunned", forSeconds, override)
        if override then
            self.cooldowns.stunned.current = forSeconds
        else
            self.cooldowns.stunned.current = self.cooldowns.stunned.current + forSeconds
        end
    end

    t.Say = function(self, text, color, showFor)
        if text == nil then
            self.saying.current = nil
            self.saying.color = nil
            self.saying.timePassed = nil
            self.saying.showFor = nil
            return
        end
        if color == nil then color = {1,1,1} end
        if showFor == nil then showFor = 6 end

        self.saying.current = text
        self.saying.color = color
        self.saying.timePassed = 0
        self.saying.showFor = 6
    end

    t.SayFromSet = function(self, setType, chanceToSay, override)
        if override == nil then override = false end
        if not override and self.saying.current ~= nil then return end

        if chanceToSay ~= nil and math.random(1,100) >= chanceToSay then return end

        local sayings = sayingSets[self.sayingSet][setType]
        if sayings == nil then return end
        local randIndex = math.random(1, #sayings)
        local color = sayingSets[self.sayingSet].color
        self:Say(sayings[randIndex], color)
    end

    t.GetSpeed = function(self)
        local currentSpeed = self.speed
        for k, v in pairs(self.inventory.equipped) do
            if v.weight ~= nil then
                currentSpeed = currentSpeed - v.weight
            end
        end
        if currentSpeed < 0 then return 0 end
        if self.cooldowns.aggro.current <= 0 then currentSpeed = currentSpeed * 0.25 end
        if self.cooldowns.block.current > 0 then currentSpeed = currentSpeed / 2 end
        return currentSpeed
    end

    t.DrawUI = function(self)
        if not self.canBeDrawn then return end

        local x, y = self:GetPosition()
        y = y - self.z.current * 0.75
        x, y = Util.GetPositionOnScreen(x, y)

        -- Say
        if self.saying.current ~= nil then
            local sayColor = self.saying.color
            local sayAlpha = 1
            if self.saying.timePassed >= self.saying.showFor/10 then
                sayAlpha = Util.MathLerp(1, 0, self.saying.timePassed/self.saying.showFor)*10
            end
            love.graphics.setColor(sayColor[1], sayColor[2], sayColor[3], sayAlpha)
            local baseHeightNeeded = 40
            if self.cooldowns.showHealth.current > 0 then
                baseHeightNeeded = baseHeightNeeded + 16
            elseif self.cooldowns.showMana.current > 0 then
                baseHeightNeeded = baseHeightNeeded + 8
            end
            local heightNeeded = baseHeightNeeded + (math.floor(utf8.len(self.saying.current) / 14) + 1) * 18
            love.graphics.printf(self.saying.current, ENT_SAY_FONT, x - 96, y - heightNeeded, 192, "center")
        end

        -- Health bar
        local healthBarWidth = 40
        local currentFillWidth = Util.MathLerp(0, healthBarWidth, self.health/self.maxHealth)
        local showHealthAlpha = Util.MathLerp(0, 1, self.cooldowns.showHealth.current/self.cooldowns.showHealth.default)
        love.graphics.setColor(0.2, 0.2, 0.2, showHealthAlpha)
        love.graphics.rectangle("fill", x-(healthBarWidth/2), y-48, healthBarWidth, 8)
        love.graphics.setColor(0.8, 0.0, 0.0, showHealthAlpha)
        love.graphics.rectangle("fill", x-(healthBarWidth/2), y-48, currentFillWidth, 8)

        -- Mana bar
        if self.maxMana ~= nil then
            local manaBarWidth = 40
            local currentFillWidth2 = Util.MathLerp(0, manaBarWidth, self.mana/self.maxMana)
            local showManaAlpha = Util.MathLerp(0, 1, self.cooldowns.showMana.current/self.cooldowns.showMana.default)
            
            love.graphics.setColor(0.2, 0.2, 0.2, showManaAlpha)
            love.graphics.rectangle("fill", x-(manaBarWidth/2), y-40, manaBarWidth, 8)
            love.graphics.setColor(0.0, 0.0, 0.8, showManaAlpha)
            love.graphics.rectangle("fill", x-(manaBarWidth/2), y-40, currentFillWidth2, 8)
        end

        love.graphics.setColor(1.0, 1.0, 1.0)
    end

    t.Draw = function()
        if not t.canBeDrawn then return end

        local x, y = t:GetPosition()

        -- if damaged set to red
        if t.cooldowns.damaged.current > 0 then
            love.graphics.setColor(1.0, 0.0, 0.0)
        end

        if t.images.shadow ~= nil then
            local shadowAlpha = Util.MathLerp(1, 0, t.z.current/24)
            local r,g,b = love.graphics.getColor()
            love.graphics.setColor(r,g,b,shadowAlpha)
            love.graphics.draw(t.images.shadow, x, y, 0, t.sideFacing, 1, t.images.shadow:getWidth()/2, t.images.shadow:getHeight()/2)
            love.graphics.setColor(r,g,b)
        end
        if t.images.body ~= nil then
            local bodyScale = 1
            if t.ai.breathing ~= nil then bodyScale = t.ai.breathing.GetBodyScale() end
            love.graphics.draw(t.images.body, x, y - t.z.current*0.75, 0, t.sideFacing * bodyScale, bodyScale, t.images.body:getWidth()/2, t.images.body:getHeight()/2)
        end
        if t.images.head ~= nil then
            love.graphics.draw(t.images.head, x, y - t.z.current*0.75, 0, t.sideFacing, 1, t.images.head:getWidth()/2, t.images.head:getHeight()/2)
        end
        if t.images.face ~= nil then
            love.graphics.draw(t.images.face, x, y - t.z.current*0.75, 0, t.sideFacing, 1, t.images.face:getWidth()/2, t.images.face:getHeight()/2)
        end
        
        if t.inventory.equipped.torso ~= nil then
            local bodyScale = 1
            if t.ai.breathing ~= nil then bodyScale = t.ai.breathing.GetBodyScale() end
            love.graphics.draw(t.inventory.equipped.torso.images.equipped, x, y - t.z.current*0.75, 0, t.sideFacing * bodyScale, bodyScale, t.inventory.equipped.torso.images.equipped:getWidth()/2, t.inventory.equipped.torso.images.equipped:getHeight()/2)
        end
        if t.inventory.equipped.head ~= nil then
            love.graphics.draw(t.inventory.equipped.head.images.equipped, x, y - t.z.current*0.75, 0, t.sideFacing, 1, t.inventory.equipped.head.images.equipped:getWidth()/2, t.inventory.equipped.head.images.equipped:getHeight()/2)
        end
        if t.inventory.equipped.weapon ~= nil or t.inventory.equipped.shield ~= nil then
            local breathingMod = 0
            if t.ai.breathing ~= nil then
                breathingMod = Util.MathLerp(-0.25, 0.25, t.ai.breathing.currentCycleTime/t.ai.breathing.cycleTimeNeeded) * -t.ai.breathing.currentCycleMod
            end
            local angleToUse = t.lookAngle
            if t.sideFacing < 0 then angleToUse = angleToUse + math.pi end

            -- Draw weapon
            if t.inventory.equipped.weapon ~= nil then
                local xMod = 0
                local yMod = 0

                if t.inventory.equipped.weapon.attackType == "melee" and t.cooldowns.attack.current > 0 then
                    if t.inventory.equipped.weapon.meleeType == "poke" then
                        local movePoint = Util.MathLerp3(0, 6, 0, t.cooldowns.attack.current/t.cooldowns.attack.default, 0.85)
                        xMod = math.cos(t.lookAngle) * movePoint
                        yMod = math.sin(t.lookAngle) * movePoint
                    else
                        local change = Util.MathLerp(-1, 2, t.cooldowns.attack.current/t.cooldowns.attack.default)
                        angleToUse = angleToUse - change * t.sideFacing
                    end
                end

                local weaponImages = t.inventory.equipped.weapon.images
                local weaponImageToUse = weaponImages.equipped
                if t.cooldowns.attack.current > 0 then weaponImageToUse = weaponImages.attack end

                love.graphics.draw(weaponImageToUse, x + xMod, y + yMod - t.z.current*0.75 + breathingMod, angleToUse, t.sideFacing, 1, weaponImageToUse:getWidth()/2, weaponImageToUse:getHeight()/2)
            end
            -- Draw shield
            if t.inventory.equipped.shield ~= nil then
                local shieldRaise = t.cooldowns.block.current/t.cooldowns.block.default
                -- max +5
                local xMod = Util.MathLerp(0, 5, shieldRaise) * t.sideFacing
                -- max -3
                local yMod = Util.MathLerp(0, -3, shieldRaise)

                local shieldImage = t.inventory.equipped.shield.images.equipped
                
                love.graphics.draw(shieldImage, x + xMod, y - t.z.current*0.75 + breathingMod + yMod, 0, t.sideFacing, 1, shieldImage:getWidth()/2, shieldImage:getHeight()/2)
            end
        end

        love.graphics.setColor(1.0, 1.0, 1.0)
    end

    t.GetArmorAbsorption = function(self)
        local totalAbsorption = 0
        for k, v in pairs(self.inventory.equipped) do
            if v.absorption ~= nil then
                totalAbsorption = totalAbsorption + v.absorption
            end
        end
        if totalAbsorption > 1 then totalAbsorption = 1 end
        return Util.MathLerp(1, 0, totalAbsorption)
    end

    t.GetArmorManaRegen = function(self)
        local totalRegen = 0
        for k, v in pairs(self.inventory.equipped) do
            if v.manaRegen ~= nil then
                totalRegen = totalRegen + v.manaRegen
            end
        end
        return totalRegen
    end

    t.DropItems = function(self)
        local randomNum = nil
        local x, y = self:GetPosition()

        for k, v in pairs(self.inventory.bag) do
            randomNum = math.random(1, 100)
            if randomNum <= self.itemDropChance then
                Items.CreateDroppedItem(v, x, y)
            end
        end

        for k, v in pairs(self.inventory.equipped) do
            randomNum = math.random(1, 100)
            if randomNum <= self.itemDropChance then
                Items.CreateDroppedItem(v, x, y)
            end
        end
    end

    t.Die = function(self)
        local x, y, z = self:GetPosition()

        self:DropItems()

        if self.DeathAction ~= nil then self.DeathAction() end

        Objects.RemoveGameObject(self.uniqueID, false)

        local detectionRadii = self.sounds.detectionRadii or {}
        Sounds.PlaySound(self.sounds.death, x, y, 128, Util.MathRandomDecimal(0.75, 1.25), detectionRadii.death)

        for i=1, 20 do
            FX.CreateFX("WHITE_SMOKE", x, y, z, 20)
        end
    end

    t.ModifyMana = function(self, mod)
        if self.maxMana == nil then return false end

        local newMana = self.mana + mod

        if newMana > self.maxMana then
            self.mana = self.maxMana
        elseif newMana < 0 then
            return false
        else
            self.mana = newMana
        end

        if mod < 0 then
            self.manaLastUsed = 0
        end

        return true
    end

    t.ModifyHealth = function(self, mod)
        self.health = self.health + mod
        if self.health <= 0 then
            if not self.canBeKilled then
                self.health = 1
            else
                -- If is a multiplayer entity and not the client player, do not kill, wait for client player.
                if self.connectId ~= nil and self.uniqueID ~= Player.Get().uniqueID then
                    self.health = 1
                    return true
                end
                self:Die()
                return false
            end
        elseif self.health > self.maxHealth then
            self.health = self.maxHealth
        end

        self.cooldowns.showHealth.current = self.cooldowns.showHealth.default

        if mod < 0 then
            self.cooldowns.damaged.current = self.cooldowns.damaged.default
        end
        return true
    end

    t.GetDamaged = function(self, fromX, fromY, weapon, attackerID)
        if not self.canBeDamaged then return end

        local totalDamage = weapon.damage

        -- If player
        if self.uniqueID == Player.Get().uniqueID then
            Luven.camera:setShake(self.cooldowns.damaged.default, 0.25)
        elseif self.cooldowns.aggro.current <= 0 then
            totalDamage = totalDamage * 2
        end

        local x, y = self:GetPosition()

        -- If blocking reduce melee attacks (hit projectiles are caught in dictionary)
        if self:FacingPoint(fromX, fromY) and self.cooldowns.block.current > 0 and weapon.attackType == "melee" then
            local blockRaised = self.cooldowns.block.current/self.cooldowns.block.default
            if blockRaised > 0 and blockRaised < 0.5 then
                self.cooldowns.block.current = self.cooldowns.block.default * 0.5
                self.cooldowns.parry.current = self.cooldowns.parry.default
                local attacker = entities[attackerID]
                if attacker ~= nil and (self.connectId == nil or self.connectId == Player.Get().connectId) then
                    local angleAwayFromHit = Util.MathGetAngleTo(x, y, fromX, fromY)
                    local xMod = math.cos(angleAwayFromHit)
                    local yMod = math.cos(angleAwayFromHit)
                    attacker:Flick(xMod, yMod, 4)
                    attacker:Stun(1.5)
                    if self.uniqueID == Player.Get().uniqueID then
                        Sounds.PlayUISound("sound/shield_parry.ogg", Util.MathRandomDecimal(0.9, 1.1))
                    elseif attacker.uniqueID == Player.Get().uniqueID then
                        Sounds.PlayUISound("sound/get_parry.ogg", Util.MathRandomDecimal(0.9, 1.1))
                    end

                    if Multiplayer.IsConnected() then
                        Multiplayer.ClientSend("shieldParryMelee", {
                            attackerID = attacker.uniqueID,
                            stunDuration = 1.5,
                            flickX = xMod,
                            flickY = yMod
                        })
                    end
                end
                return
            end

            totalDamage = totalDamage * Util.MathLerp(1, (1 - self.inventory.equipped.shield.blockAbsorption), blockRaised)
        end

        -- Modify health and end function if dead
        if not self:ModifyHealth(-(totalDamage * self:GetArmorAbsorption())) then return false end

        local attackerAngleToMe = Util.MathGetAngleTo(fromX, fromY, x, y)

        local xMod = math.cos(attackerAngleToMe)
        local yMod = math.sin(attackerAngleToMe)

        if self.Move ~= nil then
            self:Move(nil, xMod, yMod, weapon.knockback)
        end

        self.ai.targetEntID = attackerID

        local detectionRadii = self.sounds.detectionRadii or {}
        Sounds.PlaySound(self.sounds.hurt, x, y, 128, Util.MathRandomDecimal(0.75, 1.25), detectionRadii.hurt)
        return true
    end

    t.EquipFromSlot = function(self, slotNumber)
        local itemInSlot = self.inventory.bag[slotNumber]
        local itemInEquipSlot = self.inventory.equipped[itemInSlot.equipType]

        -- if trying to equip a shield with a weapon that cannot use a shield
        if itemInSlot.equipType == "shield" and self.inventory.equipped.weapon ~= nil and self.inventory.equipped.weapon.canUseShield == nil then
            for i=1, InventoryScreen.GetMaxSlots() do
                if self.inventory.bag[i] == nil then
                    self.inventory.bag[i] = self.inventory.equipped.weapon
                    self.inventory.equipped.weapon = nil
                    break
                end
            end
            if Player.Get().inventory.equipped.weapon ~= nil then return end
        -- if trying to equip a weapon that cannot use a shield with a shield equipped already
        elseif itemInSlot.equipType == "weapon" and self.inventory.equipped.shield ~= nil and itemInSlot.canUseShield == nil then
            for i=1, InventoryScreen.GetMaxSlots() do
                if self.inventory.bag[i] == nil then
                    self.inventory.bag[i] = self.inventory.equipped.shield
                    self.inventory.equipped.shield = nil
                    break
                end
            end
            if Player.Get().inventory.equipped.shield ~= nil then return end
        end

        self.inventory.equipped[itemInSlot.equipType] = itemInSlot
        self.inventory.bag[slotNumber] = itemInEquipSlot
    end

    t.Attack = function(self)
        if not self.hasControl then return end

        local currentWeapon = self.inventory.equipped.weapon
        if currentWeapon == nil or self.cooldowns.attack.current > 0 or self.cooldowns.block.current > 0 then return end

        if currentWeapon.manaCost ~= nil then
            if self.maxMana == nil then return end
            self.cooldowns.showMana.current = self.cooldowns.showMana.default
            if not self:ModifyMana(-currentWeapon.manaCost) then return end
        end

        self.cooldowns.attack.current = self.cooldowns.attack.default

        local x, y = self:GetPosition()
        
        currentWeapon:Attack(x, y, self)
        self.ai.attackWait = self.cooldowns.attack.current + Util.MathRandomDecimal(0.01, 0.25)

        local detectionRadii = currentWeapon.sounds.detectionRadii or {}
        Sounds.PlaySound(currentWeapon.sounds.attack, x, y, 128, Util.MathRandomDecimal(0.8, 1.5), detectionRadii.attack)

        if Multiplayer.IsConnected() and self.uniqueID == Player.Get().uniqueID then
            local data = {
                x = x,
                y = y,
                manaCost = currentWeapon.manaCost,
                sound = currentWeapon.sounds.attack,
                detectionRadii = detectionRadii.attack
            }
            Multiplayer.ClientSend("clientAttack", data)
        end
    end

    t.Block = function(self)
        if not self.hasControl then return end

        local currentShield = self.inventory.equipped.shield
        if currentShield == nil or self.cooldowns.attack.current > 0 or self.cooldowns.parry.current > 0 then return end

        if currentShield.manaCost ~= nil then
            if self.maxMana == nil then return end
            self.cooldowns.showMana.current = self.cooldowns.showMana.default
            if not self:ModifyMana(-currentShield.manaCost) then return end
        end

        self.cooldowns.block.increase = true
    end

    t.AddActiveEffect = function(self, action, forSeconds, everySeconds)
        local uniqueID = math.random(1, 1000000000)
        while self.activeEffects[uniqueID] ~= nil do uniqueID = math.random(1, 1000000000) end
        local activeEffect = {
            uniqueID = uniqueID,
            action = action,
            forSeconds = forSeconds,
            everySeconds = everySeconds,
            lastActionInSeconds = 0,
            runningForSeconds = 0
        }
        self.activeEffects[uniqueID] = activeEffect
        action()
    end

    t.UpdateActiveEffects = function(self, dt)
        for k, v in pairs(self.activeEffects) do
            v.lastActionInSeconds = v.lastActionInSeconds + dt
            v.runningForSeconds = v.runningForSeconds + dt

            if v.runningForSeconds >= v.forSeconds then
                self.activeEffects[v.uniqueID] = nil
                goto continue
            end

            if v.lastActionInSeconds >= v.everySeconds then
                v.action()
                v.lastActionInSeconds = 0
            end
            ::continue::
        end
    end

    t.UpdateCooldowns = function(self, dt)
        if self.inventory.equipped.weapon ~= nil then
            self.cooldowns.attack.default = self.inventory.equipped.weapon.attackCooldown
        end
        if self.inventory.equipped.shield ~= nil then
            self.cooldowns.block.default = self.inventory.equipped.shield.blockCooldown
        end
        if self.defaultFaceTimer ~= nil and self.defaultFaceTimer > 0 then
            self.defaultFaceTimer = self.defaultFaceTimer - dt
            if self.defaultFaceTimer < 0 then
                self.defaultFaceTimer = 0
                self:SetFaceEmotion(nil)
            end
        end

        -- Cooldowns
        for k, v in pairs(self.cooldowns) do
            if not v.increase then
                if v.current > 0 then
                    v.current = v.current - dt
                    if v.current < 0 then
                        v.current = 0
                    end
                end
            else
                --v.increase = false
                if v.current < v.default then
                    v.current = v.current + dt
                    if v.current > v.default then
                        v.current = v.default
                    end
                end
            end
        end

        -- Say cooldown
        if self.saying.timePassed ~= nil then
            self.saying.timePassed = self.saying.timePassed + dt
            if self.saying.timePassed >= self.saying.showFor then
                self:Say(nil)
            end
        end
    end

    t.UpdateStats = function(self, dt)
        if self.maxMana ~= nil then 
            if self.mana < self.maxMana and self.manaLastUsed >= 1 then
                local baseRegen = dt * 4
                local totalRegen = baseRegen * (1 + self:GetArmorManaRegen())
                self.mana = self.mana + totalRegen
                self:ModifyMana(totalRegen)
            end

            if self.mana > self.maxMana then
                self.mana = self.maxMana
            end
        end

        if self.manaLastUsed ~= nil then
            self.manaLastUsed = self.manaLastUsed + dt
        end
    end

    t.Update = function(self, dt)
        if PAUSEAI then return end

        self:UpdateActiveEffects(dt)
        self:UpdateCooldowns(dt)
        self:UpdateStats(dt)

        if self.cooldowns.stunned.current > 0 then return end

        if ent.aiUpdate ~= nil then ent.aiUpdate(dt, self) end

        if not self:UpdateZAxis(dt) then return end

        -- Pathing to moveto point
        if #Rooms.GetCurrentRoomData().navPolygons[1] > 0 and self.ai.movingTo ~= nil and (self.hasControl or self.ai.movingTo[3] ~= nil) then
            local x, y = self:GetPosition()

            if self.ai.moveToWaitForEntID ~= nil then
                local entity = Objects.GetGameObjects()[self.ai.moveToWaitForEntID]
                if entity == nil then
                    self.ai.moveToWaitForEntID = nil
                else
                    local entX, entY = entity:GetPosition()
                    local distBetween = Util.MathDistance(x, y, entX, entY)
                    if distBetween >= 128 then
                        return
                    end
                end
            end

            local moveToZ = self.ai.movingTo[3] or 0
            if moveToZ > 0 then
                if self.z.current < moveToZ then
                    self.z.velocity = self:GetSpeed()
                elseif self.z.current >= moveToZ then
                    self.z.current = moveToZ
                    self.z.velocity = 0
                end
            end

            local moveToX, moveToY = self.ai.movingTo[1], self.ai.movingTo[2]
            local distanceToMoveTo = Util.MathDistance(x, y, moveToX, moveToY)

            -- Cache path for performance and update 4 times per second
            if self.ai.movingToPath == nil or self.ai.movingToPath.sleepTimer <= 0 then
                self.ai.movingToPath = {
                    sleepTimer = Util.MathRandomDecimal(0.2, 0.3),
                    --sleepTimer = 0.25,
                    path = Rooms.GetCurrentRoomData().navigation:shortest_path(x, y, moveToX, moveToY)
                }
            end
            self.ai.movingToPath.sleepTimer = self.ai.movingToPath.sleepTimer - dt
            local pathToMoveTo = self.ai.movingToPath.path

            -- If path has more than a starting point
            local targetCoord = pathToMoveTo[2]
            if targetCoord ~= nil then
                local targetX, targetY = targetCoord[1], targetCoord[2]
                local angleToTarget = Util.MathGetAngleTo(x, y, targetX, targetY)

                local xMod = math.cos(angleToTarget)
                local yMod = math.sin(angleToTarget)
    
                self:Move(dt, xMod, yMod, self:GetSpeed())
                if self.ai == nil or self.ai.targetEntID == nil then
                    self:ChangeLookAngle(angleToTarget)
                end
            end
        end
    end

    t.FacingPoint = function(self, otherX, otherY)
        local range = 0.15
        local selfX, selfY = self:GetPosition()
        local angleToOther = Util.MathGetAngleTo(selfX, selfY, otherX, otherY)
        if (self.sideFacing == -1 and (angleToOther >= math.pi/2 - range or angleToOther <= -math.pi/2 + range)) or
        (self.sideFacing == 1 and angleToOther <= math.pi/2 + range and angleToOther >= -math.pi/2 - range) then
            return true
        end
        return false
    end

    t.FacingEntity = function(self, otherEntity)
        local entX, entY = otherEntity:GetPosition()
        return self:FacingPoint(entX, entY)
    end

    t.CanSeeEntity = function(self, otherEntity, ignoreVisibility, ignoreEntities)
        if otherEntity.canBeSeen ~= nil and not otherEntity.canBeSeen then return false end

        if ignoreVisibility == nil then ignoreVisibility = false end
        if ignoreEntities == nil then ignoreEntities = true end

        local selfX, selfY = self:GetPosition()
        local otherX, otherY = otherEntity:GetPosition()
        local dist = Util.MathDistance(selfX, selfY, otherX, otherY)

        local rayHasHitWall = false
        if not self.seeThruWalls then
            Objects.GetPhysicsWorld():rayCast(selfX, selfY, otherX, otherY, function(fixture, x, y, xn, yn, fraction)
                if fixture ~= otherEntity.physicsFixture and fixture ~= self.physicsFixture then
                    if ignoreEntities and (fixture:getBody():getType() ~= "static" or fixture:getUserData().canSeeThru) then return -1 end
                    rayHasHitWall = true
                    return 0
                else
                    return -1
                end
            end)
        end

        --[[return not rayHasHitWall and
        (ignoreVisibility or (self:SameZLevelAsObject(otherEntity) and self:FacingEntity(otherEntity) and
        math.random(1, 100) <=
        (Lighting.GetVisibilityAt(otherX, otherY) + Util.MathLerp(100, 0, dist/(self.sightRange/1.5)))))]]
        return not rayHasHitWall and
        (ignoreVisibility or (self:SameZLevelAsObject(otherEntity) and self:FacingEntity(otherEntity)))
    end

    t.ChangeLookAngle = function(self, lookX, lookY)
        -- if angle is supplied
        if lookY == nil then
            self.lookAngle = lookX
        -- if angle is not supplied but coordinates are
        else
            local x, y = self:GetPosition()
            self.lookAngle = Util.MathGetAngleTo(x, y, lookX, lookY)
        end

        if self.lookAngle > math.pi/2 or self.lookAngle < -math.pi/2 then
            self.sideFacing = -1
        else
            self.sideFacing = 1
        end
    end

    if toStore then
        Objects.StoreGameObject(t, withKey)
        entities[t.uniqueID] = t
    end

    if t.BirthAction ~= nil then t.BirthAction() end

    return t
end

return this