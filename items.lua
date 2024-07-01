local this = {}

local itemDictionary = {}

local droppedItems = {}

function this.Init()
    itemDictionary = require("dictionaries/items")
end

function this.GetArmorItem(equipSpot, name)
    if equipSpot == nil then return end
    local armorIDToUse = equipSpot:upper()
    if name ~= nil then
        armorIDToUse = equipSpot:upper() .. "_" .. name:upper()
    end
    return itemDictionary.armor[armorIDToUse]
end

function this.GetWeaponItem(name)
    if name == nil then return end
    return itemDictionary.weapons[name:upper()]
end

function this.GetShieldItem(name)
    if name == nil then return end
    return itemDictionary.shields[name:upper()]
end

function this.GetSpecialItem(name)
    if name == nil then return end
    return itemDictionary.special[name:upper()]
end

function this.GetItemDictionary()
    return itemDictionary
end

function this.GetRandomItems(minItems, maxItems, lootTier)
    local items = {}
    local itemTables = {itemDictionary.weapons, itemDictionary.shields, itemDictionary.armor, itemDictionary.special}
    local randomNumOfItems = math.random(minItems, maxItems)
    for i=1, randomNumOfItems do
        local item = Util.GetRandomElementFromTables(itemTables, function(element)
            return element.doNotIncludeInRandomItems == nil and
            (lootTier == nil or element.lootTier == nil or element.lootTier <= lootTier)
        end)
        table.insert(items, item)
    end

    return items
end

local function StoreDroppedItem(droppedItem)
    local newID = math.random(0, 1000000000)
    while droppedItems[newID] ~= nil do
        newID = math.random(0, 1000000000)
    end
    droppedItem.uniqueID = newID
    droppedItems[newID] = droppedItem
end

function this.CreateDroppedItem(item, x, y, canBePickedUp)
    if item.doNotDrop then return end

    if canBePickedUp == nil then canBePickedUp = true end
    local droppedItem = {}
    droppedItem.item = item
    droppedItem.x, droppedItem.y, droppedItem.z = x, y, 0
    droppedItem.origX, droppedItem.origY = x, y
    droppedItem.dropToX, droppedItem.dropToY = Util.GetNavValidRandomPointNear(x, y, 8)
    droppedItem.canBePickedUp = canBePickedUp
    droppedItem.droppingSeconds = 0
    droppedItem.dropForSeconds = Util.MathRandomDecimal(0.2, 0.75)
    droppedItem.velocity = {
        x = (droppedItem.dropToX - droppedItem.origX) / droppedItem.dropForSeconds,
        y = (droppedItem.dropToY - droppedItem.origY) / droppedItem.dropForSeconds,
        z = droppedItem.dropForSeconds * 156.8
    }
    StoreDroppedItem(droppedItem)
end

local function RemoveDroppedItem(droppedItemID)
    droppedItems[droppedItemID] = nil
end

local function EntityPickupDroppedItem(ent, droppedItem)
    local screenWidth, screenHeight = love.window.getMode()
    local inventoryItem = droppedItem.item
    local slotNumber = Player.GetNextItemSlotNumberFor(droppedItem.item)

    if slotNumber == nil then return end

    ent.inventory.bag[slotNumber] = inventoryItem
    RemoveDroppedItem(droppedItem.uniqueID)
end

function this.RemoveAllDroppedItems()
    for k, v in pairs(droppedItems) do
        RemoveDroppedItem(k)
    end
end

function this.Update(dt)
    local plyX, plyY = Player.Get():GetPosition()

    for k, v in pairs(droppedItems) do
        if v.droppingSeconds ~= nil then
            v.droppingSeconds = v.droppingSeconds + dt
            local timeLeft = v.dropForSeconds - v.droppingSeconds

            -- only change z velocity
            v.velocity.z = v.velocity.z - (dt * 313.6)

            v.x = v.x + v.velocity.x * dt
            v.y = v.y + v.velocity.y * dt
            v.z = v.z + v.velocity.z * dt

            if v.droppingSeconds >= v.dropForSeconds then
                v.x, v.y, v.z = v.dropToX, v.dropToY, 0
                v.droppingSeconds = nil
            end
            
            goto continue
        end

        local dist = Util.MathDistance(v.x, v.y, plyX, plyY)
        if dist <= 10 then
            if v.canBePickedUp then
                EntityPickupDroppedItem(Player.Get(), v)
            end
        else
            v.canBePickedUp = true
        end

        ::continue::
    end
end

function this.AddToYSort()
    for k, v in pairs(droppedItems) do
        YSort.Add(v.y, function()
            local droppedItemImage = v.item.images.inventory
            local imageScale = 0.35
            love.graphics.draw(droppedItemImage, v.x, v.y - (v.z*0.75), 0, imageScale, imageScale, droppedItemImage:getWidth()/2 * imageScale, droppedItemImage:getHeight()/2 * imageScale)
        end)
    end
end

return this