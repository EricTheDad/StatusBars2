-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally


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

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateAuraBar
--
--  Description:    Create a bar to display the auras on a unit
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateAuraBar( key, unit )

    local barType = kAura;
    local displayName = StatusBars2_ConstructDisplayName( unit, barType );

    -- Create the bar
    local bar = StatusBars2_CreateBar( key, "StatusBars2_AuraBarTemplate", unit, displayName, barType );

    -- Set the options template
    bar.optionsTemplate = "StatusBars2_AuraBarOptionsTemplate";

    -- Initialize the button array
    bar.buttons = {};

    -- Set the event handlers
    bar.OnEvent = StatusBars2_AuraBar_OnEvent;
    bar.OnEnable = StatusBars2_AuraBar_OnEnable;
    bar.BarIsVisible = StatusBars2_AuraBar_IsVisible;
    bar.IsDefault = StatusBars2_AuraBar_IsDefault;
    bar.SetBarScale = StatusBars2_AuraBar_SetScale;
    bar.SetBarPosition = StatusBars2_AuraBar_SetPosition;
    bar.GetBarHeight = StatusBars2_AuraBar_GetHeight;

    -- Register for events
    bar:RegisterEvent( "UNIT_AURA" );
    bar:RegisterEvent( "PLAYER_REGEN_ENABLED" );
    bar:RegisterEvent( "PLAYER_REGEN_DISABLED" );
    if( unit == "target" ) then
        bar:RegisterEvent( "PLAYER_TARGET_CHANGED" );
    elseif( unit == "focus" ) then
        bar:RegisterEvent( "PLAYER_FOCUS_CHANGED" );
    elseif( unit == "pet" ) then
        bar:RegisterEvent( "UNIT_PET" );
    end

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_OnEvent
--
--  Description:    Aura bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_OnEvent( self, event, ... )

    -- Aura changed
    if( event == "UNIT_AURA" ) then
        local arg1 = ...;
        if( arg1 == self.unit ) then
            StatusBars2_UpdateAuraBar( self );
        end

    -- Target changed
    elseif( event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" or event == "UNIT_PET" ) then
        if( self:BarIsVisible( ) ) then
            StatusBars2_UpdateAuraBar( self );
        end

    -- Entering combat
    elseif( event == 'PLAYER_REGEN_DISABLED' ) then
        self.inCombat = true;

    -- Exiting combat
    elseif( event == 'PLAYER_REGEN_ENABLED' ) then
        self.inCombat = false;
    end;

    -- Update visibility
    if( self:BarIsVisible( ) ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_OnEnable
--
--  Description:    Aura bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_OnEnable( self )

    StatusBars2_UpdateAuraBar( self );
    StatusBars2_StatusBar_OnEnable( self );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_IsVisible
--
--  Description:    Determine if an aura bar is visible
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_IsVisible( self )

    return StatusBars2_StatusBar_IsVisible( self ) and ( UnitExists( self.unit ) and not UnitIsDeadOrGhost( self.unit ) );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_IsDefault
--
--  Description:    Determine if a bar is in its default state
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_IsDefault( self )

    -- No need to check, if there are no auras the bar will be empty anyway
    return false;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_SetScale
--
--  Description:    Set the bar scale
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_SetScale( self, scale )

    self:SetScale( scale );
 
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_SetPosition
--
--  Description:    Set the bar position
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_SetPosition( self, x, y )

        StatusBars2_StatusBar_SetPosition( self, x, y );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraBar_GetHeight
--
--  Description:    Get the bar height
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraBar_GetHeight( self )

    return self:GetHeight( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_UpdateAuraBar
--
--  Description:    Update an aura bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_UpdateAuraBar( self )

    -- If dragging have to cancel before hiding the buttons
    if( self.isMoving ) then
        StatusBars2_StatusBar_OnMouseUp( self, "LeftButton" );
    end

    -- Button offset
    local offset = 2;

    -- Hide all the buttons
    for name, button in pairs( self.buttons ) do
        button:Hide( );
    end

    -- Buffs
    if( StatusBars2_Settings.bars[ self.key ].showBuffs ) then
        offset = StatusBars2_ShowAuraButtons( self, "Buff", UnitBuff, MAX_TARGET_BUFFS, StatusBars2_Settings.bars[ self.key ].onlyShowSelf, offset );
    end

    -- Debuffs
    if( StatusBars2_Settings.bars[ self.key ].showDebuffs ) then

        -- Add a space between the buffs and the debuffs
        if( offset > 2 ) then
            offset = offset + StatusBars2_GetAuraSize( self );
        end

        offset = StatusBars2_ShowAuraButtons( self, "Debuff", UnitDebuff, MAX_TARGET_DEBUFFS, StatusBars2_Settings.bars[ self.key ].onlyShowSelf, offset );

    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_ShowAuraButtons
--
--  Description:    Show buff or debuff buttons (icons)
--
-------------------------------------------------------------------------------
--
function StatusBars2_ShowAuraButtons( self, auraType, getAuraFunction, maxAuras, mineOnly, offset )

    local playerIsTarget = UnitIsUnit(PlayerFrame.unit, self.unit);

    -- Iterate over the unit auras
    for i = 1, maxAuras do

        -- Get the aura
        local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable,_, spellID = getAuraFunction( self.unit, i );


        -- If the aura exists show it
        if( icon ~= nil ) then

            --print(name..": "..spellID);

            -- Determine if the button should be shown
            if( ( caster == "player" or not mineOnly ) and ( duration > 0 or not StatusBars2_Settings.bars[ self.key ].onlyShowTimed ) ) then

                if( not StatusBars2_Settings.bars[ self.key ].onlyShowListed
                or ( StatusBars2_Settings.bars[ self.key ].auraFilter and StatusBars2_Settings.bars[ self.key ].auraFilter[ name ] )) then
                    -- Get the button
                    local buttonName = self:GetName( ) .. "_" .. auraType .. "Button" .. i;
                    local button = StatusBars2_GetAuraButton( self, i, buttonName, "Target" .. auraType .. "FrameTemplate", name, rank, icon, count, debuffType, duration, expirationTime, offset );

                    -- Update the offset
                    offset = offset + button:GetWidth( ) + 2;
                
                    -- Show the button
                    button:Show( );
                end
            end
        else
            break;
        end
    end

    return offset;
end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetAuraButton
--
--  Description:    Get an aura button for this bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetAuraButton( self, id, buttonName, template, auraName, auraRank, auraIcon, auraCount, debuffType, auraDuration, auraExpirationTime, offset )

    -- Get the button
    local button = self.buttons[ buttonName ];

    -- If the button does not exist create it
    if( button == nil ) then
        button = CreateFrame( "Button", buttonName, self, template );
        button:SetSize( StatusBars2_GetAuraSize( self ), StatusBars2_GetAuraSize( self ) );
        button:SetScript( "OnMouseDown", StatusBars2_AuraButton_OnMouseDown );
        button:SetScript( "OnMouseUp", StatusBars2_AuraButton_OnMouseUp );

        button.DefaultOnEnter = button:GetScript( "OnEnter" );
        button.DefaultOnLeave = button:GetScript( "OnLeave" );
        button:SetScript( "OnEnter", StatusBars2_AuraButton_OnEnter );
        button:SetScript( "OnLeave", StatusBars2_AuraButton_OnLeave );

        -- Set the ID
        button:SetID( id );

        -- Set the parent bar
        button.parentBar = self;

        -- This prevents the icon text from falling off the button when we scale.
        local buttonCount = _G[ buttonName .."Count" ];
        buttonCount:SetAllPoints();
        buttonCount:SetJustifyV("BOTTOM");

        -- Add the finished button to the bar
        self.buttons[ buttonName ] = button;
    end

    -- Set the unit
    button.unit = self.unit;

    -- Set the icon
    local buttonIcon = _G[ buttonName .. "Icon" ];
    buttonIcon:SetTexture( auraIcon );

    -- Set the count
    local buttonCount = _G[ buttonName .."Count" ];
    if( auraCount > 1 ) then
        buttonCount:SetText( auraCount );
        buttonCount:Show( );
    else
        buttonCount:Hide( );
    end

    -- Set the cooldown
    local buttonCooldown = _G[ buttonName .. "Cooldown" ];
    if( auraDuration > 0 ) then
        buttonCooldown:Show( );
        CooldownFrame_SetTimer( buttonCooldown, auraExpirationTime - auraDuration, auraDuration, 1 );
    else
        buttonCooldown:Hide( );
    end

    -- Set the position
    button:SetPoint( "TOPLEFT", self, "TOPLEFT", offset, 0 );

    -- Enable/disable mouse for moving or tooltips
    button:EnableMouse( StatusBars2_Settings.bars[ self.key ].enableTooltips or not StatusBars2_Settings.locked );

    -- If its a debuff set the border size and color
    if( template == "TargetDebuffFrameTemplate" ) then

        -- Get debuff type color
        local color = DebuffTypeColor[ "none" ];
        if( debuffType ) then
            color = DebuffTypeColor[ debuffType ];
        end

        -- Get the border
        local border = _G[ buttonName .. "Border" ];

        -- Set its size and color
        border:SetAllPoints( );
        border:SetVertexColor(color.r, color.g, color.b);
    end

    return button;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_GetAuraSize
--
--  Description:    Get the size of an aura button
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetAuraSize( self )

    return self:GetHeight( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraButton_OnMouseDown
--
--  Description:    Called when the mouse button goes down in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraButton_OnMouseDown( self, button )

    if( not StatusBars2_Settings.locked ) then
        StatusBars2_StatusBar_OnMouseDown( self.parentBar, button );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraButton_OnMouseUp
--
--  Description:    Called when the mouse goes up in this frame
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraButton_OnMouseUp( self, button )

    if( not StatusBars2_Settings.locked ) then
        StatusBars2_StatusBar_OnMouseUp( self.parentBar, button );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraButton_OnEnter
--
--  Description:    Override for button template's OnEnter
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraButton_OnEnter( self )

    if( StatusBars2_Settings.bars[ self.parentBar.key ].enableTooltips ) then
        self.DefaultOnEnter( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_AuraButton_OnLeave
--
--  Description:    Override for button template's OnLeave
--
-------------------------------------------------------------------------------
--
function StatusBars2_AuraButton_OnLeave( self )

    if( StatusBars2_Settings.bars[ self.parentBar.key ].enableTooltips ) then
        self.DefaultOnLeave( self );
    end

end
