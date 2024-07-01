local this = {}

local currentMenu = nil
local contentBoxes = {}

local lockMouseClick = false

function this.SetMenu(menuStr)
	lockMouseClick = true

	local screenWidth, screenHeight = love.window.getMode()

	contentBoxes = {}
	if menuStr == nil then
		currentMenu = nil
		return
	end
	local lastMenuName = nil
	if currentMenu ~= nil then
		lastMenuName = currentMenu.miscData.menuName
	end
	FX.RemoveAllFX(true)
	currentMenu = require("menus/" .. menuStr)
	currentMenu.miscData = {}
	currentMenu.miscData.menuName = menuStr
	currentMenu.miscData.lastMenuName = lastMenuName
	currentMenu.miscData.textKeys = {}

	for i=1, #currentMenu do
		local node = currentMenu[i]
		-- find total height of all content
		local totalHeight = 0
		local totalWidth = 0
		for i=1, #node.content do
			local content = node.content[i]
			if type(content.padding) == "number" then
				content.padding = {
					top = content.padding,
					bottom = content.padding,
					left = content.padding,
					right = content.padding
				}
			end
			local contentPadding = content.padding or {}
			local leftPadding = contentPadding.left or 0
			local rightPadding = contentPadding.right or 0
			local topPadding = contentPadding.top or 0
			local bottomPadding = contentPadding.bottom or 0

			if content.fontSize ~= nil and content.text ~= nil then totalHeight = totalHeight + content.fontSize
			elseif content.image ~= nil then
				local imageScale = content.imageScale or 1
				totalHeight = totalHeight + content.image:getHeight() * imageScale
				local imageWidth = content.image:getWidth() * imageScale
				if imageWidth > totalWidth then totalWidth = imageWidth end
			elseif content.height ~= nil then totalHeight = totalHeight + content.height end

			local widthPadding = leftPadding + rightPadding
			if content.width ~= nil and content.width + widthPadding > totalWidth then totalWidth = content.width + widthPadding end
			
			totalHeight = totalHeight + topPadding + bottomPadding
		end

		local anchorX, anchorY = screenWidth/2, screenHeight/2
		if node.anchor == "l" then
			anchorX, anchorY = 0, screenHeight/2
		elseif node.anchor == "r" then
			anchorX, anchorY = screenWidth, screenHeight/2
		elseif node.anchor == "t" then
			anchorX, anchorY = screenWidth/2, 0
		elseif node.anchor == "b" then
			anchorX, anchorY = screenWidth/2, screenHeight
		elseif node.anchor == "bl" then
			anchorX, anchorY = 0, screenHeight
		end
		
		local x1, y1 = anchorX + node.offsetX - totalWidth * 0.5, anchorY + node.offsetY - totalHeight * 0.5
		if contentBoxes[i] == nil then
			contentBoxes[i] = {}
		end
		for j=1, #node.content do
			local content = node.content[j]
			local x2, y2 = x1, y1
			if content.width ~= nil then
				x2 = x2 + content.width
			elseif content.image ~= nil then
				local imageScale = content.imageScale or 1
				x2 = x2 + content.image:getWidth() * imageScale
			else
				x2 = x2 + screenWidth
			end

			if content.fontSize ~= nil and content.text ~= nil then
				y2 = y2 + content.fontSize
			elseif content.image ~= nil then
				local imageScale = content.imageScale or 1
				y2 = y2 + content.image:getHeight() * imageScale
			elseif content.height ~= nil then
				y2 = y2 + content.height
			end

			if content.padding ~= nil then
				local topPadding = content.padding.top or 0
				local bottomPadding = content.padding.bottom or 0
				local leftPadding = content.padding.left or 0
				local rightPadding = content.padding.right or 0
				x2 = x2 + rightPadding + leftPadding
				y2 = y2 + bottomPadding + topPadding
			end

			local sliderValue = nil
			if content.slider then
				sliderValue = 1
			end
			if content.textKey then
				currentMenu.miscData.textKeys[content.textKey] = content.inputText
			end
			local createdContentBox = {
				x1 = x1,
				y1 = y1,
				x2 = x2,
				y2 = y2,
				height = content.height,
				width = content.width,
				padding = content.padding,
				hoverValue = 0,
				sliderValue = sliderValue,
				textValue = content.inputText,
				textKey = content.textKey,
				Click = content.Click,
				ClickHeld = content.ClickHeld
			}
			contentBoxes[i][#contentBoxes[i]+1] = createdContentBox

			if content.Start ~= nil then content.Start(currentMenu.miscData, createdContentBox) end

			y1 = y2
		end
	end
end

function this.GetMenu()
	return currentMenu
end

function this.Init()
	this.SetMenu("title")
	Options.LoadSavedOptions()
end

local function DrawNode(nodeKey, node, screenWidth, screenHeight)
	for i=1, #node.content do
		local content = node.content[i]
		local contentBox = contentBoxes[nodeKey][i]
		local padding = content.padding or {}
		local topPadding = padding.top or 0
		local bottomPadding = padding.bottom or 0
		local leftPadding = padding.left or 0
		local rightPadding = padding.right or 0
		local opacityToUse = content.opacity or 1
		local alphaToUse = opacityToUse
		local fontSize = content.fontSize or 32
		local font = love.graphics.newFont("fonts/slkscr.ttf", fontSize)
		if content.Click ~= nil then
			alphaToUse = Util.MathLerp(1, 0.5, contentBox.hoverValue) * opacityToUse
		end
		
		--love.graphics.circle("fill", contentBox.x1, contentBox.y1, 4)
		--love.graphics.circle("fill", contentBox.x2, contentBox.y2, 4)

		if content.text ~= nil then
			local alignToUse = content.alignText or "center"
			love.graphics.setColor(1, 1, 1, alphaToUse)
			love.graphics.printf(content.text, font, contentBox.x1 + leftPadding, contentBox.y1 + topPadding, content.width, alignToUse)
		elseif content.image ~= nil then
			local imageScale = content.imageScale or 1
			love.graphics.setColor(1, 1, 1, alphaToUse)
			local horizontalMod = content.horizontalMod or 1
			love.graphics.draw(content.image, contentBox.x1 + leftPadding, contentBox.y1 + topPadding, 0, imageScale * horizontalMod, imageScale)
		elseif contentBox.sliderValue ~= nil then
			love.graphics.setColor(0.5, 0.5, 0.5)
			love.graphics.rectangle("fill", contentBox.x1 + leftPadding, contentBox.y1 + topPadding, contentBox.width, contentBox.height, contentBox.width/32, contentBox.height/4, 16)
			if contentBox.sliderValue > 0 then
				love.graphics.setColor(1, 1, 1)
				local currentWidth = Util.MathLerp(0, contentBox.width, contentBox.sliderValue)
				love.graphics.rectangle("fill", contentBox.x1 + leftPadding, contentBox.y1 + topPadding, currentWidth, contentBox.height, contentBox.width/32, contentBox.height/4, 16)
			end
		elseif contentBox.textValue ~= nil then
			local boxHoverColor = Util.MathLerp(0.75, 0.5, contentBox.hoverValue)
			love.graphics.setColor(boxHoverColor, boxHoverColor, boxHoverColor)
			love.graphics.rectangle("fill", contentBox.x1 + leftPadding, contentBox.y1 + topPadding, contentBox.width, contentBox.height, contentBox.width/32, contentBox.height/4, 16)
			
			love.graphics.setColor(0, 0, 0)
			local textToDisplay = contentBox.textValue
			if currentMenu.miscData.currentContentBox == contentBox and math.floor(currentMenu.miscData.dtPassed) % 2 == 0 then
				textToDisplay = " " .. textToDisplay .. "_"
			end
			love.graphics.printf(textToDisplay, font, contentBox.x1 + leftPadding, contentBox.y1 + topPadding + content.height/2 - fontSize/2, content.width, "center")
		end
	end
	love.graphics.setColor(1,1,1)
end
function this.Draw(screenWidth, screenHeight)
	if currentMenu == nil then return end

	for i=1, #currentMenu do
		local node = currentMenu[i]
		DrawNode(i, node, screenWidth, screenHeight)
	end
end

function this.Update(dt)
	if currentMenu.Update ~= nil then currentMenu.Update(dt, currentMenu.miscData) end

	if lockMouseClick and not love.mouse.isDown(1) then
		lockMouseClick = false
	end

	-- Send total dt passed to misc data
	if currentMenu.miscData.dtPassed == nil then
		currentMenu.miscData.dtPassed = dt
	else
		currentMenu.miscData.dtPassed = currentMenu.miscData.dtPassed + dt
	end

	

	-- Check for text input and backspace being held
	if currentMenu.miscData.currentContentBox ~= nil and currentMenu.miscData.currentContentBox.textValue ~= nil then
		local contentBox = currentMenu.miscData.currentContentBox
		if love.keyboard.isDown("backspace") then
			if contentBox.backspaceTextTimer == nil then
				contentBox.backspaceTextTimer = 0.75
			else
				contentBox.backspaceTextTimer = contentBox.backspaceTextTimer - dt
			end

			if contentBox.backspaceTextTimer <= 0 then
				contentBox.backspaceTextTimer = 0.125
				contentBox.textValue = contentBox.textValue:sub(1, #contentBox.textValue-1)
			end
		else
			contentBox.backspaceTextTimer = nil
		end
	end

	dt = dt * 2
	local x, y = love.mouse.getPosition()
	local foundBox = false
	for i=1, #contentBoxes do
		local nodeSet = contentBoxes[i]
		for j=1, #nodeSet do
			local contentBox = nodeSet[j]
			if not foundBox and x >= contentBox.x1 and x <= contentBox.x2 and y >= contentBox.y1 and y <= contentBox.y2 then
				foundBox = true
				if currentMenu.miscData.currentContentBox ~= nil and currentMenu.miscData.currentContentBox ~= contentBox then
					currentMenu.miscData.currentContentBox.backspaceTextTimer = nil
				end
				currentMenu.miscData.currentContentBox = contentBox

				-- Check for click being held
				if not lockMouseClick and contentBox.ClickHeld ~= nil and love.mouse.isDown(1) then contentBox.ClickHeld(x, y, currentMenu.miscData) end

				-- Set hover value
				if contentBox.hoverValue < 1 then
					contentBox.hoverValue = contentBox.hoverValue + dt
					if contentBox.hoverValue > 1 then
						contentBox.hoverValue = 1
					end
				end
			else
				-- Unset hover value
				if contentBox.hoverValue > 0 then
					contentBox.hoverValue = contentBox.hoverValue - dt
					if contentBox.hoverValue < 0 then
						contentBox.hoverValue = 0
					end
				end
			end
		end
	end
end

function this.CheckMousePress(x, y, button, isTouch, presses)
	for i=1, #contentBoxes do
		local nodeSet = contentBoxes[i]
		for j=1, #nodeSet do
			local contentBox = nodeSet[j]
			if x >= contentBox.x1 and x <= contentBox.x2 and y >= contentBox.y1 and y <= contentBox.y2 then
				if not lockMouseClick and contentBox.Click ~= nil then contentBox.Click(x, y, currentMenu.miscData) end
				return
			end
		end
	end
end

function this.CheckKeyPress(key, scanCode, isRepeat)
	local currentBox = currentMenu.miscData.currentContentBox
	if currentBox ~= nil and currentBox.textValue ~= nil then
		if #key == 1 and #currentBox.textValue < 22 then
			currentBox.textValue = currentBox.textValue .. key
		elseif key == "backspace" then
			currentBox.textValue = currentBox.textValue:sub(1, #currentBox.textValue-1)
		end

		if currentBox.textKey ~= nil then
			currentMenu.miscData.textKeys[currentBox.textKey] = currentBox.textValue
		end
	end
end

return this