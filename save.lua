local this = {}

local homeDirectoryString = Util.GetHomeDirectory()

local reloadMarkText = nil
local reloadMarkFade = nil
local reloadMarkFadeIn = nil

local gameFlags = {}

local function GetSaveDataLuaString()
    local luaStrTop = [[local save = {}
save.roomName = "%s"
save.playerHealth = %f
save.playerMana = %f
save.currentOutsideLight = %f
save.currentDayNightCycleMod = %d
save.playerInventory = {}
save.playerInventory.equipped = {}
]]
	local plyX, plyY = Player.Get():GetPosition()
	luaStrTop = luaStrTop:format(Rooms.GetCurrentRoomData().name, Player.Get().health, Player.Get().mana, Rooms.GetCurrentRoomData().currentOutsideLight, Rooms.GetDayNightCycleMod())

	local playerInventory = Player.Get().inventory

	if playerInventory.equipped.weapon ~= nil then
		local weaponStr = "save.playerInventory.equipped.weapon = \"%s\""
		weaponStr = weaponStr:format(playerInventory.equipped.weapon.id)
		luaStrTop = luaStrTop .. weaponStr .. "\n"
	end
	if playerInventory.equipped.shield ~= nil then
		local shieldStr = "save.playerInventory.equipped.shield = \"%s\""
		shieldStr = shieldStr:format(playerInventory.equipped.shield.id)
		luaStrTop = luaStrTop .. shieldStr .. "\n"
	end
	if playerInventory.equipped.torso ~= nil then
		local torsoStr = "save.playerInventory.equipped.torso = \"%s\""
		torsoStr = torsoStr:format(playerInventory.equipped.torso.id)
		luaStrTop = luaStrTop .. torsoStr .. "\n"
	end
	if playerInventory.equipped.head ~= nil then
		local headStr = "save.playerInventory.equipped.head = \"%s\""
		headStr = headStr:format(playerInventory.equipped.head.id)
		luaStrTop = luaStrTop .. headStr .. "\n"
	end

	if #playerInventory.bag > 0 then
		luaStrTop = luaStrTop .. "save.playerInventory.bag = {\n\t"

		for k, v in pairs(playerInventory.bag) do
			local bagItemString = [[{
		equipType = "%s",
		itemID = "%s",
		slotNum = %d
	},
	]]
			bagItemString = bagItemString:format(v.equipType, v.id, k)

			luaStrTop = luaStrTop .. bagItemString
		end

		luaStrTop = luaStrTop .. "}\n"
	end

	luaStrTop = luaStrTop .. "save.gameFlags = {\n"
	for k, v in pairs(gameFlags) do
		luaStrTop = luaStrTop .. k .. " = true,\n"
	end
	luaStrTop = luaStrTop .. "}\n"


    local luaStrBottom = [[
return save]]

    return luaStrTop .. luaStrBottom
end
-- Save is on current room, save after changing room
function this.Save(saveName)
	--os.execute("mkdir \"" .. homeDirectoryString .. "\\_saves\"")
	love.filesystem.createDirectory("_saves")
    local file, err = io.open(love.filesystem.getSaveDirectory() .. "\\_saves\\" .. saveName .. ".lua", "w")
    if file then
        file:write(GetSaveDataLuaString())
        file:close()
    else
        print(err)
    end
end

