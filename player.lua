local this = {}

local get = nil

function this.Init(x, y)
	InventoryScreen.Init()

	local ply = Ents.NewEntity(false, "PLAYER", x, y)

	if EDITOR_ENABLED then
		--ply.canBeDamaged = false
	end

	ply.cooldowns.dash = {
		current = 0,
		default = 3
	}
	ply.dash = {
		secondsSince = 0
	}

	ply.faction = Factions.GetFactionOf("PLAYER")

	ply.inventory.isOpened = false
	ply.inventory.bag = {}
	ply.inventory.equipped.weapon = nil
	ply.inventory.equipped.shield = nil
	ply.inventory.equipped.torso = nil
	ply.inventory.equipped.head = nil

	ply.DropItems = function(self) end

	ply.GetEquippedID = function(self, equippedSlot)
		local id = nil
		if self.inventory.equipped[equippedSlot] ~= nil then
			id = self.inventory.equipped[equippedSlot].id
		end
		return id
	end

	ply.Die = function(self)
		local x, y, z = self:GetPosition()

		self.canBeDrawn = false
		self.hasControl = false
		self.canBeSeen = false
		self.canBeDamaged = false

        local detectionRadii = self.sounds.detectionRadii or {}
        Sounds.PlaySound(self.sounds.death, x, y, 128, Util.MathRandomDecimal(0.75, 1.25), detectionRadii.death)
        for i=1, 20 do
            FX.CreateFX("WHITE_SMOKE", x, y, z, 20)
        end

		if not Multiplayer.IsConnected() then
			Save.MarkForReload("You have died!")
		else
			self.ai.mpRespawn = 3

			Multiplayer.ClientSend("playerDied", self.connectId)
		end
	end

	ply.MultiplayerUpdate = function(self, dt)
		if Multiplayer.IsConnected() then
			if self.ai.mpRespawn ~= nil then
				if self.ai.mpRespawn < 0 then
					local x, y = Util.GetNavValidRandomPointNear(200, 200, 2000)

					self.canBeDrawn = true
					self.hasControl = true
					self.canBeSeen = true
					self.canBeDamaged = true
					self.health = self.maxHealth
					self.mana = self.maxMana

					Util.RandomizePlayerEquipment()

					self.physicsBody:setPosition(x, y)

					self.ai.mpRespawn = nil

					Multiplayer.ClientSend("playerRespawned", {
						connectId = self.connectId,
						uniqueID = self.uniqueID,
						x = x,
						y = y
					})
				else
					self.ai.mpRespawn = self.ai.mpRespawn - dt
				end
				return
			else
				local plyX, plyY = self:GetPosition()
				Multiplayer.ClientSend("clientUpdateData", {
					health = self.health,
					mana = self.mana,
					x = plyX,
					y = plyY,
					z = self.z.current,
					lookAngle = self.lookAngle,
					sideFacing = self.sideFacing,
					blocking = self.cooldowns.block.increase,
					weaponID = self:GetEquippedID("weapon"),
					shieldID = self:GetEquippedID("shield"),
					torsoID = self:GetEquippedID("torso"),
					headID = self:GetEquippedID("head")
				})
			end
		end
	end

	ply.Update = function(self, dt)
		if Save.IsReloading() then return end
		self.cooldowns.aggro.current = 1

		self:MultiplayerUpdate(dt)

		if not PAUSEAI then
			AI.AIBreathe(dt, self)

			if not self:UpdateZAxis(dt) then return end
			self:UpdateActiveEffects(dt)
			self:UpdateCooldowns(dt)
			self:UpdateStats(dt)
		end

        if self.cooldowns.stunned.current > 0 then return end
		if not self.hasControl then return end

		-- Check blocking
		if self.inventory.equipped.shield ~= nil and love.mouse.isDown(2) then
			self:Block()
		else
			self.cooldowns.block.increase = false
		end

		if self.ai.attackWait == nil then
			self.ai.attackWait = 0
		elseif self.ai.attackWait > 0 then
			self.ai.attackWait = self.ai.attackWait - dt
		end

		-- Attack if left click (held) down and weapon is not melee

		if Editor.GetInEditMode() or Editor.GetInNavMode() then goto SkipAttackCheck end

		if InventoryScreen.GetSelectedItem() == nil then
			if love.mouse.isDown(1) and self.ai.attackWait <= 0 then
				self:Attack()
			elseif love.mouse.isDown(2) then
				self:Block()
			end
		end

		::SkipAttackCheck::
	

		local plyX, plyY = self:GetPosition()
		local cursorX, cursorY = Util.GetPositionInWorld()
		self:ChangeLookAngle(cursorX, cursorY)
	
		-- Get moused over gameobject
		local receivedMousedOverGameObjectID = false
		for k, v in pairs(Objects.GetGameObjects()) do
			local objectX, objectY = v:GetPosition()
			local topLeftX, topLeftY, bottomRightX, bottomRightY = objectX - v.image:getHeight()/2, objectY - v.image:getWidth()/2, objectX + v.image:getHeight()/2, objectY + v.image:getWidth()/2
			if cursorX > topLeftX and cursorY > topLeftY and cursorX < bottomRightX and cursorY < bottomRightY and get.uniqueID ~= v.uniqueID then
				self.mousedOverID = v.uniqueID
				receivedMousedOverGameObjectID = true
				break
			end
		end
		if not receivedMousedOverGameObjectID then
			self.mousedOverID = nil
		end
		
		-- Player inputs WASD
		local xMod = Util.BoolToInt(love.keyboard.isDown("d")) - Util.BoolToInt(love.keyboard.isDown("a"))
		local yMod = Util.BoolToInt(love.keyboard.isDown("s")) - Util.BoolToInt(love.keyboard.isDown("w"))

		-- Shift dash
		self.dash.secondsSince = self.dash.secondsSince + dt
		local tryDash = love.keyboard.isDown("lshift")
		local tryDoubleDash = self.dash.secondsSince >= 0.69 and self.dash.secondsSince <= 0.79
		if tryDash and (tryDoubleDash or self.cooldowns.dash.current == 0) and (xMod ~= 0 or yMod ~= 0) then
			local dashDamageMult = 2
			self.dash.secondsSince = 0
			if tryDoubleDash then
				dashDamageMult = 1.25
				self.dash.secondsSince = 0.79
			end

			-- Push ents in front of dash out of way
			local dashPushMaxDist = 48
			local dashAngle = Util.MathGetAngleTo(plyX, plyY, plyX + xMod, plyY + yMod)
			local entIDsToDamage = Ents.GetEntityIDsInRangeWithDistanceAndAngle(plyX, plyY, dashPushMaxDist, dashAngle, 0.7)
			for k, v in pairs(entIDsToDamage) do
				-- If ent is not player
				if v ~= self.uniqueID then
					local entity = Objects.GetGameObjects()[v]
					-- If entity can see player (not behind wall)
					if entity:GetZLevel() == 1 and entity:CanSeeEntity(self, true) and Factions.IsFactionEnemyOf(self.faction, entity.faction.name) then
						-- Damage entity and push them
						local entX, entY = entity:GetPosition()
						local distFromPly = Util.MathDistance(plyX, plyY, entX, entY)
						local dashWeapon = {
							damage = Util.MathLerp(self:GetSpeed() * dashDamageMult, 0, distFromPly/dashPushMaxDist),
							knockback = Util.MathLerp(self:GetSpeed() * 6 * dashDamageMult, 0, distFromPly/dashPushMaxDist)
						}

						entity:Stun(1)
						entity:GetDamaged(plyX, plyY, dashWeapon, self.uniqueID)

						if Multiplayer.IsConnected() then
							Multiplayer.ClientSend("entityDashStunned", {
								x = plyX,
								y = plyY,
								stunDuration = 1,
								dashWeapon = dashWeapon,
								victimEntityID = entity.uniqueID,
								attackingEntityID = self.uniqueID
							})
						end
					end
				end
			end

			-- Player push for dash
			self:Flick(xMod, yMod, self:GetSpeed() * dashDamageMult)
			self.cooldowns.dash.current = self.cooldowns.dash.default
		end
	
		-- Player movement WASD
		self:Move(dt, xMod, yMod, self:GetSpeed())
	end

	Objects.StoreGameObject(ply)
	Ents.StoreEntity(ply.uniqueID, ply)

    get = ply
