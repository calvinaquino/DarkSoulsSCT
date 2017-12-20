

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
        modules = {
            playerDamageTaken = true,
            petDamageDone = true,
        },
        mode = 0; --0 default, 1 percent, 2 scaled
        animationDuration = 0.6,
        textSize = 25,
        xOffset = 50,
        yOffset = -30,
        font = "Friz Quadrata TT",
        color = "ffff00",
        anchor = "CENTER",
        format = {
            enabled = true,
            separatorEnabled = true,
            thousandEnabled = true,
        },

    },
};