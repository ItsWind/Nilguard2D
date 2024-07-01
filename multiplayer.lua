local sock = require("libraries/sock")
local lume = require("libraries/lume")

local port = 22122

local client = nil
local server = nil

local clientEnts = {}

local this = {}

local function SetClientEntityUpdateData(updateData)
	if updateData.connectId == client.connectId then return end
	local ent = clientEnts[updateData.connectId]
	if ent == nil then return end

	ent.health = updateData.health
	ent.mana = updateData.mana
	ent.physicsBody:setPosition(updateData.x, updateData.y)
	ent.z.current = updateData.z
	ent.lookAngle = updateData.lookAngle
	ent.sideFacing = updateData.sideFacing
	ent.cooldowns.block.increase = updateData.blocking

	ent.inventory.equipped.weapon = Items.GetWeaponItem(updateData.weaponID)
	ent.inventory.equipped.shield = Items.GetShieldItem(updateData.shieldID)
	ent.inventory.equipped.torso = Items.GetArmorItem(updateData.torsoID)
	ent.inventory.equipped.head = Items.GetArmorItem(updateData.headID)
end

local function CreateClientEntity(connectId, uniqueID, x, y)
	x = x or 200
	y = y or 200
	if connectId ~= client.connectId then
		clientEnts[connectId] = Ents.NewEntity(true, "PLAYER", x, y, uniqueID)
		clientEnts[connectId].faction = Factions.GetFactionOf("PLAYER_ENEMY")
		clientEnts[connectId].images.face = love.graphics.newImage("sprites/entities/humanoid/humanoid_face_happy.png")
	else
		clientEnts[connectId] = Player.Get()
		if uniqueID ~= nil then
			local oldID = Player.Get().uniqueID
			Objects.GetGameObjects()[oldID] = nil
			Ents.GetEntities()[oldID] = nil
			Player.Get().uniqueID = uniqueID
			Objects.GetGameObjects()[uniqueID] = Player.Get()
			Ents.GetEntities()[uniqueID] = Player.Get()

			clientEnts[connectId].physicsBody:setPosition(x, y)
		end
	end

	clientEnts[connectId].health = 100
	clientEnts[connectId].maxHealth = 100

	clientEnts[connectId].connectId = connectId

	return clientEnts[connectId]
end

local function RemoveClientEntity(connectId)
	Objects.RemoveGameObject(clientEnts[connectId].uniqueID)
	clientEnts[connectId] = nil
end

local function EstablishConnection(ipStr)
	client = sock.newClient(ipStr, port)
	client:setSerialization(lume.serialize, lume.deserialize)
	client:enableCompression()

    -- Called when a connection is made to the server
    client:on("connect", function(data)
		if this.IsHost() then return end
        print("Client connected to the server.")
		client:send("requestClientEnts", true)
    end)

	client:on("receiveClientEnts", function(data)
		for k, v in pairs(data) do
			-- Skip over ourselves, as playerConnected handled our client entity
			if k ~= client.connectId then
				CreateClientEntity(k, v)
			end
		end
	end)

	client:on("playerConnected", function(data)
		if this.IsHost() then return end
		CreateClientEntity(data.connectId, data.entUniqueID, data.x, data.y)
		print("PLAYER CONNECTED")
	end)

	client:on("playerDisconnected", function(connectId)
		RemoveClientEntity(connectId)
	end)

	client:on("clientUpdateData", function(data)
		SetClientEntityUpdateData(data)
	end)

	client:on("clientAttack", function(data)
		local ent = clientEnts[data.connectId]
		if ent == nil then return end

		ent.cooldowns.attack.current = ent.cooldowns.attack.default
		if data.manaCost ~= nil then
			ent.cooldowns.showMana.current = ent.cooldowns.showMana.default
		end
        Sounds.PlaySound(data.sound, data.x, data.y, 128, Util.MathRandomDecimal(0.8, 1.5), data.detectionRadii)
	end)

	client:on("projectileHit", function(data)
		if this.IsHost() then return end
		Projectiles.DoProjectileHit(data.projectileID, data.x, data.y, data.hitID)
	end)

	client:on("launchedProjectile", function(data)
		Projectiles.NewProjectile(data.projectileType, data.attackingEntityID, data.x, data.y, data.direction, 14, data.uniqueID)
	end)

	client:on("getDamaged", function(data)
		local ent = Ents.GetEntities()[data.victimEntityID]

		local fakeWeapon = {
			damage = data.damage,
			knockback = data.knockback,
			attackType = data.attackType
		}

		ent:GetDamaged(data.x, data.y, fakeWeapon, data.attackingEntityID)
	end)

	client:on("playerDied", function(connectId)
		clientEnts[connectId]:Die()
	end)

	client:on("playerRespawned", function(data)
		CreateClientEntity(data.connectId, data.uniqueID, data.x, data.y)
	end)

	client:on("entityDashStunned", function(data)
		local victim = Ents.GetEntities()[data.victimEntityID]

		victim:Stun(data.stunDuration)
		victim:GetDamaged(data.x, data.y, data.dashWeapon, data.attackingEntityID)
	end)

	client:on("shieldParryMelee", function(data)
		local attacker = Ents.GetEntities()[data.attackerID]

		attacker:Flick(data.flickX, data.flickY, 4)
		attacker:Stun(data.stunDuration)
	end)

	client:connect()

	Player.Get().images.face = love.graphics.newImage("sprites/entities/humanoid/humanoid_face_happy.png")

	Util.RandomizePlayerEquipment()
