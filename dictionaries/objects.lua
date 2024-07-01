local gameObjectDictionary = {}

gameObjectDictionary.ENT_CRATE_WOOD = {
    physicsType = "dynamic",
    physicsDamping = 500,
    yDrawPosOffset = 8,
    canSeeThru = true,
    image = love.graphics.newImage("sprites/entities/breakables/crate_wood.png"),
    collider = {
        x = 16,
        y = 8,
        offsetX = 0,
        offsetY = 2
    }
}
gameObjectDictionary.ENT_IRON_BARS = {
    physicsType = "static",
    yDrawPosOffset = 16,
    canSeeThru = true,
    image = love.graphics.newImage("sprites/objects/iron_bars.png"),
    collider = {
        x = 16,
        y = 2,
        offsetX = 0,
        offsetY = 15
    },
}
gameObjectDictionary.ENT_BUSH = {
    physicsType = "static",
    yDrawPosOffset = 6,
    canSeeThru = true,
    image = love.graphics.newImage("sprites/entities/breakables/bush.png"),
    collider = {
        x = 12,
        y = 4,
        offsetX = 0,
        offsetY = 2
    },
}

gameObjectDictionary.ENT_HUMAN = {
    physicsType = "dynamic",
    physicsDamping = 5,
    yDrawPosOffset = 8,
    image = love.graphics.newImage("sprites/entities/base_humanoid.png"),
    collider = {
        x = 8,
        y = 8,
        offsetX = 0,
        offsetY = 4
    }
}
gameObjectDictionary.ENT_YDET_RELIK = {
    physicsType = "dynamic",
    physicsDamping = 5,
    yDrawPosOffset = 12,
    image = love.graphics.newImage("sprites/entities/base_humanoid.png"),
    collider = {
        x = 12,
        y = 12,
        offsetX = 0,
        offsetY = 6
    }
}

