local this = {}

function this.BoolToInt(bool)
	local t = { [true]=1, [false]=0 }
	return t[bool]
end

function this.BoolToStr(bool)
	if bool then
		return "true"
	end
	return "false"
end

function this.RandomizePlayerEquipment()
	Player.Get().inventory.equipped.weapon = this.GetRandomElementFromTable(Items.GetItemDictionary().weapons, function(item)
		return not item.doNotIncludeInRandomItems
	end)
	if Player.Get().inventory.equipped.weapon.canUseShield then
		print(Player.Get().inventory.equipped.weapon.canUseShield)
		Player.Get().inventory.equipped.shield = this.GetRandomElementFromTable(Items.GetItemDictionary().shields, function(item)
			return not item.doNotIncludeInRandomItems
		end)
	else
		Player.Get().inventory.equipped.shield = nil
	end
	Player.Get().inventory.equipped.torso = this.GetRandomElementFromTable(Items.GetItemDictionary().armor, function(item)
		return item.equipType == "torso" and not item.doNotIncludeInRandomItems
	end)
	Player.Get().inventory.equipped.head = this.GetRandomElementFromTable(Items.GetItemDictionary().armor, function(item)
		return item.equipType == "head" and not item.doNotIncludeInRandomItems
	end)
end

function this.DamageEntity(x, y, entityID, damage, knockback, attackerID)
    local entity = Objects.GetGameObjects()[entityID]
    if entity:GetZLevel() ~= 1 then return end
    local attackerEntity = Objects.GetGameObjects()[attackerID]

    if not Multiplayer.IsConnected() and attackerEntity ~= nil and not Factions.IsFactionEnemyOf(attackerEntity.faction, entity.faction.name) then return end

    local weapon = {
        damage = damage,
        knockback = knockback
    }

    entity:GetDamaged(x, y, weapon, attackerID)
end

function this.DamageEntitiesInArea(x, y, radius, damage, knockback, attackerID)
    for k, v in pairs(Ents.GetEntities()) do
        if v:GetZLevel() ~= 1 then goto continue end
        local entX, entY = v:GetCenterMassPosition()
        local distFromOrigin = this.MathDistance(x, y, entX, entY)
        if distFromOrigin > radius then goto continue end

        local rayHasHitWall = false
        Objects.GetPhysicsWorld():rayCast(x, y, entX, entY, function(fixture, x, y, xn, yn, fraction)
            if fixture:getBody():getType() == "static" then
                rayHasHitWall = true
                return 0
            else
                return -1
            end
        end)

        if not rayHasHitWall then
            local distPercent = distFromOrigin/radius
            
            damage = this.MathLerp(damage, 1, distPercent)
            knockback = this.MathLerp(knockback*2, 1, distPercent)

            this.DamageEntity(x, y, v.uniqueID, damage, knockback, attackerID)
        end
        ::continue::
    end
end

function this.DrawBloomImage(bloomImage, x, y, applyMidOffset, direction)
	if applyMidOffset == nil then applyMidOffset = true end
	if direction == nil then direction = 0 end
	local applyXOffset, applyYOffset = 0, 0
	if applyMidOffset then
		applyXOffset, applyYOffset = bloomImage:getWidth()/2, bloomImage:getHeight()/2
	end

	local bloomPasses = 4
	for xOff=-bloomPasses, bloomPasses do
		for yOff=-bloomPasses, bloomPasses do
			local alphaPercentage = (math.abs(xOff) + math.abs(yOff)) / (bloomPasses*2)
			local alphaMax = 0.4 / bloomPasses
			local alphaMin = 0.02 / bloomPasses
			local alphaToUse = Util.MathLerp(alphaMax, alphaMin, alphaPercentage)
			love.graphics.setColor(1,1,1,alphaToUse)
			love.graphics.draw(bloomImage, x+xOff, y+yOff, direction, 1, 1, applyXOffset, applyYOffset)
			love.graphics.setColor(1,1,1)
		end
	end
end

function this.GetMaskCategoryBinaryDecimal(groupNumber)
	local binaryNumberAsStr = ""
	for i=1, 16 do
		local toAdd = "0"
		if groupNumber == i then toAdd = "1" end
		binaryNumberAsStr = toAdd .. binaryNumberAsStr
	end

	local decimalNumber = 0
	for i=0, #binaryNumberAsStr - 1 do
		local exponent = #binaryNumberAsStr - 1 - i
		local numberInBit = tonumber(binaryNumberAsStr:sub(i+1, i+1))
		decimalNumber = decimalNumber + (numberInBit * 2^exponent)
	end

	return decimalNumber
