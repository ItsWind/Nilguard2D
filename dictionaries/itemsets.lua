local this = {}

local function GetRandomArmorByEquipType(equipType, allArmors, chanceForNone, testAction)
	if chanceForNone ~= nil and math.random(1,100) <= chanceForNone then
		return nil
	end

	if testAction == nil then
		testAction = function(item)
			return true
		end
	end

	local armorIDs = {}
	for k, v in pairs(allArmors) do
		if testAction(v) and v.equipType == equipType and v.doNotIncludeInItemSets == nil then
			table.insert(armorIDs, v.id)
		end
	end

	if #armorIDs == 0 then
		return nil
	end

	return Items.GetArmorItem(armorIDs[math.random(1,#armorIDs)])
end

local function GetRandomWeaponByAttackType(attackType, allWeapons, testAction)
	if testAction == nil then
		testAction = function(item)
			return true
		end
	end

	local weaponIDs = {}
	for k, v in pairs(allWeapons) do
		if testAction(v) and v.attackType == attackType and v.doNotIncludeInItemSets == nil then
			table.insert(weaponIDs, v.id)
		end
	end

	if #weaponIDs == 0 then
		return nil
	end

	return Items.GetWeaponItem(weaponIDs[math.random(1,#weaponIDs)])
end

local function GetRandomShield(allShields, chanceForNone, testAction)
	if chanceForNone ~= nil and math.random(1,100) <= chanceForNone then
		return nil
	end

	if testAction == nil then
		testAction = function(item)
			return true
		end
	end

	local shieldIDs = {}
	for k, v in pairs(allShields) do
		if testAction(v) and v.doNotIncludeInItemSets == nil then
			table.insert(shieldIDs, v.id)
		end
	end

	if #shieldIDs == 0 then
		return nil
	end

	return Items.GetShieldItem(shieldIDs[math.random(1,#shieldIDs)])
end

local function GetRandomTorso(allArmors, chanceForNone, testAction)
	return GetRandomArmorByEquipType("torso", allArmors, chanceForNone, testAction)
end

local function GetRandomHead(allArmors, chanceForNone, testAction)
	return GetRandomArmorByEquipType("head", allArmors, chanceForNone, testAction)
end

this.OTHRIAN_GUARD = {
	weapon = function()
		return Items.GetWeaponItem("BASIC_SWORD")
	end,
	shield = function()
		return GetRandomShield(Items.GetItemDictionary().shields, 50)
	end,
	torso = function()
		return Items.GetArmorItem("TORSO", "OTHRIAN")
	end,
	head = function()
		return GetRandomHead(Items.GetItemDictionary().armor, 50, function(item)
			return item.manaRegen == nil
		end)
	end
}

this.RANDOM_MELEE = {
	weapon = function()
		return GetRandomWeaponByAttackType("melee", Items.GetItemDictionary().weapons)
	end,
	shield = function()
		return GetRandomShield(Items.GetItemDictionary().shields, 80)
	end,
	torso = function()
		return GetRandomTorso(Items.GetItemDictionary().armor, 50, function(item)
			if item.manaRegen == nil then
				return true
			end
			return false
		end)
	end,
	head = function()
		return GetRandomHead(Items.GetItemDictionary().armor, 50, function(item)
			if item.manaRegen == nil then
				return true
			end
			return false
		end)
	end
}

this.BASIC_MELEE = {
	weapon = function()
		return Items.GetWeaponItem("BASIC_SWORD")
	end,
	shield = function()
		return GetRandomShield(Items.GetItemDictionary().shields, 80)
	end,
	torso = function()
		return GetRandomTorso(Items.GetItemDictionary().armor, 65, function(item)
			return item.manaRegen == nil
		end)
	end,
	head = function()
		return GetRandomHead(Items.GetItemDictionary().armor, 85, function(item)
			return item.manaRegen == nil
		end)
	end
}

this.ELITE_MELEE = {
	weapon = function()
		return Items.GetWeaponItem("DIAMOND_SWORD")
	end,
	shield = function()
		return GetRandomShield(Items.GetItemDictionary().shields, 25)
	end,
	torso = function()
		return GetRandomTorso(Items.GetItemDictionary().armor, 30, function(item)
			return item.manaRegen == nil
		end)
	end,
	head = function()
		return GetRandomHead(Items.GetItemDictionary().armor, 50, function(item)
			return item.manaRegen == nil
		end)
	end
}

this.BOW = {
	weapon = function()
		return Items.GetWeaponItem("BOW")
	end,
	shield = function()
		return nil
	end,
	torso = function()
		return GetRandomTorso(Items.GetItemDictionary().armor, 75, function(item)
			return item.manaRegen == nil
		end)
	end,
	head = function()
		return GetRandomHead(Items.GetItemDictionary().armor, 95, function(item)
			return item.manaRegen == nil
		end)
	end
}

this.MAGE = {
	weapon = function()
		return GetRandomWeaponByAttackType("ranged", Items.GetItemDictionary().weapons, function(item)
			return item.manaCost ~= nil
		end)
	end,
	shield = function()
		return nil
	end,
	torso = function()
		return GetRandomTorso(Items.GetItemDictionary().armor, 30, function(item)
			return item.manaRegen ~= nil
		end)
	end,
	head = function()
		return GetRandomHead(Items.GetItemDictionary().armor, 50, function(item)
			return item.manaRegen ~= nil
		end)
	end
}

this.CHADRION = {
	weapon = function()
		return Items.GetWeaponItem("BASIC_SWORD")
	end,
	shield = function()
		return nil
	end,
	torso = function()
		return Items.GetArmorItem("TORSO", "METAL")
	end,
	head = function()
		return Items.GetArmorItem("HEAD", "CHAIN")
	end
}

this.NAM_OLAH = {
	weapon = function()
		return Items.GetWeaponItem("NAM_OLAH")
	end,
	shield = function()
		return nil
	end,
	torso = function()
		return nil
	end,
	head = function()
		return nil
	end
}

this.YDET_RELIK = {
	weapon = function()
		return Items.GetWeaponItem("YDET_RELIK")
	end,
	shield = function()
		return nil
	end,
	torso = function()
		return nil
	end,
	head = function()
		return nil
	end
}

this.YDET_RELIK_NORMAL = {
	weapon = function()
		return Items.GetWeaponItem("STAFF_FIRE")
	end,
	shield = function()
		return nil
	end,
	torso = function()
		return Items.GetArmorItem("TORSO", "MAGE")
	end,
	head = function()
		return Items.GetArmorItem("HEAD", "RELIK_CROWN")
	end
}

return this