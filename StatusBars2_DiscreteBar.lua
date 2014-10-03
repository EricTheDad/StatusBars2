-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally


local groups = addonTable.groups;
local bars = addonTable.bars;

-- Bar types
local kHealth = addonTable.barTypes.kHealth;
local kPower = addonTable.barTypes.kPower;
local kAura = addonTable.barTypes.kAura;
local kAuraStack = addonTable.barTypes.kAuraStack;
local kCombo = addonTable.barTypes.kCombo;
local kRune = addonTable.barTypes.kRune;
local kDruidMana = addonTable.barTypes.kDruidMana;
local kUnitPower = addonTable.barTypes.kUnitPower;
local kEclipse = addonTable.barTypes.kEclipse;
local kDemonicFury = addonTable.barTypes.kDemonicFury;

local kDefaultPowerBarColor = addonTable.kDefaultPowerBarColor;


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateDiscreteBar
--
--  Description:    Create a bar to track a discrete number of values.
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateDiscreteBar( key, unit, displayName, barType, boxCount )

    -- Create the bar
    local bar = StatusBars2_CreateBar( key, "StatusBars2_DiscreteBarTemplate", unit, displayName, barType );

    -- Set custom options template
    bar.optionsTemplate = "StatusBars2_AuraStatckBarOptionsTemplate";
    bar.configTemplate = "auraStackBarOptionsTabPage";

    -- Base methods for subclasses to call
    bar.DiscreteBar_OnEnable = StatusBars2_DiscreteBar_OnEnable;

    -- Override default methods as needed
    bar.OnEnable = StatusBars2_DiscreteBar_OnEnable;
    bar.GetColor = StatusBars2_GetDiscreteBarColor;

    -- Bar starts off with no boxes created.
    bar.boxCount = 0;

    -- Now create the number of boxes initially requested.  We may create more or hide
    -- some in the future, depending on spec/glyph/talent changes.
    StatusBars2_SetDiscreteBarBoxCount( bar, boxCount );

    return bar;

end;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_SetDiscreteBarBoxCount
--
--  Description:    Adjusts the number of boxes on a discrete bar.
--
-------------------------------------------------------------------------------
--
function StatusBars2_SetDiscreteBarBoxCount( bar, boxCount )

    if ( bar.boxCount ~= boxCount ) then
        StatusBars2_CreateDiscreteBarBoxes( bar, boxCount );
        StatusBars2_AdjustDiscreteBarBoxes( bar, boxCount );
    end
end;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateDiscreteBarBoxes
--
--  Description:    Creates boxes on a discrete bar.
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateDiscreteBarBoxes( bar, desiredBoxCount )

    assert( desiredBoxCount < 20, "Way too many discrete boxes" );
    
    local boxes = { bar:GetChildren( ) };
    local boxesAvailableCount = #boxes;

    if ( boxesAvailableCount < desiredBoxCount ) then

        local name = bar:GetName( );

        -- Initialize the boxes
        local i;
        for i = boxesAvailableCount + 1, desiredBoxCount do
            local boxName = name .. '_Box' .. i;
            local statusName = name .. '_Box' .. i .. '_Status';
            local box = CreateFrame( "Frame", boxName, bar, "StatusBars2_DiscreteBoxTemplate" );
            local status = box:GetChildren( );
            status:SetValue( 0 );
        end
    end

