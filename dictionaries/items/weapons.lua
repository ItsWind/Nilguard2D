local function MeleeAttack(weapon, x, y, attackingEntity)
    local angleVariance = 0.7
    if weapon.meleeType == "poke" then
        angleVariance = 0.25
    end

    local entIDsToDamage = Ents.GetEntityIDsInRangeWithDistanceAndAngle(x, y, weapon.range, attackingEntity.lookAngle, angleVariance)

    for k, v in pairs(entIDsToDamage) do
        if v ~= attackingEntity.uniqueID then
            local entity = Objects.GetGameObjects()[v]
            if entity:GetZLevel() ~= 1 then return end

            if entity ~= nil and Factions.IsFactionEnemyOf(attackingEntity.faction, entity.faction.name) and attackingEntity:CanSeeEntity(entity, true) then
                entity:GetDamaged(x, y, weapon, attackingEntity.uniqueID)

                if Multiplayer.IsConnected() then
                    local data = {
                        x = x,
                        y = y,
                        --weaponID = weapon.id,
                        damage = weapon.damage,
                        knockback = weapon.knockback,
                        attackType = "melee",
                        victimEntityID = entity.uniqueID,
                        attackingEntityID = attackingEntity.uniqueID
                    }
                    Multiplayer.ClientSend("getDamaged", data)
                end
            end
        end
    end
end

local function LaunchProjectile(self, x, y, attackingEntity)
    local direction = Util.MathRandomDecimal(attackingEntity.lookAngle - self.precisionVariance, attackingEntity.lookAngle + self.precisionVariance)
	local projectile = Projectiles.NewProjectile(self.projectileType, attackingEntity.uniqueID, x, y, direction, 14)

    if Multiplayer.IsConnected() then
        local data = {
            uniqueID = projectile.uniqueID,
            projectileType = self.projectileType,
            attackingEntityID = attackingEntity.uniqueID,
            x = x,
            y = y,
            direction = direction
        }
        Multiplayer.ClientSend("launchedProjectile", data)
    end
end

local dict = {}

dict.PITCHFORK = {
    lootTier = 1,
    id = "PITCHFORK",
    equipType = "weapon",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/pitchfork.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/weapons/pitchfork.png"),
        attack = love.graphics.newImage("sprites/items/equipped/weapons/pitchfork_attack.png")
    },
    sounds = {
        attack = "sound/attack/sword_swing.ogg",
        detectionRadii = {
            attack = 16
        }
    },
    range = 40,
    damage = 20,
    knockback = 8,
    attackCooldown = 0.6,
    attackType = "melee",
    meleeType = "poke",
    Attack = MeleeAttack
}

dict.BASIC_SWORD = {
    lootTier = 1,
    id = "BASIC_SWORD",
    equipType = "weapon",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/basic_sword.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/weapons/basic_sword.png"),
        attack = love.graphics.newImage("sprites/items/equipped/weapons/basic_sword_attack.png")
    },
    sounds = {
        attack = "sound/attack/sword_swing.ogg",
        detectionRadii = {
            attack = 16
        }
    },
    canUseShield = true,
    range = 20,
    damage = 40,
    knockback = 1,
    attackCooldown = 0.3,
    attackType = "melee",
    Attack = MeleeAttack
}

dict.DIAMOND_SWORD = {
    lootTier = 2,
    id = "DIAMOND_SWORD",
    equipType = "weapon",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/diamond_sword.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/weapons/diamond_sword.png"),
        attack = love.graphics.newImage("sprites/items/equipped/weapons/diamond_sword_attack.png")
    },
    sounds = {
        attack = "sound/attack/sword_swing.ogg",
        detectionRadii = {
            attack = 16
        }
    },
    canUseShield = true,
    range = 25,
    damage = 50,
    knockback = 2,
    attackCooldown = 0.3,
    attackType = "melee",
    Attack = MeleeAttack
}

dict.STAFF_FIRE = {
    lootTier = 2,
    id = "STAFF_FIRE",
    equipType = "weapon",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/staff_fire.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/weapons/staff_fire.png"),
        attack = love.graphics.newImage("sprites/items/equipped/weapons/staff_fire_attack.png")
    },
    sounds = {
        attack = "sound/attack/staff_fire_shoot.ogg",
        detectionRadii = {
            attack = 96
        }
    },
    precisionVariance = 0.2,
    attackCooldown = 1.0,
    attackType = "ranged",
    projectileType = "FIREBALL",
    manaCost = 25,
    Attack = LaunchProjectile
}

dict.STAFF_ICE = {
    lootTier = 2,
    id = "STAFF_ICE",
    equipType = "weapon",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/staff_ice.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/weapons/staff_ice.png"),
        attack = love.graphics.newImage("sprites/items/equipped/weapons/staff_ice_attack.png")
    },
    sounds = {
        attack = "sound/attack/staff_fire_shoot.ogg",
        detectionRadii = {
            attack = 96
        }
    },
    precisionVariance = 0.1,
    attackCooldown = 0.3,
    attackType = "ranged",
    projectileType = "ICE_SPIKE",
    manaCost = 8,
    Attack = LaunchProjectile
}

