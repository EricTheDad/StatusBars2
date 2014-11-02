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

-- Number of runes
local kMaxRunes = 6;


-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateRuneBar
--
--  Description:    Create a rune bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_CreateRuneBar( group, index, removeWhenHidden )

    -- Create the bar
    local bar = StatusBars2_CreateBar( group, index, removeWhenHidden, "rune", "StatusBars2_RuneFrameTemplate", "player", RUNES, kRune );
    local name = bar:GetName( );

    -- Create the rune table
    bar.runes = {};

    -- Initialize the rune buttons
    local i;
    for i = 1, 6 do
        local rune = _G[ name .. '_RuneButton' .. i ];
        rune.parentBar = bar;
        rune:SetScript( "OnMouseDown", StatusBars2_ChildButton_OnMouseDown );
        rune:SetScript( "OnMouseUp", StatusBars2_ChildButton_OnMouseUp );
        rune:SetScript( "OnHide", StatusBars2_RuneButton_OnHide );
        RuneButton_Update( rune, i, true );
    end

    -- Set the event handlers
    bar.OnEvent = StatusBars2_RuneBar_OnEvent;
    bar.OnEnable = StatusBars2_RuneBar_OnEnable;
    bar.IsDefault = StatusBars2_RuneBar_IsDefault;

    -- Events to register for on enable
    bar.eventsToRegister["RUNE_POWER_UPDATE"] = true;
    bar.eventsToRegister["RUNE_TYPE_UPDATE"] = true;
    bar.eventsToRegister["PLAYER_REGEN_ENABLED"] = true;
    bar.eventsToRegister["PLAYER_REGEN_DISABLED"] = true;
    bar.eventsToRegister["PLAYER_ENTERING_WORLD"] = true;

    return bar;

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_OnEvent
--
--  Description:    Rune bar event handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_RuneBar_OnEvent( self, event, ... )

    -- Entering combat
    if( event == "PLAYER_REGEN_DISABLED" ) then
        self.inCombat = true;

    -- Leaving combat
    elseif( event == "PLAYER_REGEN_ENABLED" ) then
        self.inCombat = false;

    -- Player entering world
    elseif( event == "PLAYER_ENTERING_WORLD" ) then
        StatusBars2_RuneBar_UpdateAllRunes( self );

    -- Rune power update
    elseif( event == "RUNE_POWER_UPDATE" ) then
        local runeIndex, isEnergize = ...;
        if runeIndex and runeIndex >= 1 and runeIndex <= kMaxRunes then
            local runeButton = _G[ self:GetName( ) .. '_RuneButton' .. runeIndex ];
            local cooldown = _G[runeButton:GetName().."Cooldown"];

            local start, duration, runeReady = GetRuneCooldown(runeIndex);

            if not runeReady  then
                if start then
                    CooldownFrame_SetTimer(cooldown, start, duration, 1);
                end
                runeButton.energize:Stop();
            else
                cooldown:Hide();
                runeButton.shine:SetVertexColor(1, 1, 1);
                RuneButton_ShineFadeIn(runeButton.shine)
            end

            if isEnergize  then
                runeButton.energize:Play();
            end
        else
            assert(false, "Bad rune index")
        end

    -- Rune type update
    elseif ( event == "RUNE_TYPE_UPDATE" ) then
        local runeIndex = ...;
        if ( runeIndex and runeIndex >= 1 and runeIndex <= kMaxRunes ) then
            RuneButton_Update(_G[ self:GetName( ) .. '_RuneButton' .. runeIndex ], runeIndex);
        end
    end

    -- Update the bar visibility
    if( self:BarIsVisible( ) ) then
        StatusBars2_ShowBar( self );
    else
        StatusBars2_HideBar( self );
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_OnEnable
--
--  Description:    Rune bar enable handler
--
-------------------------------------------------------------------------------
--
function StatusBars2_RuneBar_OnEnable( self )

    -- Enable or disable moving
    local i;
    for i = 1, 6 do

        -- Get the rune button
        local rune = _G[ self:GetName( ) .. '_RuneButton' .. i ];

        -- If not grouped or locked enable the mouse for moving
        if( not StatusBars2.locked ) then
            rune:EnableMouse( true );
        else
            rune:EnableMouse( false );
        end
    end

    -- Update the runes
    StatusBars2_RuneBar_UpdateAllRunes( self );

    -- Call the base method
    self:BaseBar_OnEnable( );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_UpdateAllRunes
--
--  Description:    Update all runes
--
-------------------------------------------------------------------------------
--
function StatusBars2_RuneBar_UpdateAllRunes( self )

    for i=1,kMaxRunes do
        local runeButton = _G[ self:GetName( ) .. '_RuneButton' .. i ];
        if runeButton then
            RuneButton_Update( runeButton, i, true );
        end
    end

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneButton_OnHide
--
--  Description:    Called when the frame is hidden
--
-------------------------------------------------------------------------------
--
function StatusBars2_RuneButton_OnHide( self )

    local OnHideScript = self.parentBar:GetScript( "OnHide" );
    OnHideScript( self.parentBar );

end

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_RuneBar_IsDefault
--
--  Description:    Determine if a rune bar is at its default state
--a
-------------------------------------------------------------------------------
--
function StatusBars2_RuneBar_IsDefault( self )

    local isDefault = true;

    -- Look for a rune that is not ready
    local i;
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown( i );
        if( not runeReady ) then
            isDefault = false;
            break;
        end
    end

    return isDefault;

end
