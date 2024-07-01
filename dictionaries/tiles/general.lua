local dict = {}

dict.GRASS = {
    image = love.graphics.newImage("sprites/tiles/ground/grass.png")
}
dict.DIRT = {
    image = love.graphics.newImage("sprites/tiles/ground/dirt.png")
}
dict.STONE = {
    image = love.graphics.newImage("sprites/tiles/ground/stone.png")
}
dict.WATER = {
    animateMult = 4,
    images = {
        love.graphics.newImage("sprites/tiles/animated/water/1.png"),
        love.graphics.newImage("sprites/tiles/animated/water/2.png"),
        love.graphics.newImage("sprites/tiles/animated/water/3.png"),
        love.graphics.newImage("sprites/tiles/animated/water/4.png"),
    }
}
dict.MANA_PETALS = {
    overlay = true,
    animateMult = 4,
    images = {
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/1.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/2.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/3.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/4.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/5.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/6.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/7.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/8.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/9.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/10.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/11.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/12.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/13.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/14.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/15.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/16.png"),
    },
    bloomImages = {
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/1.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/2.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/3.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/4.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/5.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/6.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/7.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/8.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/9.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/10.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/11.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/12.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/13.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/14.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/15.png"),
        love.graphics.newImage("sprites/tiles/ground/overlay/mana_petals/16.png"),
    }
}

return dict