-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally



-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Trace
--
--  Description:    Trace a message to the console
--
-------------------------------------------------------------------------------
--
function StatusBars2_Trace( message )
    DEFAULT_CHAT_FRAME:AddMessage( message );
end

-------------------------------------------------------------------------------
--
--  Name:
--
--  Description:    Trace a message to the console
--
-------------------------------------------------------------------------------
--
function safePrint( value )
    if value then
        return value;
    else
        return "nil";
    end
end

-------------------------------------------------------------------------------
--
--  Name:
--
--  Description:    Trace a message to the console
--
-------------------------------------------------------------------------------
--
function printBool( boolVal )
    if boolVal then
        return "true";
    else
        return "false";
    end
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
    return floor( x * mult + 0.5 ) / mult
end
