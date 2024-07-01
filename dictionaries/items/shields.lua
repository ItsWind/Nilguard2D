local dict = {}

dict.WOOD = {
    id = "WOOD",
    equipType = "shield",
    images = {
        inventory = love.graphics.newImage("sprites/items/inventory/shield_wood.png"),
        equipped = love.graphics.newImage("sprites/items/equipped/shields/wood.png")
    },
    blockCooldown = 0.1,
    blockAbsorption = 0.75
}

return dict