-- Libraries
utf8 = require("utf8")
Profile = require("libraries/profile")

AI = require("ai")
YSort = require("ysort")
Objects = require("objects")
Factions = require("factions")
Items = require("items")
Ents = require("ents")
Util = require("util")
Player = require("player")
InventoryScreen = require("inventory")
Editor = require("editor")
Tiles = require("tiles")
Rooms = require("rooms")
Lighting = require("lighting")
Sounds = require("sounds")
Projectiles = require("projectiles")
FX = require("fx")
Save = require("save")
Menus = require("menus")
Options = require("options")
Multiplayer = require("multiplayer")

EDITOR_ENABLED = true
PROFILER_ENABLED = false
PAUSEAI = false
GET_TEXT_INPUT, CURRENT_TEXT_INPUT = nil, ""
PROFILE_REPORT = nil

function love.load()
	love.filesystem.setIdentity("Nilguard")

	-- Math random seed NEEDED NO DELETE
	math.randomseed(os.time())

	-- Window stuff
	-- Set filter to nearest for pixel art
	love.window.setTitle("Nilguard")
	love.graphics.setDefaultFilter( 'nearest', 'nearest' )
	love.mouse.setCursor(love.mouse.newCursor("sprites/cursor.png", 16, 16))

	-- Set screen width and height
	local screenWidth, screenHeight = 1200, 900
	if not EDITOR_ENABLED then
		screenWidth, screenHeight = love.window.getDesktopDimensions()
	end
	love.window.setMode(screenWidth, screenHeight)

	-- Set fonts
	WIDTH_MULT = screenWidth * 0.04
	BOSSBAR_WIDTH_MULT = screenWidth * 0.03
	FONT = love.graphics.newFont("fonts/slkscr.ttf", WIDTH_MULT)
	ENT_SAY_FONT = love.graphics.newFont("fonts/slkscr.ttf", 18)
	DIALOG_FONT = love.graphics.newFont("fonts/slkscr.ttf", 32)
	BOSSBAR_FONT = love.graphics.newFont("fonts/slkscr.ttf", BOSSBAR_WIDTH_MULT)

	-- Init lighting
	Lighting.Init()

	-- Init items
	Items.Init()

	-- Init ents
	Ents.Init()

	-- Init physics
	Objects.Init()

	-- Init tiles
	Tiles.Init()

	-- Init editor
	if EDITOR_ENABLED then
		Editor.Init()
	end

	-- Init projectiles
	Projectiles.Init()

	-- Init fx
	FX.Init()

	-- Init save/room (and init player)
	--Save.Init()
	Menus.Init()

	if PROFILER_ENABLED then
		Profile.start()
	end
end

local profilerTimer = 0
function love.update(dt)
	if PROFILER_ENABLED then
		profilerTimer = profilerTimer + dt
		if math.floor(profilerTimer) % 5 == 0 then
			PROFILE_REPORT = Profile.report(20)
			Profile.reset()
		end
	end

	Multiplayer.Update(dt)

	Sounds.UpdateUIAndMusic(dt)

	if Menus.GetMenu() ~= nil then
		Menus.Update(dt)
		FX.Update(dt, true)
		if not Multiplayer.IsConnected() then
			return
		end
	end

	-- Change dt based on mult
	dt = dt * Rooms.GetDTMult()

	-- UPDATE ROOM BEFORE ANYTHING
	Rooms.Update(dt)

	-- CHECK RELOAD
	Save.Update(dt)

	-- Update physics/objects
	Objects.Update(dt)

	-- Projectiles update
	Projectiles.Update(dt)

	-- Items update
	Items.Update(dt)

	-- FX update
	FX.Update(dt, false)

	-- Lighting update
	Lighting.Update(dt)

	-- Sounds world sounds update
	Sounds.UpdateWorldSounds(dt)

	-- Editor update
	if EDITOR_ENABLED then
		Editor.Update(dt)
	end
end

