local tileDictionary = {}

local dictionariesToAdd = {
    require("dictionaries/tiles/general"),
    require("dictionaries/tiles/overlay"),
}

for k, v in pairs(dictionariesToAdd) do
    for i, j in pairs(v) do
        tileDictionary[i] = j
    end
end

return tileDictionary