end

function this.Get()
	return get
end

function this.GetNextItemSlotNumberFor(item)
	local maxSlots = InventoryScreen.GetMaxSlots()
	local slotNumsTaken = {}

	for k in pairs(get.inventory.bag) do
		slotNumsTaken[k] = true
	end

	for i=1, maxSlots do
		if slotNumsTaken[i] == nil then
			return i
		end
	end

	return nil
end

-- Inventory draw
function this.DrawInventory(screenWidth, screenHeight)
	if get.inventory.isOpened then
		InventoryScreen.Draw()
	end
	InventoryScreen.DrawSelectedItem()
end

local playerControls = {}
playerControls.u = function()
	local mouseX, mouseY = Util.GetPositionInWorld()

	print(mouseX .. " " .. mouseY)
	Multiplayer.ClientSendTest("HELLO")
end
playerControls.tab = function()
	get.inventory.isOpened = not get.inventory.isOpened
	get.hasControl = not get.inventory.isOpened
end

function this.CheckKeyPress(key, scanCode, isRepeat)
	if Save.IsReloading() then return end
	if (not get.hasControl and (key ~= "tab" or Rooms.IsCutsceneRunning())) or Editor.GetInEditMode() or Editor.GetInNavMode() then return end

	if playerControls[key] ~= nil then playerControls[key]() end
end

function this.CheckMousePress(x, y, button, isTouch, presses)
	if Save.IsReloading() then return end
	local mouseX, mouseY = love.mouse.getPosition()
	local x, y = get:GetPosition()

	-- If mouse is pressed when inventory is opened
	if get.inventory.isOpened then
		InventoryScreen.CheckClick(mouseX, mouseY, button)
		return
	else
		if InventoryScreen.CheckClickInWorld(mouseX, mouseY, button, get.mousedOverID) then return end
	end

	if Rooms.IsCutsceneRunning() then
		Rooms.AdvanceCutsceneStage()
		return
	end

	if get.cooldowns.stunned.current > 0 then return end
	if not get.hasControl then return end

	-- Inventory is not opened and mouse is pressed
	if Editor.GetInEditMode() or Editor.GetInNavMode() then return end

	if InventoryScreen.GetSelectedItem() == nil then
		if button == 1 then
			get:Attack()
		elseif button == 2 then
			get:Block()
		end
	end
end

function this.CheckMouseScroll(x, y)
	if Editor.GetInEditMode() then return end

	local currentScale = Luven.camera.scaleX
	local changedScale = currentScale + (y * 1)

	if changedScale > 8 then
		changedScale = 8
	elseif changedScale < 1 then
		changedScale = 1
	end
	Luven.camera:setScale(changedScale)
end

return this