function love.draw()
	local screenWidth, screenHeight = love.window.getMode()
	love.graphics.setScissor(0, 0, screenWidth, screenHeight)

	if Menus.GetMenu() ~= nil then
		FX.AddToYSort(true)
		YSort.Draw()
		Menus.Draw(screenWidth, screenHeight)
		love.graphics.print(love.timer.getFPS(), 5, 5, 0)
		return
	end

	-- Draw inside of camera
	Luven.drawBegin()
		-- Draw room tiles
		Rooms.DrawTiles(false)
		Rooms.DrawTiles(true)

		-- Y SORTED ITEMS
		Items.AddToYSort()
		Objects.AddToYSort()
		Projectiles.AddToYSort()
		FX.AddToYSort(false)
	
		-- Y Sort Draw
		YSort.Draw()
	
		-- Draw editor dummy
		if EDITOR_ENABLED then
			Editor.Draw()
		end
	Luven.drawEnd()

	Lighting.Draw()

	-- UI

	Ents.DrawUI()

	-- Draw inventory stuff
	Player.DrawInventory()

	-- If text input is available
	if GET_TEXT_INPUT ~= nil then
		love.graphics.print("ENTER TEXT: " .. CURRENT_TEXT_INPUT, screenWidth/2, screenHeight/2)
	end

	-- Draw cutscene text
	Rooms.DrawCutscene(screenWidth, screenHeight)

	-- Draw boss bar if there is boss
	Rooms.DrawBossBar(screenWidth, screenHeight)

	-- Draw flash timer for teleporting
	Rooms.DrawFlashTimer(screenWidth, screenHeight)

	Save.Draw(screenWidth, screenHeight)

	love.graphics.print(love.timer.getFPS(), 5, 5, 0)

	if PROFILER_ENABLED then
		love.graphics.print(PROFILE_REPORT or "Cooking...")
	end
end

function love.keypressed(key, scanCode, isRepeat)
	if Menus.GetMenu() ~= nil then
		Menus.CheckKeyPress(key, scanCode, isRepeat)
		if Menus.GetMenu().miscData.menuName == "paused" and key == "escape" then
			Menus.SetMenu(nil)
		end
		return
	end

	-- Capture text input
	if GET_TEXT_INPUT ~= nil then
		if key == "return" then
			GET_TEXT_INPUT()
		elseif key == "backspace" then
			CURRENT_TEXT_INPUT = CURRENT_TEXT_INPUT:sub(1, CURRENT_TEXT_INPUT:len()-1)
		elseif key:len() > 1 then
			return
		else
			local char = key
			if love.keyboard.isDown("lshift") then char = char:upper() end
			CURRENT_TEXT_INPUT = CURRENT_TEXT_INPUT .. char
		end
		return
	end

	-- Pause stuff
	if key == "escape" then
		--PAUSED = not PAUSED
		Menus.SetMenu("paused")
		return
	end

	Multiplayer.CheckKeyPress(key, scanCode, isRepeat)

	Player.CheckKeyPress(key, scanCode, isRepeat)

	if EDITOR_ENABLED then
		Editor.CheckKeyPress(key, scanCode, isRepeat)
	end
end

function love.mousepressed(x, y, button, isTouch, presses)
	if Menus.GetMenu() ~= nil then
		Menus.CheckMousePress(x, y, button, isTouch, presses)
		return
	end

	Player.CheckMousePress(x, y, button, isTouch, presses)

	if EDITOR_ENABLED then
		Editor.CheckMousePress(x, y, button, isTouch, presses)
	end
end

function love.wheelmoved(x, y)
	if Menus.GetMenu() ~= nil then
		return
	end

	Player.CheckMouseScroll(x, y)

	if EDITOR_ENABLED then
		Editor.CheckMouseScroll(x, y)
	end
end

function love.focus(f)
	--[[if not f and Menus.GetMenu() == nil then
		Menus.SetMenu("paused")
	end]]
end

function love.quit()
	Multiplayer.KillServerAndClient()
end