end

local function EstablishHost()
	server = sock.newServer("*", port)
	server:setSerialization(lume.serialize, lume.deserialize)
	server:enableCompression()
	
    -- Called when a connection is made to the server
    server:on("connect", function(data, otherClient)
        print("Client connected to the server.")
		local x, y = Util.GetNavValidRandomPointNear(200, 200, 2000)
		print(x .. " " .. y)
		CreateClientEntity(otherClient.connectId, nil, x, y)
		server:sendToAll("playerConnected", {
			connectId = otherClient.connectId,
			entUniqueID = clientEnts[otherClient.connectId].uniqueID,
			x = x,
			y = y
		})
    end)
    
    -- Called when the client disconnects from the server
    server:on("disconnect", function(data, otherClient)
        print("Client disconnected from the server.")
		server:sendToAll("playerDisconnected", otherClient.connectId)
    end)

	server:on("requestClientEnts", function(data, otherClient)
		local clientEntConnectIDs = {}
		for k, v in pairs(clientEnts) do
			clientEntConnectIDs[k] = v.uniqueID
		end
		otherClient:send("receiveClientEnts", clientEntConnectIDs)
	end)

	server:on("clientUpdateData", function(data, otherClient)
		data.connectId = otherClient.connectId
		server:sendToAll("clientUpdateData", data)
	end)

	server:on("clientAttack", function(data, otherClient)
		data.connectId = otherClient.connectId
		server:sendToAllBut(otherClient, "clientAttack", data)
	end)

	server:on("launchedProjectile", function(data, otherClient)
		server:sendToAllBut(otherClient, "launchedProjectile", data)
	end)

	server:on("getDamaged", function(data, otherClient)
		server:sendToAllBut(otherClient, "getDamaged", data)
	end)

	server:on("playerDied", function(connectId, otherClient)
		server:sendToAllBut(otherClient, "playerDied", connectId)
	end)

	server:on("playerRespawned", function(data, otherClient)
		server:sendToAllBut(otherClient, "playerRespawned", data)
	end)

	server:on("entityDashStunned", function(data, otherClient)
		server:sendToAllBut(otherClient, "entityDashStunned", data)
	end)

	server:on("shieldParryMelee", function(data, otherClient)
		server:sendToAllBut(otherClient, "shieldParryMelee", data)
	end)

	EstablishConnection("localhost")
end

local function SetupMPArena(arenaName)
	Rooms.ChangeRoom(arenaName, true, true, false)
	Player.Get().ai.attackWait = 1
end

function this.ConnectFromMenu(ipStr)
	SetupMPArena("mparena")
	EstablishConnection(ipStr)
end

function this.HostFromMenu()
	SetupMPArena("mparena")
	EstablishHost()
end

function this.ClientSend(event, data)
	if client == nil then return end

	client:send(event, data)
end

function this.HostSendToAll(event, data)
	if server == nil then return end

	server:sendToAll(event, data)
end

function this.GetClientConnectID()
	return client.connectId
end

function this.IsConnected()
	return client ~= nil
end

function this.IsHost()
	return server ~= nil
end

function this.KillServerAndClient()
	if client ~= nil then
		client:disconnectNow()
	end
	if server ~= nil then
		server:destroy()
	end
end

function this.Update(dt)
	if server ~= nil then server:update() end
	if client ~= nil then client:update() end
	for k, v in pairs(clientEnts) do
		v.cooldowns.aggro.current = 1
	end
end

local multiplayerControls = {}
multiplayerControls.f4 = function()
	if server ~= nil or client ~= nil then return end
	-- Establish host
	EstablishHost()
end
multiplayerControls.f5 = function()
	if server ~= nil or client ~= nil then return end

	Player.Get().hasControl = false
	CURRENT_TEXT_INPUT = "localhost"
	GET_TEXT_INPUT = function()
		-- Text input ip to connect to
		EstablishConnection(CURRENT_TEXT_INPUT)

		GET_TEXT_INPUT = nil
		CURRENT_TEXT_INPUT = ""
		Player.Get().hasControl = true
	end
end
function this.CheckKeyPress(key, scanCode, isRepeat)
	if multiplayerControls[key] ~= nil then multiplayerControls[key]() end
end

return this