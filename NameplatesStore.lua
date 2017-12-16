--nameplate storage and handling for keeping track of their positions.
NameplatesStore = {
    -- stored by guid
    x = {},
    y = {},
    ticker = nil,
    data = {},
};
    
function NameplatesStore:storeForGuid(guid, nameplate)
    self.data[guid] = nameplate;
end
    
function NameplatesStore:storeForUnit(unit, nameplate)
    local guid = UnitTokenStore:guidForUnit(unit);
    self.data[guid] = nameplate; 
end
    
function NameplatesStore:getForGuid(guid)
    return self.data[guid];
end
    
function NameplatesStore:getForUnit(unit) 
    local guid = UnitTokenStore:guidForUnit(unit);
    return self.data[guid];
end
    
function NameplatesStore:removeForGuid(guid)
    self.data[guid] = nil;
end
    
function NameplatesStore:removeForUnit(unit)
    local guid = UnitTokenStore:guidForUnit(unit);
    self.data[guid] = nil;
end

function NameplatesStore:startSavingPositions()
    if (not self.ticker) then
        self.ticker =  C_Timer.NewTicker(1/10, self.savePositions);
    end
end

function NameplatesStore:stopSavingPositions()
    if (self.ticker) then
        self.ticker:Cancel();
        self.ticker = nil;
    end
end

function NameplatesStore:savePositions()
    -- iterate through units
    for unit in UnitTokenStore.units do
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit);
        local guid = UnitTokenStore:guidForUnit(unit);
        if (nameplate and not UnitIsDead(unit) and nameplate:IsShown()) then
            local fontString = FontStringManager:visibleForGuid(guid);
            fontString:SetPoint("CENTER", nameplate, "CENTER", 0, 0);
            self.x[guid], self.y[guid] = fontString:GetCenter();
        end
    end
end

function NameplatesStore:clear()
    for guid, _ in pairs(self.data) do
        self.x[guid] = nil;
        self.y[guid] = nil;
        self.data[guid] = nil;
    end
    self:stopSavingPositions();
end