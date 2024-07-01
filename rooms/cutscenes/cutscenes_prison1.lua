local this = {}

this[0] = {
    time = 6,
    text = {
        content = "\"Hey! ___You! ___Get up! Get up!\"",
        time = 4,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = -36,
        y = 313,
        time = 3
    },
    Start = function(gameObjects)
        local enemies = {
            gameObjects[372199029],
            gameObjects[856605746]
        }
        for k, v in pairs(enemies) do
            v.hasControl = false
        end

        local theGuy = gameObjects[444225576]
        theGuy.ai.doNotFollow = true
        local otherGuys = {
            gameObjects[760206978],
            gameObjects[924708822]
        }
        for k, v in pairs(otherGuys) do
            v.hasControl = false
            v.inventory.equipped.torso = nil
        end

        theGuy.ai.movingTo = {-21, 330}
        theGuy.cooldowns.aggro.current = 999
        theGuy.canBeKilled = false
    end
}
this[1] = {
    time = 6,
    text = {
        content = "\"You're alive? ____Good. Let's get you out of here.\"",
        time = 4,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = -36,
        y = 313,
        time = 3
    },
    End = function(gameObjects)
        local theGuy = gameObjects[444225576]

        theGuy.ai.movingTo = {-24, 331}
    end
}
this[2] = {
    time = 7,
    text = {
        content = "____________\"That should do it. __Here, take this sword just in case we run into trouble.\"",
        time = 5,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = -36,
        y = 313,
        time = 3
    },
    End = function(gameObjects)
        Player.Get().inventory.equipped.weapon = Items.GetWeaponItem("BASIC_SWORD")
    end,
    Update = function(dt, gameObjects)
        local theGuy = gameObjects[444225576]
        local theDoor = gameObjects[788096285]

        if theDoor == nil then return end

        local x1, y1 = theGuy:GetPosition()
        local x2, y2 = theDoor:GetPosition()

        local angleToDoor = Util.MathGetAngleTo(x1, y1, x2, y2)
        theGuy:ChangeLookAngle(angleToDoor)

        theGuy:Attack()
    end
}
this[3] = {
    time = 6,
    text = {
        content = "\"Looks like the war has come, __my friend. ___No time for questions, we gotta leave.\"",
        time = 3,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = -36,
        y = 313,
        time = 3
    }
}
this[4] = {
    time = 5,
    text = {
        content = "\"I need to gather the others, come on! ____Let's go!\"",
        time = 3,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = -36,
        y = 313,
        time = 3
    },
    End = function(gameObjects)
        local theGuy = gameObjects[444225576]
        local otherGuys = {
            gameObjects[760206978],
            gameObjects[924708822]
        }

        theGuy.ai.movingTo = {325, 336}
        theGuy.cooldowns.aggro.current = 999
        for k, v in pairs(otherGuys) do
            v.hasControl = true
            v.ai.movingTo = {325, 336}
            v.cooldowns.aggro.current = 999
        end
    end
}

this[10] = {
    time = 5,
    text = {
        content = "\"Seems like we got trouble up ahead!\"",
        time = 2,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = 559,
        y = 131,
        time = 3
    },
    End = function(gameObjects)
        local theGuy = gameObjects[444225576]
        local otherGuys = {
            gameObjects[760206978],
            gameObjects[924708822]
        }

        theGuy.ai.movingTo = {531, 75}
        theGuy.ai.moveToWaitForEntID = nil
        theGuy.cooldowns.aggro.current = 999
        for k, v in pairs(otherGuys) do
            v.ai.movingTo = {531, 75}
            v.ai.moveToWaitForEntID = nil
            v.cooldowns.aggro.current = 999
        end

        local enemies = {
            gameObjects[372199029],
            gameObjects[856605746]
        }

        for k, v in pairs(enemies) do
            v.hasControl = true
        end
    end
}

this[12] = {
    time = 5,
    text = {
        content = "\"Well, ____that's taken care of.\"",
        time = 3,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "ply",
        y = "ply",
        time = 3
    },
    End = function(gameObjects)
        local theGuy = gameObjects[444225576]
        local plyX, plyY = Player.Get():GetPosition()
        local randX, randY = Util.GetNavValidRandomPointNear(plyX, plyY, 32)

        theGuy.ai.movingTo = {randX, randY}
    end
}
this[13] = {
    time = 6,
    text = {
        content = "\"Let's see if we can find a way out of here.\"",
        time = 3,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "ply",
        y = "ply",
        time = 3
    },
    End = function(gameObjects)
        local theGuy = gameObjects[444225576]
        theGuy.ai.doNotFollow = false
    end
}

this[15] = {
    time = 8,
    text = {
        content = "\"Woah! That certainly looks.. ___well.. ____dangerous.\"",
        time = 6,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "ply",
        y = "ply",
        time = 3
    },
    Start = function(gameObjects)
        local theGuy = gameObjects[444225576]
        local plyX, plyY = Player.Get():GetPosition()
        local randX, randY = Util.GetNavValidRandomPointNear(plyX, plyY, 32)

        theGuy.ai.movingTo = {randX, randY}
        theGuy.cooldowns.aggro.current = 99
    end
}
this[16] = {
    time = 7,
    text = {
        content = "\"Uhhh... __do you think it can get us out of here?\"",
        time = 5,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "ply",
        y = "ply",
        time = 3
    }
}
this[17] = {
    time = 5,
    text = {
        content = "\"What!? You think I'm scared!?\"",
        time = 2,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "ply",
        y = "ply",
        time = 3
    }
}
this[18] = {
    time = 5,
    text = {
        content = "...",
        time = 4
    },
    cam = {
        x = "ply",
        y = "ply",
        time = 3
    }
}
this[19] = {
    time = 3,
    text = {
        content = "\"I'm not scared.\"",
        time = 2,
        color = {0.8, 1, 0.5}
    },
    cam = {
        x = "ply",
        y = "ply",
        time = 3
    }
}

return this