local this = {}

local selectedItem = nil
local itemScale = 4
local images = {}
local slots = {}

local horizontalSlots = 5
local verticalSlots = 5

local bagSlotScale = 6
local bagSlotPadding = 8
local bagSlotSize = bagSlotScale * 16

local equipSlotScale = 8
local equipSlotPadding = 16
local equipSlotSize = equipSlotScale * 16

function this.GetSelectedItem()
	return selectedItem
end

function this.GetMaxSlots()
	return horizontalSlots * verticalSlots
end

function this.SetupInventory()
	local screenWidth, screenHeight = love.window.getMode()
	local screenCenterX, screenCenterY = screenWidth/2, screenHeight/2

	images.empty = love.graphics.newImage("sprites/inventory_slot_empty.png")
	images.weapon = love.graphics.newImage("sprites/inventory_slot_weapon.png")
	images.shield = love.graphics.newImage("sprites/inventory_slot_shield.png")
	images.torso = love.graphics.newImage("sprites/inventory_slot_torso.png")
	images.head = love.graphics.newImage("sprites/inventory_slot_head.png")

	-- Bag slots
	local slotX = screenCenterX - ((horizontalSlots / 2) * bagSlotSize + ((horizontalSlots / 2) - 0.5) * bagSlotPadding)
	local slotY = screenCenterY - ((verticalSlots / 2) * bagSlotSize + ((verticalSlots / 2) - 0.5) * bagSlotPadding) - (equipSlotSize/2)

	for i=1, verticalSlots do
		for j=1, horizontalSlots do
			local slotNumber = (horizontalSlots * (i - 1)) + j
			slots[slotNumber] = {
				slotType = slotNumber,
				size = bagSlotSize,
				x1 = slotX,
				y1 = slotY,
				x2 = slotX + bagSlotSize,
				y2 = slotY + bagSlotSize
			}

			slotX = slotX + bagSlotSize + bagSlotPadding
		end
		slotX = screenCenterX - ((horizontalSlots / 2) * bagSlotSize + ((horizontalSlots / 2) - 0.5) * bagSlotPadding)
		slotY = slotY + bagSlotSize + bagSlotPadding
	end

	-- Equip slots
	--local equipX = screenCenterX - (2 * equipSlotSize + equipSlotPadding)
	local equipX = screenCenterX - (2.05 * equipSlotSize + equipSlotPadding)
	local equipY = slotY + equipSlotPadding

	for i=1, 4 do
		local equipKey = "weapon"
		if i == 2 then
			equipKey = "shield"
		elseif i == 3 then
			equipKey = "head"
		elseif i == 4 then
			equipKey = "torso"
		end

		slots[equipKey] = {
			slotType = equipKey,
			size = equipSlotSize,
			x1 = equipX,
			y1 = equipY,
			x2 = equipX + equipSlotSize,
			y2 = equipY + equipSlotSize
		}

		equipX = equipX + equipSlotSize + equipSlotPadding
	end
end

function this.Init()
	this.SetupInventory()
end

local function DropSelectedItem()
	local plyX, plyY = Player.Get():GetPosition()
	Items.CreateDroppedItem(selectedItem, plyX, plyY, false)
	selectedItem = nil
end

