local fxDictionary = {}

fxDictionary.EMPTY_3 = {
    effectTime = 3,
    fadeAway = false,
    applyVelocity = {x=0, y=0, z=0}
}

fxDictionary.FALLING_FIREBALL = {
    image = love.graphics.newImage("sprites/projectiles/fireball.png"),
    bloomImage = love.graphics.newImage("sprites/projectiles/fireball.png"),
    rotation = math.pi/2,
    effectTime = 99,
    fadeAway = false,
    damping = 1,
    applyVelocity = {x=0, y=0, z=-85.33},
    light = {
        color = { 0.8, 0.8, 0.0, 1.0 },
        power = 0.3,
    },
    HitGround = function(self)
        local plyX, plyY = Player.Get():GetPosition()
        local distFromPlayer = Util.MathDistance(plyX, plyY, self.x, self.y)
        if not Rooms.IsCutsceneRunning() then
		    Util.DamageEntitiesInArea(self.x, self.y, 32, 150, 2, nil)
        end
        Sounds.PlaySound("sound/projectiles/fireball_hit.ogg", self.x, self.y, 128, math.random(0.8, 1.5), 0)
        local shakeIntensity = Util.MathLerp(0.25, 0, distFromPlayer/256)
        Luven.camera:setShake(0.3, shakeIntensity)
        for i=1, 200 do
            local randX, randY = math.random(self.x-4, self.x+4), math.random(self.y-4, self.y+4)
            FX.CreateFX("STONE_CRUMB", randX, randY, 0, {
                x = Util.MathRandomDecimal(-200, 200),
                y = Util.MathRandomDecimal(-100, 100),
                z = Util.MathRandomDecimal(50, 200)
            })
        end
    end
}

fxDictionary.STONE_CRUMB = {
    image = love.graphics.newImage("sprites/particles/stone_crumb.png"),
    effectTime = 4,
    fadeAway = true,
    damping = 0.001,
    applyVelocity = {x=0, y=0, z=-1000}
}

fxDictionary.STUNNED = {
    image = love.graphics.newImage("sprites/particles/stunned.png"),
    effectTime = 1,
    fadeAway = true,
    applyVelocity = {x=0, y=0, z=50}
}

fxDictionary.SMOKE = {
    image = love.graphics.newImage("sprites/particles/smoke.png"),
    effectTime = 1,
    fadeAway = true,
    applyVelocity = {x=0, y=0, z=50}
}

fxDictionary.LONG_SMOKE = {
    image = love.graphics.newImage("sprites/particles/smoke.png"),
    effectTime = 10,
    fadeAway = true,
    applyVelocity = {x=0, y=0, z=50}
}

fxDictionary.WHITE_SMOKE = {
    image = love.graphics.newImage("sprites/particles/white_smoke.png"),
    effectTime = 1,
    fadeAway = true,
    applyVelocity = {x=0, y=0, z=50}
}

fxDictionary.MANA_TREE_LEAF = {
    image = love.graphics.newImage("sprites/particles/mana_tree_leaf.png"),
    effectTime = 8,
    fadeAway = true,
    applyVelocity = {x=0, y=0, z=-150}
}

fxDictionary.LEAF = {
    image = love.graphics.newImage("sprites/particles/leaf.png"),
    effectTime = 8,
    fadeAway = true,
    applyVelocity = {x=0, y=0, z=-150}
}

fxDictionary.HP = {
    image = love.graphics.newImage("sprites/particles/hp.png"),
    effectTime = 1,
    fadeAway = true,
    applyVelocity = {x=0, y=0, z=50}
}

fxDictionary.MANA = {
    image = love.graphics.newImage("sprites/particles/mana.png"),
    effectTime = 0.5,
    fadeAway = true,
    applyVelocity = {x=0, y=0, z=50}
}

fxDictionary.WISP = {
    bloomImage = love.graphics.newImage("sprites/particles/wisp_bloom.png"),
    image = love.graphics.newImage("sprites/particles/wisp.png"),
    effectTime = 60,
    fadeAway = true,
    applyVelocity = 500,--313.6,
    light = {
        color = { 0.0, 0.25, 0.25, 1.0 },
        power = 0.3,
    }
}

fxDictionary.MENU_WISP = {
    bloomImage = love.graphics.newImage("sprites/particles/wisp_bloom.png"),
    image = love.graphics.newImage("sprites/particles/wisp.png"),
    effectTime = 10,
    fadeAway = true,
    applyVelocity = 2000
}

return fxDictionary