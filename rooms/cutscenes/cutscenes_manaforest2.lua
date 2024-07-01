local this = {}

this[0] = {
    time = 5,
    text = {
        content = "\"Wha- ____Who-\"",
        time = 2,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 218,
        y = 117,
        time = 3
    },
    Start = function(gameObjects)
        local nam = gameObjects[470541203]
        nam.cooldowns.aggro.current = 99
        nam.ai.movingTo = {218, 117}
    end
}
this[1] = {
    time = 5,
    text = {
        content = "\"Oh... ____right.\"",
        time = 2,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 218,
        y = 117,
        time = 3
    }
}
this[2] = {
    time = 8,
    text = {
        content = "\"Howdy! ___I'm Nam Olah. __I'm sure you have many questions...\"",
        time = 6,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 218,
        y = 117,
        time = 3
    }
}
this[3] = {
    time = 7,
    text = {
        content = "\"I will answer all of them in due time, __but first...\"",
        time = 5,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 218,
        y = 117,
        time = 3
    }
}
this[4] = {
    time = 5,
    text = {
        content = "\"Come and check out this cool thing I did!\"",
        time = 2,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 218,
        y = 117,
        time = 3
    },
    End = function(gameObjects)
        local nam = gameObjects[470541203]
        nam.cooldowns.aggro.current = 999
        nam.ai.movingTo = {72, 222}
    end
}

this[6] = {
    time = 4,
    text = {
        content = "\"It's ____a hole!\"",
        time = 2,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 48,
        y = 208,
        time = 3
    },
    Start = function(gameObjects)
        local nam = gameObjects[470541203]
        nam.cooldowns.aggro.current = 99
        nam.ai.movingTo = {72, 222}
    end
}
this[7] = {
    time = 5,
    text = {
        content = "\"Pretty good, right?\"",
        time = 2,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 48,
        y = 208,
        time = 3
    }
}
this[8] = {
    time = 5,
    text = {
        content = "\"Too bad we can't jump in due to technical limitations and our creator not wanting to put that much effort into the\"",
        time = 5,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 48,
        y = 208,
        time = 3
    }
}
this[9] = {
    time = 13,
    text = {
        content = "\"Anyway... _____you are curious as to where we are, ___who I am, __and a great deal of other things, I'm sure.\"",
        time = 10,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 48,
        y = 208,
        time = 3
    }
}
this[10] = {
    time = 5,
    text = {
        content = "\"Go on then, ____ask away.\"",
        time = 3,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    },
    Start = function(gameObjects)
        local nam = gameObjects[470541203]
        nam.cooldowns.aggro.current = 999999
        nam.ai.movingTo = {76, 208}
    end
}
this[11] = {
    dialogs = {
        {
            text = "Where are we?",
            goToIndex = 100
        },
        {
            text = "Who are you?",
            goToIndex = 110
        },
        {
            text = "I used a teleporter of some kind to get here. What was that?",
            goToIndex = 120
        },
        {
            text = "EXIT",
            goToIndex = 12
        },
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    },
    Start = function(gameObjects)
        local nam = gameObjects[470541203]
        nam.cooldowns.aggro.current = 999999
        nam.ai.movingTo = {76, 208}
    end
}
this[100] = {
    time = 8,
    text = {
        content = "\"A good question. ____We are somewhere that's nowhere.\"",
        time = 6,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    },
    End = function()
        Rooms.SetCutsceneStage(11)
    end
}
this[110] = {
    time = 8,
    text = {
        content = "\"I am what the folks call ___a 'first one'.\"",
        time = 6,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    }
}
this[111] = {
    time = 8,
    text = {
        content = "\"I suppose it makes sense... ____I did come before them.\"",
        time = 6,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    },
    End = function()
        Rooms.SetCutsceneStage(11)
    end
}
this[120] = {
    time = 8,
    text = {
        content = "\"Ahhh! Yes! ____Was it black like midnight shining with an electric blue?\"",
        time = 6,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    }
}
this[121] = {
    time = 8,
    text = {
        content = "\"Constructs made by my kind a long time ago. ____Useful things if you know how to use them.\"",
        time = 6,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    }
}
this[122] = {
    time = 8,
    text = {
        content = "\"You, __of course, __have no need to *learn* magic like the rest of your people.\"",
        time = 6,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    },
    End = function()
        Rooms.SetCutsceneStage(11)
    end
}
this[12] = {
    time = 5,
    text = {
        content = "\"Nothing else? ____Very well.\"",
        time = 3,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    }
}
this[13] = {
    time = 8,
    text = {
        content = "\"Another guides your hand. I am here to guide them, __and by extension; ___you.\"",
        time = 6,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    }
}
this[14] = {
    time = 5,
    text = {
        content = "\"Come. ___There is much to do.\"",
        time = 2,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 76,
        y = 208,
        time = 3
    },
    End = function(gameObjects)
        local nam = gameObjects[470541203]
        nam.cooldowns.aggro.current = 999
        nam.ai.movingTo = {225, 359}
    end
}

this[16] = {
    time = 7,
    text = {
        content = "\"Our reality knows your path, __I do not. __I am only here to tell you to listen.\"",
        time = 5,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 225,
        y = 359,
        time = 3
    },
    Start = function(gameObjects)
        local nam = gameObjects[470541203]
        nam.cooldowns.aggro.current = 99
        nam.ai.movingTo = {225, 359}
    end
}
this[17] = {
    time = 9,
    text = {
        content = "\"Trust the path it has set out for you. ___I pray you have the courage to walk it.\"",
        time = 7,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 254,
        y = 364,
        time = 3
    },
    Start = function(gameObjects)
        local nam = gameObjects[470541203]
        nam.cooldowns.aggro.current = 99
        nam.ai.movingTo = {230, 361}

        local inactiveTeleporter = gameObjects[283084232]
        local x, y = inactiveTeleporter:GetPosition()
        Objects.RemoveGameObject(inactiveTeleporter.uniqueID)
        Objects.NewGameObject(true, "TELEPORTER_ACTIVE", x, y)
    end
}
this[18] = {
    time = 10,
    text = {
        content = "\"You should take this. ____It's dangerous to go alone.\"",
        time = 7,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 230,
        y = 361,
        time = 3
    },
    Start = function(gameObjects)
        local nam = gameObjects[470541203]
        local x, y = nam:GetPosition()
        y = y - 16
        Items.CreateDroppedItem(Items.GetWeaponItem("STAFF_MANAFESTATION"), x, y)
    end
}
this[19] = {
    time = 10,
    text = {
        content = "\"This is not the last we will see of each other. ___It was nice to have company for a while, but there are things to do.\"",
        time = 7,
        color = {0, 0.5, 0}
    },
    cam = {
        x = 230,
        y = 361,
        time = 3
    },
    End = function(gameObjects)
        local nam = gameObjects[470541203]
        nam.cooldowns.aggro.current = 0
        nam.ai.movingTo = {230, 361}
    end
}

return this