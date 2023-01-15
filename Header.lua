

-- LIBRARIES --


AceAddon = LibStub("AceAddon-3.0");
LibEasing = LibStub("LibEasing-1.0");
SharedMedia = LibStub("LibSharedMedia-3.0");

DarkSoulsSCT = AceAddon:NewAddon("DarkSoulsSCT", "AceConsole-3.0", "AceEvent-3.0");
DarkSoulsSCT.frame = CreateFrame("Frame", nil, UIParent);



-- LOCALS --


Defaults = {
    global = {
        enabled = true,
        playerDamageTaken = true,
        petDamageDone = true,
        mode = 0; --0 default, 1 percent, 2 scaled
        --
        factor = 1.0,
        font = "Friz Quadrata TT",
        --
        target = {
            animationDuration = 1.0,
            textSize = 25,
            xOffset = -16,
            yOffset = -30,
            color = "ffff00",
            anchor = "RIGHT",
        },
        self = {
            animationDuration = 1.0,
            textSize = 25,
            xOffset = -10,
            yOffset = 30,
            color = "ffff00",
            anchor = "RIGHT",
        },
        --
        format = {
            enabled = true,
            separatorEnabled = true,
            thousandEnabled = true,
            percentEnabled = true,
        },
    },
};