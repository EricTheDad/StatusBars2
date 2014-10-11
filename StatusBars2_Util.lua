-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally

local groups = addonTable.groups;
local bars = addonTable.bars;

-------------------------------------------------------------------------------
--
--  Name:           shallowCopy
--
--  Description:    Shallow table copy.
--
-------------------------------------------------------------------------------
--
function shallowCopy(original)
    if original then
        local copy = {}
        for key, value in pairs(original) do
            copy[key] = value
        end
        return copy
    end
    -- intentionally returning nil if original was nil
end

-------------------------------------------------------------------------------
--
--  Name:           deepCopy
--
--  Description:    Deep table copy.
--
-------------------------------------------------------------------------------
--
function deepCopy(original)
    if original then
        local copy = {}
        for k, v in pairs(original) do
            -- as before, but if we find a table, make sure we copy that too
            if type(v) == 'table' then
                v = deepCopy(v)
            end
            copy[k] = v
        end
        return copy
    end
    -- intentionally returning nil if original was nil
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Round
--
--  Description:    Round a number
--
-------------------------------------------------------------------------------
--
function StatusBars2_Round( x, places )
    local mult = 10 ^  ( places or 0 )
    return x and (floor( x * mult + 0.5 ) / mult) or x;
end