gameObjectDictionary.STONE_PILLAR = {
    physicsType = "static",
    yDrawPosOffset = -12,
    proxCull = true,
    image = love.graphics.newImage("sprites/objects/stone_pillar.png"),
    collider = {
        x = 64,
        y = 48,
        offsetX = 0,
        offsetY = 6
    },
}
gameObjectDictionary.STONE_WALL_OUTSIDE = {
    physicsType = "static",
    proxCull = true,
    image = love.graphics.newImage("sprites/objects/stone_wall_outside.png"),
    collider = {
        x = 128,
        y = 32,
        offsetX = 0,
        offsetY = 16
    },
}
gameObjectDictionary.IRON_BARS = {
    physicsType = "static",
    yDrawPosOffset = 16,
    proxCull = true,
    canSeeThru = true,
    image = love.graphics.newImage("sprites/objects/iron_bars.png"),
    collider = {
        x = 16,
        y = 2,
        offsetX = 0,
        offsetY = 15
    },
}
gameObjectDictionary.SPAWNER_FX_EXPLOSION_FALLING_FIREBALL = {
    editorDrawOnly = true,
    physicsType = "static",
    yDrawPosOffset = -8,
    canSeeThru = true,
    image = love.graphics.newImage("sprites/objects/barrier.png"),
    collider = {
        x = 0,
        y = 0,
        offsetX = 0,
        offsetY = 0,
        noCollide = true
    },
    Update = function(self, dt)
        if self.updateFXTimer == nil then
            self.updateFXTimer = 0
            self.tickToFXTimer = Util.MathRandomDecimal(0.5, 3)
        end
        self.updateFXTimer = self.updateFXTimer + dt

        if self.updateFXTimer >= self.tickToFXTimer then
            self.updateFXTimer = 0
            self.tickToFXTimer = Util.MathRandomDecimal(0.5, 3)

            local plyX, plyY = Player.Get():GetPosition()
            local randX, randY = Util.GetNavValidRandomPointNear(plyX, plyY, 256)
            FX.CreateFX("FALLING_FIREBALL", randX, randY, 512, {
                x = 0,
                y = 0,
                z = -85.33
            }, nil, nil, function(self, dt)
                local randX, randY = math.random(self.x-2, self.x+2), math.random(self.y-2, self.y+2)
                FX.CreateFX("SMOKE", randX, randY, self.z, 5)
            end)
        end
    end
}
gameObjectDictionary.SPAWNER_FX_EXPLOSION_WALL_DUST = {
    editorDrawOnly = true,
    physicsType = "static",
    yDrawPosOffset = -8,
    canSeeThru = true,
    image = love.graphics.newImage("sprites/objects/barrier.png"),
    collider = {
        x = 0,
        y = 0,
        offsetX = 0,
        offsetY = 0,
        noCollide = true
    },
    Update = function(self, dt)
        if self.updateFXTimer == nil then
            self.updateFXTimer = 0
            self.tickToFXTimer = Util.MathRandomDecimal(0.5, 3)
        end
        self.updateFXTimer = self.updateFXTimer + dt

        if self.updateFXTimer >= self.tickToFXTimer then
            self.updateFXTimer = 0
            self.tickToFXTimer = Util.MathRandomDecimal(0.5, 3)

            local plyX, plyY = Player.Get():GetPosition()
            local randX, randY = Util.GetNavValidRandomPointNear(plyX, plyY, 256)
            local distFromPlayer = Util.MathDistance(plyX, plyY, randX, randY)

            Sounds.PlaySound("sound/projectiles/fireball_hit.ogg", randX, randY, 256, math.random(0.8, 1.5), 0)
            local shakeIntensity = Util.MathLerp(0.25, 0, distFromPlayer/256)
            Luven.camera:setShake(0.3, shakeIntensity)


            for i=1, 200 do
                randX, randY = math.random(randX-4, randX+4), math.random(randY-4, randY+4)
                FX.CreateFX("STONE_CRUMB", randX, randY, 128, {
                    x = Util.MathRandomDecimal(-500, 500),
                    y = 0,
                    z = Util.MathRandomDecimal(5, 50)
                })
            end
        end
    end
}
gameObjectDictionary.BARRIER = {
    editorDrawOnly = true,
    physicsType = "static",
    yDrawPosOffset = -8,
    canSeeThru = true,
    image = love.graphics.newImage("sprites/objects/barrier.png")
}
gameObjectDictionary.STONEWALL = {
    physicsType = "static",
    yDrawPosOffset = -8,
    image = love.graphics.newImage("sprites/objects/stonewall.png")
}
gameObjectDictionary.TREE = {
    physicsType = "static",
    yDrawPosOffset = 28,
    proxCull = true,
    image = love.graphics.newImage("sprites/objects/tree.png"),
    collider = {
        x = 16,
        y = 8,
        offsetX = 0,
        offsetY = 28
    },
    Update = function(self, dt)
        if self.updateFXTimer == nil or self.updateFXTimer >= self.fxTimerTrigger then
            self.updateFXTimer = 0
            self.fxTimerTrigger = Util.MathRandomDecimal(5, 10)

            local x, y = self:GetCenterMassPosition()

            local randX, randY, randZ = math.random(x-16, x+16), math.random(y-16, y+16), math.random(48, 64)
            FX.CreateFX("LEAF", randX, randY, randZ, {
                x = Util.MathRandomDecimal(-50, 50),
                y = Util.MathRandomDecimal(-50, 50),
                z = 0
            })
        end
        self.updateFXTimer = self.updateFXTimer + dt
    end
}
gameObjectDictionary.MANA_TREE = {
    physicsType = "static",
    yDrawPosOffset = 28,
    proxCull = true,
    image = love.graphics.newImage("sprites/objects/mana_tree.png"),
    bloomImage = love.graphics.newImage("sprites/objects/mana_tree_bloom.png"),
    light = {
        colorRange = { min = { 0.0, 0.95, 0.95, 1.0 }, max = { 0.0, 1.0, 1.0, 1.0 } },
        powerRange = { min = 0.3, max = 0.32 },
        speedRange = { min = 0.0, max = 0.2 }
    },
    collider = {
        x = 16,
        y = 8,
        offsetX = 0,
        offsetY = 28
    },
    Update = function(self, dt)
        if self.updateWispFXTimer == nil or self.updateWispFXTimer >= self.wispFXTimerTrigger then
            local x, y = self:GetCenterMassPosition()
            self.updateWispFXTimer = 0
            self.wispFXTimerTrigger = Util.MathRandomDecimal(14, 16)

            local randX, randY, randZ = math.random(x-16, x+16), math.random(y-16, y+16), math.random(48, 64)
            for i=1, 20 do
                FX.CreateFX("MANA_TREE_LEAF", randX, randY, randZ, 50)
            end
            FX.CreateFX("WISP", randX, randY, randZ, 100, nil, nil, function(self, dt)
                if self.dtTimer == nil then self.dtTimer = 0 end
                self.dtTimer = self.dtTimer + dt
                if self.dtTimer >= 0.05 then
                    self.dtTimer = 0
                    FX.CreateFX("WHITE_SMOKE", self.x, self.y, self.z, 10, nil, {0, 0.95, 0.95})
                end
            end)
        end
        
        if self.updateLeafFXTimer == nil or self.updateLeafFXTimer >= self.leafFXTimerTrigger then
            local x, y = self:GetCenterMassPosition()
            self.updateLeafFXTimer = 0
            self.leafFXTimerTrigger = Util.MathRandomDecimal(5, 10)

            local randX, randY, randZ = math.random(x-16, x+16), math.random(y-16, y+16), math.random(48, 64)
            FX.CreateFX("MANA_TREE_LEAF", randX, randY, randZ, {
                x = Util.MathRandomDecimal(-50, 50),
                y = Util.MathRandomDecimal(-50, 50),
                z = 0
            })
        end

        self.updateWispFXTimer = self.updateWispFXTimer + dt
        self.updateLeafFXTimer = self.updateLeafFXTimer + dt
    end
}
gameObjectDictionary.STONEWALL_OVERLAY = {
    physicsType = "static",
    yDrawPosOffset = 64,
    image = love.graphics.newImage("sprites/objects/stonewall.png")
}
gameObjectDictionary.STANDINGTORCH = {
    physicsType = "static",
    yDrawPosOffset = 8,
    canSeeThru = true,
    image = love.graphics.newImage("sprites/objects/standingtorch.png"),
    bloomImage = love.graphics.newImage("sprites/objects/standingtorch_bloom.png"),
    light = {
        colorRange = { min = { 0.8, 0.8, 0.0, 0.8 }, max = { 1.0, 1.0, 0.0, 1.0 } },
        powerRange = { min = 0.35, max = 0.40 },
        speedRange = { min = 0.12, max = 0.2 }
    },
    collider = {
        x = 4,
        y = 2,
        offsetX = 0,
        offsetY = 7
    },
    Update = function(self, dt)
        if self.fxTimer == nil then self.fxTimer = 0 end
        self.fxTimer = self.fxTimer + dt

        local currentTimerValue = tonumber(string.format("%.2f", self.fxTimer))
        if currentTimerValue % 0.25 == 0 then
            local x, y = self:GetPosition()
            y = self:GetYDrawLevel()
            local randRange = 2
            local randX, randY = math.random(x-randRange, x+randRange), math.random(y-randRange, y+randRange)
            FX.CreateFX("SMOKE", randX, randY, 12, 5)
        end
    end
}
gameObjectDictionary.CAMPFIRE = {
    physicsType = "static",
    canSeeThru = true,
    image = love.graphics.newImage("sprites/objects/campfire.png"),
    bloomImage = love.graphics.newImage("sprites/objects/campfire_bloom.png"),
    light = {
        colorRange = { min = { 0.8, 0.8, 0.0, 0.8 }, max = { 1.0, 1.0, 0.0, 1.0 } },
        powerRange = { min = 0.55, max = 0.60 },
        speedRange = { min = 0.12, max = 0.2 }
    },
    collider = {
        x = 16,
        y = 6,
        offsetX = 0,
        offsetY = 0
    },
    Update = function(self, dt)
        if self.fxTimer == nil then self.fxTimer = 0 end
        self.fxTimer = self.fxTimer + dt

        local currentTimerValue = tonumber(string.format("%.2f", self.fxTimer))
        if currentTimerValue % 0.05 == 0 then
            local x, y = self:GetPosition()
            local randRange = 2
            local randX, randY = math.random(x-randRange, x+randRange), math.random(y-randRange, y+randRange)
            FX.CreateFX("LONG_SMOKE", randX, randY, 4, 5)
        end
    end
}

