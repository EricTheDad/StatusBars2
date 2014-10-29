-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally

local groups = addonTable.groups;
local bars = addonTable.bars;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ShallowCopy
--
--  Description:    Shallow table copy.
--
-------------------------------------------------------------------------------
--
function StatusBars2_ShallowCopy(original)
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
--  Name:           StatusBars2_DeepCopy
--
--  Description:    Deep table copy.
--
-------------------------------------------------------------------------------
--
function StatusBars2_DeepCopy(original)
    if original then
        local copy = {}
        for k, v in pairs(original) do
            -- as before, but if we find a table, make sure we copy that too
            if type(v) == 'table' then
                v = StatusBars2_DeepCopy(v)
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

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Frame_ShowBackdrop
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2_Frame_ShowBackdrop( self )

    -- Set an edge so we can see the aura self
    local backdropInfo = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = {
            left = 5,
            right = 5,
            top = 5,
            bottom = 5
        }
    };

    self:SetBackdrop( backdropInfo );
    self:SetBackdropColor( 0, 0, 0, 0.85 );

    -- Create a font string if we don't have one
    if( self.text == nil ) then
        self.text = self:CreateFontString( );
        self.text:SetPoint("CENTER",0,0);
    end

end


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Frame_HideBackdrop
--
--  Description:    
--
-------------------------------------------------------------------------------
--
function StatusBars2_Frame_HideBackdrop( self )

    -- Get rid of the edge if it was added in config mode
    self:SetBackdrop( nil );

    -- Hide the text if it was displayed from config mode
    if ( self.text ) then
        self.text:Hide( );
    end

end

