

-- HELPERS --


local function rgbToHex(r, g, b)
    return string.format("%02x%02x%02x", math.floor(255 * r), math.floor(255 * g), math.floor(255 * b));
end

local function hexToRGB(hex)
    return tonumber(hex:sub(1,2), 16)/255, tonumber(hex:sub(3,4), 16)/255, tonumber(hex:sub(5,6), 16)/255, 1;
end


-- MENU


local anchorValues = {
    ["CENTER"] = "Center",
    ["TOP"] = "Top",
    ["TOPRIGHT"] = "Top right",
    ["RIGHT"] = "Right",
    ["BOTTOMRIGHT"] = "Bottom right",
    ["BOTTOM"] = "Bottom",
    ["BOTTOMLEFT"] = "Bottom left",
    ["LEFT"] = "Left",
    ["TOPLEFT"] = "Top left",
};

local modeValues = {
    [0] = "Default",
    [1] = "Percent",
    [2] = "Scaled",
};

local menu = {
    name = "DarkSoulsSCT",
    handler = DarkSoulsSCT,
    type = 'group',
    args = {
        enable = {
            type = 'toggle',
            name = "Enable",
            desc = "Enables or disables Dark Souls Scrolling Combag Text",
            get = "IsEnabled",
            set = function(_, newValue) if (not newValue) then DarkSoulsSCT:Disable(); else DarkSoulsSCT:Enable(); end end,
            order = 1,
            width = "half",
        },
        disableBlizzardFCT = {
            type = 'toggle',
            name = "Disable Blizzard FCT",
            desc = "",
            get = function(_, newValue) return GetCVar("floatingCombatTextCombatDamage") == "0" end,
            set = function(_, newValue)
                if (newValue) then
                    SetCVar("floatingCombatTextCombatDamage", "0");
                else
                    SetCVar("floatingCombatTextCombatDamage", "1");
                end
            end,
            order = 2,
        },
        mode = {
            type = 'group',
            name = "Mode",
            order = 9,
            inline = true,
            disabled = function() return not DarkSoulsSCT.db.global.enabled; end;
            args = {
                scaledMode = {
                    type = 'select',
                    name = "Scoring mode",
                    disabled = function() return not DarkSoulsSCT.db.global.enabled; end;
                    desc = "Changes how the damage value is calculated/shown.\n\nDefault: Value is the default Blizzard's implementation.\n\nPercent: Value is shown as a percent of the target's max heath.\n\nScaled: Value is a score based on your own base health. This is mostly meant as a new damage scoring system for Blizzard's new scaling tech, so the player can have a real feedback on power progression of the character.",
                    values = modeValues,
                    get = function() return DarkSoulsSCT.db.global.mode; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.mode = newValue; end,
                    order = 1,
                    width = "full",
                },
            },
        },
        modules = {
            type = 'group',
            name = "Modules",
            order = 10,
            inline = true,
            disabled = function() return not DarkSoulsSCT.db.global.enabled; end;
            args = {
                playerDamageTaken = {
                    type = 'toggle',
                    name = "Player damage taken",
                    desc = "Displays damage taken by the player under his nameplate. Uses same style as damage done text.",
                    get = function() return DarkSoulsSCT.db.global.playerDamageTaken; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.playerDamageTaken = newValue; end,
                    order = 1,
                    width = "full",
                },
                petDamageDone = {
                    type = 'toggle',
                    name = "Pet damage",
                    desc = "Enables SCT to account for pet damage.",
                    get = function() return DarkSoulsSCT.db.global.petDamageDone; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.petDamageDone = newValue; end,
                    order = 2,
                    width = "full",
                },
            },
        },
        customization = {
            type = 'group',
            name = "Customization",
            order = 20,
            inline = true,
            disabled = function() return not DarkSoulsSCT.db.global.enabled; end;
            args = {
                defaultColor = {
                    type = 'color',
                    name = "Text color",
                    desc = "",
                    hasAlpha = false,
                    set = function(_, r, g, b) DarkSoulsSCT.db.global.color = rgbToHex(r, g, b); end,
                    get = function() return hexToRGB(DarkSoulsSCT.db.global.color); end,
                    order = 2,
                },
                textDuration = {
                    type = 'range',
                    name = "Text duration",
                    desc = "The duration the damage texts stays on screen. higher amounts make it easier for the value to stack.",
                    disabled = function() return not DarkSoulsSCT.db.global.enabled; end,
                    min = 0,
                    max = 5,
                    step = .01,
                    get = function() return DarkSoulsSCT.db.global.animationDuration; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.animationDuration = newValue; end,
                    order = 2,
                    width = "full",
                },
                textSize = {
                    type = 'range',
                    name = "Text size",
                    desc = "Size of the text.",
                    disabled = function() return not DarkSoulsSCT.db.global.enabled; end,
                    min = 5,
                    max = 50,
                    step = 1,
                    get = function() return DarkSoulsSCT.db.global.textSize; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.textSize = newValue; end,
                    order = 3,
                    width = "full",
                },
                xOffset = {
                    type = 'range',
                    name = "X offset",
                    desc = "Horizontal offset of the text. Positive moves the text to the right.",
                    disabled = function() return not DarkSoulsSCT.db.global.enabled; end,
                    min = -100,
                    max = 100,
                    step = 1,
                    get = function() return DarkSoulsSCT.db.global.xOffset; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.xOffset = newValue; end,
                    order = 4,
                    width = "full",
                },
                yOffset = {
                    type = 'range',
                    name = "Y offset",
                    desc = "Vertical offset of the text. Positive moves the text upwards.",
                    disabled = function() return not DarkSoulsSCT.db.global.enabled; end,
                    min = -100,
                    max = 100,
                    step = 4,
                    get = function() return DarkSoulsSCT.db.global.yOffset; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.yOffset = newValue; end,
                    order = 5,
                    width = "full",
                },
                font = {
                    type = "select",
                    dialogControl = "LSM30_Font",
                    name = "Font",
                    order = 6,
                    values = AceGUIWidgetLSMlists.font,
                    get = function() return DarkSoulsSCT.db.global.font; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.font = newValue; end,
                },
                anchor = {
                    type = "select",
                    name = "Text anchor",
                    order = 7,
                    values = anchorValues,
                    get = function() return DarkSoulsSCT.db.global.anchor; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.anchor = newValue; end,
                },
            },
        },
        formatting = {
            type = 'group',
            name = "Formatting",
            order = 30,
            inline = true,
            disabled = function() return not DarkSoulsSCT.db.global.enabled; end;
            args = {
                formatEnabled = {
                    type = 'toggle',
                    name = "Enable formatting",
                    desc = "Enables formatting of the damage text",
                    
                    get = function() return DarkSoulsSCT.db.global.format.enabled; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.format.enabled = newValue; end,
                    order = 1,
                    width = "full",
                },
                separatorEnabled = {
                    type = 'toggle',
                    name = "Enable separator",
                    desc = "Formats the damage numbers where a value of '1255385' becomes '1,255,385' instead",
                    disabled = function() return not DarkSoulsSCT.db.global.format.enabled; end;
                    get = function() return DarkSoulsSCT.db.global.format.separatorEnabled; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.format.separatorEnabled = newValue; end,
                    order = 2,
                    width = "full",
                },
                thousandEnabled = {
                    type = 'toggle',
                    name = "Enable thousand formatter",
                    desc = "Formats the damage numbers where a value of '1255385' becomes '1,255k' instead",
                    disabled = function() return not DarkSoulsSCT.db.global.format.enabled; end;
                    get = function() return DarkSoulsSCT.db.global.format.thousandEnabled; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.format.thousandEnabled = newValue; end,
                    order = 2,
                    width = "full",
                },
            },
        },
    },
};

function DarkSoulsSCT:OpenMenu()
    --blizzard open menu bug fix, calling twice
    InterfaceOptionsFrame_OpenToCategory(self.menu);
    InterfaceOptionsFrame_OpenToCategory(self.menu);
end

function DarkSoulsSCT:RegisterMenu()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DarkSoulsSCT", menu);
    self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DarkSoulsSCT", "DarkSoulsSCT");
end