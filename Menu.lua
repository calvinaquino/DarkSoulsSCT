

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
    [1] = "Target Health",
    [2] = "Player Base Health",
};

-- MENU FUNCTIONS

local function setDarsSoulsSCTEnabled(_, newValue)
    if (not newValue) then
        DarkSoulsSCT:Disable();
    else
        DarkSoulsSCT:Enable();
    end
end

local function isDarkSoulsSCTDisabled()
    return not DarkSoulsSCT.db.global.enabled;
end

local function setCVarValue(cvar, value)
    if (value) then
        SetCVar(cvar, "0");
    else
        SetCVar(cvar, "1");
    end
end

-- MENU OPTIONS

local menu = {
    name = "DarkSoulsSCT",
    handler = DarkSoulsSCT,
    type = 'group',
    args = {
        enable = {
            type = 'toggle',
            name = "Enable",
            desc = "Enables or disables Dark Souls Scrolling Combag Text",
            get = function(_, newValue) return DarkSoulsSCT:IsEnabled() end,
            set = setDarsSoulsSCTEnabled,
            order = 1,
            width = "half",
        },
        blizzardDisableFCT = {
            type = 'group',
            name = "Disable Blizzard Floating Combat Texts",
            desc = "",
            inline = true,
            order = 2,
            args = {
                damage = {
                    type = 'toggle',
                    name = "Damage",
                    desc = "Disables damage floating combat text on others",
                    get = function(_, newValue) return GetCVar("floatingCombatTextCombatDamage") == "0" end,
                    set = function(_, newValue) setCVarValue("floatingCombatTextCombatDamage", newValue) end,
                    order = 1,
                },
                self = {
                    type = 'toggle',
                    name = "Self",
                    desc = "Disables floating combat text on self",
                    get = function(_, newValue) return GetCVar("enableFloatingCombatText") == "0" end,
                    set = function(_, newValue) setCVarValue("enableFloatingCombatText", newValue) end,
                    order = 2,
                },
                healing = {
                    type = 'toggle',
                    name = "Healing",
                    desc = "Disables healing floating combat text on others",
                    get = function(_, newValue) return GetCVar("floatingCombatTextCombatHealing") == "0" end,
                    set = function(_, newValue) setCVarValue("floatingCombatTextCombatHealing", newValue) end,
                    order = 3,
                },
                autos = {
                    type = 'toggle',
                    name = "Auto Attacks",
                    desc = "Disables auto attack floating combat text",
                    get = function(_, newValue) return GetCVar("floatingCombatTextCombatDamageAllAutos") == "0" end,
                    set = function(_, newValue) setCVarValue("floatingCombatTextCombatDamageAllAutos", newValue) end,
                    order = 4,
                },
                healingAbsorb = {
                    type = 'toggle',
                    name = "Healing Absorb",
                    desc = "Disables healing absorb floating combat text on others",
                    get = function(_, newValue) return GetCVar("floatingCombatTextCombatHealingAbsorbTarget") == "0" end,
                    set = function(_, newValue) setCVarValue("floatingCombatTextCombatHealingAbsorbTarget", newValue) end,
                    order = 5,
                },
                healingAbsorbSelf = {
                    type = 'toggle',
                    name = "Healing Absorb Self",
                    desc = "Disables healing absorb floating combat text on others",
                    get = function(_, newValue) return GetCVar("floatingCombatTextCombatHealingAbsorbSelf") == "0" end,
                    set = function(_, newValue) setCVarValue("floatingCombatTextCombatHealingAbsorbSelf", newValue) end,
                    order = 6,
                },
                petDamage = {
                    type = 'toggle',
                    name = "Pet Damage",
                    desc = "Disable pet melee damage floating combat text",
                    get = function(_, newValue) return GetCVar("floatingCombatTextPetMeleeDamage") == "0" end,
                    set = function(_, newValue) setCVarValue("floatingCombatTextPetMeleeDamage", newValue) end,
                    order = 7,
                },
                petSpellDamage = {
                    type = 'toggle',
                    name = "Pet Spell Damage",
                    desc = "Disable pet spell damage floating combat text",
                    get = function(_, newValue) return GetCVar("floatingCombatTextPetSpellDamage") == "0" end,
                    set = function(_, newValue) setCVarValue("floatingCombatTextPetSpellDamage", newValue) end,
                    order = 8,
                },
            },
        },
        mode = {
            type = 'group',
            name = "Mode",
            order = 9,
            inline = true,
            disabled = isDarkSoulsSCTDisabled,
            args = {
                scaledMode = {
                    type = 'select',
                    name = "Scoring mode",
                    disabled = function() return not DarkSoulsSCT.db.global.enabled; end;
                    desc = "Changes how the damage value is calculated/shown.\n\nDefault: Value is the default Blizzard's implementation.\n\nTarget Health: Value is shown as a percent of the target's max heath.\n\nPlayer Base Health: Value is based on the player character's base health. This option is for those that dont like blizzard's auto scaling or iLvL power creep effect on your damage numbers, so the player can have a real feedback on power progression of the character relative to his base stats for that level.",
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
            disabled = isDarkSoulsSCTDisabled,
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
            disabled = isDarkSoulsSCTDisabled,
            args = {
                target = {
                    type = 'group',
                    name = "Target",
                    order = 1,
                    inline = true,
                    args = {
                        defaultColor = {
                            type = 'color',
                            name = "Text color",
                            desc = "",
                            disabled = isDarkSoulsSCTDisabled,
                            hasAlpha = false,
                            set = function(_, r, g, b) DarkSoulsSCT.db.global.target.color = rgbToHex(r, g, b); end,
                            get = function() return hexToRGB(DarkSoulsSCT.db.global.target.color); end,
                            order = 2,
                        },
                        textDuration = {
                            type = 'range',
                            name = "Text duration",
                            desc = "The duration the damage texts stays on screen. higher amounts make it easier for the value to stack.",
                            disabled = isDarkSoulsSCTDisabled,
                            min = 0,
                            max = 5,
                            step = .01,
                            get = function() return DarkSoulsSCT.db.global.target.animationDuration; end,
                            set = function(_, newValue) DarkSoulsSCT.db.global.target.animationDuration = newValue; end,
                            order = 2,
                            width = "full",
                        },
                        textSize = {
                            type = 'range',
                            name = "Text size",
                            desc = "Size of the text.",
                            disabled = isDarkSoulsSCTDisabled,
                            min = 5,
                            max = 50,
                            step = 1,
                            get = function() return DarkSoulsSCT.db.global.target.textSize; end,
                            set = function(_, newValue) DarkSoulsSCT.db.global.target.textSize = newValue; end,
                            order = 3,
                            width = "full",
                        },
                        xOffset = {
                            type = 'range',
                            name = "X offset",
                            desc = "Horizontal offset of the text. Positive moves the text to the right.",
                            disabled = isDarkSoulsSCTDisabled,
                            min = -100,
                            max = 100,
                            step = 1,
                            get = function() return DarkSoulsSCT.db.global.target.xOffset; end,
                            set = function(_, newValue) DarkSoulsSCT.db.global.target.xOffset = newValue; end,
                            order = 4,
                            width = "full",
                        },
                        yOffset = {
                            type = 'range',
                            name = "Y offset",
                            desc = "Vertical offset of the text. Positive moves the text upwards.",
                            disabled = isDarkSoulsSCTDisabled,
                            min = -100,
                            max = 100,
                            step = 4,
                            get = function() return DarkSoulsSCT.db.global.target.yOffset; end,
                            set = function(_, newValue) DarkSoulsSCT.db.global.target.yOffset = newValue; end,
                            order = 5,
                            width = "full",
                        },
                        anchor = {
                            type = "select",
                            name = "Text anchor",
                            disabled = isDarkSoulsSCTDisabled,
                            order = 7,
                            values = anchorValues,
                            get = function() return DarkSoulsSCT.db.global.target.anchor; end,
                            set = function(_, newValue) DarkSoulsSCT.db.global.target.anchor = newValue; end,
                        },
                    },
                },
                self = {
                    type = 'group',
                    name = "Self",
                    order = 2,
                    inline = true,
                    args = {
                        defaultColor = {
                            type = 'color',
                            name = "Text color",
                            desc = "",
                            disabled = isDarkSoulsSCTDisabled,
                            hasAlpha = false,
                            set = function(_, r, g, b) DarkSoulsSCT.db.global.self.color = rgbToHex(r, g, b); end,
                            get = function() return hexToRGB(DarkSoulsSCT.db.global.self.color); end,
                            order = 2,
                        },
                        textDuration = {
                            type = 'range',
                            name = "Text duration",
                            desc = "The duration the damage texts stays on screen. higher amounts make it easier for the value to stack.",
                            disabled = isDarkSoulsSCTDisabled,
                            min = 0,
                            max = 5,
                            step = .01,
                            get = function() return DarkSoulsSCT.db.global.self.animationDuration; end,
                            set = function(_, newValue) DarkSoulsSCT.db.global.self.animationDuration = newValue; end,
                            order = 2,
                            width = "full",
                        },
                        textSize = {
                            type = 'range',
                            name = "Text size",
                            desc = "Size of the text.",
                            disabled = isDarkSoulsSCTDisabled,
                            min = 5,
                            max = 50,
                            step = 1,
                            get = function() return DarkSoulsSCT.db.global.self.textSize; end,
                            set = function(_, newValue) DarkSoulsSCT.db.global.self.textSize = newValue; end,
                            order = 3,
                            width = "full",
                        },
                        xOffset = {
                            type = 'range',
                            name = "X offset",
                            desc = "Horizontal offset of the text. Positive moves the text to the right.",
                            disabled = isDarkSoulsSCTDisabled,
                            min = -100,
                            max = 100,
                            step = 1,
                            get = function() return DarkSoulsSCT.db.global.self.xOffset; end,
                            set = function(_, newValue) DarkSoulsSCT.db.global.self.xOffset = newValue; end,
                            order = 4,
                            width = "full",
                        },
                        yOffset = {
                            type = 'range',
                            name = "Y offset",
                            desc = "Vertical offset of the text. Positive moves the text upwards.",
                            disabled = isDarkSoulsSCTDisabled,
                            min = -100,
                            max = 100,
                            step = 4,
                            get = function() return DarkSoulsSCT.db.global.self.yOffset; end,
                            set = function(_, newValue) DarkSoulsSCT.db.global.self.yOffset = newValue; end,
                            order = 5,
                            width = "full",
                        },
                        anchor = {
                            type = "select",
                            name = "Text anchor",
                            disabled = isDarkSoulsSCTDisabled,
                            order = 7,
                            values = anchorValues,
                            get = function() return DarkSoulsSCT.db.global.self.anchor; end,
                            set = function(_, newValue) DarkSoulsSCT.db.global.self.anchor = newValue; end,
                        },
                    },
                },
                font = {
                    type = "select",
                    dialogControl = "LSM30_Font",
                    name = "Font",
                    disabled = isDarkSoulsSCTDisabled,
                    order = 7,
                    values = AceGUIWidgetLSMlists.font,
                    get = function() return DarkSoulsSCT.db.global.font; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.font = newValue; end,
                },
                factor = {
                    type = 'range',
                    name = "Factor",
                    desc = "The factor the damage number is scaled by.",
                    disabled = isDarkSoulsSCTDisabled,
                    min = 0.01,
                    max = 1000,
                    step = .01,
                    get = function() return DarkSoulsSCT.db.global.factor; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.factor = newValue; end,
                    order = 8,
                    width = "full",
                },
            },
        },
        formatting = {
            type = 'group',
            name = "Formatting",
            order = 30,
            inline = true,
            disabled = isDarkSoulsSCTDisabled,
            args = {
                formatEnabled = {
                    type = 'toggle',
                    name = "Enable formatting",
                    desc = "Enables formatting of the damage text",
                    disabled = isDarkSoulsSCTDisabled,
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
                percentEnabled = {
                    type = 'toggle',
                    name = "Enable percent",
                    desc = "Appends a % to the end of the damage number",
                    disabled = function() return not DarkSoulsSCT.db.global.format.enabled; end;
                    get = function() return DarkSoulsSCT.db.global.format.percentEnabled; end,
                    set = function(_, newValue) DarkSoulsSCT.db.global.format.percentEnabled = newValue; end,
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