function this.Load(saveName)
	reloadMarkFadeIn = 0.5

	if not Util.FileExists(love.filesystem.getSaveDirectory() .. "\\_saves\\" .. saveName .. ".lua") then
		Rooms.ChangeRoom("prison1", true, true, false)
		return
	end

	local saveData = dofile(love.filesystem.getSaveDirectory() .. "\\_saves\\" .. saveName .. ".lua")
	Rooms.ChangeRoom(saveData.roomName, true, true, false)
	Rooms.GetCurrentRoomData().currentOutsideLight = saveData.currentOutsideLight
	Rooms.SetDayNightCycleMod(saveData.currentDayNightCycleMod)

	gameFlags = {}
	for k, v in pairs(saveData.gameFlags) do
		gameFlags[k] = true
	end

	Player.Get().ai.attackWait = 1
	Player.Get().health = saveData.playerHealth
	Player.Get().mana = saveData.playerMana

	if saveData.playerInventory.equipped.weapon ~= nil then
		Player.Get().inventory.equipped.weapon = Items.GetWeaponItem(saveData.playerInventory.equipped.weapon)
	end
	if saveData.playerInventory.equipped.shield ~= nil then
		Player.Get().inventory.equipped.shield = Items.GetShieldItem(saveData.playerInventory.equipped.shield)
	end
	if saveData.playerInventory.equipped.torso ~= nil then
		local torsoID = saveData.playerInventory.equipped.torso
		local sepIndex = torsoID:find("_", 1, true)
		Player.Get().inventory.equipped.torso = Items.GetArmorItem("TORSO", torsoID:sub(sepIndex+1))
	end
	if saveData.playerInventory.equipped.head ~= nil then
		local headID = saveData.playerInventory.equipped.head
		local sepIndex = headID:find("_", 1, true)
		Player.Get().inventory.equipped.head = Items.GetArmorItem("HEAD", headID:sub(sepIndex+1))
	end

	if saveData.playerInventory.bag ~= nil then
		for k, v in pairs(saveData.playerInventory.bag) do
			local equipType = v.equipType
			local item = nil
			if equipType == "weapon" then
				item = Items.GetWeaponItem(v.itemID)
			elseif equipType == "torso" then
				local sepIndex = v.itemID:find("_", 1, true)
				item = Items.GetArmorItem("TORSO", v.itemID:sub(sepIndex+1))
			elseif equipType == "head" then
				local sepIndex = v.itemID:find("_", 1, true)
				item = Items.GetArmorItem("HEAD", v.itemID:sub(sepIndex+1))
			elseif equipType == "special" then
				item = Items.GetSpecialItem(v.itemID)
			end
			Player.Get().inventory.bag[v.slotNum] = item
		end
	end
end

function this.AddGameFlag(gameFlagKey)
	gameFlags[gameFlagKey] = true
end

function this.HasGameFlag(gameFlagKey)
	return gameFlags[gameFlagKey] ~= nil
end

function this.IsReloading()
	return reloadMarkFade ~= nil
end

function this.MarkForReload(cause)
	if reloadMarkFade == nil then
		Player.Get().inventory.isOpened = false
		Sounds.PlayBackgroundMusic(nil)
		reloadMarkFade = 0
		reloadMarkText = cause
	end
end

local function CheckReload(dt)
	if reloadMarkFade ~= nil then
		reloadMarkFade = reloadMarkFade + dt
		if reloadMarkFade >= 6 then
			reloadMarkFade = nil
			reloadMarkText = nil
			this.Load("testsave")
		end
	end
end

local function CheckReloadFadeIn(dt)
	if reloadMarkFadeIn ~= nil then
		PAUSEAI = true
		reloadMarkFadeIn = reloadMarkFadeIn - dt
		if reloadMarkFadeIn <= 0 then
			PAUSEAI = false
			reloadMarkFadeIn = nil
		end
	end
end

function this.Init()
	this.Load("testsave")
end

function this.Update(dt)
	CheckReload(dt)
	CheckReloadFadeIn(dt)
end

function this.Draw(screenWidth, screenHeight)
	if reloadMarkFade ~= nil then
		local alpha = reloadMarkFade/3
		love.graphics.setColor(0, 0, 0, alpha)
		love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
		if reloadMarkText ~= nil then
			love.graphics.setColor(1, 1, 1, alpha)
			love.graphics.printf(reloadMarkText, BOSSBAR_FONT, 0, screenHeight / 2, screenWidth, "center")
		end
		love.graphics.setColor(1,1,1)
	elseif reloadMarkFadeIn ~= nil then
		local alpha = reloadMarkFadeIn/0.5
		love.graphics.setColor(0, 0, 0, alpha)
		love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
		love.graphics.setColor(1,1,1)
	end
end

return this