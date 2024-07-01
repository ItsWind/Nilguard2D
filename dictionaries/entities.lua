local entityDictionary = {}

local dictionariesToAdd = {
    require("dictionaries/entities/bosses"),
    require("dictionaries/entities/general_enemy"),
    require("dictionaries/entities/general_friendly"),
    require("dictionaries/entities/unique"),
    require("dictionaries/entities/breakables"),
}

for k, v in pairs(dictionariesToAdd) do
    for i, j in pairs(v) do
        entityDictionary[i] = j
    end
end

return entityDictionary