end

function this.MathRandomDecimal(min, max)
	return (math.random() * (max - min)) + min
end

function this.GetNavValidRandomPointNear(x, y, range, currentTries)
	if currentTries == nil then currentTries = 0 end

	if currentTries >= 1000 then return x, y end

	local randX = math.random(x-range,x+range)
	while randX == x do randX = math.random(x-range,x+range) end
	local randY = math.random(y-range,y+range)
	if not Rooms.GetCurrentRoomData().navigation:is_point_inside(randX, randY) then
		return this.GetNavValidRandomPointNear(x, y, range, currentTries+1)
	end
	return randX, randY
end

function this.GetRandomElementFromTable(someTable, testAction)
	if testAction == nil then
		testAction = function(element)
			return true
		end
	end

    local keySet = {}
    for k, v in pairs(someTable) do
		if testAction(v) then
			table.insert(keySet, k)
		end
    end

	return someTable[keySet[math.random(#keySet)]]
end

function this.GetRandomElementFromTables(tableOfTables, testAction)
	return this.GetRandomElementFromTable(tableOfTables[math.random(#tableOfTables)], testAction)
end

function this.GetHomeDirectory()
	--local homeDirectoryString = io.popen"cd":read'*l'
	local homeDirectoryString = love.filesystem.getWorkingDirectory()
	if homeDirectoryString == "C:/Users/stric/AppData/Local/Programs/Microsoft VS Code" then
		homeDirectoryString = "C:/Users/stric/Desktop/NewLuaGame"
	end
	return homeDirectoryString
end

function this.FileExists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end

function this.GetPositionInWorld(x, y)
	local mouseX, mouseY = love.mouse.getPosition()
	x = x or mouseX
	y = y or mouseY
	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
	local w2, h2 = sw * 0.5, sh * 0.5
	local t, l = 0, 0
	local camX, camY = Luven.camera.x, Luven.camera.y
	local scale, sin, cos = Luven.camera.scaleX, math.sin(0), math.cos(0)
	x,y = (x - w2 - l) / scale, (y - h2 - t) / scale
	x,y = cos*x - sin*y, sin*x + cos*y
	return x + camX, y + camY
end

function this.GetPositionOnScreen(x, y)
	local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
	local w2, h2 = sw * 0.5, sh * 0.5
	local t, l = 0, 0
	local camX, camY = Luven.camera.x, Luven.camera.y
	local scale, sin, cos = Luven.camera.scaleX, math.sin(0), math.cos(0)
	--x,y = (x + w2 + l) * scale, (y + h2 + t) * scale
	--x,y = cos/x + sin/y, sin/x - cos/y
	--return x - camX, y - camY
	x,y = x - camX, y - camY
	x,y = cos*x + sin*y, -sin*x + cos*y
	return scale * x + w2 + l, scale * y + h2 + t
end

function this.GetCorrectedTilePosition(tileSize, x, y)
	local xMult = math.floor(x / tileSize)
	local yMult = math.floor(y / tileSize)
	return xMult * tileSize, yMult * tileSize
end

function this.BoxesIntersect(a, b)
	return a.x1 < b.x2 and a.x2 > b.x1 and
	a.y1 < b.y2 and a.y2 > b.y1
end

function this.MathGetAngleTo(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function this.MathRound(num)
	return num + (2^52 + 2^51) - (2^52 + 2^51)
end

function this.MathDistance(x1, y1, x2, y2)
	local dx = x1 - x2
	local dy = y1 - y2
	return math.sqrt ( dx * dx + dy * dy )
end

function this.MathLerp(a,b,t)
	return a * (1-t) + b * t
end

function this.MathLerp3(a, b, c, t, z)
	if t <= z then
		return this.MathLerp(a, b, t * 2)
	else
		return this.MathLerp(b, c, (t * 2) - 1);
	end
end

function this.MathConvertToPositiveRadians(radians)
    if radians < 0 then
        local diff = math.abs(-math.pi - radians)
        radians = math.pi + diff
    end
	return radians
end

return this