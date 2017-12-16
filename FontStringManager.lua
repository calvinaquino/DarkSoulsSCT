--fontstring manager for in use fontstrings. basically the inverse of the cache.
--this guy holds refrence to fontstrings in use, and is able to create them dynamically.
--the manager also is responsible for reusing the currently visible fontstring so they dont overlap.
--basically the number of running fontstrings cannot exceed the number of visible nameplates.
FontStringManager = {
    running = {},
}

function FontStringManager.visibleForGuid(manager, guid)
    return manager.running[guid];
end

function FontStringManager.newForGuid(manager, guid)
    local fontString = nil;
    -- check if there are fontstrings currently running for that guid
    fontString = manager.running[guid];
    if (not fontString) then
        -- no fontstrings running for that guid;
        -- check if there are available fontstrings in the cache
        fontString = FontStringsCache:pop();
    end
    if (not fontString) then
        -- no cached fontstrings;
        -- create one and put on the store
        fontString = DarkSoulsSCT.frame:CreateFontString();
        manager.running[guid] = fontString;
    end

    return fontString;
end
function FontStringManager.releaseForGuid(manager, guid)
    local fontString = manager.running[guid];
    -- hide / cleanup
    fontString:Hide();
    FontStringsCache:store(fontString);
    manager.running[guid] = nil;
end

function FontStringManager.clear(manager)
    for guid, _ in pairs(manager.running) do
        manager.running[guid] = nil;
    end
end