local this = {}

local ySortDrawActions = {}

function this.Add(yLevel, drawAction)
	local newDrawAction = {
		yLevel = yLevel,
		Draw = drawAction
	}

	table.insert(ySortDrawActions, newDrawAction)
end

function this.Draw()
    local sortedKeys = {}
    for k in pairs(ySortDrawActions) do table.insert(sortedKeys, k) end

    table.sort(sortedKeys, function(a, b)
		local drawAction1 = ySortDrawActions[a]
		local drawAction2 = ySortDrawActions[b]
        return drawAction1.yLevel < drawAction2.yLevel
    end)

    for k, v in ipairs(sortedKeys) do
        local drawAction = ySortDrawActions[v]
        drawAction.Draw()
    end

	ySortDrawActions = {}
end

return this