dict.STAFF_MANAFESTATION = {
    doNotLetAISwitchTo = true,
    doNotGiveToNPCs = true,
    doNotIncludeInItemSets = true,
    doNotIncludeInRandomItems = true,
    lootTier = 2,
    id = "STAFF_MANAFESTATION",
    equipType = "weapon",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/staff_manafestation.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/weapons/staff_manafestation.png"),
        attack = love.graphics.newImage("sprites/items/equipped/weapons/staff_manafestation_attack.png")
    },
    sounds = {
        attack = "sound/attack/staff_fire_shoot.ogg",
        detectionRadii = {
            attack = 96
        }
    },
    attackCooldown = 3,
    attackType = "ranged",
    manaCost = 50,
    Attack = function(self, x, y, attackingEntity)
        local spawnX, spawnY = Util.GetNavValidRandomPointNear(x, y, 24)
        FX.CreateFX("EMPTY_3", spawnX, spawnY, 0, nil, function(self)
            Ents.NewEntity(true, "PLAYER_MANAFESTATION", spawnX, spawnY)
            for i=1, 100 do
                local randX, randY = Util.MathRandomDecimal(self.x - 8, self.x + 8), Util.MathRandomDecimal(self.y - 8, self.y + 8)
                local randRedGreen = Util.MathRandomDecimal(0, 0.6)
                FX.CreateFX("WHITE_SMOKE", randX, randY, 0, 50, nil, {randRedGreen, randRedGreen, 1})
            end
        end, nil, function(self, dt)
            local randX, randY = Util.MathRandomDecimal(self.x - 8, self.x + 8), Util.MathRandomDecimal(self.y - 8, self.y + 8)
            local randRedGreen = Util.MathRandomDecimal(0, 0.6)
            FX.CreateFX("WHITE_SMOKE", randX, randY, 0, 5, nil, {randRedGreen, randRedGreen, 1})
        end)
    end
}

dict.BOW = {
    lootTier = 1,
    id = "BOW",
    equipType = "weapon",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/bow.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/weapons/bow.png"),
        attack = love.graphics.newImage("sprites/items/equipped/weapons/bow_attack.png")
    },
    sounds = {
        attack = "sound/attack/bow_shoot.ogg",
        detectionRadii = {
            attack = 8
        }
    },
    precisionVariance = 0.05,
    attackCooldown = 1.5,
    attackType = "ranged",
    projectileType = "ARROW",
    Attack = LaunchProjectile
}

dict.PISTOL = {
    doNotLetAISwitchTo = true,
    doNotGiveToNPCs = true,
    doNotIncludeInRandomItems = true,
    doNotIncludeInItemSets = true,
    id = "PISTOL",
    equipType = "weapon",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/pistol.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/weapons/pistol.png"),
        attack = love.graphics.newImage("sprites/items/equipped/weapons/pistol_attack.png")
    },
    sounds = {
        attack = "sound/attack/pistol_shoot.ogg",
        detectionRadii = {
            attack = 512
        }
    },
    attackCooldown = 0.1,
    attackType = "ranged",
    projectileType = "BULLET",
    Attack = LaunchProjectile
}

dict.NAM_OLAH = {
    doNotIncludeInRandomItems = true,
    doNotIncludeInItemSets = true,
    doNotDrop = true,
    id = "NAM_OLAH",
    equipType = "weapon",
    images = {
        equipped = love.graphics.newImage("sprites/items/equipped/weapons/nam/walking_stick.png"),
        attack = love.graphics.newImage("sprites/items/equipped/weapons/nam/walking_stick_attack.png")
    },
    sounds = {
        attack = "sound/attack/sword_swing.ogg",
        detectionRadii = {
            attack = 16
        }
    },
    range = 20,
    damage = 80,
    knockback = 4,
    attackCooldown = 0.3,
    attackType = "melee",
    Attack = MeleeAttack
}

dict.YDET_RELIK = {
    doNotIncludeInRandomItems = true,
    doNotIncludeInItemSets = true,
    doNotDrop = true,
    id = "YDET_RELIK",
    equipType = "weapon",
    images = {
        equipped = love.graphics.newImage("sprites/items/equipped/weapons/bosses/ydet_relik.png"),
        attack = love.graphics.newImage("sprites/items/equipped/weapons/bosses/ydet_relik_attack.png")
    },
    sounds = {
        attack = "sound/attack/sword_swing.ogg",
        detectionRadii = {
            attack = 16
        }
    },
    range = 20,
    damage = 65,
    knockback = 6,
    attackCooldown = 0.15,
    attackType = "melee",
    Attack = MeleeAttack
}

return dict