gameObjectDictionary.TELEPORTER_INACTIVE = {
    physicsType = "static",
    yDrawPosOffset = 8,
    canSeeThru = true,
    image = love.graphics.newImage("sprites/objects/teleporter_inactive.png"),
    collider = {
        x = 0,
        y = 0,
        offsetX = 0,
        offsetY = 8,
        noCollide = true
    }
}
gameObjectDictionary.TELEPORTER_ACTIVE = {
    physicsType = "static",
    yDrawPosOffset = 8,
    canSeeThru = true,
    image = love.graphics.newImage("sprites/objects/teleporter_active.png"),
    bloomImage = love.graphics.newImage("sprites/objects/teleporter_bloom.png"),
    light = {
        colorRange = { min = { 0.0, 0.95, 0.95, 1.0 }, max = { 0.0, 1.0, 1.0, 1.0 } },
        powerRange = { min = 0.65, max = 0.7 },
        speedRange = { min = 0.0, max = 0.2 }
    },
    collider = {
        x = 0,
        y = 0,
        offsetX = 0,
        offsetY = 8,
        noCollide = true
    },
    Update = function(self, dt)
        if Rooms.IsCutsceneRunning() then return end

        local x, y = self:GetCenterMassPosition()
        local plyX, plyY = Player.Get():GetCenterMassPosition()

        if Util.MathDistance(x, y, plyX, plyY) <= 4 then
            Rooms.MarkForChangeRoom(Rooms.GetCurrentRoomData().nextRoomName, true, false, true, "sound/ui/teleport.ogg", true)
        end
    end
}

return gameObjectDictionary