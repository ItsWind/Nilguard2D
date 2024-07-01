local this = {}

local factionDictionary = {}

factionDictionary.PLAYER = {
	name = "PLAYER",
	enemies = {
		["PLAYER_ENEMY"] = true
	}
}

factionDictionary.PLAYER_ENEMY = {
	name = "PLAYER_ENEMY",
	enemies = {
		["PLAYER"] = true
	}
}

function this.GetFactionOf(factionName)
	return factionDictionary[factionName:upper()]
end

function this.IsFactionEnemyOf(faction, otherFactionName)
	return faction.enemies[otherFactionName] ~= nil
end

return this