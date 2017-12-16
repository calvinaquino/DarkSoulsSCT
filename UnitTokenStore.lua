--small manager/helper for keeping track of units and their respective guids
UnitTokenStore = {
    guids = {},
    units = {},
};

-- store
function UnitTokenStore:store(unit, guid)
    self.units[guid] = unit;
    self.guids[unit] = guid;
end

-- get
function UnitTokenStore:guidForUnit(unit)
    return self.guids[unit];
end

function UnitTokenStore:unitForGuid(guid)
    return self.units[guid];
end

-- remove
function UnitTokenStore:removeForGuid(guid)
    local unit = self.units[guid];
    self.units[guid] = nil;
    self.guids[unit] = nil;
end

function UnitTokenStore:removeForUnit(unit)
    local guid = self.guids[unit];
    self.units[guid] = nil;
    self.guids[unit] = nil;
end

function UnitTokenStore:clear()
    for guid, unit in pairs(self.units) do
        self.units[guid] = nil;
        self.guids[unit] = nil;
    end
end