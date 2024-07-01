local this = {}

this.Update = function(dt, miscData)
    if miscData.fxTimer == nil or miscData.fxTimer >= 0.25 then
        local screenWidth, screenHeight = love.window.getMode()
        miscData.fxTimer = 0
        -- 1 top 2 right 3 bottom 4 left
        local randBound = math.random(1,4)
        local outsideRange = 8

        local x, y = 0, 0
        if randBound == 1 then
            x = Util.MathRandomDecimal(0, screenWidth)
            y = -outsideRange
        elseif randBound == 2 then
            x = screenWidth + outsideRange
            y = Util.MathRandomDecimal(0, screenHeight)
        elseif randBound == 3 then
            x = Util.MathRandomDecimal(0, screenWidth)
            y = screenHeight + outsideRange
        else
            x = -outsideRange
            y = Util.MathRandomDecimal(0, screenHeight)
        end

        local angleToCenter = Util.MathGetAngleTo(x, y, screenWidth/2 + math.random(-200, 200), screenHeight/2 + math.random(-200, 200))
        local xMod = math.cos(angleToCenter)
        local yMod = math.sin(angleToCenter)

        local velocity = {
            x = xMod * 500,
            y = yMod * 500,
            z = 0
        }

        FX.CreateFX("MENU_WISP", x, y, 0, velocity, nil, nil, function(self, dt)
            if self.dtTimer == nil then self.dtTimer = 0 end
            self.dtTimer = self.dtTimer + dt
            if self.dtTimer >= 0.05 then
                self.dtTimer = 0
                FX.CreateFX("WHITE_SMOKE", self.x, self.y, self.z, 10, nil, {0, 0.95, 0.95}, nil, true)
            end
        end, true)
    end

    miscData.fxTimer = miscData.fxTimer + dt
end

-- entity guy
this[1] = {
    anchor = "r",
    offsetX = -128,
    offsetY = 128,
    content = {
        {
            image = love.graphics.newImage("sprites/entities/base_humanoid.png"),
            imageScale = 32,
            opacity = 0.15
        }
    }
}

-- sword for entity guy
this[2] = {
    anchor = "r",
    offsetX = 384,
    offsetY = 128,
    content = {
        {
            image = love.graphics.newImage("sprites/items/equipped/weapons/basic_sword.png"),
            imageScale = 32,
            horizontalMod = -1,
            opacity = 0.15
        }
    }
}

-- shield for entity guy
this[3] = {
    anchor = "r",
    offsetX = 384,
    offsetY = 128,
    content = {
        {
            image = love.graphics.newImage("sprites/items/equipped/shields/wood.png"),
            imageScale = 32,
            horizontalMod = -1,
            opacity = 0.15
        }
    }
}

-- entity guy
this[4] = {
    anchor = "l",
    offsetX = 128,
    offsetY = 128,
    content = {
        {
            image = love.graphics.newImage("sprites/entities/base_humanoid.png"),
            imageScale = 32,
            opacity = 0.15
        }
    }
}

-- sword for entity guy
this[5] = {
    anchor = "l",
    offsetX = 128,
    offsetY = 128,
    content = {
        {
            image = love.graphics.newImage("sprites/items/equipped/weapons/staff_fire.png"),
            imageScale = 32,
            opacity = 0.15
        }
    }
}

-- shield for entity guy
this[6] = {
    anchor = "l",
    offsetX = 128,
    offsetY = 128,
    content = {
        {
            image = love.graphics.newImage("sprites/items/equipped/armor/torso/mage.png"),
            imageScale = 32,
            opacity = 0.15
        }
    }
}

-- shield for entity guy
this[7] = {
    anchor = "l",
    offsetX = 128,
    offsetY = 128,
    content = {
        {
            image = love.graphics.newImage("sprites/items/equipped/armor/head/mage.png"),
            imageScale = 32,
            opacity = 0.15
        }
    }
}

-- buttons on side
this[8] = {
    anchor = "c",
    offsetX = 0,
    offsetY = 280,
    content = {
        {
            text = "Play",
            alignText = "center",
            width = 150,
            padding = 24,
            fontSize = 32,
            Click = function()
                Menus.SetMenu(nil)
                Save.Init()
            end
        },
        {
            text = "PVP",
            alignText = "center",
            width = 150,
            padding = 24,
            fontSize = 32,
            Click = function()
                Menus.SetMenu("multiplayer")
            end
        },
        {
            text = "Options",
            alignText = "center",
            width = 150,
            padding = 24,
            fontSize = 32,
            Click = function()
                Menus.SetMenu("options")
            end
        },
        {
            text = "Quit",
            alignText = "center",
            width = 150,
            padding = 24,
            fontSize = 32,
            Click = function()
                love.event.quit()
            end
        },
    }
}

-- logo thing
this[9] = {
    anchor = "c",
    offsetX = 0,
    offsetY = -140,
    content = {
        {
            image = love.graphics.newImage("sprites/menus/title/titlelogo.png"),
            imageScale = 0.99
        }
    }
}

-- fools logo thing
this[10] = {
    anchor = "bl",
    offsetX = 240,
    offsetY = -50,
    content = {
        {
            image = love.graphics.newImage("sprites/menus/title/lovelogo.png"),
            imageScale = 0.075,
            opacity = 0.55
        }
    }
}

-- fools logo thing
this[11] = {
    anchor = "bl",
    offsetX = 80,
    offsetY = -50,
    content = {
        {
            image = love.graphics.newImage("sprites/menus/title/foolslogo.png"),
            imageScale = 0.25,
            opacity = 0.55
        }
    }
}

return this