function this.CheckClickInWorld(clickX, clickY, button, mousedOverID)
	if selectedItem == nil then return false end
	Player.Get().ai.attackWait = 1

	if mousedOverID == nil then
		DropSelectedItem()
		return true
	end

	local mousedOver = Objects.GetGameObjects()[mousedOverID]

	if mousedOver == nil or mousedOver.health == nil or mousedOver.isBreakable then
		DropSelectedItem()
		return true
	end

	-- mousedOver is an entity at this point
	if selectedItem.doNotGiveToNPCs then return false end
	if Factions.IsFactionEnemyOf(mousedOver.faction, "PLAYER") then return false end

	if selectedItem.InventoryUse ~= nil then
        mousedOver:SayFromSet("buffed", 100, true)
		selectedItem.InventoryUse(mousedOver)
		selectedItem = nil
		return true
	elseif mousedOver.canBeEquipped and selectedItem.equipType ~= nil then
		if button == 1 then
			if selectedItem.equipType == "shield" and mousedOver.inventory.equipped.weapon ~= nil and mousedOver.inventory.equipped.weapon.canUseShield == nil then return end
			if selectedItem.equipType == "weapon" and mousedOver.inventory.equipped.shield ~= nil and selectedItem.canUseShield == nil then return end
			mousedOver:SayFromSet("equip", 100, true)
			local equippedInSlot = mousedOver.inventory.equipped[selectedItem.equipType]
			mousedOver.inventory.equipped[selectedItem.equipType] = selectedItem
			selectedItem = equippedInSlot
		elseif button == 2 then
			mousedOver:SayFromSet("bagStore", 100, true)
			mousedOver.inventory.bag[#mousedOver.inventory.bag+1] = selectedItem
			selectedItem = nil
		end
		return true
	end

	return false
end

function this.CheckClick(clickX, clickY, button)
	local clickedSlotKey = nil
	for k, v in pairs(slots) do
		if clickX >= v.x1 and clickX <= v.x2 and clickY >= v.y1 and clickY <= v.y2 then
			clickedSlotKey = v.slotType
			break
		end
	end

	-- If click has slot
	if clickedSlotKey ~= nil then
		local clickedSlotType = type(clickedSlotKey)
		-- If click is a bag slot
		if clickedSlotType == "number" then
			local itemInSlot = Player.Get().inventory.bag[clickedSlotKey]

			-- If right clicked a useable item
			if button == 2 and itemInSlot ~= nil and itemInSlot.InventoryUse ~= nil then
				itemInSlot.InventoryUse(Player.Get())
				Player.Get().inventory.bag[clickedSlotKey] = nil
				return
			-- If shift clicked an equippable item
			elseif love.keyboard.isDown("lshift") and itemInSlot ~= nil and
			(itemInSlot.equipType == "weapon" or itemInSlot.equipType == "head" or itemInSlot.equipType == "torso" or itemInSlot.equipType == "shield") then
				if itemInSlot.equipType == "weapon" and Player.Get().cooldowns.attack.current > 0 then return end
				if itemInSlot.equipType == "shield" and Player.Get().cooldowns.block.current > 0 then return end
				Player.Get():EquipFromSlot(clickedSlotKey)
				return
			end

			-- Switch selected item and bag slot item
			Player.Get().inventory.bag[clickedSlotKey] = selectedItem
			selectedItem = itemInSlot
		-- If click is an equip slot
		else
			if clickedSlotKey == "weapon" and Player.Get().cooldowns.attack.current > 0 then return end
			if clickedSlotKey == "shield" and Player.Get().cooldowns.block.current > 0 then return end

			local itemInEquipSlot = Player.Get().inventory.equipped[clickedSlotKey]

			if selectedItem == nil or selectedItem.equipType == clickedSlotKey then
				if selectedItem ~= nil then
					local usingWeapon = Player.Get().inventory.equipped.weapon
					local usingShield = Player.Get().inventory.equipped.shield
					if selectedItem.equipType == "shield" and usingWeapon ~= nil and usingWeapon.canUseShield == nil then
						for i=1, this.GetMaxSlots() do
							if Player.Get().inventory.bag[i] == nil then
								Player.Get().inventory.bag[i] = usingWeapon
								Player.Get().inventory.equipped.weapon = nil
								break
							end
						end
						if Player.Get().inventory.equipped.weapon ~= nil then return end
					elseif selectedItem.equipType == "weapon" and usingShield ~= nil and selectedItem.canUseShield == nil then
						for i=1, this.GetMaxSlots() do
							if Player.Get().inventory.bag[i] == nil then
								Player.Get().inventory.bag[i] = usingShield
								Player.Get().inventory.equipped.shield = nil
								break
							end
						end
						if Player.Get().inventory.equipped.shield ~= nil then return end
					end
				end
				Player.Get().inventory.equipped[clickedSlotKey] = selectedItem
				selectedItem = itemInEquipSlot
			end
		end
	-- If click has no slot, then drop item
	else
		if selectedItem ~= nil then
			DropSelectedItem()
		end
	end
end

function this.DrawSelectedItem()
	if selectedItem ~= nil then
		local mouseX, mouseY = love.mouse.getPosition()
		local itemImage = selectedItem.images.inventory
		love.graphics.draw(itemImage, mouseX, mouseY, 0, itemScale, itemScale, itemImage:getWidth()/2, itemImage:getHeight()/2)
	end
end

function this.Draw()
	for k, v in pairs(slots) do
		local imageToUse = images.empty
		local slotType = type(v.slotType)

		if slotType == "number" then
			love.graphics.draw(imageToUse, v.x1, v.y1, 0, bagSlotScale, bagSlotScale)

			local itemInSlot = Player.Get().inventory.bag[v.slotType]
			if itemInSlot ~= nil then
				local itemInSlotImage = itemInSlot.images.inventory
				love.graphics.draw(itemInSlotImage, v.x1, v.y1, 0, itemScale, itemScale, -4, -4)
			end
		else
			local alphaToUse = 1
			if v.slotType == "weapon" and Player.Get().cooldowns.attack.current > 0 then
				alphaToUse = Util.MathLerp(1, 0, Player.Get().cooldowns.attack.current/Player.Get().cooldowns.attack.default)
			elseif v.slotType == "shield" and Player.Get().cooldowns.block.current > 0 then
				alphaToUse = Util.MathLerp(1, 0, Player.Get().cooldowns.block.current/Player.Get().cooldowns.block.default)
			end

			local itemInSlot = Player.Get().inventory.equipped[v.slotType]
			if itemInSlot == nil then imageToUse = images[v.slotType] end

			if v.slotType == "shield" and Player.Get().inventory.equipped.weapon ~= nil and Player.Get().inventory.equipped.weapon.canUseShield == nil then
				love.graphics.setColor(0.5, 0.2, 0.2, alphaToUse)
			else
				love.graphics.setColor(1,1,1,alphaToUse)
			end
			love.graphics.draw(imageToUse, v.x1, v.y1, 0, equipSlotScale, equipSlotScale)
			
			if itemInSlot ~= nil then
				local itemInSlotImage = itemInSlot.images.inventory
				love.graphics.draw(itemInSlotImage, v.x1, v.y1, 0, itemScale, itemScale, -8, -8)
			end
			love.graphics.setColor(1,1,1)
		end
	end
end

return this