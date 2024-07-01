local this = {}

local activeEffects = {}

local fxDictionary = {}

function this.Init()
	fxDictionary = require("dictionaries/fx")
end

function this.RemoveAllFX(forMenu)
	for k, v in pairs(activeEffects) do
		if forMenu ~= nil and v.forMenu ~= forMenu then goto continue end
		if v.light ~= nil then Lighting.RemoveLight(v.light) end
		activeEffects[k] = nil
		::continue::
	end
end

function this.CreateFX(effectName, x, y, z, initialVelocity, doneAction, color, update, forMenu)
	if forMenu == nil then forMenu = false end
	if initialVelocity == nil then
		initialVelocity = {x=0, y=0, z=0}
	elseif type(initialVelocity) == "number" then
		initialVelocity = {
			x=Util.MathRandomDecimal(-initialVelocity, initialVelocity),
			y=Util.MathRandomDecimal(-initialVelocity, initialVelocity),
			z=Util.MathRandomDecimal(-initialVelocity, initialVelocity)
		}
	end

	local fxInDict = fxDictionary[effectName:upper()]

	local fx = {}
	fx.originalKey = effectName:upper()
	fx.fromDict = fxInDict
	if fxInDict.images ~= nil then
		fx.images = fxInDict.images
	else
		fx.image = fxInDict.image
	end
	fx.bloomImage = fxInDict.bloomImage
	fx.velocity = initialVelocity
	fx.damping = fxInDict.damping
	fx.rotation = fxInDict.rotation
	fx.currentTime = 0
	fx.forMenu = forMenu
	fx.Update = update
	fx.HitGround = fxInDict.HitGround

	fx.x = x
	fx.y = y
	fx.z = z

	fx.DoneAction = doneAction

	fx.color = color

	if fxInDict.light ~= nil and not forMenu then
		fx.light = Lighting.AddStillLight(fx.x, fx.y - fx.z*0.75, fxInDict.light.color, fxInDict.light.power)
	end

	local uniqueID = math.random(1, 1000000000)
	while activeEffects[uniqueID] ~= nil do uniqueID = math.random(1, 1000000000) end

	fx.uniqueID = uniqueID
	activeEffects[uniqueID] = fx
end

function this.Update(dt, forMenu)
	for k, v in pairs(activeEffects) do
		if v.forMenu ~= forMenu then goto continue end
		v.currentTime = v.currentTime + dt

		v.x = v.x + (v.velocity.x * dt)
		v.y = v.y + (v.velocity.y * dt)
		v.z = v.z + (v.velocity.z * dt)
		if v.z < 0 then
			if v.HitGround ~= nil then
				v:HitGround()
				if v.light ~= nil then Lighting.RemoveLight(v.light) end
				activeEffects[v.uniqueID] = nil
				return
			else
				v.z = 0
			end
		end

		if v.light ~= nil then
			--Luven.setLightPosition(v.light, v.x, v.y - v.z*0.75)
			Luven.setLightPosition(v.light, v.x, v.y)
			local lightPower = Util.MathLerp(v.fromDict.light.power, 0, v.z/(v.fromDict.light.power*256))
			if lightPower < 0 then lightPower = 0 end
			Luven.setLightPower(v.light, lightPower)
		end

		local applyVelocity = fxDictionary[v.originalKey].applyVelocity
		-- Randomize velocity if no table
		if type(applyVelocity) == "number" then
			applyVelocity = {
				x = Util.MathRandomDecimal(-applyVelocity, applyVelocity),
				y = Util.MathRandomDecimal(-applyVelocity, applyVelocity),
				z = Util.MathRandomDecimal(-applyVelocity, applyVelocity)
			}
		end

		v.velocity.x = v.velocity.x + (applyVelocity.x * dt)
		v.velocity.y = v.velocity.y + (applyVelocity.y * dt)
		v.velocity.z = v.velocity.z + (applyVelocity.z * dt)

		local dampingBase = v.damping or 0.5
		local damping = dampingBase^dt
		v.velocity.x = v.velocity.x * damping
		v.velocity.y = v.velocity.y * damping
		v.velocity.z = v.velocity.z * damping

		if v.Update ~= nil then v:Update(dt) end
		
		local maxEffectTime = fxDictionary[v.originalKey].effectTime
		if v.currentTime >= maxEffectTime then
			if v.DoneAction ~= nil then v:DoneAction() end
			if v.light ~= nil then Lighting.RemoveLight(v.light) end
			activeEffects[v.uniqueID] = nil
		end

		::continue::
	end
end

function this.AddToYSort(forMenu)
	for k, v in pairs(activeEffects) do
		if v.forMenu == forMenu then
			YSort.Add(v.y, function()
				if v.images == nil and v.image == nil then return end

				local alphaToUse = 1
				local percentOfTime = v.currentTime/fxDictionary[v.originalKey].effectTime
				if fxDictionary[v.originalKey].fadeAway then
					alphaToUse = Util.MathLerp(1, 0, percentOfTime)
				end
		
				local rotationToUse = v.rotation or 0
				local colorToUse = v.color or {1, 1, 1}
				love.graphics.setColor(colorToUse[1], colorToUse[2], colorToUse[3], alphaToUse)
				-- Draw animation images
				if v.images ~= nil then
					local imageIndexToDraw = Util.MathRound(Util.MathLerp(1, #v.images, percentOfTime))
					local imageToDraw = v.images[imageIndexToDraw]
					love.graphics.draw(imageToDraw, v.x, v.y - v.z*0.75, rotationToUse, 1, 1, imageToDraw:getWidth()/2, imageToDraw:getHeight()/2)

					-- Draw bloom
					if v.bloomImages ~= nil then
						Util.DrawBloomImage(v.bloomImages[imageIndexToDraw], v.x, v.y - v.z*0.75, true, rotationToUse)
					end
				-- Draw static image
				else
					love.graphics.draw(v.image, v.x, v.y - v.z*0.75, rotationToUse, 1, 1, v.image:getWidth()/2, v.image:getHeight()/2)

					-- Draw bloom
					if v.bloomImage ~= nil then
						Util.DrawBloomImage(v.bloomImage, v.x, v.y - v.z*0.75, true, rotationToUse)
					end
				end
				love.graphics.setColor(1, 1, 1)
			end)
		end
	end
end

return this