end;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AdjustDiscreteBarBoxes
--
--  Description:    Adjusts the number and size of boxes visible on a discrete bar.
--
-------------------------------------------------------------------------------
--
function StatusBars2_AdjustDiscreteBarBoxes( bar, boxCount )

    bar.boxCount = boxCount;
    
    -- The boxes look too far apart if you put them side by side because the frame
    -- has a pretty wide shadow on it.  Let them overlap a bit to snuggle them to
    -- a more aesthetically pleasing spacing
    local overlap = 3;
    local statusWidthDiff = 8;
    local combinedBoxWidth = bar:GetWidth( ) + ( boxCount - 1 ) * overlap;
    local boxWidth = combinedBoxWidth / boxCount;
    local boxLeft = 0;
    
    local backdropInfo = { edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16 };
    
    -- If the box size gets below 32, the edge elements within a box start to overlap and it looks crappy.
    -- So if that happens, scale the edge size down just enough that the elements don't overlap.
    if ( boxWidth < 32 ) then

        -- With the edge smaller, we also want less overlap
        overlap = overlap * boxWidth / 32;
        statusWidthDiff = statusWidthDiff * boxWidth / 32;

        -- Recalculate box size to go with the new overlap.
        combinedBoxWidth = bar:GetWidth( ) + ( boxCount - 1 ) * overlap;
        boxWidth = combinedBoxWidth / boxCount;

        -- Now we're ready to calculate the new edge size
        backdropInfo.edgeSize = 16 * boxWidth / 32;

    end

    local boxes = { bar:GetChildren( ) };

    -- Initialize the boxes
    for i, box in ipairs(boxes) do

        box:SetBackdrop( backdropInfo );

        if ( i <= bar.boxCount ) then
            local status = box:GetChildren( );
            box:SetWidth( boxWidth );
            status:SetWidth( boxWidth - statusWidthDiff );

            -- Set the status bar to draw behind the edge frame so it doesn't overlap.
            -- This should be possible in XML, but the documentation is too sketchy for me to figure it out.
            status:SetFrameLevel( box:GetFrameLevel( ) - 1 );
            status:SetBackdropColor( 0, 0, 0, 0.85 );

            box:SetPoint( "TOPLEFT", bar, "TOPLEFT", boxLeft , 0 );
            boxLeft = boxLeft + boxWidth - overlap;
            box:Show( );
        else
            box:Hide( );
        end
    end

end;

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateDiscreteBarBoxColors
--
--  Description:    Set the color of the boxes on a discrete bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateDiscreteBarBoxColors( bar )

    local boxes = { bar:GetChildren( ) };

    -- Initialize the boxes
    for i, box in ipairs(boxes) do
        local status = box:GetChildren( );
        status:SetStatusBarColor( bar:GetColor( i ) );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateDiscreteBar
--
--  Description:    Update a discrete bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateDiscreteBar( bar, current )

    -- Update the boxes
    boxes = { bar:GetChildren( ) };
    
    -- Initialize the boxes
    for i, box in ipairs(boxes) do
    
        local status = box:GetChildren( );
       
        if i <= current then
            status:SetValue( 1 );
        else
            status:SetValue( 0 );
        end
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetDiscreteBarColor
--
--  Description:    Get the color for the boxes of a discrete bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetDiscreteBarColor( bar, boxIndex )

    if( bar.color ) then
        return unpack(bar.color);
    elseif( bar.type == kCombo ) then
        return 1, 0, 0;
    elseif( bar.type == kAuraStack ) then
        if( bar.key == "anticipation" ) then
            return 0.6, 0, 0;
        elseif( bar.key == "maelstromWeapon" ) then
            return 0, 0.5, 1;
        elseif( bar.key == "frenzy" ) then
            return 1, 0.6, 0;
        end
    else
        return StatusBars2_GetPowerBarColor( bar.powerToken );
    end

    return kDefaultPowerBarColor.r, kDefaultPowerBarColor.g, kDefaultPowerBarColor.b;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_DiscreteBar_OnEnable
--
--  Description:    Discrete bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_DiscreteBar_OnEnable( self )

    if( StatusBars2.configMode ) then

        -- Show a backdrop so we can see the bar
        self:Bar_ShowBackdrop( );

        local r, g, b = self:GetColor( );
        self:SetBackdropColor( r, g, b, 1.0 );

        -- Hide all the boxes
        for i, box in ipairs( { self:GetChildren( ) } ) do
            box:Hide( );
        end

    else

        -- Hide the backdrop if we showed it for config mode
        self:Bar_HideBackdrop( );

        -- Show all boxes that should be active in case they were hidden by config mode
        for i, box in ipairs( { self:GetChildren( ) } ) do
            if( i <= self.boxCount ) then
                box:Show( );
            end
        end

        StatusBars2_UpdateDiscreteBarBoxColors( self );

    end

    -- Call the base method
    self:Bar_OnEnable( );

end
