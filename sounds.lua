local this = {}

local masterVolume = 1

local backgroundMusic, backgroundMusicQueued = nil, nil
local worldSoundsPlaying = {}
local uiSoundsPlaying = {}

local function UpdateVolume(worldSnd)
	local plyX, plyY = Player.Get():GetPosition()
	local distanceToPlayer = Util.MathDistance(worldSnd.x, worldSnd.y, plyX, plyY)
	local volumeToSet = Util.MathLerp(1.0, 0.0, distanceToPlayer/worldSnd.maxDist)
	if volumeToSet < 0 then volumeToSet = 0 end

	worldSnd.snd:setVolume(volumeToSet * masterVolume)
	worldSnd.snd:setPitch(worldSnd.normalPitch * Rooms.GetDTMult())
end

local function CreateWorldSound(srcPath, x, y, maxDist)
	return {
		snd = love.audio.newSource(srcPath, "static"),
		x = x,
		y = y,
		maxDist = maxDist
	}
end

function this.GetMasterVolume()
	return masterVolume
end

function this.SetMasterVolume(newVolume)
	masterVolume = newVolume
end

function this.GetAllWorldSounds()
	return worldSoundsPlaying
end

function this.UpdateUIAndMusic(dt)
	if backgroundMusic ~= nil then
		dt = dt / 16
		local currentVolume = backgroundMusic:getVolume()
			
		if not backgroundMusic:isPlaying() then
			backgroundMusic:play()
		end

		if backgroundMusicQueued ~= nil then
			backgroundMusic:setVolume(currentVolume - dt)
			if backgroundMusic:getVolume() <= (0.01 * masterVolume) then
				backgroundMusic:stop()
				backgroundMusic:release()
				backgroundMusic = backgroundMusicQueued
				backgroundMusicQueued = nil
			end
			return
		end

		if currentVolume < (0.25 * masterVolume) then
			backgroundMusic:setVolume(currentVolume + dt)
		else
			backgroundMusic:setVolume(0.25 * masterVolume)
		end
	end

	for i=#uiSoundsPlaying, 1, -1 do
		local uiSnd = uiSoundsPlaying[i]
		if not uiSnd:isPlaying() then
			uiSnd:release()
			table.remove(uiSoundsPlaying, i)
		end
	end
end

function this.UpdateWorldSounds(dt)
	for i=#worldSoundsPlaying, 1, -1 do
		local worldSnd = worldSoundsPlaying[i]
		UpdateVolume(worldSnd)
		if not worldSnd.snd:isPlaying() then
			worldSnd.snd:release()
			table.remove(worldSoundsPlaying, i)
		end
	end
end

function this.PlayUISound(srcPath, pitch)
	if pitch == nil then pitch = 1 end

	local uiSound = love.audio.newSource(srcPath, "static")
	uiSound:setVolume(1.0 * masterVolume)
	uiSound:setPitch(pitch)
	uiSound:play()
end

function this.PlayBackgroundMusic(fileName)
	if fileName == nil then
		if backgroundMusic ~= nil then
			backgroundMusic:stop()
			backgroundMusic:release()
			backgroundMusic = nil
		end
		return
	end

	if backgroundMusic ~= nil then
		backgroundMusicQueued = love.audio.newSource("sound/music/" .. fileName, "stream")
		backgroundMusicQueued:setVolume(0)
	else
		backgroundMusic = love.audio.newSource("sound/music/" .. fileName, "stream")
		backgroundMusic:setVolume(0)
	end
end

function this.PlaySound(srcPath, x, y, maxDist, pitch, detectionRadius)
	if pitch == nil then pitch = 1 end
	if detectionRadius == nil then detectionRadius = 64 end
	local worldSnd = CreateWorldSound(srcPath, x, y, maxDist)
	worldSnd.normalPitch = pitch
	for k, v in pairs(Ents.GetEntityIDsInArea(x, y, detectionRadius)) do
		local entity = Objects.GetGameObjects()[v]
		entity.ai.targetSoundPos = {
			x,
			y,
			detectionRadius/3
		}
	end
	UpdateVolume(worldSnd)
	worldSnd.snd:play()
	table.insert(worldSoundsPlaying, worldSnd)
end

return this