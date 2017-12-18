

-- LOCALS --


--used to be able to sum damage amounts if you damage the same unit in less time than a fontstring stays on screen.
local lastAmount = 0;


-- HELPERS --


local function powSizing(elapsed, duration, start, middle, finish)
    local size = finish;
    if (elapsed < duration) then
        if (elapsed/duration < 0.5) then
            size = LibEasing.OutQuint(elapsed, start, middle - start, duration/2);
        else
            size = LibEasing.InQuint(elapsed - elapsed/2, middle, finish - middle, duration/2);
        end
    end
    return size;
end

local function getFontPath(fontName)
    local fontPath = SharedMedia:Fetch("font", fontName);
    if (fontPath == nil) then
        fontPath = "Fonts\\FRIZQT__.TTF";
    end
    return fontPath;
end

local function colored(string)
    return "|Cff"..DarkSoulsSCT.db.global.color..string.."|r";
end


-- CORE --


function DarkSoulsSCT:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("DarkSoulsSCTDB", Defaults, true);

    self:RegisterChatCommand("dssct", "OpenMenu");
    self:RegisterMenu();

    if (self.db.global.enabled == false) then
        self:Disable();
    end
end

function DarkSoulsSCT:OnEnable()
    playerGUID = UnitGUID("player");

    self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

    self.db.global.enabled = true;
end

function DarkSoulsSCT:OnDisable()
    self:UnregisterAllEvents();

    FontStringsCache:clear();

    self.db.global.enabled = false;
end


-- EVENTS --


function DarkSoulsSCT:NAME_PLATE_UNIT_ADDED(event, unit)
    local guid = UnitGUID(unit);
    UnitTokenStore:store(unit, guid);
end

function DarkSoulsSCT:NAME_PLATE_UNIT_REMOVED(event, unit)
    UnitTokenStore:removeForUnit(unit);
end

function DarkSoulsSCT:COMBAT_LOG_EVENT_UNFILTERED(event, time, cle, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    petGUID = UnitGUID("pet");
    local petDamageDoneValid = petGUID == sourceGUID and self.db.global.petDamageDone;
    local playerDamageTakenValid = playerGUID == destGUID and self.db.global.playerDamageTaken;
    local playerDamageDoneValid = playerGUID == sourceGUID;
    if (playerDamageDoneValid or playerDamageTakenValid or petDamageDoneValid) then
        if (string.find(cle, "_DAMAGE")) then
            local spellId, spellName, spellSchool, damage, overkill, school, resisted, blocked, absorbed, critical;
            if (string.find(cle, "SWING")) then
                spellName, damage, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = "melee", ...;
            else
                spellID, spellName, spellSchool, damage, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...;
            end
            self:DamageEvent(sourceGUID, destGUID, damage, critical);
        end
    end
end


-- TEXT --


function DarkSoulsSCT:DamageEvent(sourceGUID, destGUID, amount, isCrit)
    amount = amount + lastAmount;
    lastAmount = amount;
    local text = nil;
    if self.db.global.usesPercentage then
        local unit = UnitTokenStore:unitForGuid(destGUID);
        if (not unit) then
            return;
        end
        local maxHealth = UnitHealthMax(unit);
        local percent = amount / maxHealth * 100;
        text = string.format("%.1f%%", percent);
    else
        local thousand = amount > 1000;
        if (thousand) then
            amount = amount / 1000;
        end

        text = string.format("%.0f", amount);
        if (thousand) then
            text = text.."k";
        end
    end
    text = colored(text);
    self:DisplayDamage(destGUID, text, isCrit);
end


-- ANIMATION --


local function OnUpdate()
    if (next(FontStringManager.running)) then
        for guid, fontString in pairs(FontStringManager.running) do
            local elapsed = GetTime() - fontString.animationStartTime;
            if (elapsed > fontString.animationDuration) then
                FontStringManager:releaseForGuid(guid);
                lastAmount = 0;
            else
                local alpha = LibEasing.InExpo(elapsed, 1.0, -1.0, fontString.animationDuration);
                fontString:SetAlpha(alpha);

                if (fontString.pow) then
                    if (elapsed < fontString.animationDuration/6) then
                        local size = powSizing(elapsed, fontString.animationDuration/6, fontString.startHeight/2, fontString.startHeight*1.5, fontString.startHeight);
                        fontString:SetTextHeight(size);
                    else
                        fontString.pow = nil;
                        fontString:SetTextHeight(fontString.startHeight);
                        fontString:SetFont(getFontPath(DarkSoulsSCT.db.global.font), DarkSoulsSCT.db.global.textSize, "OUTLINE");
                    end
                end

                --local isTarget = UnitIsUnit(fontString.unit, "target");
                local unit = UnitTokenStore:unitForGuid(guid);
                local nameplate = NameplatesStore:getForUnit(unit);
                
                fontString:SetPoint("CENTER", fontString.anchorFrame, "CENTER", DarkSoulsSCT.db.global.xOffset, DarkSoulsSCT.db.global.yOffset);
                if (unit and nameplate) then
                    local xOffset, yOffset = fontString:GetCenter();
                    fontString:SetPoint("CENTER", fontString.anchorFrame, "CENTER", DarkSoulsSCT.db.global.xOffset + xOffset, DarkSoulsSCT.db.global.yOffset + yOffset);
                end
            end
        end
    else
        DarkSoulsSCT.frame:SetScript("OnUpdate", nil);
    end
end

-- DISPLAY --

function DarkSoulsSCT:DisplayDamage(guid, text, isCrit)
    local fontString;
    local unit = UnitTokenStore:unitForGuid(guid);
    local nameplate;

    if (unit) then
        nameplate = C_NamePlate.GetNamePlateForUnit(unit);
    end

    fontString = FontStringManager:newForGuid(guid);
    fontString:SetParent(DarkSoulsSCT.frame);
    fontString:SetFont(getFontPath(DarkSoulsSCT.db.global.font), DarkSoulsSCT.db.global.textSize, "OUTLINE");
    fontString:SetAlpha(1);
    fontString:SetDrawLayer("OVERLAY");
    fontString:SetText(text);
    fontString:Show();

    fontString.startHeight = fontString:GetStringHeight();
    fontString.pow = isCrit;

    fontString.animationDuration = self.db.global.animationDuration;
    fontString.animationStartTime = GetTime();
    fontString.anchorFrame = nameplate;

    if (DarkSoulsSCT.frame:GetScript("OnUpdate") == nil) then
        DarkSoulsSCT.frame:SetScript("OnUpdate", OnUpdate);
    end
end
