local itemDictionary = {}

local dictionariesToAdd = {
    {require("dictionaries/items/torso"), "armor"},
    {require("dictionaries/items/head"), "armor"},
    {require("dictionaries/items/weapons"), "weapons"},
    {require("dictionaries/items/shields"), "shields"},
    {require("dictionaries/items/special"), "special"},
}

for k, v in pairs(dictionariesToAdd) do
    if itemDictionary[v[2]] == nil then
        itemDictionary[v[2]] = {}
    end
    for i, j in pairs(v[1]) do
        itemDictionary[v[2]][i] = j
    end
end

return itemDictionary