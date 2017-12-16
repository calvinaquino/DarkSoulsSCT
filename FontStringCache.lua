--a stack cache for reusing fontstrings.
--we keep track of size manually because the way lua counts a table length is weird.
FontStringsCache = {
    size = 0,
    data = {},
};

--stores a fontstring into the cache data and increases the size
function FontStringsCache.store(cache, fontString)
    cache.size = cache.size + 1;
    cache[cache.size] = fontString;
end

--pops out the last cached fontstring for reuse. returns nil if there are no cached fontstrings.
function FontStringsCache.pop(cache)
    local cachedFontString = nil;
    local size = cache.size;
    if (size > 0) then
        cachedFontString = cache.data[size];
        cache.size = size - 1;
    end
    return cachedFontString;
end

function FontStringsCache.clear(cache)
    cache.data = {};
    cache.size = 0;
end

--improvements: schedule a timer to nil some data of the cache after a time.
--reasoning: if you aoe a bit and then stops for a time, you will have a full cache.
--you will might end up not aoeing and utilizing only a small part of the cache.
--i need to check the impact of keeping a big cache vs cleaning some data (not all) at intervals