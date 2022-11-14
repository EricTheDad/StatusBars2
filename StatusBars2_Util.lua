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
function StatusBars2_Round(x, places)
    local mult = 10 ^ (places or 0)
    return x and (floor(x * mult + 0.5) / mult) or x;
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_Frame_ShowBackdrop
--
--  Description:
--
-------------------------------------------------------------------------------
--
function StatusBars2_Frame_ShowBackdrop(self)
    
    if (self.SetBackdrop) then
        self:SetBackdrop();
        self:SetBackdropColor(0, 0, 0, 0.85);
    end
    
    -- Create a font string if we don't have one
    if (self.text == nil) then
        self.text = self:CreateFontString();
        self.text:SetPoint("CENTER", 0, 0);
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
function StatusBars2_Frame_HideBackdrop(self)
    
    -- Get rid of the edge if it was added in config mode
    if (self.ClearBackdrop) then
        self:ClearBackdrop();
    end
    
    -- Hide the text if it was displayed from config mode
    if (self.text) then
        self.text:Hide();
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SetupFontString
--
--  Description:
--
-------------------------------------------------------------------------------
--
function StatusBars2_SetupFontString(fontString, string_id)
    
    fontString:SetText(StatusBars2_GetLocalizedText(string_id));
    fontString:SetHeight(fontString:GetStringHeight());

end

function dump(o, max_depth)
   if not max_depth then
    max_depth = 5;
    end

   if max_depth > 0 and type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v, max_depth - 1) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function print_dump(o)
   if type(o) == 'table' then
      for k,v in pairs(o) do
        print (k, " - ", v)
      end
   else
      return tostring(o)
   end
end